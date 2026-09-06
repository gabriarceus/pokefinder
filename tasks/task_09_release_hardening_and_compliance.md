# Task 09: Mobile Release Hardening and App Store Readiness (Android & iOS)

- **Status:** Open
- **Roadmap Reference:** [ROADMAP.md §4.7, §9.3, §9.5, §9.6, §10](file:///C:/Users/gabri/Documents/GitHub/pokefinder/ROADMAP.md#L430-L475)
- **Target Platforms:** Android & iOS only
- **Priority:** P0 / Pre-1.0 (Mobile Release Readiness & Compliance)

---

## 1. Context & Objectives

Before releasing PokéFinder to Google Play and the Apple App Store, several platform configurations, permissions, and compliance requirements must be addressed:
- The app still uses template application identities (`com.example.pokefinder`).
- Android release builds use debug signing keys and allow cleartext HTTP traffic globally despite all PokeAPI endpoints being secure HTTPS.
- iOS `Info.plist` declares unnecessary capabilities (microphone access, local network access, background audio, arbitrary network loads) without matching features, which would trigger App Store review rejections.
- The Android manifest hardcodes `pokefinder`, bypassing flavor-specific `app_name` resources, and the dev flavor still defaults to production DI.
- Release scripting (`post_build.dart`) reports Git tag/push errors but still exits with code 0.
- Production logging outputs raw user queries and full payloads.
- There is no in-app About / Legal screen, missing required PokeAPI attribution, licenses, and Pokémon trademark disclaimers.

The goal of this task is to configure authentic bundle identifiers, eliminate unnecessary permissions on Android and iOS, configure secure signing, refine Italian localization, and introduce an in-app About & Attribution screen.

---

## 2. Impacted Files & Architecture Layers

- **Android Configuration:**
  - `android/app/build.gradle` (namespace, applicationId, signingConfigs, flavors)
  - `android/app/src/main/AndroidManifest.xml` (remove `usesCleartextTraffic`, clean permissions)
  - `android/app/src/main/res/` (adaptive icons, launcher drawables)
- **iOS Configuration:**
  - `ios/Runner.xcodeproj/project.pbxproj` (Bundle Identifier, code signing)
  - `ios/Runner/Info.plist` (strip microphone, arbitrary loads, background audio)
  - `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (iOS app icon set)
- **Build Scripts & Automation:**
  - `scripts/post_build.dart`
  - `.vscode/tasks.json`
  - `lib/main.dart` / environment configuration
- **Presentation & Localization:**
  - `lib/src/4_presentation/pages/about_page.dart`
  - `lib/l10n/app_en.arb`, `lib/l10n/app_it.arb` (copy review, e.g. "Cache svuotata con successo")
- **Core / Logging:**
  - Network logging interceptor & redaction policy

---

## 3. Action Items

### 3.1 Android Store Readiness (§4.7)
- [ ] Replace `com.example.pokefinder` with an owned Android `applicationId` in `android/app/build.gradle`.
- [ ] Configure secure Android release signing via keystore properties / environment variables outside Git tracking.
- [ ] Remove `android:usesCleartextTraffic="true"` from `AndroidManifest.xml`.
- [ ] Clean Android permissions: retain strictly `android.permission.INTERNET`.
- [ ] Fix flavor app labels: link `android:label` to flavor-specific string resources (`@string/app_name`).
- [ ] Add production Android adaptive icons and splash screen drawables.

### 3.2 iOS App Store Readiness (§4.7)
- [ ] Replace `com.example.pokefinder` with an owned iOS Bundle Identifier in Xcode project configuration.
- [ ] Clean up `ios/Runner/Info.plist`:
  - Remove microphone usage description (`NSMicrophoneUsageDescription`).
  - Remove local network usage description (`NSLocalNetworkUsageDescription`).
  - Remove arbitrary network loads (`NSAppTransportSecurity / NSAllowsArbitraryLoads`).
  - Remove background audio capability (`UIBackgroundModes / audio`).
- [ ] Configure Apple code signing and provision profile placeholders.
- [ ] Add production iOS `AppIcon.appiconset` assets.

### 3.3 Flavor and Script Hardening (§4.7)
- [ ] Connect Android build flavors (`dev`, `prod`) to Injectable environment configurations (`Environment.dev`, `Environment.prod`).
- [ ] Fix VS Code `.vscode/tasks.json` task references and dependencies.
- [ ] Update `scripts/post_build.dart` to exit with a non-zero exit code if Git tagging, release prerequisites, or pushes fail.
- [ ] Block release tagging if the Git worktree is dirty.

### 3.4 Localization Polish & Number Formatting (§9.3)
- [ ] Format height, weight, and stats using `intl` locale-aware formatters instead of hardcoded strings.
- [ ] Polish Italian translation copy (e.g. fix `Cache svuota con successo` to `Cache svuotata con successo`).
- [ ] Precompute and optimize sorted translation keys.

### 3.5 Logging and Privacy Policy (§9.5)
- [ ] Ensure user-entered search queries are not logged in production release mode.
- [ ] Truncate large HTTP response payloads in network logging interceptors.

### 3.6 In-App About & Attribution Screen (§9.6, §10)
- [ ] Build an in-app "About PokéFinder" screen accessible from Settings:
  - App version and build number (`package_info_plus`).
  - Clear PokeAPI attribution statement and link.
  - Pokémon trademark and non-commercial fan-project disclaimer.
  - Open source licenses viewer (`showLicensePage`).
  - GitHub repository link and issue tracker.

---

## 4. Acceptance Criteria

- [ ] Zero instances of `com.example` remain in Android or iOS project configurations.
- [ ] Android and iOS builds declare only strictly required permissions; no microphone or background audio capabilities remain.
- [ ] Android release build compiles with secure signing configuration and no cleartext traffic.
- [ ] Release scripts abort immediately with an error if Git tagging fails or worktree is dirty.
- [ ] The app displays a dedicated About screen with accurate PokeAPI credits and copyright disclaimers.
- [ ] All mobile-applicable checklist items from [ROADMAP.md §10](file:///C:/Users/gabri/Documents/GitHub/pokefinder/ROADMAP.md#L1052-L1077) are satisfied.

---

## 5. Testing & Verification Plan

- [ ] Inspect Android manifest and iOS `Info.plist` to verify minimal permissions.
- [ ] Execute `scripts/post_build.dart` in a test environment to verify failure exit codes.
- [ ] Verify localized string formatting across both English and Italian locales.
- [ ] Build release APK / App Bundle and iOS archive locally:
  - `flutter build appbundle --flavor prod`
  - `flutter build ipa` (on macOS or CI)
