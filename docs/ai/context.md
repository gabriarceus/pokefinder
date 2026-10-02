# AI context

PokeFinder: a personal Flutter app (Android + iOS) to search and browse Pokémon, backed by
PokeAPI v2. English and Italian UI.

This file covers repo structure, stack, commands and traps. Two project skills hold the details:

| Task | Load |
|---|---|
| Write, edit, refactor or review Dart in this repo | `flutter-project-conventions` — **always, before touching Dart** |
| Run the app, take screenshots, check a UI change on the emulator | `verifying-ui-on-device` |

If a generic Flutter conventions skill is also available (e.g. `flutter-conventions`), apply it too.
The rules in this repo win on conflict.

## Known issues — read before a refactor

`docs/code_review.md` lists the bugs, UI problems and simplifications found in the last review,
each with file and line, and the outcome of each item. The patterns it flagged (empty
`catch (_) {}` around `context.read`, hard-coded colors and font sizes, string routes) are gone
from the code; do not bring them back. When a task changes a fact described here, also update
this file and the skills.

## Architecture — layered, dependencies point inward

`lib/src/` has numbered layers. Imports go presentation → application → domain ← repository.

- `1_presentation/` — UI only: `pages/<screen>/`, `widgets/<area>/`, `theme/app_palette.dart`,
  `router/app_router.dart` + `router/app_routes.dart` (path builders), `extensions/`,
  `di/presentation_bloc_factory.dart`. Shared building blocks live in `widgets/`:
  `EmptyStateView`, `SectionTitle`, `LabelValueRow`, `SurfaceCard`.
- `2_application/` — blocs and cubits in `bloc/<name>/`. `LanguageCubit` lives in
  `bloc/language_cubit/language_cubit.dart`. `helpers/log_sanitizer.dart`,
  `helpers/move_name_resolver.dart`.
- `3_domain/` — entities, `failures/pokemon_failure.dart` (sealed), `repositories/i_pokemon_repository.dart`,
  `helpers/` (pure Dart), `value_objects/`. **No Flutter imports.** There is **no use case
  layer**: blocs and cubits depend on `IPokemonRepository` directly.
- `4_repository/` — `datasources/` (abstract `ApiClient`/`LocalStorage` + implementations),
  `repositories/` (`PokemonRepositoryImpl`, `MockPokemonRepository`), `models/raw_*`
  (`@JsonSerializable` DTOs), `services/`, `interceptors/`. The cache client is
  `datasources/implementations/poke_api_cache.dart`; there is no remote data source.
- `lib/bootstrap.dart` (DI setup, `RegisterModule`), `lib/main.dart` (startup + app root),
  `lib/bootstrap/mobile_storage_initializer.dart` (Hive + hydrated storage).

## State and DI (get_it + injectable)

- **App-lifetime cubits** are `@lazySingleton` and provided once at the app root in `lib/main.dart`:
  `PreferencesCubit`, `LanguageCubit`, `FavoritesCubit`, `RecentHistoryCubit`, `ComparisonCubit`,
  `TeamsCubit`. All except `ComparisonCubit` are `HydratedCubit`s (persisted JSON). A
  `HydratedCubit.fromJson` must drop a corrupt record and keep the rest, the way `TeamsCubit`
  does — `PokemonSummary.fromJson` throws on a missing id or name.
- `PokemonSummary.id` identifies the exact **form**, never the parent species, and it carries
  `parentSpeciesId`/`formCategory`/`regionalGroup` so a round trip back to a
  `PokemonIndexEntry` keeps the form lineage. Favourites, history, teams and comparison all key
  on that id.
- **Screen-scoped blocs** are `@injectable` and created only through
  `presentation_bloc_factory.dart` (`createPokemonDetailBloc`, `createPokedexBloc`, …). No raw `getIt`
  in `1_presentation/`. A screen that needs several Pokémon at once (team summary) uses one
  `PokemonListCubit` (`getPokemon` only, one `PokemonLoad` per name), not one detail bloc per
  Pokémon: the detail bloc also downloads encounters.
- Cubits that need runtime data (`DetailMovesCubit`) or have no dependencies
  (`DetailGameVersionCubit`) are not injectable and are created inline in a `BlocProvider`.
- Environments: `--flavor prod` → `Environment.prod` → `PokemonRepositoryImpl` (live PokeAPI).
  `--flavor dev` → `Environment.dev` → `MockPokemonRepository` (fixed offline data), unless
  `--dart-define=USE_MOCK=false` is passed, which points a dev build at the live API (there is a
  "Dev - Live API" launch config for it).
  `Environment` is injectable's own class; `configureDependencies` takes its `String` value.

## Data, errors, logging

- Dio → `PokeApiCache` (Hive cache, cache-first, 24 h window, stale-if-error, per-URL-and-type
  request sharing, and an epoch so a `clear()` discards writes already in flight) →
  `PokemonRepositoryImpl` (maps `Raw*` → entities, and **all** errors in one `_toFailure`) → bloc.
- `PokemonRepositoryImpl` memoizes a fresh enriched Pokédex index for the app lifetime (a stale
  offline copy is served but not kept, so the next call retries the network). It is the
  source of a Pokémon's `forms`: `/pokemon/{name}` only ever names the Pokémon itself, so the
  catalog is grouped by `effectiveParentSpeciesId` instead. `PokemonFormClassifier.hasRealForm`
  filters the vestigial `-mega` entries the index ships for species with no Mega Evolution
  (`kMegaEvolutionSpecies`).
- Fallible calls return `Either<PokemonFailure, T>` (dartz). HTTP status → failure mapping lives
  in that single `_toFailure` in `PokemonRepositoryImpl`. The UI shows failures with
  `failure.localizedMessage(context)`.
- Cache clearing and size also live on the repository (`clearCache()`, `getCacheSize()`); there
  is no `ClearCacheUseCase`/`GetCacheSizeUseCase`. `PreferencesCubit.clearCache()` returns whether
  it succeeded, and the settings page reports the failure instead of always claiming success.
- `CancellationToken` and every `cancelToken:` parameter are gone. A superseded request is
  dropped by `restartable()` plus `emit.isDone`.
- Durable user state (hydrated cubits) is in the documents directory. The disposable API cache is
  in the temporary directory. "Clear cache" never touches favorites, teams or history.
- Logging: `en_logger` with a `_prefix` per class. User input always goes through
  `sanitizeQueryForLog`. Policy: `docs/logging_policy.md`.

## i18n

- UI strings: `lib/l10n/app_en.arb` (template) + `app_it.arb` → `AppLocalizations`, read with
  `context.t()` (`extensions/language_ext.dart`).
- Bulk PokeAPI data (abilities, moves, items, locations) is translated through `lib/l10n/*_db.dart`
  maps and the `context.translateX(...)` helpers in `lib/l10n/translation_helper.dart`.
  Pokémon names stay canonical. Policy: `docs/localization_policy.md`.

## Routes (go_router, `router/app_router.dart`)

`/`, `/pokemon/:nameOrId` (`?search=` records a recent search), `/pokedex`, `/compare`,
`/matchups` (`?types=fire,flying`), `/favorites`, `/teams`, `/teams/:teamId`, `/settings`,
`/settings/about`. Deep link: `pokefinder:///pokemon/<nameOrId>`.

## Commands — fvm only, no melos (Flutter pinned in `.fvmrc`)

- Deps: `fvm flutter pub get`
- Codegen (DI + JSON): `fvm dart run build_runner build`
- Translations: `fvm flutter gen-l10n` (then `untranslated_messages.txt` must be `{}`)
- Format: `fvm dart format lib test scripts`
- Local gates: `./scripts/verify.sh` (format check + analyze + tests)
- Coverage: `./scripts/coverage.sh [min-percentage]`
- Run: `fvm flutter run --flavor dev` or `--flavor prod`. A flavor is **always** required.

The same commands exist as VS Code tasks in `.vscode/tasks.json`.

**CI is stricter than `verify.sh`.** `.github/workflows/ci.yml` also runs
`flutter analyze --fatal-infos`, `gen-l10n` + `build_runner` followed by a "no uncommitted diff"
check, and `coverage.sh 70`. Before you say a change is done, run
`fvm flutter analyze --fatal-infos` and, if you touched ARB files or annotated classes, run both
codegen commands and check `git status`.

## Do not run without an explicit request

- `scripts/post_build.dart` and the VS Code task "Build Appbundle + Post build": they **create and
  push a git tag**.
- `scripts/generate_canonical_table.dart`: it calls PokeAPI and rewrites
  `lib/src/3_domain/helpers/canonical_species_data.dart`.
- Release builds (`flutter build … --release`).

## Generated — never hand-edit

`*.g.dart`, `lib/bootstrap.config.dart`, `lib/l10n/app_localizations*.dart`,
`lib/src/3_domain/helpers/canonical_species_data.dart`. Also the AI files generated from this
folder: `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.claude/skills/`, `.opencode/skills/`
(edit `docs/ai/`, then run `./scripts/sync-ai-docs.sh`). Fix the source, then re-run the generator.
