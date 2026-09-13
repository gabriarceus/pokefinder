# AI context

Concise guide for AI-assisted development in this repo. **Code conventions are
authoritative in the `flutter-project-conventions` skill — consult it before writing or
editing Dart.** This file covers only repo structure, stack, and commands.

## What this is
PokeFinder: a Flutter app that searches Pokémon by name and shows a rich detail screen,
backed by PokeAPI v2.

## Architecture — layered, dependencies point inward
`lib/src/` uses numbered Clean Architecture layers:
- `1_presentation/` — UI only (pages, widgets, theme, extensions). Dumb widgets, no logic.
- `2_application/` — state: `bloc/` (HomeBloc; `PokemonBloc` — the detail bloc, under
  `detail_bloc/` — plus DetailMovesCubit and MoveDetailCubit) and `hydrated_bloc/`
  (LanguageCubit, persisted).
- `3_domain/` — entities, `failures/`, repository **interfaces** (`i_*`), `helpers/`
  (pure functions: StatCalculator, StringCasingExtensions), services, usecases,
  value_objects. No Flutter imports (one known exception: `Language` entity).
- `4_repository/` — `datasources/` (abstract + impl), repository **implementations**,
  `models/` (`Raw*` JSON DTOs), `services/` (domain service impls), interceptors.

## State management
- Blocs/cubits with static deps are `@injectable` → resolve via `getIt<T>()`.
- Cubits needing runtime data (e.g. `DetailMovesCubit(moves: ...)`) are created inline
  with `BlocProvider` — intentionally **not** injectable. `MoveDetailCubit` takes only
  static deps, so it *is* `@injectable`.
- States extend `Equatable`; failures surface through emitted state.

## DI (get_it + injectable)
- `configureDependencies(env)` in `lib/bootstrap.dart`. Environments: `Environment.prod`
  (real PokeAPI) and `'mock'` (`MockPokemonRepository`). `main()` uses prod.
- Inject deps as constructor args — never call `getIt` inside services.

## Errors & logging
- Fallible ops return `Either<PokemonFailure, T>` (dartz); `PokemonFailure` is sealed.
  HTTP status → typed failure in the remote datasource.
- Logging via `en_logger`: `static const _prefix = 'X'; _logger.info(msg, prefix: _prefix);`.

## Data & i18n
- PokeAPI v2 over Dio; responses cached in Hive (`hive_ce`). `Raw*` DTOs map to domain
  entities in the repository impl.
- `DataRepository` is the feature-agnostic caching layer: it fetches a URL through
  `ApiClient` and persists payloads via `LocalStorage`. Callers pick the caching
  behaviour with `FetchStrategy` (`cacheFirst`, `networkFirst`, `networkOnly`) and an
  optional `maxAge`. Add data sources on top of it — don't reimplement caching.
- UI strings: gen_l10n ARB — `lib/l10n/app_en.arb` (template) + `app_it.arb` →
  `AppLocalizations`. No ALL-CAPS in ARB (uppercase in Dart).
- Bulk data translations (abilities/moves/locations) live in `lib/l10n/*_db.dart`, keyed
  by API value — not ARB.

## Tooling — no melos; use fvm (Flutter pinned in `.fvmrc`)
- All gates at once: `./scripts/verify.sh` (format check + analyze + tests)
- Tests: `fvm flutter test` — coverage: `./scripts/coverage.sh [min-percentage]`
- Format: `fvm dart format lib test scripts`
- Codegen: `fvm dart run build_runner build` (`--delete-conflicting-outputs` was removed
  in build_runner 2.15 and is now rejected)
- Translations: `fvm flutter gen-l10n`
- Deps: `fvm flutter pub get`
- Run: `fvm flutter run --flavor dev` (or `prod`) — a flavor is always required
(Mirrored as VS Code tasks: Tests / Verify / Format / Coverage / Translations / Codegen /
Pub get.)

## Generated — never hand-edit
`*.g.dart`, `bootstrap.config.dart`, `lib/l10n/app_localizations*.dart`. Fix the source,
then re-run codegen.
