---
name: verifying-ui-on-device
description: >
  Run PokeFinder on an Android emulator and verify UI with MCP, adb and screenshots
  from macOS, Linux or Windows.
  Use after widget, page or theme changes, for visual reviews, or when asked to run the app.
  Trigger on "run the app", "check it on the emulator", "take a screenshot", "does it look right",
  "lancia l'app", "provalo sull'emulatore", "fai uno screenshot", "controlla la grafica",
  "use MCP to control the Android emulator", "usa l'mcp per controllare l'emulatore".
---

# Verifying UI on the device

## Check MCP access first

When MCP control is requested, inspect the host's available tools before starting project
work. Tool names and capabilities can differ between hosts. A browser's device emulation
does not control a native Android app.
Use the configured native mobile server as the portable default. For setup or a missing
connection, read `docs/ai/skills/configuring-mobile-mcp.md`. Its real interaction check must
pass before starting project work; tool discovery alone is insufficient.

Choose the tool by capability:

| Tool | Purpose | Access check |
|---|---|---|
| Native mobile MCP using adb/UI Automator | Android taps, swipes, text and screenshots without app instrumentation | Discover the device, inspect its screen, perform a reversible action and verify the result |
| Dart/Flutter MCP | Widget inspection, runtime errors, hot reload and restart | Discover the device, connect to DTD and inspect the running app |
| Computer Use | Control the emulator window when supported by the host | Discover the window, inspect it and verify a reversible action |

A listed emulator proves discovery only. Importing a desktop automation library proves
neither connection to its native service nor window control. Report discovery, connection
and interaction separately. If control is blocked, state the missing capability; do not claim
that MCP interaction was verified through adb commands executed in a shell.

Use the normal app entry point for device checks. This repository does not enable Flutter
Driver. Its MCP driver commands require an app-side extension, unlike runtime inspection.
Do not add driver dependencies, extra entry points or startup hooks to satisfy a tool.
If a native mobile MCP is missing or the desktop native service is unavailable, report the
host configuration issue and use an already authorized fallback. Keep these instructions
portable: select tools from the active host, rather than requiring one operating system.

## Choose data and device

| Run arguments | Data | Use |
|---|---|---|
| `--flavor dev` | Fixed mock data | Layout checks |
| `--flavor dev --dart-define=USE_MOCK=false` | Live PokeAPI | Real data in a dev build |
| `--flavor prod` | Live PokeAPI | Production flavor behavior in a debug build |

Package ids are `com.gabriarceus.pokefinder.dev` (dev) and `com.gabriarceus.pokefinder` (prod).
Follow the user's permission rules before using live APIs. Mock data does not guarantee that
remote sprite images are available offline.

Use MCP device discovery when available; otherwise run `fvm flutter devices`.
Run `adb devices` when native Android commands are needed. The examples below use
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

## Connect Dart/Flutter MCP

For runtime inspection with mock data, run from the repository root:

```text
fvm flutter --print-dtd run --flavor dev -d emulator-5554 --no-pub
```

These arguments work on macOS, Linux and Windows. Use the host's process tools and keep
stdin open, with a PTY when required, for hot reload and restart. Resolve dependencies first
if needed; `--no-pub` skips dependency resolution during launch.
If an MCP test runner's child `dart` commands use a different SDK, compare `dart --version`
with `fvm dart --version` and use the documented FVM CLI when the tool cannot preserve that SDK.

Check the launch tool's actual schema. If it cannot accept the flavor or Dart defines, use
the CLI above and connect MCP to that process. Do not change the default flavor to fit a tool.
Add the project root to the MCP server when its tools require it, using the host's absolute
file URI. Use the DTD URI printed by that launch with `connect_dart_tooling_daemon`.
The VM Service and DevTools URLs are different endpoints. After a process restart or lost
connection, obtain the current DTD URI instead of reusing a saved port or session URI.

Use `get_widget_tree` and `get_runtime_errors` for runtime inspection. A missing Flutter
Driver extension is a limit of that interaction tool, not a failed DTD connection. Use a
native device tool for input instead. After a hot restart, wait for the app root to attach;
storage initialization may still be running when the restart tool returns.

Inspect current widgets or screenshots before choosing a target. Filter diagnostics to the
relevant properties instead of printing the full tree. Follow the active tool's parameter
units and use bounded waits. View MCP screenshots as images, without printing base64 data.
Report which checks used MCP and which used adb, including native deep-link delivery and
keyboard checks. Emulated text input alone does not verify the native soft keyboard.

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
