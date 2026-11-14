# Code review

Review of branch `improvements` at commit `6388e58`. Scope: the whole repo. Assumed load: one user on one phone, sometimes offline.

Checks run on that commit: `fvm flutter analyze --fatal-infos` reports no issues, and `fvm flutter test` passes (729 tests).

No critical bug and no loss of user data was found. Each finding has four parts: what the code is, the problem with a concrete case, the smallest fix, and what happens if it is skipped. Line numbers refer to commit `6388e58`.

## Pass 1

### To fix

#### 1. Opening a Pokémon also downloads all its forms

`lib/src/4_repository/repositories/pokemon_repository_impl.dart:86-133`

- **What this is:** `getPokemon` builds the form list. For each sibling form it downloads the full `/pokemon/{form}` payload.
- **Problem:** The detail screen waits for every form before it shows anything. Charizard needs 3 extra full payloads. If one request hangs, the screen waits up to 15 s although the Pokémon itself has arrived. The form types are only used by the chips in `alternate_forms_widget.dart:209-218`.
- **Fix:** Remove the sibling fetch from `getPokemon`. Load the form types from the forms widget, after the first paint.
- **If we skip it:** Detail, comparison and teams stay slow on first load.
- **Outcome:** Fixed. `getPokemon` no longer downloads sibling forms; only its own form has types, and the new `PokemonFormDetailsCubit` loads the other forms' types for the chips after the first paint. The cubit is created again when the shown form changes.

#### 2. Reordering a team reloads every member

`lib/src/1_presentation/pages/teams/team_detail_page.dart:350-355`

- **What this is:** The team summary calls `_cubit.load` each time the member list changes.
- **Problem:** Moving one member puts all members back in loading and calls `getPokemon` for each one again, with the cost of finding 1. Sums and averages do not depend on the order.
- **Fix:** Reload only when the set of names changes, not when the order changes.
- **If we skip it:** Flicker and wasted work on every drag.
- **Outcome:** Fixed. `PokemonListCubit.load` keeps the result of every name still in the list and loads only new names, so a reorder or a removal makes no request.

#### 3. The cache can evict the Pokédex index

`lib/src/4_repository/datasources/implementations/hive_local_storage.dart:16`, `52-55`, `155-162`

- **What this is:** The cache keeps at most 100 entries and evicts the least recently used one.
- **Problem:** The index is read once and then kept in memory by the repository, so for the cache it is always the oldest entry. After about 100 other URLs it is removed from disk, and the next offline start cannot show the Pokédex. The access order is also reset on every restart: `lastAccessedAt` is written but never read (line 22).
- **Fix:** See finding 13.
- **If we skip it:** Offline mode works only after light browsing.
- **Outcome:** Fixed. The index is written with `evictable: false`, `HiveLocalStorage` stores a `pinned` flag and never evicts pinned keys, and the unused `lastAccessedAt` key is gone.

#### 4. A failed refresh looks like a success

`lib/src/2_application/bloc/pokedex_bloc/pokedex_bloc.dart:133-151`, `lib/src/1_presentation/pages/pokedex_browse/pokedex_browse_page.dart:261-289`

- **What this is:** The pull-to-refresh of the Pokédex and the "offline" banner.
- **Problem:** Offline with a cached copy, `PokeApiCache` returns the old copy and the repository drops `isStale`, so the user sees no notice. The banner can never appear: `failure` is only set together with status `failure`, and that status does not build `_CatalogView`. No test covers the banner.
- **Fix:** Carry the index `isStale` flag to the bloc state and show the banner from it.
- **If we skip it:** Old data is shown as fresh, and about 28 lines of UI are dead.
- **Outcome:** Fixed. `getPokemonIndex` returns a `PokemonIndex` record with `isStale`, `PokedexState.isStale` carries it, and the offline banner shows when it is true.

#### 5. Screen reader labels in English inside the Italian UI

`lib/src/1_presentation/pages/teams/team_detail_page.dart:579`, `lib/src/1_presentation/pages/detail/tabs/detail_stats_tab.dart:120`, `lib/src/1_presentation/widgets/detail/compact_stat_row.dart:60`

- **What this is:** The `Semantics` labels of the stat rows.
- **Problem:** They contain hand-written `sum`, `average`, `min` and `max`. This breaks the repo rule "no user-visible literal in Dart".
- **Fix:** Three ARB keys with placeholders.
- **If we skip it:** TalkBack and VoiceOver read English words in the Italian UI.
- **Outcome:** Fixed. Two new ARB strings with placeholders (`statRangeSemantics`, `teamStatSumAverageSemantics`) replace the English words in the three labels.

### To improve

#### 6. Four identical cubits

`lib/src/2_application/bloc/{species,evolution,ability_detail,move_detail}_cubit/` (262 lines)

- **What this is:** Four cubits with the same flow: load, then loaded or error.
- **Problem:** They must change together. They log without `prefix: _prefix` (`species_cubit.dart:18,24`), against the logging convention. The `Error` state carries both a `message` and a nullable `failure`.
- **Fix:** One generic load cubit with one sealed state, like `PokemonLoad`.
- **If we skip it:** Four places to touch for each change.
- **Outcome:** Fixed. One `LoadCubit<T>` with a sealed `LoadState<T>` replaces the four cubits; the factory functions keep their names, logging uses a prefix, and the state holds only the failure.

#### 7. Duplicated search rules

`lib/src/3_domain/helpers/index_suggestions_filter.dart:15-50`, `lib/src/3_domain/helpers/pokemon_index_filter_helper.dart:72-100` and `139-147`

- **What this is:** The name and id match, the keywords (`mega`, `alola`, …) and the sort by species.
- **Problem:** They are copied in two files. A new region or keyword must be added in both, or suggestions and grid disagree.
- **Fix:** Extract `matchesQuery(entry, query)` and the comparator, and use them in both.
- **If we skip it:** The first place where an inconsistency bug will appear.
- **Outcome:** Fixed. `PokemonIndexFilterHelper.matchesQuery` and `compareBySpecies` hold the rules, and the suggestions filter uses them.

#### 8. `selectedFormDetails` is redundant state

`lib/src/2_application/bloc/detail_bloc/detail_state.dart:46`, `detail_bloc.dart:89,162,201`

- **What this is:** A field of the detail success state.
- **Problem:** Every write is `PokemonFormDetails.fromPokemon(pokemon)`, so the value can always be derived from `pokemon`.
- **Fix:** Delete the field and keep only the `formDetails` getter.
- **If we skip it:** Two sources of truth to keep aligned.
- **Outcome:** Fixed. The field, its `copyWith` parameter and its props entry are gone; `formDetails` is derived from `pokemon`.

#### 9. Copied UI actions

`lib/src/1_presentation/pages/detail/detail_page.dart:190` and `lib/src/1_presentation/widgets/pokedex/pokemon_card.dart:42`; `detail_page.dart:179` and `lib/src/1_presentation/pages/comparison/comparison_page.dart:132`

- **What this is:** `_toggleComparison` with its snackbars, and the copy of the link to the clipboard.
- **Problem:** The same code lives in two places each.
- **Fix:** One shared function for each.
- **If we skip it:** A text or a behavior changes in one place only.
- **Outcome:** Fixed. `toggleComparison` and `copyPokemonLink` in `1_presentation/helpers/` replace the copies.

#### 10. Code used only by tests, or never read

- **What this is:** `FavoritesCubit.clearFavorites` (`favorites_cubit.dart:112`), `kSupportedPlatforms` (`mobile_storage_initializer.dart:9`), `buildPokemonShareUri` and `parsePokemonShareLink` (`pokemon_share_link.dart:24,37`), the `queryParameters` and `timeout` parameters of `ApiClient.get`, `ApiException.responseBody`.
- **Problem:** No caller in `lib/`. `responseBody` is written but never read.
- **Fix:** Delete them with their tests (see finding 12 for the share helpers).
- **If we skip it:** Code and tests to maintain for nothing.
- **Outcome:** Fixed. Deleted with their tests, except `buildPokemonShareUri`, which finding 12 uses.

#### 11. Repo conventions not followed in three pages

- **What this is:** `_TeamNotFoundView` and `_TeamEmptyMembersView` (`team_detail_page.dart:141-263`), the section titles in `about_page.dart:155-254`, and the size of some files.
- **Problem:** The two views have their own layout instead of `EmptyStateView`. The titles are four repeated `Text` widgets instead of `SectionTitle`. `team_detail_page.dart` has 618 lines, `evolution_chain_widget.dart` 459 and `detail_info_tab.dart` 444, against the limit of about 400.
- **Fix:** Use the two shared widgets. Move `_TeamSummarySection` to its own file.
- **If we skip it:** The exceptions become the pattern that is copied.
- **Outcome:** Fixed. `_TeamNotFoundView` and the route error page use `EmptyStateView`; the Azurill image stays as a stack overlay on the error page. `_TeamEmptyMembersView` is left: `EmptyStateView` holds its own scroll view and cannot sit inside the page's scrolling column. `TeamSummarySection` has its own file. The other long files are not split.

### To confirm

#### 12. "Copy link" copies a path, not a link

`lib/src/1_presentation/pages/detail/detail_page.dart:180`

- **What this is:** The share action of the detail and comparison screens.
- **Problem:** The clipboard gets `/pokemon/pikachu`, which opens nothing. The `pokefinder://` scheme is registered on Android and iOS and `buildPokemonShareUri` exists, but it is not used. The tests assert `/pokemon/pikachu`, so this may be on purpose.
- **Fix:** If it is not on purpose, one line: copy `buildPokemonShareUri(...)`.
- **If we skip it:** The message "Link copied" promises more than it does.
- **Outcome:** Fixed. "Copy link" copies `buildPokemonShareUri(...)` (for example `pokefinder:///pokemon/pikachu`) on the detail screen and in the comparison slot.

#### 13. How to solve finding 3

- **What this is:** The choice of the entry limit and of the Hive box type.
- **Problem:** A higher limit alone is not enough: `Hive.openBox` loads every value in memory, and each `/pokemon` payload is hundreds of KB.
- **Fix:** Recommended: a `LazyBox` plus a higher limit. The smallest alternative: never evict the index.
- **If we skip it:** Finding 3 stays open.
- **Outcome:** Decided: the index is pinned and never evicted (see finding 3). No LazyBox.

#### 14. No disk cache for images

- **What this is:** 9 `Image.network` calls with no persistent cache.
- **Problem:** Offline, the grid and the teams have no sprites although the data is cached.
- **Fix:** It needs a new dependency, so the decision is the owner's.
- **If we skip it:** Offline mode stays "text only".
- **Outcome:** Open. It needs a new dependency, so the owner decides.

### Minor

#### 15. English fallbacks in the evolution trigger formatter

`lib/src/1_presentation/helpers/evolution_trigger_formatter.dart`

- **What this is:** The optional `l10n` parameter with about 40 English fallback strings.
- **Problem:** The two callers in `lib/` always pass `l10n`. Only the tests use the fallbacks.
- **Fix:** Make the parameter required and delete the fallbacks.
- **If we skip it:** A second string table to keep aligned with the ARB files.
- **Outcome:** Fixed. `l10n` is a required parameter and the English fallbacks are gone.

#### 16. Small repetitions in the data layer

- **What this is:** `_formsFor` (`pokemon_repository_impl.dart:71-76`), the `_officialArtworkUrl` wrapper (line 18), `readEntry` in `hive_local_storage.dart:73-118`, and the comment in `presentation_bloc_factory.dart:73`.
- **Problem:** `_formsFor` computes the types that `_catalogFormsFor` computes again. The wrapper only forwards its arguments. The "remove and delete" block is repeated five times. The comment says the cry controller is "shared", but it is `@Injectable`, so each call gives a new instance.
- **Fix:** Remove the duplicates and correct the comment.
- **If we skip it:** No effect for the user.
- **Outcome:** Fixed. Types are computed once, the wrapper is gone, `readEntry` uses one `_discard` helper, and the comment says each call creates a new controller.

### Checked and correct

- Layer dependencies point inward, there is no `getIt` outside the factory, and the domain does not import Flutter.
- `_toFailure` is the only place that maps errors, and the switches on failures are exhaustive.
- The `fromJson` of the hydrated cubits drops a corrupt record and keeps the rest.
- The handling of superseded requests (`restartable` plus generation counters) is consistent in detail, Pokédex, comparison and audio.
- The epoch of `PokeApiCache.clear()` and the min/max stat formulas are correct.
- The `INTERNET` permission is in the main manifest, and `untranslated_messages.txt` is `{}`.

## Pass 2

A second full pass on the same commit. It covers the files that pass 1 read only in part or skipped: the form classifier, the entities, the raw models, the mock repository, the translation helper, the theme, the detail tabs and widgets, the matchup, favorites and settings pages, the scripts, the CI workflow and the native config. Only findings that are not in pass 1 are listed. The numbering continues.

Findings 17, 19 and 20 come from reading the code and from how Flutter works. They were not reproduced on a device.

### To fix

#### 17. Species with a hyphen in the name are shown wrong on the detail screen

`lib/src/1_presentation/extensions/form_name_formatter.dart:10-31`, used by `detail_header.dart:41`, `alternate_forms_widget.dart:73` and `form_selection_bottom_sheet.dart:232`

- **What this is:** `formatFormName` splits the name at the first hyphen and shows `Base - Modifier`.
- **Problem:** It treats every hyphen as a form separator. `mr-mime` becomes "Mr - Mime", `ho-oh` "Ho - Oh", `tapu-koko` "Tapu - Koko", `iron-valiant` "Iron - Valiant". The Pokédex card uses `PokemonFormClassifier.formatDisplayName` and shows "Mr. Mime", so the same Pokémon has two names. A Mega is "Charizard - Mega X" on the detail screen and "Mega Charizard X" on the card. No test covers these names.
- **Fix:** Use the one formatter everywhere: `context.translatePokemonIndexEntry(summary.toIndexEntry())`. Then delete `formatFormName`.
- **If we skip it:** About 40 species and every form have a wrong or inconsistent title.
- **Outcome:** Fixed. `translatePokemonName` (next to `translatePokemonIndexEntry`) gives the Pokédex card name to the detail header, the forms list and the form sheet; `formatFormName` and its ARB key are deleted.

#### 18. A new species above id 1025 is treated as an alternate form

`lib/src/3_domain/helpers/pokemon_form_classifier.dart:15-25`, `34`, `70`; `lib/src/3_domain/entities/pokemon_index_entry.dart:77`

- **What this is:** The number 1025 (the last species today) is written in four places to tell a species from a form.
- **Problem:** When PokeAPI adds species 1026, `isAlternateForm` is true for it and `classifyCategory` returns `battleMode`. The default Pokédex filter (`canonicalOnly`) hides it, and its generation is 0.
- **Fix:** One constant. PokeAPI form ids start at 10001, so the test can be `id < 10000`. The generation table still needs one new line per generation.
- **If we skip it:** The next generation is missing from the grid until someone finds the four places.
- **Outcome:** Fixed. One constant `kFirstFormId` (10001) replaces the three `1025` checks; `resolveGeneration` keeps its table.

#### 19. The detail tabs lose their state when the user changes tab

`lib/src/1_presentation/pages/detail/tabs/detail_info_tab.dart:30-31`, `lib/src/1_presentation/widgets/detail/evolution_chain_widget.dart:35-36`, `lib/src/1_presentation/pages/detail/tabs/detail_moves_tab.dart:21-33`

- **What this is:** Each tab creates its own cubit inside the tab widget. `TabBarView` disposes a tab that is off screen, and no tab keeps itself alive.
- **Problem:** Info → Moves → Info creates a new `SpeciesCubit` and a new `EvolutionCubit`: the spinner shows again and the data is read and decoded again. Leaving the Moves tab drops the search text and the learn-method filter. Only the scroll offset survives, through `PageStorageKey`.
- **Fix:** Provide these cubits above the `TabBarView`, in `_DetailSuccessView`.
- **If we skip it:** Flicker on every tab change, and a filter the user must type again.
- **Outcome:** Fixed. Each detail tab is wrapped in a keep-alive widget. A widget test changes tab and comes back; it fails without the wrapper.

#### 20. The evolution chain does not highlight the current Pokémon for forms

`lib/src/1_presentation/pages/detail/tabs/detail_info_tab.dart:307`, `lib/src/1_presentation/widgets/detail/evolution_chain_widget.dart:152`, `193`, `208`, `230`

- **What this is:** The chain marks the node whose `speciesName` equals `currentPokemonName`.
- **Problem:** The tab passes `pokemon.name`, not the species name. For `giratina-altered`, `deoxys-normal`, `raichu-alola` or any Mega, no node matches, so nothing is highlighted.
- **Fix:** Pass `pokemon.speciesName`.
- **If we skip it:** The "you are here" mark is missing on every Pokémon whose name differs from its species.
- **Outcome:** Fixed. The info tab passes `pokemon.speciesName`, and the parameter is now `currentSpeciesName`.

#### 21. Nothing checks that the Italian ARB is complete

`.gitignore` (entry `untranslated_messages.txt`), `.github/workflows/ci.yml`

- **What this is:** `gen-l10n` writes the missing Italian keys to `untranslated_messages.txt`. The rule says the file must be `{}`.
- **Problem:** The file is gitignored, so the CI step "no uncommitted diff" cannot see it, and no test reads it. A key added only to `app_en.arb` shows English text in the Italian UI and CI stays green.
- **Fix:** One CI step after `gen-l10n` that fails when the file is not `{}`.
- **If we skip it:** The rule depends on someone remembering to look.
- **Outcome:** Fixed. A CI step after `gen-l10n` fails when `untranslated_messages.txt` is not `{}`.

### To improve

#### 22. A hard-coded form type table that only a fallback uses

`lib/src/3_domain/helpers/pokemon_form_classifier.dart:445-642`, `lib/src/4_repository/repositories/pokemon_repository_impl.dart:138-158`

- **What this is:** `resolveFormTypes`, about 190 lines of types for regional forms, Megas and Rotom.
- **Problem:** Its only caller is `_resourceFormsFor`, the fallback used when the catalog is not available. There the form is the Pokémon itself, and its real types are already in `raw.types`. The table can only repeat the API or replace it with an old value. It has no test.
- **Fix:** Delete the table and use the types of the response. After finding 1, `getFormDetails` (on the interface, but called only by the repository itself), `RawFormDetails` and its mock can go too.
- **If we skip it:** 190 lines of game data to keep correct by hand.
- **Outcome:** Fixed. The table is deleted; without the catalog the form list holds only the Pokémon itself, with its own types. `getFormDetails` stays for the forms cubit.

#### 23. Sealed states read with `if (state is …)` chains

`lib/src/1_presentation/widgets/detail/evolution_chain_widget.dart:50-121`, `move_detail_bottom_sheet.dart:61-110`, `ability_detail_bottom_sheet.dart`, `lib/src/1_presentation/pages/detail/widgets/form_selection_bottom_sheet.dart`

- **What this is:** Builders that test a sealed state with `if`/`else if` and end with `return const SizedBox.shrink()`.
- **Problem:** The repo rule asks for a Dart 3 `switch`. With the chain, a new state variant compiles and shows an empty widget.
- **Fix:** An exhaustive `switch (state)` with no default branch.
- **If we skip it:** The compiler cannot point at the places to update.
- **Outcome:** Fixed. The load sheets and the evolution section read `LoadState` with an exhaustive `switch`; the form sheet and the forms list use a record pattern and a `case`.

#### 24. Five hand-built "error with retry" blocks

`detail_info_tab.dart:377-412`, `detail_items_games_tab.dart:125-153`, `evolution_chain_widget.dart:63-95`, `move_detail_bottom_sheet.dart:73-105`, `ability_detail_bottom_sheet.dart`

- **What this is:** An error icon, the failure message and a retry button.
- **Problem:** Each place builds it again with a different layout, button type and text style.
- **Fix:** One shared widget that takes the message and `onRetry`.
- **If we skip it:** The same error looks different in each section.
- **Outcome:** Fixed. `FailureRetryCard` replaces the five hand-built error blocks.

#### 25. Three game-version tables that are not aligned

`lib/src/3_domain/helpers/game_version_mappings.dart:5-37`, `lib/l10n/translation_helper.dart:86-143`, `lib/src/1_presentation/widgets/detail/game_version_color.dart`

- **What this is:** The list of versions and groups, their localized names, and their colors.
- **Problem:** `brilliant-diamond`, `shining-pearl` and the group `brilliant-diamond-and-shining-pearl` are in the first table but not in `_gameNames`, so the Italian UI shows "Brilliant Diamond". The color table has no entry for Let's Go, Legends Arceus, the Diamond and Pearl remakes and the DLCs: they are grey.
- **Fix:** Add the missing ARB keys. Add one test: every version and group of `GameVersionMappings` has a name.
- **If we skip it:** Each new game needs three edits, and a missing one is silent.
- **Outcome:** Fixed. `GameVersionMappings` and `_gameNames` match the live API version groups (DLC groups, `brilliant-diamond-shining-pearl`, Japanese groups, Legends: Z-A, Mega Dimension, Champions), with a test that every version and group has a name. Colors are unchanged.

#### 26. More places that skip the shared widgets

- **What this is:** The seven section headings of `settings_page.dart` (from line 88), the layout of `route_error_page.dart`, the title of the evolution section (`evolution_chain_widget.dart:40-46`), the clear button of the Pokédex search (`pokedex_browse_page.dart:138`), and the confirm button of `team_name_dialog.dart:84`.
- **Problem:** The headings repeat one hand-built `Text` style and do not have the `Semantics(header: true)` that `SectionTitle` gives. The route error page does not use `EmptyStateView`. The clear button is an icon-only button with no tooltip. The team dialog uses `ElevatedButton` while `confirmation_dialog.dart` uses `FilledButton`.
- **Fix:** Use `SectionTitle` and `EmptyStateView`, add the tooltip, use one button type in dialogs.
- **If we skip it:** Same as finding 11.
- **Outcome:** Fixed. Headings of the settings, about and evolution sections use `SectionTitle`, the route error page uses `EmptyStateView`, the Pokédex clear button has a tooltip, and the team dialog uses `FilledButton`.

#### 27. More code that nothing uses

- **What this is:** `filterPrefixSuggestions` (`prefix_suggestions_filter.dart`, exported at `domain.dart:30`), `CryPlaybackState.hasError`, `CacheEntry.isStale` and `CacheEntry.schemaVersion`, `RawChainLink.isBaby`, the `toJson` of every raw model, and the ARB keys `order`, `filter` and `apply`.
- **Problem:** Only tests call the first three, or nothing does. The raw models are only parsed, so the generated `toJson` code is unused.
- **Fix:** Delete them with their tests. Set `createToJson: false` on the raw models.
- **If we skip it:** Same as finding 10.
- **Outcome:** Fixed. Deleted with their tests; raw models use `createToJson: false`.

### To confirm

#### 28. Form names are localized in the domain, against the policy

`lib/src/3_domain/helpers/pokemon_form_classifier.dart:155-207` and `385-428`, `lib/src/3_domain/entities/pokemon_index_entry.dart:151-175`

- **What this is:** `formatDisplayName` picks Italian strings with an `isIt` flag ("Archeo", "di Alola", "Rotom (Lavaggio)"). `formBadgeText` returns `PRIMAL`, `REGIONAL`, `SPECIAL` and `FORM`.
- **Problem:** `docs/localization_policy.md` says form names stay canonical, but the code translates them, and it does so outside the ARB files. The badge words are category labels in English: they are shown on the card and read by the screen reader in the Italian UI.
- **Fix:** Decide which one is right. Then either update the policy, or move these strings to ARB.
- **If we skip it:** The policy and the code keep saying different things.
- **Outcome:** Decided: the code is right, the policy was out of date. Policy updated; "Giratina (Origine)" corrected to "Originale".

#### 29. Only the first evolution trigger is shown

`lib/src/1_presentation/widgets/detail/evolution_chain_widget.dart:214`, `245`

- **What this is:** The arrow between two stages shows `triggers.firstOrNull`.
- **Problem:** PokeAPI lists several `evolution_details` when a species can evolve in more than one way. The other ways are dropped.
- **Fix:** If this is not on purpose, show every trigger, for example in the trigger sheet.
- **If we skip it:** The evolution data is incomplete for those species.
- **Outcome:** No change. Checked on the live API: 60 of 485 links have several entries, and most are per-game variants of the same method, not alternatives. Showing the first entry stays.

#### 30. One null field can make a whole Pokémon unreadable

`lib/src/4_repository/models/raw_pokemon/attributes/cries.dart:10`, `lib/src/4_repository/models/raw_pokemon/raw_pokemon.dart`

- **What this is:** `RawPokemon` needs a non-null `cries.latest`, `species` and `location_area_encounters`.
- **Problem:** If PokeAPI returns `null` for the cry of one form, parsing throws and the detail screen shows "invalid response". This was not checked against the live API: no external call was made in this review.
- **Fix:** Make `latest` nullable and map it to `''`. The UI already handles an empty cry (`cry_play_button.dart:13`).
- **If we skip it:** One missing optional value hides all the other data.
- **Outcome:** No change. Checked on 331 live resources (all ids above 10000, ids 1000-1025 and a sample): `cries.latest`, `species` and `location_area_encounters` were never null.

#### 31. A dependency for one spinner

`lib/src/1_presentation/pages/detail/_loading.dart:17`

- **What this is:** `flutter_spinkit`, used once for the detail loading animation.
- **Problem:** Every other loading state uses `CircularProgressIndicator`.
- **Fix:** If the hourglass is not a design choice, use the Material indicator and remove the dependency.
- **If we skip it:** One more package to keep up to date.
- **Outcome:** No change. The hourglass is kept as a design choice.

### Minor

#### 32. Small duplicates and gaps

- **What this is:** `PokemonIndexEntry.displayName` and `getDisplayName()` (`pokemon_index_entry.dart:129-148`), `_formatCosmeticName` (`pokemon_form_classifier.dart:431-441`), `PokemonIndexEntry.officialArtworkUrl` (line 84), the doc comment above `_isCosmetic` (lines 303-306), the selection clean-up of `matchup_page.dart:15-27`, `50-54` and `61-65`, and `scripts/verify.sh`.
- **Problem:** The first getter is the second one with its default. `_formatCosmeticName` is a copy of the end of `_formatBattleModeName` and ignores its `isItalian` parameter. The artwork URL is written by hand although `PokeApiUrlHelper.officialArtworkUrl` exists. The doc comment describes `hasRealForm`, not `_isCosmetic`. The matchup page filters the same list three times. `verify.sh` runs `flutter analyze` without `--fatal-infos`, so it passes where CI fails.
- **Fix:** Remove the copies, correct the comment, add the flag to `verify.sh`.
- **If we skip it:** No effect for the user.
- **Outcome:** Fixed for the entry, classifier and `verify.sh` parts: `displayName` calls `getDisplayName()`, cosmetic and battle-mode names share one helper, the artwork URL uses `PokeApiUrlHelper`, the doc comments are correct, and `verify.sh` runs `--fatal-infos`. The matchup page normalises its initial selection in one private function.

### Checked and correct

- No test is skipped, and every test file has at least one assertion per test.
- Widget tests use the shared `pumpApp` helper. The few direct `MaterialApp` uses are for the startup error app and for one error builder.
- The type chart, `dualEffectiveness` and the matchup grouping are consistent.
- `PokemonSummary`, `FavoritePokemon`, `RecentPokemon` and `PokemonTeam` read old and partial JSON without throwing on optional fields.
- `scripts/post_build.dart` refuses a dirty worktree and an existing tag before it pushes.
- The CI workflow runs format, analyze with `--fatal-infos`, both code generators with a diff check, tests with the 70% coverage gate, and a release build.
- The Android manifest and `Info.plist` declare only the `pokefinder` scheme and the `INTERNET` permission.

### Not checked

- The app was not run on a device or emulator in either pass.
- Findings 25, 29 and 30 were later checked against the live PokeAPI (see their outcomes). The other findings were not.
- The translation databases (`lib/l10n/*_db.dart`), `canonical_species_data.dart` and `mega_evolution_data.dart` were not checked entry by entry.
- The Xcode project, the Gradle scripts and the signing setup were read only for the points listed above.
- Test quality was sampled with counts and searches. The test bodies were not read one by one.

## After the fixes

An independent verification read the whole diff after the fixes. It found one regression and a few gaps, all fixed in the same change:

- The type chips of the forms list were lost after a form switch. The forms cubit is now keyed by the shown Pokémon, with a widget test.
- A pinned cache entry could be evicted after a restart, before it was read once. Eviction now reads the pinned flag from the stored envelope.
- The keep-alive test passed without the wrapper, because a focused text field keeps its page alive. The test now removes the focus first.
- `RawPokemon.forms` and the `-unknown` form filter had no reader left and are deleted. The offline banner has a widget test.

Checks on the final tree: format, `flutter analyze --fatal-infos` and `flutter test` pass.

Still open:

- Finding 14 (disk cache for images) waits for a decision on a new dependency.
- The UI changes were not checked on a device: the shared headings in settings and about, the shared error card, the route error page, and the form chips that load after the first paint.
- `LoadCubit` has no guard for an empty URL or name. The old species and move cubits returned early in that case. No caller passes an empty value today.
- The badges `SPECIAL`, `FORM` and `REGIONAL` stay in English in the Italian UI, as the localization policy allows.
