---
name: verifying-ui-on-device
description: >
  Run PokeFinder on an Android emulator and verify UI changes with adb and screenshots.
  Use after widget, page or theme changes, for visual reviews, or when asked to run the app.
  Trigger on "run the app", "check it on the emulator", "take a screenshot", "does it look right",
  "lancia l'app", "provalo sull'emulatore", "fai uno screenshot", "controlla la grafica".
---

# Verifying UI on the device

## Choose data and device

| Run arguments | Data | Use |
|---|---|---|
| `--flavor dev` | Fixed mock data | Layout checks |
| `--flavor dev --dart-define=USE_MOCK=false` | Live PokeAPI | Real data in a dev build |
| `--flavor prod` | Live PokeAPI | Production flavor behavior in a debug build |

Package ids are `com.gabriarceus.pokefinder.dev` (dev) and `com.gabriarceus.pokefinder` (prod).
Follow the user's permission rules before using live APIs. Mock data does not guarantee that
remote sprite images are available offline.

Run `fvm flutter devices` and `adb devices` to identify the target. The examples below use
`emulator-5554`; replace it with the actual id. Use `adb` from PATH or the configured Android
SDK's `platform-tools` directory. Match invocation syntax to the active shell.

## Launch

```text
fvm flutter run --flavor dev -d emulator-5554
```

Keep the process available for hot reload and retain its log through the host's process tools.
The first Gradle build can take several minutes. Wait until the app has launched and the
screen has finished loading before inspecting it; report persistent loading or startup errors.
Use a launch tool only if it supports the required flavor and Dart defines.

FVM may write to the SDK cache, and adb uses its local server (normally port 5037). If host
permissions block either operation, follow that host's approval flow for the specific command.

## Screenshots and interaction

These commands work without binary output redirection or platform-specific image tools:

```text
adb -s emulator-5554 shell screencap -p /sdcard/pokefinder-ui-check.png
adb -s emulator-5554 pull /sdcard/pokefinder-ui-check.png ./pokefinder-ui-check.png
adb -s emulator-5554 shell wm size
adb -s emulator-5554 shell input tap X Y
adb -s emulator-5554 shell input text pika
adb -s emulator-5554 shell input swipe X1 Y1 X2 Y2 400
adb -s emulator-5554 shell input keyevent 4
adb -s emulator-5554 shell am start -a android.intent.action.VIEW -d "pokefinder:///pokemon/gengar" com.gabriarceus.pokefinder.dev
```

Use the package matching the installed flavor for deep links. Inspect the screenshot with
an available image viewer. Tap coordinates refer to the device image; if the viewer rescales
it, convert each axis using the original image dimension divided by the displayed dimension.
Choose coordinates from the current screenshot, not from a different device's layout.

Record the initial theme, language and any device settings you change, then restore them when
finished. App theme and language are in Settings and persist across restarts. Remove temporary
screenshots you created after inspection unless they are part of the requested deliverable.

## Visual checks

- Check light and dark themes, English and Italian.
- Check compact width, landscape and 200% text scaling when the changed layout is affected.
- Check aligned edges, stable chip layout and readable text on type colors (Electric is a
  useful light-color case). Disabled controls must remain readable.
- Exercise relevant loading, empty and error states. A live request for an unknown name
  checks not-found behavior; offline and timeout behavior need separate checks.
- Check for raw slugs, clipped labels and untranslated strings, allowing canonical Pokémon names.
- Check back navigation: the keyboard and suggestions should stay closed on return to Home.
- Check that the changed content remains accessible without scrolling inside an unusably small area.

Report the device, data mode, themes, locales and states checked. State any skipped checks and
blockers; a successful build alone does not verify the UI.
