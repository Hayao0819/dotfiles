#!/usr/bin/env python3
"""Deterministic ADB driver for LLM-led Android automation.

The point of this tool is that the model never guesses pixel coordinates.
`dump` reads the UI hierarchy and lists interactable elements; `tap` resolves
an element (by index / resource-id / text / content-desc) to the centre of its
`bounds` and taps there. Bounds, screencap and `input tap` all share the same
logical-pixel coordinate space, so taps land where the element actually is.

Pixel coordinates (`tap --xy`) are a fallback for screens with no usable
accessibility tree (Canvas/games/FLAG_SECURE/Flutter without semantics).
"""

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

# Cache of the last `dump` per device, so `tap --index N` refers to exactly the
# list the model just saw rather than a freshly-renumbered one.
STATE_DIR = os.path.join(tempfile.gettempdir(), "android_ctl")

# Friendly key names -> Android keycodes (`adb shell input keyevent`).
KEYCODES = {
    "home": 3,
    "back": 4,
    "menu": 82,
    "dpad_up": 19,
    "dpad_down": 20,
    "dpad_left": 21,
    "dpad_right": 22,
    "enter": 66,
    "del": 67,
    "backspace": 67,
    "tab": 61,
    "space": 62,
    "escape": 111,
    "app_switch": 187,
    "recents": 187,
    "wakeup": 224,
    "sleep": 223,
    "power": 26,
    "volume_up": 24,
    "volume_down": 25,
}


def adb(serial, args, capture=True, binary=False):
    """Run an adb command, optionally targeting a specific device serial."""
    cmd = ["adb"]
    if serial:
        cmd += ["-s", serial]
    cmd += args
    if binary:
        return subprocess.run(cmd, capture_output=True, check=False)
    res = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if res.returncode != 0 and capture:
        msg = res.stderr.strip() or res.stdout.strip() or "unknown error"
        sys.exit(f"adb {' '.join(args)} failed: {msg}")
    return res.stdout


def list_devices():
    out = subprocess.run(
        ["adb", "devices"], capture_output=True, text=True, check=False
    ).stdout
    devices = []
    for line in out.splitlines()[1:]:
        line = line.strip()
        if line and "\t" in line:
            serial, state = line.split("\t", 1)
            devices.append((serial, state))
    return devices


def resolve_serial(requested):
    """Pick the target device. Honour -s / ANDROID_SERIAL, else require one."""
    if requested:
        return requested
    env = os.environ.get("ANDROID_SERIAL")
    if env:
        return env
    online = [s for s, state in list_devices() if state == "device"]
    if len(online) == 1:
        return online[0]
    if not online:
        sys.exit("No device connected. Run `adb devices` and start an emulator "
                 "or plug in a device with USB debugging enabled.")
    sys.exit("Multiple devices connected; pass --serial <serial>:\n  "
             + "\n  ".join(online))


def state_path(serial):
    os.makedirs(STATE_DIR, exist_ok=True)
    safe = re.sub(r"[^A-Za-z0-9._-]", "_", serial or "default")
    return os.path.join(STATE_DIR, f"{safe}.json")


def parse_bounds(bounds):
    """'[x1,y1][x2,y2]' -> (x1, y1, x2, y2)."""
    m = re.match(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", bounds or "")
    if not m:
        return None
    return tuple(int(v) for v in m.groups())


def center(bounds):
    b = parse_bounds(bounds)
    if not b:
        return None
    return ((b[0] + b[2]) // 2, (b[1] + b[3]) // 2)


def short_class(cls):
    return cls.rsplit(".", 1)[-1] if cls else ""


# --- commands --------------------------------------------------------------


def cmd_devices(_args):
    devices = list_devices()
    if not devices:
        print("No devices.")
        return
    for serial, state in devices:
        print(f"{serial}\t{state}")


def cmd_info(args):
    serial = resolve_serial(args.serial)
    size = adb(serial, ["shell", "wm", "size"]).strip()
    density = adb(serial, ["shell", "wm", "density"]).strip()
    print(f"serial:  {serial}")
    print(size)
    print(density)


def cmd_shot(args):
    serial = resolve_serial(args.serial)
    out = args.out or "screen.png"
    res = adb(serial, ["exec-out", "screencap", "-p"], binary=True)
    if res.returncode != 0:
        sys.exit(f"screencap failed: {res.stderr.decode(errors='replace').strip()}")
    # adb on Windows hosts can mangle \n; on Linux exec-out is byte-clean.
    with open(out, "wb") as f:
        f.write(res.stdout)
    print(f"Saved {out}. Use this only to understand the screen; tap via `dump`"
          " + `tap`, not by reading pixels off this image.")


def collect_nodes(elem, acc):
    for node in elem.iter("node"):
        attrs = node.attrib
        interactable = (
            attrs.get("clickable") == "true"
            or attrs.get("long-clickable") == "true"
            or attrs.get("checkable") == "true"
            or attrs.get("scrollable") == "true"
            or attrs.get("focusable") == "true"
            and (attrs.get("text") or attrs.get("content-desc"))
        )
        c = center(attrs.get("bounds", ""))
        if c is None:
            continue
        acc.append({
            "role": short_class(attrs.get("class", "")),
            "text": attrs.get("text", ""),
            "id": attrs.get("resource-id", ""),
            "desc": attrs.get("content-desc", ""),
            "bounds": attrs.get("bounds", ""),
            "center": list(c),
            "clickable": attrs.get("clickable") == "true",
            "scrollable": attrs.get("scrollable") == "true",
            "interactable": bool(interactable),
        })


def cmd_dump(args):
    serial = resolve_serial(args.serial)
    # `/dev/tty` streams the XML straight back; some shells append a banner line.
    raw = adb(serial, ["exec-out", "uiautomator", "dump", "/dev/tty"])
    start = raw.find("<?xml")
    if start == -1:
        start = raw.find("<hierarchy")
    end = raw.rfind("</hierarchy>")
    if start == -1 or end == -1:
        sys.exit("uiautomator dump returned no UI tree. The screen may block it "
                 "(FLAG_SECURE / Canvas / Flutter without semantics). Fall back "
                 "to `shot` + `tap --xy` for this screen.")
    xml = raw[start:end + len("</hierarchy>")]
    try:
        root = ET.fromstring(xml)
    except ET.ParseError as e:
        sys.exit(f"failed to parse UI XML: {e}")

    nodes = []
    collect_nodes(root, nodes)
    shown = nodes if args.all else [n for n in nodes if n["interactable"]]

    # Persist so `tap --index` maps to this exact listing.
    with open(state_path(serial), "w") as f:
        json.dump(shown, f)

    if args.json:
        print(json.dumps(shown, ensure_ascii=False, indent=2))
        return

    if not shown:
        print("No interactable elements found. Try `dump --all`, or `shot` "
              "+ `tap --xy` if this screen has no accessibility tree.")
        return
    for i, n in enumerate(shown):
        label = n["text"] or n["desc"] or "—"
        rid = n["id"].split("/")[-1] if n["id"] else ""
        extra = []
        if rid:
            extra.append(f"id={rid}")
        if n["scrollable"]:
            extra.append("scrollable")
        tail = ("  " + " ".join(extra)) if extra else ""
        print(f"[{i}] {n['role']}  \"{label}\"  @{tuple(n['center'])}{tail}")


def load_state(serial):
    path = state_path(serial)
    if not os.path.exists(path):
        sys.exit("No cached dump. Run `dump` first so element indices are known.")
    with open(path) as f:
        return json.load(f)


def find_node(nodes, args):
    if args.index is not None:
        if not 0 <= args.index < len(nodes):
            sys.exit(f"index {args.index} out of range (0..{len(nodes) - 1}).")
        return nodes[args.index]
    matches = []
    for n in nodes:
        if args.id and not n["id"].endswith(args.id) and n["id"] != args.id:
            continue
        if args.text and args.text not in n["text"]:
            continue
        if args.desc and args.desc not in n["desc"]:
            continue
        matches.append(n)
    if not matches:
        sys.exit("No element matched. Re-run `dump` and check the listing.")
    if len(matches) > 1:
        opts = "; ".join(
            f"{n['text'] or n['desc'] or n['id']}@{tuple(n['center'])}"
            for n in matches[:6]
        )
        sys.exit(f"{len(matches)} elements matched, be more specific: {opts}")
    return matches[0]


def cmd_tap(args):
    serial = resolve_serial(args.serial)
    if args.xy:
        x, y = args.xy
        if args.scale and args.scale != 1.0:
            x = round(x / args.scale)
            y = round(y / args.scale)
        adb(serial, ["shell", "input", "tap", str(x), str(y)])
        print(f"Tapped ({x}, {y}).")
        return
    if args.index is None and not (args.id or args.text or args.desc):
        sys.exit("Specify one of --index / --id / --text / --desc / --xy.")
    nodes = load_state(serial)
    node = find_node(nodes, args)
    x, y = node["center"]
    adb(serial, ["shell", "input", "tap", str(x), str(y)])
    label = node["text"] or node["desc"] or node["id"] or node["role"]
    print(f"Tapped \"{label}\" at ({x}, {y}).")


def cmd_text(args):
    serial = resolve_serial(args.serial)
    s = args.string
    if not s.isascii():
        sys.exit("`input text` cannot send non-ASCII (Japanese/emoji). Use an "
                 "adb IME such as ADBKeyBoard — see reference/adb-recipes.md.")
    # `input text` treats spaces as argument separators; %s is the documented
    # escape, and shell-special chars must be guarded.
    escaped = s.replace(" ", "%s")
    for ch in "()<>|;&*\\\"'`$#":
        escaped = escaped.replace(ch, "\\" + ch)
    adb(serial, ["shell", "input", "text", escaped])
    print(f"Typed: {s}")


def cmd_key(args):
    serial = resolve_serial(args.serial)
    name = args.key.lower()
    code = KEYCODES.get(name)
    if code is None:
        if name.isdigit():
            code = int(name)
        else:
            sys.exit(f"Unknown key '{args.key}'. Known: "
                     + ", ".join(sorted(KEYCODES)) + ", or a numeric keycode.")
    adb(serial, ["shell", "input", "keyevent", str(code)])
    print(f"Sent key {args.key} ({code}).")


def cmd_swipe(args):
    serial = resolve_serial(args.serial)
    dur = str(args.dur)
    if args.coords:
        x1, y1, x2, y2 = args.coords
    else:
        size = adb(serial, ["shell", "wm", "size"])
        m = re.search(r"(\d+)x(\d+)", size)
        if not m:
            sys.exit("Could not read screen size for directional swipe.")
        w, h = int(m.group(1)), int(m.group(2))
        cx, cy = w // 2, h // 2
        # Swiping content up scrolls the page down, and vice versa.
        far, near = int(h * 0.75), int(h * 0.25)
        directions = {
            "up": (cx, far, cx, near),
            "down": (cx, near, cx, far),
            "left": (int(w * 0.75), cy, int(w * 0.25), cy),
            "right": (int(w * 0.25), cy, int(w * 0.75), cy),
        }
        if args.direction not in directions:
            sys.exit("Pass a direction (up/down/left/right) or four coordinates.")
        x1, y1, x2, y2 = directions[args.direction]
    adb(serial, ["shell", "input", "swipe",
                 str(x1), str(y1), str(x2), str(y2), dur])
    print(f"Swiped ({x1},{y1}) -> ({x2},{y2}) over {dur}ms.")


def build_parser():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("-s", "--serial", help="target device serial (else single "
                   "device / $ANDROID_SERIAL)")
    sub = p.add_subparsers(dest="cmd", required=True)

    sub.add_parser("devices", help="list adb devices").set_defaults(func=cmd_devices)
    sub.add_parser("info", help="device serial, screen size, density").set_defaults(
        func=cmd_info)

    sp = sub.add_parser("shot", help="save a screenshot for visual context")
    sp.add_argument("--out", help="output path (default screen.png)")
    sp.set_defaults(func=cmd_shot)

    sp = sub.add_parser("dump", help="list interactable UI elements with centres")
    sp.add_argument("--all", action="store_true", help="include non-interactable nodes")
    sp.add_argument("--json", action="store_true", help="emit raw JSON")
    sp.set_defaults(func=cmd_dump)

    sp = sub.add_parser("tap", help="tap an element (by index/id/text/desc) or xy")
    sp.add_argument("--index", type=int, help="index from the last `dump`")
    sp.add_argument("--id", help="resource-id (suffix match allowed)")
    sp.add_argument("--text", help="visible text (substring match)")
    sp.add_argument("--desc", help="content-desc (substring match)")
    sp.add_argument("--xy", type=int, nargs=2, metavar=("X", "Y"),
                    help="raw coordinates (fallback only)")
    sp.add_argument("--scale", type=float, default=1.0,
                    help="divide --xy by this (undo a screenshot downscale)")
    sp.set_defaults(func=cmd_tap)

    sp = sub.add_parser("text", help="type ASCII text into the focused field")
    sp.add_argument("string")
    sp.set_defaults(func=cmd_text)

    sp = sub.add_parser("key", help="send a key (back/home/enter/... or keycode)")
    sp.add_argument("key")
    sp.set_defaults(func=cmd_key)

    sp = sub.add_parser("swipe", help="scroll by direction or explicit coordinates")
    sp.add_argument("direction", nargs="?", choices=["up", "down", "left", "right"])
    sp.add_argument("--coords", type=int, nargs=4,
                    metavar=("X1", "Y1", "X2", "Y2"))
    sp.add_argument("--dur", type=int, default=400,
                    help="duration ms (longer = less inertia, default 400)")
    sp.set_defaults(func=cmd_swipe)

    return p


def main():
    args = build_parser().parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
