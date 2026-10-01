# PokeFinder — Audit of the `code_review.md` remediation

Date: 2026-10-01 · Branch: `improvements` · HEAD: `3520a9b`

This is a static audit of how `docs/code_review.md` was applied. It reads the code and runs the
CI gates. It does not run the app on a device. Use it as the work list to close the review.

## 1. Gates (all green)

| Gate                                                       | Result                                               |
| ---------------------------------------------------------- | ---------------------------------------------------- |
| `fvm flutter analyze --fatal-infos`                        | No issues                                            |
| `fvm dart format --set-exit-if-changed lib test scripts`   | 0 files changed                                      |
| `fvm flutter test`                                         | **726** tests pass (`code_review.md` still says 707) |
| `fvm flutter gen-l10n` + `fvm dart run build_runner build` | No diff in the tree                                  |
| `untranslated_messages.txt`                                | `{}`                                                 |
| `./scripts/coverage.sh 70`                                 | 81.5 %                                               |

## 2. Verdict per item

Legend: ✅ done · ⚠️ partial or done with a defect · ❌ not done.

| Section  | Items                                | Verdict                                                                            |
| -------- | ------------------------------------ | ---------------------------------------------------------------------------------- |
| Bugs     | B2–B15                               | ✅                                                                                 |
| Bugs     | B1                                   | ⚠️ the main path works, but two edge cases are wrong (see 3.1, 3.2)                |
| Visual   | A1, A2, A4, A5, A6, A8, A9, A10, A11 | ✅ in code (the device pass is still open)                                         |
| Visual   | A3                                   | ⚠️ no `filledButtonTheme` / `switchTheme` / `sliderTheme`; one local override left |
| Visual   | A7                                   | ⚠️ the tab is still "Items" in English; the type color is not the only accent      |
| Simplify | O1–O5, O7, O9, O10, O12–O15          | ✅                                                                                 |
| Simplify | O6                                   | ⚠️ the structure is right, but the file has 456 lines (target < 350)               |
| Simplify | O8                                   | ⚠️ works, but differs from the spec (value equality + `NavigationDone` round-trip) |
| Simplify | O11                                  | ❌ not started (the doc says so)                                                   |
| Simplify | O16                                  | ❌ the suite grew: 18,453 test lines vs 18,033 at `7ba359a`                        |
| Shape    | M2–M8                                | ✅                                                                                 |
| Shape    | M1                                   | ⚠️ the swallowed `catch (_)` are gone, but there is **no `pumpApp` helper**        |

## 3. Defects to fix (code)

Ordered by impact. "Confirmed" means I read the code path myself. "Likely" needs a device or a
test to prove it.

### 3.1 B1 — empty grid after a failed type load [confirmed]

- **Where**: `lib/src/2_application/bloc/pokedex_bloc/pokedex_bloc.dart`, failure branch of
  `_onTypeFilterToggled` (around line 210).
- **Problem**: only the type toggle is `sequential()`. Query, generation, sort and form events
  still run while a type is loading. They filter with the loading type selected but missing
  from `typeIdMap`, so `PokemonIndexFilterHelper` returns nothing. The failure branch removes
  the type but does not recompute `filteredEntries`.
- **Scenario**: select Fire on a slow network, type "char", the request fails → "No Pokémon
  found" with no type selected.
- **Fix**: in the failure branch, recompute `filteredEntries` with `_filter(...)` and the new
  filters (or call `_applyFilters`).
- **Test**: bloc test: toggle a type (slow, failing), send a query event before it completes,
  expect `filteredEntries` to match the query only.

### 3.2 B1 — a second tap on a loading chip selects it again [confirmed]

- **Where**: same handler, `isAdding` is computed from the state when the queued event runs.
- **Scenario**: tap Fire, tap Fire again, the first request fails. The queued tap now sees Fire
  as not selected, adds it again and fires a second request and a second SnackBar.
- **Fix**: ignore a toggle for a type in `state.loadingTypes`, or treat it as "cancel" (record
  the intent and drop the result).
- **Test**: bloc test with two toggles and a failing repository; expect the type to be
  deselected at the end and one call.

### 3.3 Numeric search loses alternate forms [confirmed]

- **Where**: `lib/src/4_repository/repositories/pokemon_repository_impl.dart`, `_getPokemon` →
  `_formsFor(canonical, …)` → `_catalogFormsFor` matches `entry.name == name`.
- **Problem**: `canonical` can be a numeric id ("25"). The catalog lookup never matches, so the
  code falls back to the resource `forms` array.
- **Scenario**: search `25` → Pikachu opens with only one form. Search `pikachu` → all forms.
- **Fix**: pass `RawPokemon.name` (the resolved name), not the input.
- **Test**: repository test: `getPokemon(PokemonName('25'))` returns the same forms as `'pikachu'`.

### 3.4 Form sheet uses the raw type color [confirmed]

- **Where**: `lib/src/1_presentation/pages/detail/widgets/form_selection_bottom_sheet.dart:115`
  (`activeThumbColor: widget.typeColor`) and `:261-293`.
- **Problem**: the sheet opens outside the body `Theme` override and does not use `readableOn`.
  For Electric (`#F7D02C`) the selected form name is yellow on a light sheet (about 1.5:1). It
  is also a local theme override (A3).
- **Fix**: use `readableOn(typeColor, …)` for text, and drop `activeThumbColor` (let the theme
  handle the switch).

### 3.5 Team page downloads encounters for every member [confirmed]

- **Where**: `lib/src/1_presentation/pages/teams/team_detail_page.dart:346-378` creates one
  `PokemonDetailBloc` per member. That bloc always calls `getEncounters`.
- **Problem**: the same waste B15 removed from Comparison. Up to 6 extra requests per open.
- **Fix**: load members with `getPokemon` only, the way `ComparisonCubit` does. Reuse that
  approach rather than a new pattern.

### 3.6 Pokémon card type chips can overflow [likely]

- **Where**: `lib/src/1_presentation/widgets/pokedex/pokemon_card.dart:241-250`: a `Wrap` inside
  `SizedBox(height: 24)` with 36 dp reserved on the right.
- **Problem**: on a 360 dp phone with 2 columns, two compact chips (e.g. "Elettro" + "Volante")
  may not fit. The second line paints outside the box. `Wrap` does not report an overflow.
- **Fix**: a `Row` with `Flexible` chips, or allow the box to grow. Check on the device first.

### 3.7 Stale test comment [confirmed by the audit agent]

- `test/repository/pokemon_repository_impl_test.dart:513-517` says the test is "left failing on
  purpose" until `lib/` is fixed. `lib/` is fixed and the test passes. Remove the comment.

## 4. Items not finished (decide or do)

| Item    | What is left                                                                                                                                                                                                                  | Suggestion                                                                                                                                                                         |
| ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **M1**  | No shared `pumpApp` helper. About 10 ad-hoc harnesses (`pumpDetailApp`, `_wrap`, `buildHarness`, …). `ensureHydratedStorage()` lives in `lib/` but only tests call it.                                                        | Add `test/helpers/pump_app.dart` that provides the 6 app cubits (mocks by default). Move the harnesses to it one file at a time. Move `ensureHydratedStorage` to `test/`.          |
| **A3**  | No `filledButtonTheme`, `switchTheme`, `sliderTheme` in `AppPalette`.                                                                                                                                                         | The M3 defaults already use the fidelity `primary`. If the device pass shows the right red, close the sub-point and update the doc. Remove the local override from 3.4 either way. |
| **A7**  | English tab label is still "Items" (`lib/l10n/app_en.arb:38`; Italian is "Luoghi"). `FilledButton.tonalIcon` (`detail_info_tab.dart:154`) and the Moves `ChoiceChip`s use the brand `secondaryContainer`, not the type color. | Rename to "Where to find" (or "Locations"). Override `secondaryContainer`/`onSecondaryContainer` in the body `Theme` too.                                                          |
| **O6**  | `comparison_page.dart` is 456 lines.                                                                                                                                                                                          | Accept it (the structure is right) or split the stat table into its own widget. Low value.                                                                                         |
| **O8**  | Spec asked identity semantics and no `NavigationDone`. The code uses value equality and keeps `NavigationDone` (`home_event.dart:24`). Also `SearchNavigation` carries the trimmed raw input, not the canonical name.         | Behavior is correct. Either accept it and update the item, or follow the spec. Check that a recent search for "Pikachu" vs "pikachu" does not create two entries.                  |
| **O11** | `USE_MOCK`, flavor and environment still all choose the mock. `docs/ai/context.md` and `README.md` now document `USE_MOCK` as kept on purpose.                                                                                | Decide: keep it (close O11 as "won't do" with the reason) or delete the mock. Your call.                                                                                           |
| **O16** | Suite grew. `test/release_hardening_test.dart` (the review's own example) is still there.                                                                                                                                     | Measure, then delete tests of trivial code. Keep coverage ≥ 70 %.                                                                                                                  |

## 5. Documentation drift

1. **Generated AI files are stale.** `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` differ from
   `docs/ai/context.md` in 4 places added by `3520a9b` (corrupt-record `fromJson` rule,
   `PokemonSummary.id` as form identity, `USE_MOCK=false`, cache epoch + index memoization +
   `clearCache()` bool). They are gitignored, so only local. Fix: `./scripts/sync-ai-docs.sh`.
2. **`CHANGELOG.md`** has nothing for `3520a9b` (Mega-form filtering, form-lineage
   `PokemonSummary`, cache epoch restored, clear-cache failure reporting, `USE_MOCK` change,
   corrupt-record eviction). The Unreleased section also contradicts itself:
   - `:55` and `:77` add `GetMoveDetailUseCase` and cancellation, which the same section later
     removes. Drop these lines.
   - `:89` says "the cache-epoch write guard are gone", but `3520a9b` brought it back.
3. **`docs/ai/context.md`** "Known issues" paragraph still lists empty `catch (_) {}`,
   hard-coded colors and string routes as existing patterns. They are gone.
4. **`docs/ai/skills/flutter-project-conventions.md`**: `:49` says `PokemonBloc` (now
   `PokemonDetailBloc`); `:120` lists `'Gen $n'` and `'XP'` as known debt (fixed). Add the
   `pumpApp` rule once M1 is done.
5. **`docs/code_review.md` Status section** is wrong in several places:
   - "the full remediation is on `main`": it is on `improvements`. `fb762f2` is dangling (no
     branch contains it).
   - "All items below have been implemented": false for M1 (and partly A3, A7, O8).
   - M3 residue: 30 `Colors.*` literals, not 24. The 6 extra are in `theme/app_palette.dart:9-15`
     (stat colors) and `widgets/detail/contrasting_text_color.dart:8-11` (black/white). All six
     are fine.
   - "707 tests": now 726.
   - Section 6, "`Request cancelled` ARB strings may be unused": these keys never existed.
     Remove the note.
6. **13 unused ARB keys** (same set in EN and IT): `aboutPokeApiWebsite`, `confirm`, `eggGroups`,
   `errorAbilityDetail`, `errorEncounters`, `errorEvolutionChain`, `errorFormDetails`,
   `errorMoveDetails`, `errorSpecies`, `filterCount`, `gameSelectorLabel`, `growthRate`,
   `pokemonCry`. Delete them (then run `gen-l10n`).

## 6. Small points (optional)

- Two separate `allVersions = 'all'` constants (`detail_moves_cubit.dart:87`,
  `detail_game_version_state.dart:9`). Moves works only because the strings match. Use one.
- `MoveNameResolver` captures the language when the cubit is created
  (`detail_moves_tab.dart:19-25`). After a language change with the detail page in the stack,
  sorting stays in the old language.
- Move names compare with `String.compareTo` (code-unit order). Accented first letters sort
  last. Probably fine for EN/IT move names; check if a name starts with "É".
- The B6 "stable order" test re-filters the same input. It does not shuffle the input, so it
  does not prove order independence.
- Leftover old prefix: `PokemonBlocState/Success/Failure/Event`, `PokemonBlocProvider`,
  `createPokemonBloc`, `test/application/pokemon_bloc_test.dart` (M7 renamed only the bloc).
- `pokemon_route_param_parser.dart:1-12`: the doc comment sits above `_numericIdRegex`, not
  above the function.
- Pokéball in dark mode: the band uses `onSurface`, so it is light, not dark.
- Display `TypeChip` (radius 12) and selectable `TypeChip` (`FilterChip`, radius ~8) differ a
  little in shape.
- Stats tab Total row uses the 3-column row also in compact mode, where the header is hidden.
- B9 side effect: `*-totem-alola` forms are now cosmetic and hidden by default. Probably right,
  but not written down anywhere.
- `_catalog` is memoized even when it came from a stale offline copy; only pull-to-refresh
  renews it.
- Empty untracked dir `lib/src/3_domain/usecases/.claude/` (tool artifact). Delete the folder.

## 7. Device pass (still open)

Run the `verifying-ui-on-device` skill, light and dark, IT and EN:

- Detail page: collapsing header, header at text scale 2.0 (the `#025` number is outside the
  `FittedBox` in a 44 dp row and may clip), app bar icons on Electric/Fairy/Ice, tabs, form
  sheet on Electric (3.4).
- Pokédex grid at 360 dp width with dual-type cards (3.6), filter sheet, offline banner, type
  filter loading and failure.
- Home (button widths, Pokéball, recent shelf), drawer, empty states (Teams, Compare, Favorites,
  Pokédex, Matchups), matchup chips, error page with network off.
- Settings section titles still use their own `titleSmall` + primary style, not `SectionTitle`.
  Decide if they should match.

## 8. Suggested order

1. Code defects 3.1–3.5, each with its test → verify: `fvm flutter test`.
2. Decisions on O11, O8, O6, A3 → update `code_review.md` with the outcome.
3. M1 `pumpApp` helper, then O16 test pruning → verify: `./scripts/coverage.sh 70`.
4. A7 (EN label, accent), unused ARB keys → verify: `gen-l10n` + `git status`.
5. Docs: CHANGELOG, `docs/ai/` fixes, `./scripts/sync-ai-docs.sh`, rewrite the `code_review.md`
   Status section.
6. Device pass (section 7), including 3.6.
7. Optional points from section 6.
