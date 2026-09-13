# PokeFinder

> The best app to find information about Pokémon.

PokeFinder is a mobile Flutter app (officially targeting **Android and iOS**) that
lets you search a Pokémon by name or Pokédex ID and explore a detail screen with its
stats, abilities, moves, items, encounters, forms, and cry. Data comes from the public
[PokeAPI](https://pokeapi.co/). It is built around a clean, layered architecture.

## Features

- Search a Pokémon by name or numeric Pokédex ID, with autocomplete suggestions
- Canonical routing (`/pokemon/:nameOrId`) supporting deep linking and recovery fallback
- Detail screen with tabs: info, stats, moves, items & games
- Move detail sheet, and switching between a Pokémon's alternate forms
- Plays the Pokémon cry
- Switch the app language (English / Italian, or follow the system)
- Isolated storage lifecycles (durable user preferences vs. disposable API cache)

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

### Flavors and DI environments

Two build flavors are configured, `dev` and `prod` (Android product flavors and
matching Xcode schemes), differing in application id suffix and display name. Every
`flutter run` and `flutter build` invocation must pass one of them.

Dependency injection environments are mapped to the build flavor: `--flavor dev`
binds `Environment.dev` with `MockPokemonRepository` for deterministic offline development,
while `--flavor prod` binds `Environment.prod` with `PokemonRepositoryImpl` for live PokeAPI data.

## Getting started

```bash
# 1. Install the pinned Flutter SDK
fvm install

# 2. Fetch dependencies
fvm flutter pub get

# 3. Generate code (DI, JSON models) and translations
fvm dart run build_runner build
fvm flutter gen-l10n

# 4. Run the app (a flavor is always required)
fvm flutter run --flavor dev
```

## Quality checks

`scripts/verify.sh` runs every gate — formatting, static analysis, tests — and is the
single entry point to check the project is healthy:

```bash
./scripts/verify.sh
```

The individual commands, and test coverage:

```bash
fvm dart format lib test scripts   # apply formatting
fvm flutter analyze                # static analysis
fvm flutter test                   # tests
./scripts/coverage.sh              # tests with total line coverage
./scripts/coverage.sh 60           # ...and fail below the given percentage
```
