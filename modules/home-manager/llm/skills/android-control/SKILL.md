---
name: android-control
description: >-
  Drive an Android emulator or USB-connected device reliably from the command
  line without guessing pixel coordinates. Reads the UI hierarchy
  (uiautomator) to tap elements by resource-id, text, content-desc, or index —
  bounds, screenshots, and `input tap` share one coordinate space, so taps land
  on target. Screenshots are used only to understand the screen; pixel taps are
  a documented fallback for screens with no accessibility tree. Use when
  automating, testing, or operating an Android app over adb, when a tap "lands
  in the wrong place", or when the user mentions adb, an emulator, a connected
  Android phone, uiautomator, or UI automation. Bundles a deterministic CLI
  (scripts/android_ctl.py) for shot/dump/tap/text/key/swipe.
allowed-tools: Bash, Read
---

# android-control

Reliable, repeatable Android automation over `adb`. The hard problem this skill
solves: when a model looks at a screenshot and taps the pixel it *sees*, the tap
lands in the wrong place — the screenshot the model sees is downscaled, so its
pixel coordinates do not match the device's. The fix is to **never tap by
guessed pixels**. Instead read the UI hierarchy, pick an element, and let the
tool compute the exact centre of that element's bounds. `bounds`, `screencap`,
and `input tap` all use the same logical-pixel coordinate space, so this always
hits the target.

## The one rule

Screenshots are for *understanding* the screen ("what is on screen, what should
I do next"). Taps come from `dump` (structured UI data), not from reading pixels
off a screenshot. Only drop to pixel taps when a screen genuinely has no
accessibility tree (see Fallback).

## Setup check

```bash
python3 scripts/android_ctl.py devices   # confirm a device is online
python3 scripts/android_ctl.py info      # serial, screen size, density
```

If several devices are connected, pass `-s <serial>` to every command (or set
`ANDROID_SERIAL`). A USB device needs USB debugging enabled and the host
authorised; an emulator just needs to be running.

## Core loop

1. **See** — capture a screenshot and Read it to decide the next action:
   ```bash
   python3 scripts/android_ctl.py shot --out screen.png
   ```
   Read `screen.png` to understand state. Do **not** read coordinates off it.

2. **List** — dump the interactable elements:
   ```bash
   python3 scripts/android_ctl.py dump
   ```
   Output is a numbered list: `[3] Button "Log in" @(540, 1505)  id=login_btn`.
   The `dump` is cached, so `tap --index` refers to exactly this listing.

3. **Act** — tap the element you chose. Prefer the most stable selector:
   ```bash
   python3 scripts/android_ctl.py tap --id login_btn      # most stable
   python3 scripts/android_ctl.py tap --text "Log in"     # visible text
   python3 scripts/android_ctl.py tap --desc "Search"     # icon buttons
   python3 scripts/android_ctl.py tap --index 3           # from the dump above
   ```
   Selector preference: `--id` > `--desc` > `--text` > `--index`. Resource-ids
   survive layout and language changes; text does not.

4. **Verify** — re-`shot` or re-`dump` and confirm the screen changed as
   expected before the next step. If nothing changed, the element may not have
   been tappable — re-`dump` and pick again. Give the UI a moment to settle
   between an action and the next dump.

## Typing, keys, scrolling

```bash
python3 scripts/android_ctl.py text "hello world"   # ASCII only; spaces handled
python3 scripts/android_ctl.py key enter            # back/home/enter/del/tab/...
python3 scripts/android_ctl.py swipe up             # scroll content up
python3 scripts/android_ctl.py swipe down --dur 700 # slower = less overshoot
```

Tap the target field first so it has focus, then `text`. `input text` cannot
send Japanese, emoji, or other non-ASCII — the tool refuses these and points to
the ADBKeyBoard recipe in the reference.

## Fallback: screens with no accessibility tree

Games, `Canvas`-drawn UIs, `FLAG_SECURE` screens, and Flutter without semantics
return no usable `dump`. Only then tap by pixel — and account for screenshot
downscaling. See **reference/adb-recipes.md** for the scale-correction formula,
`tap --xy`/`--scale`, the full keycode table, ADBKeyBoard for non-ASCII input,
and troubleshooting.

## Notes

- All paths use forward slashes; run commands from the skill directory or pass
  an absolute path to `android_ctl.py`.
- The tool targets one device at a time. Be explicit with `-s` whenever more
  than one device is attached so actions don't hit the wrong one.
- This skill operates a real device/emulator: confirm with the user before
  destructive in-app actions (purchases, deletions, sending messages).
