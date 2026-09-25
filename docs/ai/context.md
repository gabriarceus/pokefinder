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

`docs/code_review.md` lists known bugs, UI problems and planned simplifications, each with file
and line. Some existing code is flagged there as a pattern **not** to copy (empty `catch (_) {}`
around `context.read`, hard-coded colors and font sizes, string routes). When a task fixes an item,
also update the facts in this file and in the skills.

## Architecture — layered, dependencies point inward

`lib/src/` has numbered layers. Imports go presentation → application → domain ← repository.

- `1_presentation/` — UI only: `pages/<screen>/`, `widgets/<area>/`, `theme/app_palette.dart`,
  `router/app_router.dart`, `extensions/`, `di/presentation_bloc_factory.dart`.
- `2_application/` — blocs and cubits in `bloc/<name>/`. `LanguageCubit` lives in
  `hydrated_bloc/language_storage.dart`. `helpers/log_sanitizer.dart`.
- `3_domain/` — entities, `failures/pokemon_failure.dart` (sealed), `repositories/i_pokemon_repository.dart`,
  `usecases/`, `helpers/` (pure Dart), `value_objects/`. **No Flutter imports.**
- `4_repository/` — `datasources/` (abstract + implementations), `repositories/`
  (`PokemonRepositoryImpl`, `MockPokemonRepository`, `DataRepository` cache layer),
  `models/raw_*` (`@JsonSerializable` DTOs), `services/`, `interceptors/`.
- `lib/bootstrap.dart` (DI setup, `RegisterModule`), `lib/main.dart` (startup + app root),
  `lib/bootstrap/mobile_storage_initializer.dart` (Hive + hydrated storage).

## State and DI (get_it + injectable)

- **App-lifetime cubits** are `@lazySingleton` and provided once at the app root in `lib/main.dart`:
  `PreferencesCubit`, `LanguageCubit`, `FavoritesCubit`, `RecentHistoryCubit`, `ComparisonCubit`,
  `TeamsCubit`. All except `ComparisonCubit` are `HydratedCubit`s (persisted JSON).
- **Screen-scoped blocs** are `@injectable` and created only through
  `presentation_bloc_factory.dart` (`createPokemonBloc`, `createPokedexBloc`, …). No raw `getIt`
  in `1_presentation/`.
- Cubits that need runtime data (`DetailMovesCubit`) or have no dependencies
  (`DetailGameVersionCubit`) are not injectable and are created inline in a `BlocProvider`.
- Environments: `--flavor prod` → `Environment.prod` → `PokemonRepositoryImpl` (live PokeAPI).
  `--flavor dev` → `Environment.dev` → `MockPokemonRepository` (fixed offline data).
  `--dart-define=USE_MOCK=true|false` overrides the flavor.

## Data, errors, logging

- Dio → `DataRepository` (Hive cache, `FetchStrategy.cacheFirst`, 24 h `maxAge`, stale-if-error)
  → `PokemonRemoteDataSource` → `PokemonRepositoryImpl` (maps `Raw*` → entities) → use case → bloc.
- Fallible calls return `Either<PokemonFailure, T>` (dartz). HTTP status → failure mapping lives
  in `PokemonRemoteDataSource._mapError`. The UI shows failures with `failure.localizedMessage(context)`.
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
