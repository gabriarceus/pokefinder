# Task 01: Mobile Bootstrap and Canonical Routing (Android & iOS)

- **Status:** Done
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
- [x] Separate storage locations using `path_provider` on Android & iOS:
  - **Durable storage:** Place `HydratedBloc` (language, preferences) in `getApplicationDocumentsDirectory()`.
  - **Disposable cache:** Place Hive API response cache in `getTemporaryDirectory()` or application support cache directory.
- [x] Catch storage initialization exceptions and render a clean, recoverable mobile startup screen with a "Retry" button rather than crashing before the first frame renders.
- [x] Explicitly declare supported platform targets as **Android and iOS**.

### 3.2 Canonical Mobile Route Contract `/pokemon/:nameOrId` (§4.3)
- [x] Replace the fragile `/detail` route with `/pokemon/:nameOrId` in router configuration.
- [x] Safely parse and validate `:nameOrId` (supporting both Pokémon names and numeric Pokédex IDs).
- [x] Create a dedicated mobile router error/not-found screen for malformed or missing route parameters.
- [x] Update all navigation callers (`HomePage`, search submission, autocomplete taps) to navigate to `/pokemon/:nameOrId`.
- [x] Preserve the entered search query and focus state when popping back from detail to home.

---

## 4. Acceptance Criteria

- [x] Mobile bootstrap cleanly initializes on both Android and iOS without unhandled storage exceptions.
- [x] User preferences (such as selected language) survive device restarts and OS temporary cache cleans.
- [x] API cache remains disposable and manually clearable via the in-app settings action.
- [x] Navigating to `/pokemon/pikachu` or `/pokemon/25` renders the corresponding Pokémon.
- [x] Invalid route parameters (e.g. `/pokemon/invalid!param`) render a graceful error screen with a button to return to the home screen.
- [x] Returning from detail to home restores previous search text and state.

---

## 5. Testing & Verification Plan

- [x] **Unit Tests:**
  - Route parameter parser tests: valid names, numeric IDs, negative/zero IDs, and invalid input strings (`test/domain/pokemon_route_param_parser_test.dart`).
  - Storage path configuration verification (`test/bootstrap/mobile_storage_initializer_test.dart`).
- [x] **Widget Tests:**
  - Startup error widget renders failure message and retry button (`test/widget/startup_error_page_test.dart`, `test/widget/bootstrap_test.dart`).
  - Route error widget renders not-found message and return home action (`test/widget/route_error_page_test.dart`).
  - Canonical route resolution, deep links, and back navigation preserving state (`test/presentation/app_router_test.dart`).
- [x] **Smoke Tests:**
  - Validated with headless test harness verifying home screen loads and direct routes resolve cleanly.

