# Task 01: Mobile Bootstrap and Canonical Routing (Android & iOS)

- **Status:** Open
- **Roadmap Reference:** [ROADMAP.md §4.1, §4.3](file:///C:/Users/gabri/Documents/GitHub/pokefinder/ROADMAP.md#L180-L302), [PR 1 §12](file:///C:/Users/gabri/Documents/GitHub/pokefinder/ROADMAP.md#L1115-L1125)
- **Target Platforms:** Android & iOS only
- **Priority:** P0 (Release Blocker)

---

## 1. Context & Objectives

The application startup (`bootstrap()` in `lib/main.dart`) currently mixes up storage responsibilities on mobile:
- Disposable API response caching is placed in `getApplicationDocumentsDirectory()`, where user-generated durable documents belong.
- Durable user state (language preferences via `HydratedBloc`) is placed in `getTemporaryDirectory()`, which is susceptible to OS-level cache clearing when storage is low.

Furthermore, navigation to Pokémon details uses `/detail` with an unsafe cast from `state.extra` (`(state.extra as Map<String, dynamic>)['pokemonName']`). This prevents deep linking, app links, universal links, and causes crashes if the extra payload is missing or invalid.

The goal of this task is to establish a robust mobile bootstrap for Android and iOS that cleanly isolates durable user preferences from disposable API cache, and implement a canonical `/pokemon/:nameOrId` route suitable for deep linking and safe internal navigation.

---

## 2. Impacted Files & Architecture Layers

- **Bootstrap / Core:**
  - `lib/main.dart` / `lib/bootstrap.dart`
  - Mobile storage initialization helper (`path_provider`)
- **Routing:**
  - `lib/src/2_application/router/app_router.dart` (GoRouter configuration)
  - Detail screen navigation call sites (`HomePage`, autocomplete widgets, etc.)
- **Presentation:**
  - Startup / initialization error fallback screen with retry
  - Router-level not-found / invalid parameter fallback screen
- **Tests:**
  - Bootstrap and storage path tests
  - Route parsing and deep-link navigation tests

---

## 3. Action Items

### 3.1 Mobile-First Storage Bootstrap (§4.1)
- [ ] Separate storage locations using `path_provider` on Android & iOS:
  - **Durable storage:** Place `HydratedBloc` (language, preferences) in `getApplicationDocumentsDirectory()`.
  - **Disposable cache:** Place Hive API response cache in `getTemporaryDirectory()` or application support cache directory.
- [ ] Catch storage initialization exceptions and render a clean, recoverable mobile startup screen with a "Retry" button rather than crashing before the first frame renders.
- [ ] Explicitly declare supported platform targets as **Android and iOS**.

### 3.2 Canonical Mobile Route Contract `/pokemon/:nameOrId` (§4.3)
- [ ] Replace the fragile `/detail` route with `/pokemon/:nameOrId` in router configuration.
- [ ] Safely parse and validate `:nameOrId` (supporting both Pokémon names and numeric Pokédex IDs).
- [ ] Create a dedicated mobile router error/not-found screen for malformed or missing route parameters.
- [ ] Update all navigation callers (`HomePage`, search submission, autocomplete taps) to navigate to `/pokemon/:nameOrId`.
- [ ] Preserve the entered search query and focus state when popping back from detail to home.

---

## 4. Acceptance Criteria

- [ ] Mobile bootstrap cleanly initializes on both Android and iOS without unhandled storage exceptions.
- [ ] User preferences (such as selected language) survive device restarts and OS temporary cache cleans.
- [ ] API cache remains disposable and manually clearable via the in-app settings action.
- [ ] Navigating to `/pokemon/pikachu` or `/pokemon/25` renders the corresponding Pokémon.
- [ ] Invalid route parameters (e.g. `/pokemon/invalid!param`) render a graceful error screen with a button to return to the home screen.
- [ ] Returning from detail to home restores previous search text and state.

---

## 5. Testing & Verification Plan

- [ ] **Unit Tests:**
  - Route parameter parser tests: valid names, numeric IDs, negative/zero IDs, and invalid input strings.
  - Storage path configuration verification.
- [ ] **Widget Tests:**
  - Startup error widget renders failure message and retry button.
  - Route error widget renders not-found message and return home action.
- [ ] **Smoke Tests:**
  - Launch smoke test on Android emulator and iOS simulator verifying home screen loads and direct route resolves.
