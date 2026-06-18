# adb recipes and edge cases

Detail for android-control. The main loop lives in SKILL.md; this file holds the
fallback paths and the things that bite you in practice.

## Contents

- Why pixel taps drift, and how to correct them
- Pixel-tap fallback with `tap --xy` / `--scale`
- Keycode table
- Non-ASCII text input (ADBKeyBoard)
- Swipe / scroll tuning
- Device & connection troubleshooting
- When `dump` returns nothing

## Why pixel taps drift, and how to correct them

`adb exec-out screencap -p` captures the screen at its full logical resolution
(the value `wm size` reports, e.g. `1080x2400`). `adb shell input tap x y` uses
that *same* coordinate space. So a tap computed from an unmodified screenshot is
exact — there is no drift at this layer.

Drift comes from one place: the screenshot handed to the model gets downscaled
(the API caps images at a long edge / megapixel budget). The model reasons over
the smaller image and returns coordinates in *that* space, but the device taps
in the original space. The tap lands short by the downscale ratio.

Two ways out:

1. **Don't tap by pixels at all** — the whole `dump` → `tap --id/--text/--index`
   path. Element bounds are already in device coordinates, so the model only
   picks *which* element; the tool computes the centre. This is the default and
   it sidesteps the problem entirely.

2. **Correct the scale** when you must tap a pixel (fallback below).

Note for current Claude models: Opus 4.8 / 4.7 map coordinates 1:1 with the
image up to a 2576 px long edge, so if the screenshot's long edge is ≤ 2576 the
returned coordinates need no correction. Most phones (long edge ≤ 2400) are
already within this. Apply the scale formula only for higher-resolution panels.

## Pixel-tap fallback with `tap --xy` / `--scale`

Use only on screens where `dump` yields nothing.

```bash
# Coordinates already in device space (long edge within the 1:1 range):
python3 scripts/android_ctl.py tap --xy 540 1200

# Coordinates read off a downscaled screenshot: undo the downscale.
# scale = (downscaled long edge) / (device long edge)
# e.g. device 1440x3120 (long 3120) shown at long 1568 -> scale = 1568/3120 ≈ 0.5026
python3 scripts/android_ctl.py tap --xy 760 1340 --scale 0.5026
```

`--scale` divides the given coordinates by the factor to recover device-space
pixels. Get the device long edge from `android_ctl.py info`.

## Keycode table

`android_ctl.py key <name>` accepts these names (or any numeric keycode):

| name | code | name | code |
|------|------|------|------|
| home | 3 | back | 4 |
| menu | 82 | app_switch / recents | 187 |
| dpad_up | 19 | dpad_down | 20 |
| dpad_left | 21 | dpad_right | 22 |
| enter | 66 | del / backspace | 67 |
| tab | 61 | space | 62 |
| escape | 111 | power | 26 |
| wakeup | 224 | sleep | 223 |
| volume_up | 24 | volume_down | 25 |

`key wakeup` is handy when a USB device's screen is off and taps are being
ignored.

## Non-ASCII text input (ADBKeyBoard)

`input text` only sends ASCII. For Japanese, emoji, or other Unicode, install
[ADBKeyBoard](https://github.com/senzhk/ADBKeyBoard), make it the active IME,
then broadcast the string:

```bash
adb shell ime set com.android.adbkeyboard/.AdbIME
adb shell am broadcast -a ADB_INPUT_TEXT --es msg 'こんにちは'
adb shell ime reset    # restore the normal keyboard afterwards
```

Tap the target field first so it has focus.

## Swipe / scroll tuning

`swipe up/down/left/right` derives endpoints from `wm size` and swipes through
the screen centre. "up" pushes content up (scrolls the page down).

- Overshooting (inertial fling carries past the target): raise `--dur` to
  600–800 ms so it registers as a drag, not a flick.
- Precise drags (sliders, reordering): pass explicit endpoints:
  ```bash
  python3 scripts/android_ctl.py swipe --coords 540 1600 540 600 --dur 500
  ```

## Device & connection troubleshooting

- `adb devices` shows `unauthorized` → accept the USB-debugging prompt on the
  device. Shows nothing → check the cable / `adb kill-server && adb start-server`.
- Multiple devices → every command needs `-s <serial>`, or export
  `ANDROID_SERIAL`. The tool refuses to guess when more than one is online.
- Taps ignored on a real device → screen may be off/locked: `key wakeup`, then
  unlock. Disable the "Pointer location" developer option; its overlay adds
  noise to screenshots.
- Do **not** change `wm size` / `wm density` mid-session. Overriding them to a
  value the panel doesn't match causes dead taps and broken layouts. Set
  resolution via the AVD profile instead and leave it fixed.

## When `dump` returns nothing

`uiautomator dump` fails or returns an empty tree on `FLAG_SECURE` screens,
`Canvas`/OpenGL games, and Flutter apps that don't expose semantics. Options, in
order:

1. `dump --all` — sometimes the interactable filter is too strict; the full tree
   may still contain the element.
2. Flutter: relaunch with accessibility/semantics enabled if you control the
   build.
3. Pixel fallback — `shot`, Read the image, then `tap --xy` with the scale
   correction above. This is the only situation where guessing a coordinate is
   acceptable, and it is the least reliable path.
