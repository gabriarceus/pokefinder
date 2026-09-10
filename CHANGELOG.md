# Changelog

All notable changes to this project will be documented in this file, following the “Keep a Changelog” standard.

## [Unreleased]

### Added

- Canonical mobile route `/pokemon/:nameOrId` with parameter validation and a `RouteErrorPage`.
- Recoverable mobile startup error screen (`StartupErrorApp`, `StartupErrorPage`) with retry action.
- Storage lifecycle separation: durable user state in documents storage, disposable cache in temporary directory.
- Exhaustive domain `PokemonFailure` taxonomy (`PokemonNotFoundFailure`, `NetworkUnavailableFailure`, `RequestTimeoutFailure`, `RateLimitedFailure`, `ServerFailure`, `InvalidResponseFailure`, `StorageFailure`) with full localization in English and Italian.
- Detail failure screen (`DetailFailure`) with localized descriptions, primary Retry, and Edit Search navigation restoring query state.
- In-place recovery UX for partial async views: inline retry for encounters, retry and default form rollback for alternate forms, retry action in move detail sheet, and non-blocking indicator for search autocomplete index failures.
- Media fallback and cry audio error handling in `JustAudioCryController` with `unavailable` state, playback suppression on failure, tap-to-retry, accessibility semantics/tooltips, and placeholder icon for broken sprites.
- Transport error diagnostics in `ApiException` and `DioApiClient` preserving status codes, timeout types, connection errors, cancellations, and safely truncated response payloads.
- Responsive mobile and tablet layouts supporting compact phones (320×568), standard phones (390×844), landscape orientation (844×390), and tablets (768×1024) across Home and Detail views.
- 2.0x Dynamic Type and system font scaling support with scrollable tab bars and responsive containers without visual overflow.
- Mobile accessibility semantics with explicit announcements for Pokémon headers, shiny sprites, cry audio buttons, and stats (announcing base, min, and max values).
- Interactive touch targets meeting WCAG 2.5.5 minimum 48×48 dp sizing across primary actions, buttons, and autocomplete suggestion items.
- Resilient type badge fallback (`TypeChip`) with network error recovery and graceful degradation to high-contrast localized text chips.
- Pure domain prefix suggestion helper (`filterPrefixSuggestions`) with case-insensitive and whitespace-trimmed matching.
- Keyboard search ergonomics: `TextInputAction.search`, hardware keyboard navigation, inline validation errors, and submission deduplication.
- `scripts/verify.sh`, running every quality gate (format, analysis, tests).
- `scripts/coverage.sh`, reporting total line coverage with an optional minimum.

### Changed

- Replaced `/detail` route and unsafe extra payload cast with GoRouter configuration in `app_router.dart`.
- Preserved search query and focus state when popping back from detail to home.
- Consolidated autocomplete suggestion filtering into `PokeTextField`'s default builder, removing redundant imperative queries from `HomeBloc`.
- Wrapped submitting state mutation in `setState` within `HomePage` listener to ensure deterministic widget tree rebuilds.
- Applied the Dart tall-style formatter across `lib`, `test` and `scripts`.
- Aligned `README.md` and `CLAUDE.md` with the current codebase.
- Upgraded dependencies within their existing constraints.

## [1.0.0-rc1] - 2026-09-02

### Added

- Detail screen with a tabbed layout: info, stats, moves, items & games.
- Autocomplete suggestions while typing a Pokémon name.
- Move detail sheet, and selection of alternate forms and shiny sprites.
- Pokémon cry playback, behind a `CryAudioController` domain abstraction.
- Pokémon stats with computed minimum and maximum values.
- Encounter locations, held items and game indices.
- Hive-backed local storage, and a feature-agnostic `DataRepository` exposing
  `cacheFirst`, `networkFirst` and `networkOnly` fetch strategies.
- Italian translation databases for abilities, moves and locations, with a
  translation helper.
- Language selection from the settings drawer, and a clear-cache action.
- Typed `json_serializable` models for the PokeAPI payloads.
- Mock repository, registered under its own dependency injection environment.
- Test suite covering domain helpers, blocs, repositories and widgets.

### Changed

- Restructured the project into numbered Clean Architecture layers.
- Replaced `http` with `dio`, adding a logging interceptor for API calls.
- Replaced stringly-typed errors with a sealed `PokemonFailure` carried through
  bloc states, mapping HTTP status codes to typed failures.
- Replaced magic strings with enums: `StatKind`, `LearnMethod`, `PokemonType`.
- Split the monolithic detail page into per-tab widgets and shared components.
- Upgraded the pinned Flutter SDK and the project dependencies.

### Fixed

- iOS playback of `.ogg` cries, using media_kit as the audio backend.
- Internet permission missing in release builds.
- Resource leaks, network and cache robustness, and search input normalization.
- Bloc not provided to the form selection bottom sheet.
- Pokémon name shown when displaying alternate forms.

### Removed

- `http` dependency, superseded by `dio`.
- Unknown form entry from the API fetch.

## [0.1.0] - 2025-04-25

### Added

- Initial public release of PokéFinder.
- Search functionality for Pokémon by name.
- Detail view for individual Pokémon.
- Language switching support (English/Italian) with HydratedBloc persistence.
- Routing with GoRouter.

### Changed

- Refactored `language.dart` for simpler `Language` model.
- Organized dependency injection in `main.dart`.
- Updated UI layout for home and detail pages.

### Fixed

- Correct initialization of `WidgetsFlutterBinding` before HydratedBloc storage setup.
- Resolved language persistence issue on app restart.
- Fixed navigation edge cases in `HomeBloc` listener.
