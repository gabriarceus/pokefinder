---
name: configuring-mobile-mcp
description: >
  Configure or troubleshoot native Android emulator control through MCP on Windows,
  macOS or Linux. Use when the mobile MCP is missing, a session cannot control the
  emulator, or the user asks for reliable setup across computers. Trigger on
  "configure Android MCP", "make emulator control work", "configura l'mcp Android",
  "fallo funzionare su Windows e macOS", "controllo dell'emulatore al primo tentativo".
---

# Configuring mobile MCP

Read `docs/ai/skills/verifying-ui-on-device.md` for tool selection and app verification.
This workflow configures the host, without adding files or dependencies to the Flutter app.
Setup is complete only after the real interaction check passes on each computer.

## Shared server choice

Use [Mobile Next](https://github.com/mobile-next/mobile-mcp), a native mobile MCP server
that supports Android emulators on Windows, macOS and Linux. Keep Dart/Flutter MCP for
runtime inspection. Prefer a local stdio connection on the computer running the emulator.
Desktop window automation is a fallback, not the portable baseline.

Install the same published package version on both computers. The current baseline is
`@mobilenext/mobile-mcp@1.0.9`, checked against the publisher's
[release list](https://github.com/mobile-next/mobile-mcp/releases/tag/1.0.9).
This version passed a direct MCP client check on Windows with Node 24 and an Android 17
emulator. macOS still needs its own first setup and interaction check.
Retain the version until an explicit upgrade is needed. Avoid `@latest`
at session startup, which can change behavior or require a download.

## Prepare each computer once

Check Node.js compatibility with the selected release, Android SDK Platform Tools, and a
booted emulator. Current upstream prerequisites specify Node.js 20 or later; use a supported
Node LTS release. Android checks do not require Xcode.

Find Node and the SDK on the active computer. Use Android Studio's configured SDK location
instead of guessing a user's home directory. The MCP process must receive the same SDK
location as the adb command used for verification.

| Host shell | Find Node | Verify the selected SDK and device |
|---|---|---|
| Windows PowerShell | `(Get-Command node).Source` | `& "<SDK>/platform-tools/adb.exe" devices -l` |
| macOS/Linux shell | `command -v node` | `"<SDK>/platform-tools/adb" devices -l` |

The selected emulator must appear with status `device`. Device ids are discovered each
session; they are not copied from another computer. If needed, boot an existing Android
Studio virtual device and wait for startup. Preserve other running devices and adb sessions.

Follow session permissions before installation or host configuration changes. In particular,
the user's API/registry permission rule applies to npm downloads. Keep the installation in
a user tool directory outside this repository:

```text
npm install --prefix "<USER_TOOL_DIRECTORY>" --save-exact @mobilenext/mobile-mcp@1.0.9
```

Resolve and verify the installed package's `bin` entry from its package metadata. The current
entry is `node_modules/@mobilenext/mobile-mcp/lib/index.js` under that tool directory.
Launch it with the absolute Node executable. This avoids Windows `.cmd` launcher differences
and GUI clients that inherit a different PATH. Complete any first-run native component setup
during this preparation, under the same permissions, rather than during an app review.

## Register the local server

Use the active client's supported registration interface. Machine-specific paths belong in
that client's local configuration, not shared project files. Keep existing servers intact.
Do not print or inspect unrelated configuration sections, credentials or environment values.

For Codex, the local CLI supports the following command. Replace each placeholder with a
verified absolute path on that computer; quote paths containing spaces:

```text
codex mcp add mobile_mcp --env "ANDROID_HOME=<SDK>" --env MOBILEMCP_DISABLE_TELEMETRY=1 -- "<NODE>" "<USER_TOOL_DIRECTORY>/node_modules/@mobilenext/mobile-mcp/lib/index.js"
```

The equivalent local configuration uses the same structure on all three operating systems:

```toml
[mcp_servers.mobile_mcp]
command = "<ABSOLUTE_NODE_EXECUTABLE>"
args = ["<ABSOLUTE_SERVER_ENTRY_POINT>"]

[mcp_servers.mobile_mcp.env]
ANDROID_HOME = "<ABSOLUTE_ANDROID_SDK_DIRECTORY>"
MOBILEMCP_DISABLE_TELEMETRY = "1"
```

Use forward slashes or correctly escaped backslashes for Windows paths in TOML.
The Node path, package path and SDK path differ between computers; the server and workflow
remain the same. Other providers need their own local MCP configuration format. Synchronizing
project skills does not register MCP servers with a client.

Refresh the client's MCP connection or open a new session after registration. Inspect the
tools actually exposed to the agent. A running server outside the client's tool catalogue
does not give the agent access. A manually started server is not the same as a registered one.
An SDK client smoke check can verify the registered server before refreshing the session;
report that result separately from tool availability in the active agent session.

## Verify access before project work

Use the exposed native mobile tools and their actual schemas. Mobile Next currently provides
`mobile_list_available_devices`, `mobile_get_foreground_app`, `mobile_take_screenshot`,
`mobile_list_elements_on_screen`, `mobile_click_on_screen_at_coordinates`, `mobile_type_keys`
and `mobile_press_button`. Host prefixes and parameters may differ; discover them first.

1. List devices through MCP and choose the online Android emulator by its returned identity.
   Mobile Next may return the virtual device name instead of adb's `emulator-5554` serial;
   use the identifier returned by that MCP tool for all following calls.
2. Read the foreground app and take a screenshot; inspect the image, not its base64 data.
3. Read screen elements and perform one reversible tap using that observation. For example,
   open the navigation drawer when Home is visible. Confirm that the expected UI appears.
4. Return to the original screen through MCP and confirm restoration. Test text entry too
   when the requested journey uses the keyboard; clear only the test text you entered.
5. Continue the app task only after these checks pass. Report any missing capability before
   editing application code. Never label shell-only adb interaction as verified MCP control.

If the app has not been installed, follow the normal flavor-specific launch workflow in the
device skill, then repeat the access check. A desktop screenshot alone does not prove input.
Tool success can precede the end of an animation. Verify the resulting screen with a fresh
observation and bounded waits before the next action, including keyboard dismissal.

| Failure | Focused check |
|---|---|
| Native mobile tools are absent | Client registration, connection refresh and startup error |
| Server cannot start | Absolute Node path, installed entry point and supported Node version |
| adb sees the emulator but MCP does not | Server's SDK location and local versus remote execution |
| Emulator is offline or still booting | Selected virtual device state; wait before interaction |
| Elements are incomplete | Use the current screenshot and coordinates, then verify the action |

After two failures of the same approach, report the evidence instead of repeating it.
Confirm setup separately for Windows and macOS; success on one does not certify the other.

Sources: [Mobile Next setup](https://github.com/mobile-next/mobile-mcp#installation-and-configuration),
[Codex MCP configuration](https://learn.chatgpt.com/docs/extend/mcp?surface=cli).
