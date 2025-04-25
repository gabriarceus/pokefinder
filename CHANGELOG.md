# Changelog

All notable changes to this project will be documented in this file, following the “Keep a Changelog” standard.

## [Unreleased]

### Added

- _(TBD)_ New features to be released.
- _(TBD)_ Improvements and enhancements.

### Changed

- _(TBD)_ Major refactors or breaking API changes.

### Fixed

- _(TBD)_ Bug fixes and minor tweaks.

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
