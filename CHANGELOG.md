# Changelog

All notable changes to this project will be documented in this file, following the “Keep a Changelog” standard.

## [Unreleased]

### Added

- Offline type matchup calculator `/matchups` (Gen VI onward 18-type chart):
  pure-domain `TypeMatchupChart` with all 324 attack/defense multipliers,
  dual-type multiplication (4×, ¼×, immunity override), and grouped results
  (4×, 2×, ½×, ¼×, 0×) with localized type names. Select 1–2 defending types
  with 48dp targets and screen-reader announcements; empty state included.
  Entry via drawer tool and tappable detail type chips (preset with the
  Pokémon's 1–2 types, `?types=` query), EN + IT strings, no network.
- Side-by-side Pokémon comparison `/compare` (max 2, in-memory): pick entries
  from Pokédex card compare action / long-press or the detail compare action;
  dual entries render in one shared card with side-by-side headers, sprites,
  type chips, and localized metric/imperial height/weight that stay side by
  side on phone portrait, plus an aligned `[first] <stat> [second]` stat table
  driven by `buildComparisonStatRows` with leader highlighting and a shared
  total row. Single entries reuse the shared `CompactStatRow` with the detail
  screen. Each side fetches through its own detail bloc, so a failure shows
  inline retry without destroying the valid side; per-entry canonical share
  links, guarded sprite placeholders, compare-button tooltips, remove-one,
  clear-all, empty state, EN + IT strings, and Pokédex badge navigation
  included.
- Detail artwork & sprite-variant gallery (Info tab): grid of available
  variants (official artwork, front/back, shiny, female, Home) with localized
  labels (EN + IT), tap-to-preview dialog, placeholder icons on missing or
  failed images, and screen-reader variant names. Records URLs + fallback
  order only (official artwork → front default → others); image bytes stay in
  the platform cache. Raw sprite DTOs now model female variants and
  `other/home` as nullable.
- Detail share action: copies the canonical `/pokemon/:nameOrId` link for the
  displayed Pokémon/form to the clipboard (clipboard only, no new permissions);
  `pokefinder:///pokemon/:nameOrId` deep links on Android and iOS resolve to the
  canonical route with the router error fallback for invalid values.
- Italian item-name database (`lib/l10n/items_db.dart`, generated from PokeAPI)
  with `translateItem` title-case fallback, plus `translation_coverage_test`
  failing CI on raw-slug or ALL-CAPS rendering.
- `GetMoveDetailUseCase` with cancellation support, mirroring the
  species/evolution/ability flows.
- `docs/logging_policy.md` (redaction, truncation, debug vs release) and
  `docs/localization_policy.md` (canonical vs localized names, fallback rule).

- Browsable Pokédex `/pokedex`: paginated grid, pull-to-refresh, skeleton loaders, scroll/filter restore, multi-type (18) / generation (1-9) / sort (ID, Name) filters, contains + numeric-ID search, Random Pokémon.
- Detail depth: species flavor text (IT with EN fallback), genus, generation, habitat; branching evolution chain with full trigger badges and tap-to-navigate; on-demand ability sheet; unified game-version selector syncing moves, encounters, items; inline forms gallery with tap-to-switch.
- First-class alternate forms: Mega / Primal / Regional (Alola, Galar, Hisui, Paldea) / G-Max / battle-mode classification with O(1) parent mapping, interleaved ordering under parent species, form badges, localized titles (`Mega Charizard X`, `Alolan Vulpix` / `Vulpix di Alola`), keyword search (`mega`, `alola`, …), dual generation context.
- Foundation: canonical `/pokemon/:nameOrId` deep-link route with error page; durable prefs vs. disposable cache storage split; startup retry screen.
- Mobile UX: safe layouts from 320px phones to tablets, landscape and 200% text scaling; 48×48 dp targets; screen-reader semantics; keyboard Search action with inline validation.
- Personalization: Favorites `/favorites` with reactive sync and ID / Name / Date sorting; Recently Viewed (20) + Recent Searches (10) with shelf, dedup and pause/clear; System / Light / Dark theme; Metric / Imperial units; cry autoplay + volume; Settings `/settings` and About `/settings/about` (version, PokeAPI credit, trademark disclaimer, licenses).
- Quality gates: GitHub Actions CI (pinned FVM, format, `analyze --fatal-infos`, codegen check, coverage, release APK), 8 critical-journey integration tests, `verify.sh` / `coverage.sh`, release-hardening tests.
- Resilience: full `PokemonFailure` taxonomy (not found, offline, timeout, rate-limited, server, invalid response, storage, cancelled); Retry + Edit Search recovery; inline retry for encounters / forms / move sheet; cry `unavailable` state and sprite / type-chip fallbacks; request cancellation + deduplication; stale-cache indicator; stat-by-name mapping and sprite fallback chain.

### Changed

- Presentation blocs/cubits resolve exclusively through
  `lib/src/1_presentation/di/presentation_bloc_factory.dart` (single documented
  construction point); no raw `getIt` calls remain in `1_presentation/`.
- `MoveDetailCubit` goes through `GetMoveDetailUseCase` like the
  species/evolution/ability flows; the move-detail repository path accepts
  cancellation tokens end to end.
- Evolution trigger badges localize embedded item/move/type names in Italian;
  unknown learn methods and generation codes fall back to title case.
- Applied tall-style formatter; moved `path`, `yaml` to `dev_dependencies`; upgraded dependencies; replaced `com.example` IDs with production IDs; `post_build.dart` aborts on dirty worktree / failure.
- Decoupled `HomeBloc` via `ClearCacheUseCase`; consolidated URL / asset helpers into `PokeApiUrlHelper`; flavor-to-DI mapping (`dev` → mock, `prod` → live).
- Production logging redacted (queries) and truncated (payloads); measurements and stats use locale-aware `intl` formatting; Italian copy polish.

### Fixed

- Sprite gallery duplicated official artwork under "Front (default)": the
  front pixel sprite is now retained as `spriteFrontDefault` and shown as its
  own variant; preview dialog scrolls on compact landscape and large text
  scaling; gallery tiles expose a single screen-reader announcement.
- Held items rendered as ALL-CAPS raw API slugs; they now show localized names
  with title-case fallback.
- Accessibility and UI: redundant / missing screen-reader announcements, 48dp touch targets, Italian badge localization, Hive LRU bloat and jank.
- Crashes and logic: version-selector assertion on Pokémon switch, evolution trigger shadowing (item / trade / gender lost with level), form type filtering, autocomplete false positives on `canonical`, pull-to-refresh unmount crash, cancelled-request surfacing as failure.
- Store compliance: Android INTERNET-only, no cleartext traffic, flavor labels, adaptive icons; iOS plist stripped (mic, local network, arbitrary loads, background audio).

### Removed

- Unused runtime deps (`flutter_animate`, `gap`, `pokeball_widget`, `flutter_gen`); redundant `WAKE_LOCK` permission; dead test-only constructors and hydration calls.

## [1.0.0-rc1] - 2026-09-02

### Added

- Autocomplete suggestions while typing a Pokémon name.
- Detail screen with a tabbed layout: info, stats, moves, items & games.
- Encounter locations, held items and game indices.
- Hive-backed local storage, and a feature-agnostic `DataRepository` exposing `cacheFirst`, `networkFirst` and `networkOnly` fetch strategies.
- Italian translation databases for abilities, moves and locations, with a translation helper.
- Language selection from the settings drawer, and a clear-cache action.
- Mock repository, registered under its own dependency injection environment.
- Move detail sheet, and selection of alternate forms and shiny sprites.
- Pokémon cry playback, behind a `CryAudioController` domain abstraction.
- Pokémon stats with computed minimum and maximum values.
- Test suite covering domain helpers, blocs, repositories and widgets.
- Typed `json_serializable` models for the PokeAPI payloads.

### Changed

- Replaced `http` with `dio`, adding a logging interceptor for API calls.
- Replaced magic strings with enums: `StatKind`, `LearnMethod`, `PokemonType`.
- Replaced stringly-typed errors with a sealed `PokemonFailure` carried through bloc states, mapping HTTP status codes to typed failures.
- Restructured the project into numbered Clean Architecture layers.
- Split the monolithic detail page into per-tab widgets and shared components.
- Upgraded the pinned Flutter SDK and the project dependencies.

### Fixed

- Bloc not provided to the form selection bottom sheet.
- Internet permission missing in release builds.
- iOS playback of `.ogg` cries, using media_kit as the audio backend.
- Pokémon name shown when displaying alternate forms.
- Resource leaks, network and cache robustness, and search input normalization.

### Removed

- `http` dependency, superseded by `dio`.
- Unknown form entry from the API fetch.

## [0.1.0] - 2025-04-25

### Added

- Detail view for individual Pokémon.
- Initial public release of PokéFinder.
- Language switching support (English/Italian) with HydratedBloc persistence.
- Routing with GoRouter.
- Search functionality for Pokémon by name.

### Changed

- Organized dependency injection in `main.dart`.
- Refactored `language.dart` for simpler `Language` model.
- Updated UI layout for home and detail pages.

### Fixed

- Correct initialization of `WidgetsFlutterBinding` before HydratedBloc storage setup.
- Fixed navigation edge cases in `HomeBloc` listener.
- Resolved language persistence issue on app restart.
