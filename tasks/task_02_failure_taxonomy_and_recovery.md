# Task 02: Failure Taxonomy, Media Error States and Recovery UX

- **Status:** Open
- **Roadmap Reference:** [ROADMAP.md §4.2, §9.1](file:///C:/Users/gabri/Documents/GitHub/pokefinder/ROADMAP.md#L220-L270), [PR 2 §12](file:///C:/Users/gabri/Documents/GitHub/pokefinder/ROADMAP.md#L1126-L1136)
- **Priority:** P0 (Release Blocker)

---

## 1. Context & Objectives

Currently, `PokemonFailure` only distinguishes `Unauthorized`, `BadRequest`, and `Unexpected`. `DioApiClient` discards `DioException.type`, and HTTP 404, network offline, timeouts, HTTP 429 rate limits, HTTP 5xx server errors, decoding failures, and storage issues are all flattened into generic unexpected failures.

Furthermore, UI components lack actionable recovery flows:
- If detail fetch fails, users often see raw errors or lack clear "Retry" and "Edit Search" actions.
- Partial failures (e.g. encounters, alternate forms, move details) can break the entire screen or fail silently.
- `CryPlaybackState` in `JustAudioCryController` lacks an `error` or `unavailable` state: if loading audio fails, calling `toggle()` still attempts to play and silently logs errors.
- Raw exception messages occasionally leak into the UI.

The objective is to establish an exhaustive failure model in domain/data layers, map them into localized, actionable failure UI states across all asynchronous views, and implement proper cry audio error handling.

---

## 2. Impacted Files & Architecture Layers

- **Core / Network:**
  - `lib/src/0_core/exceptions/api_exception.dart`
  - `lib/src/1_data/data_sources/dio_api_client.dart`
  - `lib/src/1_data/data_sources/pokemon_remote_data_source.dart`
- **Domain Failures:**
  - `lib/src/3_domain/failures/failures.dart` (`PokemonFailure` hierarchy)
- **Presentation & BLoCs:**
  - `PokemonBloc` (detail page error handling & state)
  - `DetailMovesCubit`, `MoveDetailCubit`
  - `JustAudioCryController` / `CryPlaybackState`
  - Detail screen error views, inline retry widgets, and autocomplete loading/error states
- **Localization:**
  - `lib/l10n/app_en.arb`, `lib/l10n/app_it.arb`

---

## 3. Action Items

### 3.1 Exhaustive Failure Model (§4.2)
- [ ] Preserve transport diagnostics in `ApiException` (HTTP status code, connection timeout vs receive timeout, cancellation flag, response body safely truncated).
- [ ] Expand `PokemonFailure` sealed class/union to include:
  - `PokemonNotFoundFailure` (HTTP 404)
  - `NetworkUnavailableFailure` (SocketException, offline connectivity)
  - `RequestTimeoutFailure` (Connect/receive timeout)
  - `RateLimitedFailure` (HTTP 429)
  - `ServerFailure` (HTTP 5xx)
  - `InvalidResponseFailure` (JSON schema mismatch or parsing error)
  - `StorageFailure` (Cache read/write issue)
  - `UnexpectedFailure` (Final fallback only)
- [ ] Map Dio exceptions accurately in `DioApiClient` and remote data sources without leaking raw exceptions.

### 3.2 Presentation Recovery & Retry UX (§4.2)
- [ ] **Main Detail Screen Failure:** Provide distinct UI cards with:
  - Specific localized message (e.g., "Pokémon not found", "No internet connection", "Server error").
  - Primary "Retry" action.
  - "Edit Search" action (returns to home with the previous search query restored).
- [ ] **Partial Async Sections:**
  - Encounters failure: Show localized inline failure banner with an inline "Retry" button.
  - Alternate form failure: Show inline error message within form sheet, allowing retry or safe rollback to the default form.
  - Move detail bottom sheet failure: Localized message with retry action.
  - Autocomplete index failure: Non-blocking warning state; direct search must remain operable.

### 3.3 Audio Failure and Media Fallbacks (§9.1)
- [ ] Add `error` / `unavailable` state to `CryPlaybackState`.
- [ ] Update `JustAudioCryController` so failed sound loading disables playback instead of attempting `play()`.
- [ ] Provide localized tooltip and accessibility semantics for cry states (`loading`, `playing`, `stopped`, `unavailable`, `retry`).
- [ ] Gracefully handle sprite image 404/failure with a clean placeholder icon instead of raw text `:( `.

---

## 4. Acceptance Criteria

- [ ] Searching for a non-existent name or ID displays a clear, localized "Pokémon not found" message.
- [ ] Offline mode, timeouts, rate limits, and server errors each render distinct, localized messages.
- [ ] No raw Dio, socket, or stack-trace strings are shown to the user.
- [ ] Every recoverable async section (detail, encounters, forms, move details) has a functional retry button.
- [ ] Audio loading failures transition the button to an "unavailable" or "retry" state without crashing or freezing.
- [ ] An autocomplete index fetch failure does not block manual name/ID lookup.

---

## 5. Testing & Verification Plan

- [ ] **Unit Tests:**
  - `DioApiClient` mapping for timeouts, connection errors, 404, 429, 500, and cancellations.
  - `PokemonRemoteDataSource` failure conversion to domain `PokemonFailure`.
  - `CryAudioController` lifecycle, failed sound load, and state transitions.
- [ ] **BLoC Tests:**
  - `PokemonBloc` emits proper failure states on network error, not found, and subsequent retry success.
  - `MoveDetailCubit` retry flow and state emission.
- [ ] **Widget Tests:**
  - Main detail error view renders Retry and Edit Search buttons and triggers callbacks.
  - Encounters section renders inline retry upon encounter fetch failure.
