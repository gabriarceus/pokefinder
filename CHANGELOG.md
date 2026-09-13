# Changelog

All notable changes to this project will be documented in this file, following the “Keep a Changelog” standard.

## [Unreleased]

### Added

- Persistent Favorites management (`FavoritePokemon`, `FavoritesCubit`, `FavoriteSortOrder`) with toggle buttons in detail app bar and Pokédex cards, reactive synchronization across screens, and dedicated Favorites route `/favorites` featuring 3-way sorting (ID, Name, Date Added) and empty state illustration.
- Bounded Recently Viewed and Search History (`RecentPokemon`, `RecentHistoryCubit`) with deduplication, capacity limit eviction (20 Pokémon, 10 searches), quick-access horizontal shelf and search chips on Home, and pause/clear controls.
- Expanded User Preferences (`PreferencesCubit`, `UnitSystem`, `MeasurementFormatter`) persisted via durable storage:
  - System / Light / Dark theme mode with instantaneous reactive update across all screens.
  - Metric (m, kg) vs Imperial (ft/in, lbs) units toggle with locale-aware `intl` formatting on Pokémon detail screens.
  - Audio preferences: auto-play cry on detail open toggle and volume control integrated into `CryAudioController`.
  - Approximate storage/cache size calculation (`GetCacheSizeUseCase`, `LocalStorage.getByteSize()`) and confirmation dialog before cache purge.
- Dedicated Settings route `/settings` accessible from navigation drawer and home app bar.
- Full localization in English and Italian for all new settings, units, history controls, and empty states.
- First-class discovery and classification for alternate forms, Mega Evolutions, Primal Reversions, Regional variants (Alola, Galar, Hisui, Paldea), Gigantamax forms, and battle mode shifts (`PokemonFormCategory`, `PokemonRegionalGroup`).
- Pure domain helper `PokemonFormClassifier` enabling deterministic O(1) canonical parent species mapping, franchise debut generation resolution, and localized titles (`Mega Charizard X`, `Alolan Vulpix` / `Vulpix di Alola`) with zero additional network requests.
- Form category filter segmented control (`PokedexFormFilter`: All Forms, Canonical Only, Mega Evolutions, Regional Forms, Gigantamax) and cosmetic/costume form toggle in `PokedexFilterBottomSheet`.
- Dual generation context support matching both canonical parent species generation and form debut generation (e.g. Gen 7 matches Alolan forms).
- Interleaved browse ordering in the Pokédex grid placing alternate forms directly beneath their canonical parent species with official `#0001–#1025` numbering and form pills.
- Visual form indicator badges (`⚡ Mega`, `🌍 Regional`, `💥 G-Max`, `✨ Forms`) on base cards with full English and Italian localization and screen reader accessibility announcements.
- Natural search and autocomplete support for form categories and regional keywords (`"mega"`, `"primal"`, `"gmax"`, `"regional"`, `"alola"`, `"galar"`, `"hisui"`, `"paldea"`).
- Unit, BLoC, and widget test suites covering form classification, localized titles, dual generation bounds, interleaved sorting, form filter controls, and base card accessibility semantics.
- Browsable Pokédex discovery route `/pokedex` with responsive layouts for mobile and tablets, pull-to-refresh (`RefreshIndicator`), infinite scroll pagination, and shimmer skeleton loading states.
- Domain model `PokemonIndexEntry` capturing numeric Pokédex ID, name, details URL, generation (Gen 1-9), and official artwork URLs.
- Mobile filtering bottom sheet (`PokedexFilterBottomSheet`) supporting multi-type intersection filtering across 18 Pokémon types, Generation 1-9 selection, and 4-way sorting (ID / Name ascending & descending).
- Instant "Random Pokémon" action picking uniformly from the current filtered catalog and navigating directly to its detail view.
- `PokedexBloc` managing catalog discovery, pagination state, filter application, type ID mapping cache, and random Pokémon selection.
- Domain filter and sort helper `PokemonIndexFilterHelper` and `PokedexSortOrder` providing pure, deterministic discovery routines.
- Unified autocomplete in `PokeTextField` consuming structured `PokemonIndexEntry` items for prefix, contains, and numeric ID matching.
- Discovery entry points added to `HomeAppBar`, `HomeDrawer`, and `HomePage`.
- Full localization in English and Italian for all Pokédex discovery, filter, and sorting labels.
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
- Pure domain `ClearCacheUseCase` decoupling `HomeBloc` from direct repository layer caching details.
- In-flight network request deduplication service (`RequestDeduplicator`) with transparent retry recovery when an in-flight caller cancels.
- In-memory LRU access tracking in `HiveLocalStorage` delivering O(1) eviction without deserializing payload envelopes and eliminating redundant disk writes on cache hits.
- Cache envelope schema versioning (`kCurrentCacheSchemaVersion`) and deterministic `Clock` injection across caching layers.
- Cooperative request cancellation lifecycle via `CancellationToken` in domain use cases, repository methods, and data sources.
- Domain `RequestCancelledFailure` variant with exhaustive handling across presentation and domain layers.
- Resilient PokeAPI DTO mapping: stat mapping by explicit API name independent of array ordering, and fallback sprite hierarchy (`official-artwork` -> `front_default` -> `front_shiny` -> `back_default`).
- Empty collection validation returning `InvalidResponseFailure` when `types` collections are empty in `getPokemon` and `getFormDetails`.
- Stale data indicator (`Icons.cloud_off_rounded`) and tooltip in `DetailAppBar` when serving expired cache records.
- GitHub Actions CI workflow (`.github/workflows/ci.yml`) enforcing pinned FVM Flutter setup, dependency hygiene, formatting, static analysis (`--fatal-infos`), code generation consistency via untracked porcelain status checks, line coverage threshold verification, and an Android release APK build (`--flavor dev --release`) targeting Java 21.
- Pure domain autocomplete filter helper `filterIndexSuggestions` matching index entries by name substring, numeric ID, and formatted ID.
- Automated test suites covering remote data source Pokédex index URL parsing and type ID mapping, repository index delegation, and `PokemonCard` accessibility semantics.
- End-to-end integration test suite (`test/integration/critical_journeys_test.dart`) covering all 8 critical user journeys from ROADMAP §5.4: valid search to detail navigation, not found recovery and retry, offline cached Pokémon inspection, direct `/pokemon/:nameOrId` deep links, form selection and rollback, move detail inspection and retry, language persistence across app restarts, and cache clearing.
- Unit and BLoC test suite expansion covering `HomeBloc` (normalization, suggestions, error states), `PokemonBloc` (loading, stale cached data, retry, form toggles), `MoveDetailCubit` (error handling and retry), `LearnMethod` domain mapping, `LoggingInterceptor`, and version colors.

### Changed

- Removed redundant catalog re-enrichment pass in `PokedexBloc._onFetchIndex`, relying directly on the repository's enriched domain entities.
- Equipped `PokemonCard` form badge containers with `Flexible` and text ellipsis to prevent horizontal overflow in compact layouts and dynamic typography.
- Consolidated autocomplete suggestions in `PokeTextField` around structured `PokemonIndexEntry` items, removing the redundant `allNames` parameter.
- Moved search text controller synchronization out of `PokedexBrowsePage` builder into `_onBlocListener` to avoid mutating external state during widget builds.
- Equipped `PokedexLoadMoreEvent` with `droppable()` concurrency transformer to eliminate premature multi-page loading during inertial fling gestures.
- Added debounce transformer (250ms) for search query changes in `PokedexBloc`, while immediately processing empty query resets.
- Replaced `/detail` route and unsafe extra payload cast with GoRouter configuration in `app_router.dart`.
- Preserved search query and focus state when popping back from detail to home.
- Consolidated autocomplete suggestion filtering into `PokeTextField`'s default builder, removing redundant imperative queries from `HomeBloc`.
- Wrapped submitting state mutation in `setState` within `HomePage` listener to ensure deterministic widget tree rebuilds.
- Decoupled `HomeBloc` from `DataRepository` by introducing and injecting `ClearCacheUseCase`.
- Allowed `TypeError` and `FormatException` to propagate through `DioApiClient.get` rather than flattening them into generic network errors.
- Prevented `DataRepository._cacheFirst` and `DataRepository._networkFirst` from returning stale cached data when a request is intentionally cancelled.
- Preserved valid disk envelopes on generic type argument mismatch in `HiveLocalStorage.readEntry` by returning `null` without deleting data.
- Applied the Dart tall-style formatter across `lib`, `test` and `scripts`.
- Aligned `README.md` and `CLAUDE.md` with the current codebase.
- Upgraded dependencies within their existing constraints.
- Relocated tooling dependencies (`path`, `yaml`) from runtime dependencies to `dev_dependencies`.
- Replaced `bc` dependency in `scripts/coverage.sh` with pure `awk` floating-point comparison for cross-platform portability.
- Restricted CI workflow `cancel-in-progress` concurrency to pull requests and non-`main` branches to preserve build verification history on `main`.
- Extracted shared confirmation dialog helper (`showConfirmationDialog`, `showClearCacheConfirmationDialog`) to eliminate duplicate cache purge dialogs in `SettingsPage` and `HomeDrawer`.
- Flattened canonical router hierarchy in `createAppRouter()` by removing redundant nested `ShellRoute` and its duplicate `MultiBlocProvider`.
- Capitalized recent history items using pure domain `capitalize()` extension rather than ad-hoc string slicing.

### Fixed

- Prevented unverified or failed searches from polluting recent search history by deferring search query persistence until successful Pokémon resolution on detail view (`PokemonBlocSuccess`).
- Exposed favorite toggle button semantics to screen readers on `PokemonCard` by decoupling its accessibility node from the card body's `excludeSemantics` boundary.
- Expanded touch target dimensions to WCAG 2.5.5 / Material Design 48×48 dp minimum on `PokemonCard` favorite toggle and recent history card close buttons.
- Corrected misleading "About" section header on `SettingsPage` to "Language" with localized keys in English and Italian.
- Prevented false-positive autocomplete and search matches across all canonical species when queries match substrings of the internal `'canonical'` category name (e.g. `"ca"`, `"on"`, `"an"`).
- Corrected elemental type filtering for alternate forms by checking form IDs directly rather than falling back to parent species types.
- Fixed `PokemonFormClassifier.classifyCategory` returning `battleMode` for canonical species when called without an explicit `id` parameter.
- Localized hardcoded English badge text on base cards for Italian locale (`🌍 Regionali`, `✨ Forme`, `💥 Gigamax`).
- Restored missing screen reader accessibility announcements on base cards possessing alternate forms.
- Silent filter bypass and false-positive matches in `PokemonIndexFilterHelper` when type ID sets are missing or unresolved from the cache map.
- Unpropagated type fetch failures in `PokedexBloc._onTypeFilterToggled` by emitting `state.failure` on repository errors.
- Unhandled `StateError` on pull-to-refresh completion when navigating away or unmounting `PokedexBrowsePage` by providing an `orElse` fallback to `firstWhere`.
- Redundant screen reader announcements in `PokemonCard` by configuring `excludeSemantics: true` and embedding localized types in the parent semantics label.
- UI jank and append-only Hive storage bloat caused by full-box JSON decoding during LRU eviction and rewriting large payloads on every read.
- Concurrent request cancellation cascading failures to joining deduplicated callers in `RequestDeduplicator`.
- Cancelled requests surfacing as runtime failures or assertion errors in `PokemonBloc` by adding lifecycle guards (`token.isCancelled` and `emit.isDone`) and ignoring cancellation failures.
- Redundant screen reader announcements for stale cache indicator in `DetailAppBar` by removing the nested `Semantics` wrapper inside `Tooltip`.
- Duplicate cache cleared SnackBar queued between `HomeDrawer` and `HomePage` by removing redundant `BlocListener` from `HomeDrawer`.

### Removed

- Ineffective `ensureHydratedStorage()` calls from `PreferencesCubit`, `FavoritesCubit`, and `RecentHistoryCubit` constructor bodies and `createAppRouter()`.
- Dead fallback and unreachable `try/catch` in `HomeBloc.FetchAllPokemonNamesEvent`.
- Artificial `@visibleForTesting` constructor `PokemonBloc.withCancelToken`, replacing it with standard event-driven cancellation testing.
- Unused runtime dependencies: `flutter_animate`, `gap`, `pokeball_widget`, and `flutter_gen`.

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
