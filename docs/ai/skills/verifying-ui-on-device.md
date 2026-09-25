---
name: verifying-ui-on-device
description: >
  How to run PokeFinder on the Android emulator, drive it with adb and check a UI change with
  screenshots (layout, alignment, contrast, dark mode, Italian strings). Use after any change to
  a widget, page or theme, for a visual review, or when asked to run, screenshot or try the app.
  Trigger on "run the app", "check it on the emulator", "take a screenshot", "does it look right",
  "lancia l'app", "provalo sull'emulatore", "fai uno screenshot", "controlla la grafica".
---

# Verifying UI on the device

## 1. Pick the flavor

| Flavor | Data | Use it for |
|---|---|---|
| `--flavor dev` | `MockPokemonRepository`, offline, fixed data | layout checks, fast and deterministic |
| `--flavor prod` | live PokeAPI | real sprites, real error and timeout states |

Package ids: `com.gabriarceus.pokefinder` (prod), `com.gabriarceus.pokefinder.dev` (dev).

## 2. Launch

```bash
fvm flutter devices                          # find the emulator id, e.g. emulator-5554
fvm flutter run --flavor dev -d emulator-5554   # run it in the background, keep the log
```

- The first Gradle build takes 5-10 minutes (media_kit). Wait for `Using the Impeller rendering
  backend` in the log before you take a screenshot.
- The Dart MCP `launch_app` tool cannot pass `--flavor`. Use the shell command above.
- Sandboxed shells: `adb` needs the local port 5037 and fvm writes to its SDK cache. Both fail
  with "Operation not permitted" inside the sandbox; run them outside it.

## 3. Drive the app with adb

`adb` is in `$ANDROID_HOME/platform-tools/` (on macOS usually `~/Library/Android/sdk/platform-tools/`).

```bash
adb exec-out screencap -p > shot.png && sips -Z 900 shot.png   # screenshot, scaled for reading
adb shell wm size                          # physical size, e.g. 1440x3120
adb shell input tap X Y                    # physical pixels
adb shell input text "pika"                # type into the focused field
adb shell input swipe 720 2800 720 1300 400   # scroll down
adb shell input keyevent 4                 # system back
adb shell am start -a android.intent.action.VIEW \
  -d "pokefinder:///pokemon/gengar" com.gabriarceus.pokefinder   # deep link
```

After you scale a screenshot to 900 px height, multiply its coordinates by
`physical height / 900` before `input tap` (3.4667 on a Pixel 7 Pro).

Theme and language: Settings (drawer → Impostazioni) → Theme "Scuro" / language switch. The app
keeps them across restarts. Put them back when you finish.

## 4. What to check on each changed screen

- Light **and** dark theme.
- Alignment: elements in one column share left and right edges. Chips do not jump rows when
  selected.
- Contrast: icons and text on type-colored backgrounds (try Pikachu for light yellow, Gengar or
  Umbreon for dark). Disabled buttons stay readable.
- Loading, empty and error states. Use `prod` with a bad name, or wait for a timeout, to see the
  error page.
- Italian strings: no raw slugs, no English left-overs, no half-translated names.
- Going back: after returning to Home, the keyboard and the suggestion list stay closed.
- The content you changed is visible without scrolling a tiny area.

## 5. Report

List what you checked, with the flavor and theme used. Say clearly what you did not check.
