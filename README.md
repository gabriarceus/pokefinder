# PokeFinder

> The best app to find information about Pokémon.

PokeFinder is a mobile Flutter app (officially targeting **Android and iOS**) for
searching, browsing, and exploring Pokémon. Data comes from the public
[PokeAPI](https://pokeapi.co/). It is built around a clean, layered architecture.

## Features

- Search a Pokémon by name or Pokédex ID, with prefix, contains, and numeric-ID autocomplete
- Browsable Pokédex with pagination, pull-to-refresh, type (18) / generation (1-9) / sort filters, and Random Pokémon
- Alternate forms: Mega, Primal, Regional (Alola, Galar, Hisui, Paldea), G-Max and battle modes, with badges, localized titles, and keyword search
- Detail screen with tabs (info, stats, moves, items & games), species flavor text, branching evolution chain, ability sheets, unified game-version selector, and inline forms gallery
- Favorites and Recently Viewed / Recent Searches with reactive sync
- Side-by-side comparison of up to 2 Pokémon (base/min/max stats, types, height/weight) from Pokédex cards or the detail screen
- Offline type matchup calculator: 1–2 defending types, grouped weaknesses / resistances / immunities (4×, 2×, ½×, ¼×, 0×), via drawer or tappable detail type chips
- Settings: language (English / Italian / system), theme (System / Light / Dark), Metric / Imperial units, cry autoplay + volume, cache size + purge
- About screen with app version, PokeAPI credit, trademark disclaimer, and licenses
- Offline support via cached index and details, with stale indicator and Retry / Edit Search recovery
- Responsive layouts (320px phones to tablets, landscape, 200% text scaling) with screen-reader semantics and 48×48 dp targets

## Routes

| Route                | Screen                                     |
| -------------------- | ------------------------------------------ |
| `/`                  | Home / search                              |
| `/pokemon/:nameOrId` | Detail (name or numeric ID, deep-linkable) |
| `/pokedex`           | Browsable Pokédex                          |
| `/compare`           | Side-by-side Pokémon comparison (max 2)    |
| `/matchups`          | Offline type matchup calculator (1–2 defending types, `?types=` preset) |
| `/favorites`         | Favorites                                  |
| `/settings`          | Settings                                   |
| `/settings/about`    | About & Legal                              |

Invalid parameters fall back to a route error page.

The detail screen offers a copy-link action that copies the canonical path
(`/pokemon/:nameOrId`) to the clipboard; the same path is reachable as a
cold-start deep link (`pokefinder:///pokemon/:nameOrId`, declared via an
Android intent filter and an iOS URL type). Copy uses the platform clipboard
only — no share-sheet plugin, no new permissions on either OS.

## Tools used

- **[Flutter](https://flutter.dev) + [fvm](https://fvm.app)** — UI toolkit, SDK pinned in `.fvmrc`
- **[flutter_bloc](https://pub.dev/packages/flutter_bloc) / [hydrated_bloc](https://pub.dev/packages/hydrated_bloc)** — state management, with persisted language, theme, favorites, and history
- **[get_it](https://pub.dev/packages/get_it) + [injectable](https://pub.dev/packages/injectable)** — dependency injection; swaps real and mock data sources per flavor
- **[go_router](https://pub.dev/packages/go_router)** — navigation between screens
- **[dio](https://pub.dev/packages/dio)** — HTTP client for PokeAPI, with logging interceptor
- **[hive_ce](https://pub.dev/packages/hive_ce) + [path_provider](https://pub.dev/packages/path_provider)** — local cache for API responses
- **[dartz](https://pub.dev/packages/dartz)** — `Either`-based error handling with a sealed `PokemonFailure`
- **[just_audio](https://pub.dev/packages/just_audio) + [just_audio_media_kit](https://pub.dev/packages/just_audio_media_kit)** — plays the Pokémon cry (`.ogg` on iOS)
- **[intl](https://pub.dev/packages/intl) + flutter_localizations** — locale-aware formatting and translations (ARB files)
- **[en_logger](https://pub.dev/packages/en_logger)** — prefixed logging with release-mode redaction
- **[bloc_concurrency](https://pub.dev/packages/bloc_concurrency) + [clock](https://pub.dev/packages/clock)** — request transformers, cancellation/dedup, deterministic cache expiry
- **[package_info_plus](https://pub.dev/packages/package_info_plus) + [url_launcher](https://pub.dev/packages/url_launcher)** — About screen version info and external links
- **gen_l10n** — translations from `lib/l10n/app_en.arb` (template) + `app_it.arb`

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

### Bloc construction and use cases

Presentation widgets never call `getIt` directly. Blocs and cubits with
static dependencies are `@injectable` and are obtained exclusively through
`lib/src/1_presentation/di/presentation_bloc_factory.dart`, the single
documented construction point (it also builds the non-injectable,
runtime-data `DetailMovesCubit`). The only other sanctioned `getIt` call
sites are the app-lifetime singletons provided at the app root
(`lib/main.dart`). Every repository flow is fronted by a use case
(`GetPokemonSpeciesUseCase`, `GetEvolutionChainUseCase`,
`GetAbilityDetailUseCase`, `GetMoveDetailUseCase`, …) — cubits depend on
the use case, never on `IPokemonRepository` directly.

### Flavors and DI environments

Two build flavors are configured, `dev` and `prod` (Android product flavors and
matching Xcode schemes), differing in application id suffix and display name. Every
`flutter run` and `flutter build` invocation must pass one of them.

Dependency injection environments are mapped to the build flavor: `--flavor dev`
binds `Environment.dev` with `MockPokemonRepository` for deterministic offline development,
while `--flavor prod` binds `Environment.prod` with `PokemonRepositoryImpl` for live PokeAPI data.

## Data, caching, and i18n

- PokeAPI v2 over Dio; responses cached in Hive via a feature-agnostic `DataRepository` with `cacheFirst`, `networkFirst`, and `networkOnly` fetch strategies.
- Durable user state (language, theme, favorites, history) lives in documents storage; disposable API cache lives in temporary storage.
- UI strings: `lib/l10n/app_en.arb` + `app_it.arb` → `AppLocalizations`. Bulk data translations (abilities, moves, items, locations) live in `lib/l10n/*_db.dart`, keyed by API value — see `docs/localization_policy.md`.
- Logging redacts user queries at release level and truncates payloads — see `docs/logging_policy.md`.

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

Generated files (`*.g.dart`, `bootstrap.config.dart`, `lib/l10n/app_localizations*.dart`) are never hand-edited; fix the source, then re-run codegen.

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
fvm flutter test                   # tests (unit, bloc, widget, integration journeys)
./scripts/coverage.sh              # tests with total line coverage
./scripts/coverage.sh 60           # ...and fail below the given percentage
```

Every PR to `main` runs the same gates in GitHub Actions (`.github/workflows/ci.yml`), plus codegen-consistency and release-build checks.

## Attribution

Pokémon data and sprites by [PokeAPI](https://pokeapi.co/). Pokémon © Nintendo / Creatures Inc. / GAME FREAK inc. PokéFinder is an unofficial non-commercial fan project, not affiliated with or endorsed by the rights holders.
