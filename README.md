# PokeFinder

> The best app to find information about Pokémon.

PokeFinder is a small Flutter app that lets you search a Pokémon by name and explore a
detail screen with its stats, abilities, moves, items, encounters, forms, and cry. Data
comes from the public [PokeAPI](https://pokeapi.co/). It is built as a learning project
around a clean, layered architecture.

## Features

- Search a Pokémon by name from the home screen
- Detail screen with tabs: info, stats, moves, items & games
- Switch the app language (English / Italian, or follow the system)
- Real or mock data source, selected at startup via dependency injection
- Offline caching of API responses

## Tools used

- **Flutter + fvm** — UI toolkit, with the SDK version pinned per project
- **flutter_bloc / hydrated_bloc** — state management, with a persisted language choice
- **get_it + injectable** — dependency injection; swaps the real and mock data sources
- **go_router** — navigation between screens
- **dio** — HTTP client for the PokeAPI
- **hive_ce** — local cache for API responses
- **dartz** — `Either`-based error handling
- **just_audio** — plays the Pokémon cry
- **gen_l10n** — translations (ARB files)

## Architecture

The code is organized in numbered layers under `lib/src/`, with dependencies pointing
inward (UI → application → domain ← repository):

```
lib/src/
├── 1_presentation/   UI: pages, widgets, theme (reacts to state, no logic)
├── 2_application/    blocs & cubits (events, states, logic)
├── 3_domain/         entities, failures, repository interfaces, use cases
└── 4_repository/     data sources, repository implementations, API models
```

## Getting started

```bash
# 1. Install the pinned Flutter SDK
fvm install

# 2. Fetch dependencies
fvm flutter pub get

# 3. Generate code (DI, JSON models) and translations
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter gen-l10n

# 4. Run the app
fvm flutter run
```

Run the tests with `fvm flutter test`.
