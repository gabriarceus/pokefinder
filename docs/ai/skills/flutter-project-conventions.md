---
name: flutter-project-conventions
description: >
  PokeFinder-specific Dart and Flutter rules for state, DI, PokeAPI data, failures, UI,
  localization and tests. Always read before writing, editing, refactoring or reviewing Dart,
  translations or tests in this repo. Trigger on "add a feature", "new endpoint", "new screen",
  "refactor", "review", "aggiungi una schermata", "aggiungi una traduzione", "sistema il bug",
  "rivedi il codice".
---

# PokeFinder project conventions

Apply the precedence and verification rules in `docs/ai/context.md`. All paths below are
relative to the repository root. Keep project decisions here and change history in `CHANGELOG.md`.

## Where new code goes

| New thing | Location |
|---|---|
| Entity, value object, enum | `lib/src/3_domain/entities/`, `lib/src/3_domain/value_objects/` — pure Dart, `Equatable` |
| Pure logic | `lib/src/3_domain/helpers/`, with tests in `test/domain/` |
| PokeAPI JSON model | `lib/src/4_repository/models/raw_<name>/raw_<name>.dart`, `@JsonSerializable` |
| Bloc / cubit | `lib/src/2_application/bloc/`, in a `<name>_bloc/` or `<name>_cubit/` folder |
| Screen | `lib/src/1_presentation/pages/<screen>/` + `lib/src/1_presentation/router/app_router.dart` |
| Shared widget | `lib/src/1_presentation/widgets/<area>/` |

Export new domain files from `lib/src/3_domain/domain.dart`. Keep files focused; split pages
that pass about 400 lines by responsibility.

## State and dependency injection

- Screen-scoped blocs with injected dependencies use `@injectable` and a `createX(...)` function
  in `lib/src/1_presentation/di/presentation_bloc_factory.dart` that starts the first load.
  Widgets use the factory in `BlocProvider(create: ...)`; only the factory resolves `getIt`
  inside the presentation layer.
- `DetailMovesCubit` takes runtime data through `createDetailMovesCubit` and is not injectable.
  `DetailGameVersionCubit` has no dependencies and is created inline in a `BlocProvider`.
- App-lifetime cubits are `@lazySingleton` and provided with `BlocProvider.value` in `MyApp`:
  `PreferencesCubit`, `LanguageCubit`, `FavoritesCubit`, `RecentHistoryCubit`, `ComparisonCubit`,
  `TeamsCubit`. All except `ComparisonCubit` use `HydratedCubit`.
- Persisted JSON must remain readable after changes. Keep old keys readable and test old records.
  In `fromJson`, drop a corrupt record and keep the rest, as `TeamsCubit` does;
  `PokemonSummary.fromJson` throws for an invalid id or name.
- `PokemonSummary` is the shared list record. Its id identifies the exact form, not its parent
  species. Preserve parent species, form category and regional group through JSON and
  `toIndexEntry()`. Favorites, history, teams and comparison key on that id.
- Inject `Clock` (default `const Clock()`) for current time; see `FavoritesCubit`.
- Use sealed loading/failure/success states (`PokemonDetailState`) or an `Equatable` state with
  `copyWith` for filters (`PokedexState`). Use the `_unset` sentinel to clear nullable fields;
  see `PokemonDetailSuccess.copyWith`. Switch on sealed states without new `map` wrappers.
- Guard side effects with `listenWhen` when a bloc emits success repeatedly for one entity.
  Detail data, encounters and forms can each emit success; audio and history must not repeat.
- `HomeBlocState.pendingNavigation` holds a `SearchNavigation` value. `NavigationDone` clears
  it after navigation, so submitting the same search again still emits a request.
- For async selection changes, emit the selection before loading. Show progress, then roll back
  and report failure on error. Recompute derived filters on rollback because other events may
  have run. A second tap on a loading type cancels the selection; see `_onTypeFilterToggled`.
- Superseded bloc requests use `restartable()` and `emit.isDone` to drop obsolete results.
- For several Pokémon without encounters, use `PokemonListCubit` and `PokemonLoad`; creating
  one `PokemonDetailBloc` per entry also downloads encounters. `ComparisonCubit` loads its
  own details with `getPokemon` only.

## Repository and cache

Dio → `PokeApiCache` → `PokemonRepositoryImpl` → bloc. Fallible calls return
`Either<PokemonFailure, T>` (dartz).

- `PokeApiCache` uses a 24-hour cache window, stale-if-error fallback and request sharing by
  URL and type. Its epoch prevents an in-flight request from writing after `clear()`.
  `forceRefresh` tries the network first and reads cached data only on failure.
- The repository memoizes a fresh enriched index. A stale offline index is served without
  memoizing it, so the next call retries the network.
- Forms come from the index grouped by `effectiveParentSpeciesId`; the Pokémon resource's
  `forms` array is not the full species catalogue. `PokemonFormClassifier.hasRealForm` uses
  `kMegaEvolutionSpecies` to filter vestigial Mega entries.
- Cache size and clearing are repository methods. `PreferencesCubit.clearCache()` returns
  whether it succeeded; callers must report failure.

To add an endpoint:

1. Add the `@JsonSerializable` raw model and its `part '<file>.g.dart'` declaration.
2. Add the method to `IPokemonRepository`, `PokemonRepositoryImpl` and `MockPokemonRepository`.
3. Build URLs with `PokeApiUrlHelper`. Reuse `_fetch<J, T>(url, toEntity)` in the implementation
   for cache access, parsing and failure mapping; see `getFormDetails` and `getEncounters`.
   Use `_typeFromUrl` for type mapping. Keep error conversion in the existing `_toFailure`.
4. Add only fields callers need. Group sprite URLs in `PokemonSprites`. Reuse `PokemonSummary`
   for lists; `PokemonDetailSuccess.summary` builds it from detail state.
5. Run generation and checks as listed in `docs/ai/context.md`.

## Failures

- Use existing `PokemonFailure` subtypes. New subtypes need an exhaustive case in
  `lib/src/1_presentation/extensions/pokemon_failure_ext.dart` and ARB strings.
  Display with `failure.localizedMessage(context)`.
- Show failures to the user; do not turn them into empty data.
- Do not catch errors from `context.read/watch/select`. Fix the provider tree or test setup.

## UI

- Use `Theme.of(context).colorScheme` and `textTheme` roles from
  `lib/src/1_presentation/theme/app_palette.dart`.
  Do not add `Colors.*`, `fontSize:` literals or local brand-red overrides. Existing game-brand
  colors, stat colors and contrast black/white values are intentional data and helpers.
- Type colors come from `TypeColorScheme.getColorFromType`. Use localized `TypeChip` labels;
  PokeAPI type sprites contain English text and must not appear in the Italian UI.
- Use `contrastingTextColor(background)` for black/white text and `color.readableOn(brightness)`
  for readable accents. Pass the real background, not `Colors.transparent`.
- Use `SectionTitle`, `SurfaceCard`, `LabelValueRow` and `EmptyStateView` for shared layouts.
  Text must be at least `labelSmall`. Use spacing in multiples of 4 and page padding of 16 dp.
  Align the left and right edges of elements stacked in a column.
- Material 3 controls provide 48 dp targets by default; avoid redundant minimum-size overrides.
  Measure the tappable widget, not its inner tooltip. Label meaningful images and icon buttons
  for accessibility.
- Build routes with `AppRoutes` (`lib/src/1_presentation/router/app_routes.dart`)
  and use `context.push` / `context.pop`.
  Close dialogs and sheets with `context.pop()` or `Navigator.pop`. Unfocus text fields before
  pushing a route. Deep links use `pokefinder:///pokemon/<nameOrId>`; route definitions are in
  `lib/src/1_presentation/router/app_router.dart`.

## Localization and logging

- Read `docs/localization_policy.md` for canonical names and translation fallbacks, and
  `docs/logging_policy.md` for logging behavior.
- Search existing ARB keys before adding both English and Italian strings. Use `context.t()`.
  Numbers with units need localized strings too. Apply uppercase styling in Dart, not ARB.
- Translate API slugs with `context.translateX` from `lib/l10n/translation_helper.dart`.
  Translation tests cover database integrity and selected helper cases; they do not scan every
  screen. Inspect changed UI for raw slugs and untranslated strings.
- Log through `EnLogger` with a stable class prefix. Pass user input through `sanitizeQueryForLog`.

## Tests

- Use `test/domain/`, `test/application/`, `test/repository/`, `test/widget/` and
  `test/integration/critical_journeys_test.dart`. Shared data is in `test/fixtures/pokemon_fixture.dart`.
- Use `mocktail`; register fallback values in `setUpAll`. Wrap network image pumps with
  `mockNetworkImagesFor(...)`.
- Use `tester.pumpApp(home: …)` or `pumpApp(router: …)` from `test/helpers/pump_app.dart`.
  It provides themes, localizations and the six app cubits through `TestAppCubits`; pass your
  own cubits when assertions need them instead of building another app shell.
- For hydrated cubits, set `HydratedBloc.storage = InMemoryHydratedStorage()` in `setUp`;
  the implementation belongs in `test/helpers/in_memory_hydrated_storage.dart`.
- Test public behavior. Remove obsolete tests with deleted behavior; keep meaningful coverage
  rather than tests of constants or defaults written only for the coverage gate.
