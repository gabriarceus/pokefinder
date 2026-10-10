# Changelog

All notable changes to this project will be documented in this file, following the “Keep a Changelog” standard.

## [Unreleased]

### Added

- Browsable Pokédex with search and filters; richer Pokémon details with alternate forms, evolution chains, sprite galleries and shareable deep links.
- Favorites, recent history, local teams, side-by-side comparison, an offline type matchup calculator and personalization settings.
- MIT license, contributor documentation and CI quality checks.

### Changed

- Simplified application and repository architecture, shared data models and UI components; improved caching, localization, theming and navigation.

### Fixed

- Detail-route replacement, saved cry volume, stale comparison and search results, and persistent comparison notices.
- Layout and accessibility issues, audio playback, error recovery and cache handling; improved offline behavior and recovery from corrupt stored records.
- Search and filter behavior, alternate-form loading, evolution details and localized names.

### Removed

- Redundant architecture layers, unused dependencies and unnecessary permissions.

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
