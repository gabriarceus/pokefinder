---
name: flutter-project-conventions
description: >
  PokeFinder-specific Dart and Flutter rules: where code goes, how blocs are built and
  provided, how PokeAPI data flows, failures, l10n, theme and tests. Always consult it before
  writing, editing, refactoring or reviewing Dart in this repo, adding a screen, bloc, endpoint,
  translation or test. Trigger on "add a feature", "new endpoint", "new screen", "fix the bug",
  "refactor", "review", "aggiungi una schermata", "nuovo endpoint", "aggiungi una traduzione",
  "sistema il bug", "rivedi il codice".
---

# PokeFinder project conventions

These rules add to any generic Flutter conventions you have. They win on conflict.
Known debt and planned changes are in `docs/code_review.md`. Do not copy a pattern that the
review flags, even if the code around you uses it.

## Where new code goes

| New thing | Location |
|---|---|
| Entity, value object, enum | `lib/src/3_domain/entities/`, `value_objects/` — pure Dart, `Equatable` |
| Pure logic (formatting, parsing, calculation) | `lib/src/3_domain/helpers/` + unit test in `test/domain/` |
| PokeAPI JSON model | `lib/src/4_repository/models/raw_<name>/raw_<name>.dart`, `@JsonSerializable` |
| Bloc / cubit | `lib/src/2_application/bloc/<name>_cubit/` |
| Screen | `lib/src/1_presentation/pages/<screen>/` + a route in `router/app_router.dart` |
| Widget reused by several screens | `lib/src/1_presentation/widgets/<area>/` |

Export new domain files from `lib/src/3_domain/domain.dart`. Keep files focused: split a page
when it passes ~400 lines (`comparison_page.dart` at 1000+ lines is the example to avoid).

## Blocs and cubits

- Screen-scoped, with injected dependencies → `@injectable`, plus a `createX(...)` function in
  `lib/src/1_presentation/di/presentation_bloc_factory.dart` that also dispatches the first load.
  Widgets call that function in `BlocProvider(create: ...)`, never `getIt`.
- App-lifetime → `@lazySingleton`, provided in `MyApp` (`lib/main.dart`) with `BlocProvider.value`.
- Persisted state → `HydratedCubit`. Changing `toJson` keys breaks stored favorites, teams and
  history on users' phones: keep old keys readable in `fromJson` and add a test that loads the
  old JSON.
- Current time → inject `Clock` (`package:clock`, default `const Clock()`), then `_clock.now()`.
  See `FavoritesCubit`.
- States: a sealed class for loading/failure/success flows (`PokemonBlocState`) or one
  `Equatable` state with `copyWith` for filter-like screens (`PokedexState`). To clear a nullable
  field in `copyWith`, use the `_unset` sentinel pattern (see `PokemonBlocSuccess.copyWith`).
- Switch on sealed states with a Dart 3 `switch`. Do not add new `map(...)` helpers or builder
  wrapper widgets.
- Ignore `RequestCancelledFailure` in handlers: it means a newer request replaced this one.
- A bloc that emits success several times for the same entity (e.g. `PokemonBloc`: data, then
  encounters, then form) needs `listenWhen` on every `BlocListener` that runs side effects
  (audio, history, navigation). Without it the side effect repeats.
- An async handler that updates a selection must emit the selection first, then load. Show
  progress while loading, and roll back plus show the failure on error. Use `sequential()` when two
  quick events could read the same old state.

## PokeAPI data — adding an endpoint

1. Raw model with `@JsonSerializable` + `part '<file>.g.dart'`. Run `fvm dart run build_runner build`.
2. Method on `IPokemonRemoteDataSource` + `PokemonRemoteDataSource`: call
   `_dataRepository.fetchData<Map<String, dynamic>>(url, strategy: FetchStrategy.cacheFirst,
   maxAge: _kDefaultMaxAge)` and wrap errors with `_mapError`. Build URLs in `PokeApiUrlHelper`.
   Do not add more hard-coded `https://pokeapi.co/...` strings.
3. Method on `IPokemonRepository` + `PokemonRepositoryImpl`: map `Raw*` → entity. Map a type from
   its URL with `PokemonType.fromId(PokeApiUrlHelper.extractId(url))`.
4. Add the same method to `MockPokemonRepository` (dev flavor), or the dev build fails.
5. Add only the fields the UI reads. Unused entity fields are debt (see the review, O9).

## Failures

- Use the existing `PokemonFailure` subtypes. A new subtype needs a case in
  `extensions/pokemon_failure_ext.dart` and ARB strings. Every `switch` on failures is exhaustive,
  so the analyzer shows every place to update.
- Show a failure to the user. Never turn it into an empty list or an empty state.
- Do not wrap `context.read/watch/select` in `try/catch`. A missing provider is a bug: fix the
  provider tree, or provide the cubit in the test.

## UI

- Colors: the theme lives in `lib/src/1_presentation/theme/app_palette.dart`. Use
  `Theme.of(context).colorScheme` roles. Do not add new `Colors.*` literals or local
  `backgroundColor: AppPalette.brandRed` overrides; change the theme instead.
- Type colors come only from `TypeColorScheme.getColorFromType`. Show a type with `TypeChip`
  (localized label). `TypeImage` shows the English PokeAPI sprite.
- Text on a colored surface: `contrastingTextColor(background)`. Pass the real color, never
  `Colors.transparent`.
- Text styles: `Theme.of(context).textTheme` roles. No new `fontSize:` literals. Nothing under
  `labelSmall`.
- Spacing: multiples of 4 (4, 8, 12, 16, 24). Page padding 16 dp. Elements stacked in a column
  share the same left and right edges.
- Cards: `SurfaceCard`. Label/value rows: `LabelValueRow`.
- Tap targets are 48 dp by default in Material 3. Do not add `minimumSize: Size(48, 48)` again.
  Add `Semantics` labels to icon-only buttons and to images that carry meaning.
- Navigation: `context.push('/pokemon/${Uri.encodeComponent(name)}')` and the paths in
  `router/app_router.dart`. Close sheets and dialogs with `context.pop()` / `Navigator.pop`.
- Before you push a route from a screen with a text field, call `unfocus()`, or the keyboard comes
  back when the user returns.

## Localization

- New UI string → add the key to **both** `lib/l10n/app_en.arb` and `app_it.arb`, run
  `fvm flutter gen-l10n`, check that `untranslated_messages.txt` is `{}`. Read it with `context.t()`.
- Search for an existing key first. No ALL-CAPS in ARB; use `.toUpperCase()` in Dart.
- No user-visible literal in Dart (`'Gen $n'`, `'XP'` are known debt).
- PokeAPI slugs (moves, abilities, items, locations, game versions, types) → `context.translateX`
  from `lib/l10n/translation_helper.dart`. Unknown slugs fall back to `toDisplayCase()`, never to
  a raw slug. `test/widget/translation_coverage_test.dart` enforces this.
- Pokémon species and form names stay canonical (see `docs/localization_policy.md`).

## Logging

`final EnLogger _logger;` + `static const _prefix = 'ClassName';` +
`_logger.info('...', prefix: _prefix)`. Wrap user input with `sanitizeQueryForLog`.

## Tests

- Layout: `test/domain/` (pure helpers), `test/application/` (blocs), `test/repository/`,
  `test/widget/` (screens and widgets), `test/integration/critical_journeys_test.dart`.
- Mocks: `mocktail`. Register fallbacks with `registerFallbackValue` in `setUpAll`.
- Shared data: `test/fixtures/pokemon_fixture.dart`.
- Widgets with `Image.network` → wrap the pump in `mockNetworkImagesFor(...)`.
- Hydrated cubits → `HydratedBloc.storage = InMemoryHydratedStorage();` in `setUp`.
- Test behavior through the public API. When you delete code, delete its tests too; do not keep
  tests only for the 70% coverage gate.

## Before you say "done"

- `fvm dart format lib test scripts`, `fvm flutter analyze --fatal-infos`, `fvm flutter test`.
- Touched ARB or annotated classes → run gen-l10n / build_runner and keep the regenerated files in
  the change (CI fails on a generated diff).
- Changed UI → check it on the emulator in light and dark mode (skill `verifying-ui-on-device`).
- Changed something that `docs/ai/context.md`, this skill or `README.md` describes → update it.
