# PokeFinder — Code & UI Review

Date: 2026-09-25 · Commit reviewed: `7ba359a` (main)

## Status: the refactor is implemented — what is left is verification

All items below have been implemented in `lib/`. The work was done across two sessions; the
first one ran out of context mid-way and left the test suite un-migrated.

**Read this first if you are continuing the work.** Current state of the tree:

- `lib/` is complete and `fvm flutter analyze` is clean. Do not redo these items.
- The full remediation is on `main` in the commits after `7ba359a`; `fb762f2` is a
  checkpoint of the first session's work in progress.
- `README.md`, `docs/ai/context.md` and `docs/ai/skills/` have been updated to the new
  architecture, so they no longer describe use cases, `DataRepository`,
  `PokemonRemoteDataSource` or `CancellationToken`.
- **Only the test suite needed migrating to the new APIs.** `test/` was rewritten to
  `PokemonSummary`, `PokedexFilters`, `PokeApiCache`, `AppRoutes`, `PokemonDetailPage`,
  `PokemonSprites` and the simplified widgets. The tests of removed code were deleted, not
  rewritten, per O16.

Still open, and the only real work left:

| Item | What is left |
|---|---|
| **O11** | Not started. The `dev` flavor, `MockPokemonRepository` and `Environment.dev` still exist. Either delete them or keep them and close the item. |
| **O16** | Only partially: the tests of deleted code are gone, but the suite is still large relative to the app. Re-measure before touching it. |
| **Device pass** | The visual items (A1–A11, B3, B7, B11, B12) were implemented from code, **not re-checked on the emulator**. Run the `verifying-ui-on-device` skill over the detail page, Home, the Pokédex grid, the drawer, the empty states and the filter sheet, in light and dark mode, before calling the visual work done. |
| **M3 residue** | 24 `Colors.*` literals remain in `widgets/detail/game_version_color.dart`. They are per-game brand colors (data, not theme), so this is an accepted exception rather than an oversight. |

Verified state of the two baseline gates, after the test migration:

```
fvm flutter analyze      # no issues
fvm flutter test         # all tests pass
```

---

This document is a work list for an agent. Each item has:

- **Where**: file and line (lines refer to commit `7ba359a`, i.e. **before** the refactor —
  most of them no longer point at the current code)
- **Problem**: what is wrong
- **Fix**: what to do
- **Verify**: how to check the fix

The app was run on the Pixel 7 Pro emulator (`--flavor prod`, Italian locale, light and dark theme).
Items marked **[device]** were seen on the emulator. Items marked **[code]** come from reading the code only.

Baseline before any change: `fvm flutter analyze` → no issues, `fvm flutter test` → 707 tests pass.
Keep both green after every step.

---

## 0. What is already good (do not break it)

- Layer direction (presentation → application → domain ← repository) is respected.
- `PokemonFailure` is a sealed class and switches on it are exhaustive.
- Accessibility work is real: semantics labels, 48 dp targets, text-scale handling.
- l10n with ARB files, no hard-coded Italian strings in widgets (few exceptions listed below).
- Analyzer is clean and the test suite is fast (~45 s).

---

## 1. Bugs

### B1. Pokédex type filter shows "No Pokémon found" and reacts after ~10 s [device]

- **Where**:
  - `lib/src/2_application/bloc/pokedex_bloc/pokedex_bloc.dart:182-244`
  - `lib/src/3_domain/helpers/pokemon_index_filter_helper.dart:114-127`
  - `lib/src/1_presentation/pages/pokedex_browse/pokedex_browse_page.dart:238-241`
- **Problem**:
  - The index entries have no types. The type filter needs `getPokemonIdsForType` to finish.
  - The handler awaits the network call _before_ it emits the new selection. On a slow network the chip stays unselected for many seconds, with no loading feedback.
  - When the call fails, `typeFailure` goes into `state.failure`, but the selection is kept. The filter helper then returns `false` for every entry (line 125-127), so the grid shows the "no Pokémon found" empty state. The failure is never shown: the empty view ignores `state.failure`.
  - The handler has no transformer, so two quick taps run at the same time. Both read the same `state.selectedTypes`, so one update is lost.
  - On the emulator, "Fire" alone and "Water" alone both gave zero results. The same session also showed request timeouts on the detail page, so the root cause is probably a failed or timed-out type request. The bug is that this failure is invisible and looks like "no results".
- **Fix**:
  1. Emit the new selection right away, with a `loadingTypes` flag (or a set of loading types). Show a small progress indicator on the chip or under the search bar.
  2. On failure: remove the type from the selection again, and show a SnackBar with `failure.localizedMessage`.
  3. Use `sequential()` from `bloc_concurrency` for `PokedexTypeFilterToggledEvent`.
- **Verify**: Add a bloc test where `getPokemonIdsForType` fails. Expect the type to be removed from the selection and the failure to be exposed. On the device, select "Fire": the grid shows fire Pokémon, or an error message if offline.

### B2. Detail side effects run on every success emission [code]

- **Where**: `lib/src/1_presentation/pages/detail/detail_page.dart:176-220`
- **Problem**: The `BlocListener` has no `listenWhen`. `PokemonBloc` emits `PokemonBlocSuccess` several times for the same Pokémon: first data, encounters loaded, form loading, form loaded, and form failure cleared. Each emission:
  - plays the cry again when "auto-play cry" is on,
  - calls `addRecentPokemon` again (and, after a form change, stores the form sprite and types).
- **Fix**: `listenWhen: (prev, curr) => curr is PokemonBlocSuccess && (prev is! PokemonBlocSuccess || prev.pokemon.id != curr.pokemon.id)`.
- **Verify**: Add a widget test with auto-play on: emit success, then success with encounters. Expect `play` to be called once. On the device, turn on auto-play in Settings, open a Pokémon, and check that the cry plays once.

### B3. Detail app bar icons are always white [device]

- **Where**: `detail_page.dart:283` passes `Colors.transparent`. `pages/detail/_app_bar.dart:34` calls `contrastingTextColor(backgroundColor)`.
- **Problem**: A transparent color has luminance 0, so icons and the title are always white. On light type backgrounds (Electric, Normal, Fairy, Ice) you get white icons on yellow or pink, while the Pokémon name below is black.
- **Fix**: Pass the real `typeColor`, or the computed `textColor`, to `DetailAppBar`, and use it for `itemsColor`.
- **Verify**: Open Pikachu: the back arrow, the icons and "Dettagli" are black like the name.

### B4. Drawer shows "Cache size: 0 B" and has a race when clearing [device]

- **Where**: `lib/src/1_presentation/pages/home/_drawer.dart:16-28, 37-40`
- **Problem**:
  - The drawer reads `cacheSizeBytes` but never refreshes it. Only `SettingsPage.initState` does. The drawer showed 0 B while Settings showed 512.2 KB.
  - "Clear cache" in the drawer sends `HomeBloc.ClearCacheEvent` and at once calls `PreferencesCubit.refreshCacheSize()`. The refresh can run before the clear finishes. There are two clear-cache code paths (`HomeBloc` and `PreferencesCubit`).
- **Fix**: Remove the cache block and the language block from the drawer (Settings already has both, see A8). Delete `ClearCacheEvent`, `cacheCleared` and `ClearCacheUseCase` from `HomeBloc`, and the SnackBar branch in `home_page.dart:72-78`.
- **Verify**: The drawer has navigation only. Clearing the cache in Settings updates the size.

### B5. Back on Home, suggestions and keyboard reopen and cover the buttons [device]

- **Where**: `lib/src/1_presentation/pages/home/home_page.dart:42-50, 79-98`
- **Problem**: The search field keeps focus when you open the detail page. When you come back, the field gets focus again: the keyboard and the suggestion overlay open and hide "Search" and "Browse Pokédex". This was seen 3 times.
- **Fix**: Call `_focusNode.unfocus()` in `_submitSearch` before you navigate. Also when a recent chip or card is tapped.
- **Verify**: Search "pikachu", open the detail, press back: no keyboard, no overlay.

### B6. Moves list order looks random in Italian [device]

- **Where**: `lib/src/2_application/bloc/detail_bloc/detail_moves_cubit.dart:189-195`
- **Problem**:
  - Moves are sorted by English API slug, but the list shows Italian names ("Incanto, Fossa, Ruggito" = charm, dig, growl).
  - The comparator is not consistent. Two level-up moves compare by level, any other pair compares by name. This is not a total order, so the result depends on the input order.
- **Fix**: Sort by (method group, level for level-up, display name). Keep the sorting in the cubit (the UI stays dumb). Pass it a small callable `MoveNameResolver` (a class that wraps `String Function(String slug)`, built in the presentation layer from the current locale), so the application layer no longer imports `l10n/moves_db.dart`.
- **Verify**: Unit test with mixed methods. Expect a stable order. On the device, the Italian list is alphabetical.

### B7. Error page: the Azurill image covers the "Edit search" button [device, dark theme]

- **Where**: `lib/src/1_presentation/pages/detail/failure.dart:91-101`
- **Problem**: The image is `Positioned(bottom: 0)` behind a semi-transparent `SurfaceCard`. On a phone it shows through the card and covers the second button. In dark mode the "Retry" `ElevatedButton` is dark on a dark card and is hard to see.
- **Fix**: Put the image in the `Column`, above the card (about 120 dp high, no opacity trick). Use `FilledButton` for Retry.
- **Verify**: Turn off the network, open a Pokémon: the image, message and both buttons do not overlap, in light and dark mode.

### B8. Loading detail has no way back [device]

- **Where**: `lib/src/1_presentation/pages/detail/_loading.dart`, `detail_page.dart:221-228`
- **Problem**: While loading, the page has no app bar and no back button. With a 15 s timeout, the user sees only an hourglass.
- **Fix**: Keep a plain `AppBar` (back button only) on the loading and failure states.
- **Verify**: The loading page shows a back arrow.

### B9. `pikachu-alola-cap` has the "ALOLA" regional badge [device]

- **Where**: `lib/src/3_domain/helpers/pokemon_form_classifier.dart` (regional matching)
- **Problem**: Cap Pikachu forms (`-alola-cap`, `-hoenn-cap`, …) are costumes, not regional forms. The home suggestions show them as ALOLA.
- **Fix**: Classify `pikachu-*-cap` (and the other Pikachu costume forms) as `cosmetic` before regional matching.
- **Verify**: Unit test in `pokemon_form_classifier_test.dart`. Typing "pika" shows no ALOLA badge on the cap form.

### B10. Filter sheet: "Apply" does not apply, and the close icon is almost invisible [device]

- **Where**: `lib/src/1_presentation/widgets/pokedex/pokedex_filter_bottom_sheet.dart:112-123, 406`
- **Problem**: Filters apply live. "Applica" only closes the sheet, the same as the X. The X is very light on the pink sheet.
- **Fix**: Keep one close action. Either rename the bottom button to "Show N results" and remove the X, or remove the bottom button. Use the default icon color for the X.
- **Verify**: The sheet has one clear way to close. The label matches the behavior.

### B11. The type chip in the detail header is not aligned with the name [device]

- **Where**: `lib/src/1_presentation/pages/detail/widgets/detail_header.dart:63-68`
- **Problem**: `Center` inside the `Wrap` child grows to the full column width. The chip is centered in the left column and starts about 44 dp to the right of the name.
- **Fix**: Replace `ConstrainedBox + Center` with `Align(alignment: Alignment.centerLeft, widthFactor: 1)`, or put the 48 dp constraint on the `InkWell` only.
- **Verify**: The left edge of the chip lines up with the left edge of the name.

### B12. Matchup chips jump rows when selected [device]

- **Where**: `lib/src/1_presentation/pages/matchups/matchup_page.dart` (defending type chips)
- **Problem**: The selected chip gets a check mark and grows, so the chips after it move to other rows.
- **Fix**: `showCheckmark: false` and mark the selection with the border or fill only.
- **Verify**: Selecting "Ice" does not move the other chips.

### B13. The disabled "Search" button text cannot be read [device]

- **Where**: `home_page.dart:168-191`
- **Problem**: The label color is forced to white with `TextStyle(color: onBrandRed)`, so the disabled state shows white on light grey.
- **Fix**: Set `foregroundColor` in `ElevatedButton.styleFrom` (or `FilledButton`) and remove the color from the `Text`. The theme then handles the disabled state.
- **Verify**: With an empty field, the disabled label is readable grey.

### B14. Mixed-language and untranslated labels [device]

- `pages/detail/tabs/detail_items_games_tab.dart:228` / `lib/l10n/locations_db.dart`: "Percorso 2 (Kanto) south towards viridian city", "Giardino Trofeo Area". Only part of the name is translated. Translate the whole name or fall back to the full English name. Do not mix.
- `widgets/detail/type_image.dart` + `detail_header.dart:80-85`: PokeAPI type sprites contain English text ("ELECTRIC") in the Italian UI. Always use `TypeChip` (it has a localized label).
- `widgets/pokedex/pokemon_card.dart:366`: `'Gen $genNumber'` is hard-coded. Add an ARB key.
- `pages/detail/tabs/detail_info_tab.dart:307`: `'XP'` is hard-coded.

### B15. Comparison fires an extra network request per Pokémon [code]

- **Where**: `comparison_page.dart:56-60, 119-139` uses `PokemonBlocProvider`. `detail_bloc.dart:114-121` always loads encounters.
- **Problem**: Every compared Pokémon also downloads its encounters, which the comparison page never shows.
- **Fix**: See O6 (a comparison cubit that uses `getPokemon` only).

---

## 2. Visual / layout issues

### A1. Detail header does not collapse [device] — highest visual priority

- **Where**: `detail_page.dart:322-437`
- **Problem**: The header (name, type chip, sprite) uses about 45% of the screen and never shrinks. With the tab bar and the game-version bar, the Moves tab shows only 3 moves. Info and Items scroll in a small window.
- **Fix**: Use a `NestedScrollView` with a `SliverAppBar` (`expandedHeight` about 260, pinned) that holds the header. Put the `TabBar` in `SliverPersistentHeader` / `bottom`. Remove the separate landscape branch if the sliver layout works in both orientations.
- **Verify**: On Moves, scroll up: the header shrinks to a normal app bar and at least 8 moves are visible.

### A2. Two game-version selectors, one of them useless on Stats [device]

- **Where**: `detail_page.dart:489`, `tabs/detail_moves_tab.dart:80-131`
- **Problem**: The global "Versione gioco: Tutte le versioni" bar shows on every tab, also on Stats where it has no effect. On Moves, a second "Gioco: Diamante/Perla" dropdown appears below it. Moves can never show "all versions", so the two controls conflict. The default `'diamond-pearl'` is hard-coded in 2 places (`detail_moves_cubit.dart:81` and `detail_moves_tab.dart:274`).
- **Fix**: Keep one selector. Show it only on the tabs that use it (Info flavor text, Moves, Items). Moves uses the global selection. When "all" is selected, Moves uses the latest version group that the Pokémon has.
- **Verify**: The Stats tab has no version bar. Moves has one selector.

### A3. Two different reds, and app bars with no common style [device]

- **Where**: `lib/src/1_presentation/theme/app_palette.dart`, `pages/home/_app_bar.dart:11,19,27`, `pokedex_browse_page.dart:82-88`, `settings_page.dart:85-92`, `teams_list_page.dart`, `comparison_page.dart:27`, `matchup_page.dart`
- **Problem**:
  - `brandRed = Colors.red` (#F44336) is used for app bars, buttons and switches. `ColorScheme.fromSeed` makes a different, brownish primary, which is used for section titles, tab indicators, text buttons, chips and badges. Both reds appear on the same screen (Settings: brown titles and bright red switches).
  - Home, Pokédex, Settings and Teams have red app bars. Compare and Matchups have the default surface app bar.
  - `home/_app_bar.dart` uses `Colors.red` and `Colors.white` directly, not `AppPalette`.
  - In dark mode the bright red app bar on a near-black page is harsh.
- **Fix**:
  1. `ColorScheme.fromSeed(seedColor: brand, dynamicSchemeVariant: DynamicSchemeVariant.fidelity)`, so `primary` stays close to the brand red.
  2. Set `appBarTheme`, `filledButtonTheme`, `switchTheme`, `sliderTheme` once in `AppPalette.lightTheme/darkTheme`. Remove every local `backgroundColor: AppPalette.brandRed`, `activeTrackColor`, `activeColor`, `iconTheme` and `TextStyle(color: white)`.
  3. Pick one app bar style for all pages (all red or all surface).
- **Verify**: `grep -rn "brandRed\|Colors.red\b" lib/src/1_presentation` returns only the theme file. All top-level pages look the same.

### A4. Three different type palettes [device]

- **Where**: `widgets/detail/type_color_scheme.dart:10-33`, `widgets/detail/type_chip.dart`, `pages/matchups/matchup_page.dart` (pastel selector plus saturated result chips), `pokedex_filter_bottom_sheet.dart` (no colors), `pokemon_card.dart:436-466` (its own chip)
- **Problem**:
  - The matchup page shows pastel type chips at the top and saturated chips with mixed white or black text below.
  - The Pokédex filter chips have no type color.
  - Pokémon cards draw their own chip style.
  - `PokemonType.dark => Colors.black54` is translucent, so the result depends on what is behind it.
- **Fix**: One `PokemonType → Color` map (opaque colors). One `TypeChip` widget with `selected` / `compact` variants, used everywhere. Compute the text color once with `contrastingTextColor`.
- **Verify**: All type chips in the app share colors and shape.

### A5. Pokédex grid cards [device]

- **Where**: `widgets/pokedex/pokemon_card.dart`
- **Problem**:
  - Sprite sizes are very different (tiny Bulbasaur, huge Venusaur). The pixel art is scaled up and blurry.
  - The type "watermark" circle (line 264-275) is almost invisible and looks like a stain under the heart icon.
  - Three icon buttons (team, compare, favorite) plus long-press compare on every card make the grid busy.
  - Cards show no types, because index entries have none, so every card has the same accent.
- **Fix**:
  - Use the official artwork URL in a fixed square (for example 96×96) with `FilterQuality.medium`. Or keep the sprites with `FilterQuality.none` and a fixed scale.
  - Remove the watermark.
  - Keep only the favorite button on the card. Move team and compare into a long-press menu or into the detail page (both already exist there).
- **Verify**: The cards in a row have sprites of the same size and at most one icon.

### A6. Home screen [device]

- **Where**: `home_page.dart:131-237`, `widgets/home/pokeball_widget.dart`, `pages/home/_app_bar.dart:20-26`
- **Problem**:
  - The field is up to 400 dp wide, but the two buttons are 140 dp and have different widths. They look random under the field.
  - The decorative Poké Ball is one flat salmon color (both halves the same), so it does not read as a Poké Ball. When the recent shelf is shown, it is pushed off-screen.
  - The Pokédex can be opened 3 times from Home (app bar icon, big button, drawer).
- **Fix**:
  - Make both buttons the same width as the field (`SizedBox(width: double.infinity)` inside the 400 dp box). Use `FilledButton` + `OutlinedButton`.
  - Draw the ball with a red top, white bottom and dark band, or remove it when history is present.
  - Remove the app bar Pokédex action.
- **Verify**: Field and buttons have the same left and right edges.

### A7. Detail tabs and Info content [device]

- **Where**: `detail_page.dart:552-583`, `tabs/detail_info_tab.dart`, `tabs/detail_items_games_tab.dart:65-102`, `widgets/detail/sprite_gallery_widget.dart`
- **Problem**:
  - The 4 tabs are `isScrollable` + `TabAlignment.start`. They use 60% of the width and leave the right side empty. The labels are 11 sp.
  - The "Strumenti" (items) tab holds Species, Encounters, Held items and Game indices. The "Species" section only repeats the name in upper case.
  - The Info tab is very long: the sprite gallery adds about 12 tiles with very different image sizes. Labels wrap to 1 or 2 lines, so the rows do not line up.
  - The weight and height cards are 130 dp fixed with `spaceEvenly`, so they do not line up with the full-width cards below.
  - The header sprite has no placeholder: an empty area, then the image appears.
  - The ability chips, the cry buttons (seed red) and the form button (type color) use different accent systems on the same screen.
- **Fix**:
  - Fixed tabs (`isScrollable: false`) that fill the width.
  - Delete `_SpeciesSection`. Rename the tab to "Where to find" or similar.
  - Show the sprite gallery as a horizontal strip, or behind a "Show all sprites" row.
  - Put the weight and height cards in a `Row` of two `Expanded` children with the same horizontal padding as the cards below.
  - Add a placeholder (silhouette or progress) for the header sprite.
  - Use the type color as the only accent inside the detail card.
- **Verify**: Screenshots of each tab have no empty right half and aligned edges.

### A8. Drawer [device]

- **Where**: `pages/home/_drawer.dart:50-68, 128-201`
- **Problem**:
  - The header says "Settings" (Impostazioni), but the drawer is navigation. "Settings" is also one of the items.
  - The header left padding is `5% of screen width`, and the list tiles use 16 dp, so the edges do not line up.
  - A large red destructive "Clear cache" button sits at the bottom of a navigation drawer.
- **Fix**: Header "PokéFinder" with 16 dp padding. Navigation items only (see B4).
- **Verify**: The drawer shows the title and 6 items, with aligned left edges.

### A9. Empty states look different on every page [device]

- **Where**: `teams_list_page.dart` (red icon + filled red button), `comparison_page.dart:1008-1045` (outline icon + elevated button), `matchup_page.dart`, `pokedex_browse_page.dart:350-421`, `favorites_page.dart`
- **Fix**: One `EmptyStateView(icon, title, message, action)` widget in `widgets/`. Use it on all pages.
- **Verify**: The Teams, Compare, Favorites and Pokédex empty states look the same.

### A10. Hard-coded typography and small text [code]

- **Where**: 89 `fontSize:` literals in `lib/src/1_presentation`. Many are 9-11 sp (`pokemon_card.dart:325,462`, `detail_page.dart:568,572`, `pokedex_browse_page.dart:118,166`).
- **Problem**: Headings are 18, 20 or 24 sp in different tabs. Badge text at 9 sp is hard to read. The same section title style is copied about 10 times (`detail_info_tab.dart:235,290,375,430,528`, `detail_items_games_tab.dart:76,124,286,354`, `detail_stats_tab.dart:34`).
- **Fix**: Use `textTheme` roles (`titleMedium` for section titles, `labelSmall` minimum for badges). Add a small `SectionTitle` widget.
- **Verify**: `grep -c "fontSize:" -r lib/src/1_presentation` drops to a handful.

### A11. Smaller visual points [device]

- Recent shelf card: the "×" overlaps the "#025" corner (`widgets/home/recent_history_shelf.dart`). Give the id and the close button their own row, or move the close button outside the card.
- Pokédex offline banner: `Colors.orange.shade100` / `shade900` stays bright in dark mode (`pokedex_browse_page.dart:275-292`). Use `colorScheme.tertiaryContainer` / `onTertiaryContainer`.
- Pokédex app bar badges are hand-made with `Stack` + `Positioned` twice (`pokedex_browse_page.dart:95-126, 143-175`). Use Flutter's `Badge`.

---

## 3. Over-engineering (same behavior with much less code)

### O1. Pass-through use cases

- **Where**: `lib/src/3_domain/usecases/*.dart` (9 files)
- **Problem**: Each class has one line that calls the repository. They add no logic. They are not used everywhere: `HomeBloc` and `PokedexBloc` call `IPokemonRepository` directly, which contradicts the README ("every repository flow is fronted by a use case").
- **Fix (recommended)**: Delete all use cases and inject `IPokemonRepository` into the blocs and cubits. Update the README section "Bloc construction and use cases".
- **Verify**: Analyzer is clean, the tests pass after you update the mocks.

### O2. Data stack has too many layers, and errors are mapped twice

- **Where**: `DioApiClient` → `ApiClient` → `DataRepository` (`repositories/data_repository.dart`) → `RequestDeduplicator` → `PokemonRemoteDataSource` (`datasources/implementations/pokemon_remote_datasource.dart`) → `PokemonRepositoryImpl` → use case → bloc
- **Problem**:
  - Errors are mapped two times: `_mapError` (`pokemon_remote_datasource.dart:267-304`) and `_mapRepoError` (`pokemon_repository_impl.dart:484-493`). Every repository method has a second try/catch.
  - `FetchStrategy.networkOnly`, `DataRepository.invalidate`, `RequestDeduplicator.isInFlight/activeCount` are not used in `lib/`.
  - `CacheMetadata` has three overlapping booleans (`isFresh`, `isStale`, `fromCache`) and `cachedAt`. Only `isStale` is read.
  - The "remote" data source always goes through the cache.
  - The cache-epoch logic (`_cacheEpoch`, `_safePersist`) protects against a clear that runs during a write. This is very unlikely for a personal PokeAPI browser.
- **Fix**: Keep 2 pieces:
  1. `PokeApiCache` (or keep `DataRepository`): `Future<({T data, bool isStale})> get<T>(String url)`, cache-first with stale-if-error. Only `forceRefresh` for the index.
  2. `PokemonRepositoryImpl`: calls it, parses JSON into raw models, maps to entities, and maps errors in **one** `_toFailure(Object e)`.

  Delete `IPokemonRemoteDataSource`, `PokemonRemoteDataSource`, `FetchStrategy`, `CacheMetadata`, `DataResponse`, `DataFetchException`, and `RequestDeduplicator` if you drop request sharing. Keep it only if you can show a real double request.

- **Verify**: The detail, Pokédex and offline stale banner still work. The repository tests still cover error mapping.

### O3. Nine copy-paste fetch methods and hard-coded URLs

- **Where**: `pokemon_remote_datasource.dart:40-244`
- **Problem**: Each method repeats try / `fetchData` / `fromJson` / catch with the same `strategy` and `maxAge`. The base URLs are written 4 times (`:31, :140, :178, :233`), although `PokeApiUrlHelper` exists.
- **Fix**: One private `_get<T>(String url, T Function(Map<String, dynamic>) fromJson)`. Put the endpoint builders in `PokeApiUrlHelper`. This is part of O2 if you do O2.

### O4. Custom cancellation token [code, optional]

- **Where**: `lib/src/3_domain/cancellation_token.dart`, `_bridgeToDio` in `pokemon_repository_impl.dart:519-531`, 3 tokens in `detail_bloc.dart:50-60, 71-74, 114-115, 160-164, 215, 232`
- **Problem**: `restartable()` already drops stale results. The domain token + bridge + 3 tokens + "is cancelled" checks add a lot of branches to save a few HTTP bytes.
- **Fix**: Optional. Remove `CancellationToken` and all `cancelToken` parameters, and rely on `restartable()` + `emit.isDone`. If you keep it, do O2 first so the token goes through one layer only.

### O5. PokedexBloc repeats itself and paginates a list already in memory

- **Where**: `pokedex_bloc.dart`
- **Problem**:
  - `PokemonIndexFilterHelper.filterAndSort(...)` is called 8 times with the same 8 parameters (`:127, :161, :223, :256, :287, :318, :349, :376`).
  - "Pagination" (`visibleEntries`, `currentPage`, `pageSize`, `hasMore`, `PokedexLoadMoreEvent`, `droppable()`, the scroll listener in the page, the bottom spinner) slices a list that is already fully in memory. `SliverGrid` is already lazy.
  - A 40-line custom debounce transformer (`:18-57`).
- **Fix**:
  - Put the filter fields in one `PokedexFilters` value object with `copyWith`. One `_emitFiltered(emit, filters)` method.
  - Remove the pagination and render `filteredEntries` directly.
  - Debounce with `restartable()` + `await Future.delayed(duration)` at the start of the handler (or `stream_transform`'s `debounce`).
- **Verify**: The bloc tests for filters still pass. Delete the pagination tests. Scrolling the full Pokédex stays smooth.

### O6. Comparison page: 1079 lines for 2 columns

- **Where**: `lib/src/1_presentation/pages/comparison/comparison_page.dart`
- **Problem**:
  - Two nested `PokemonBlocProvider`s with `Builder` to capture both blocs.
  - Separate "single" and "dual" layouts.
  - The loading spinner block is copied 6 times, the failure + retry block 3 times.
  - `_DualIdentityColumn` (`:254-371`) duplicates `_ComparisonSlotSuccess` (`:832-934`).
- **Fix**: Let `ComparisonCubit` (or a small `ComparisonDetailsCubit`) load `Pokemon` for each entry with `getPokemon` (no encounters). Keep a `Map<int, AsyncValue>` of loading, failure or data. Build one layout with a nullable second slot. Target: under 350 lines.
- **Verify**: Widget tests for one entry, two entries, and one side failing.

### O7. Wrapper widgets and `map` on a sealed class

- **Where**: `detail_state.dart:7-26` (`map`), `pages/detail/_bloc.dart:28-59` (`PokemonBlocBuilder`), `pages/home/_bloc.dart:26-35` (`HomeBlocBuilder`)
- **Fix**: Delete them. Use `BlocBuilder` + a Dart 3 `switch` on the sealed state.

### O8. HomeBloc state flags

- **Where**: `home_bloc.dart`, `home_state.dart`, `home_page.dart:52-99`
- **Problem**:
  - `allPokemonNames` duplicates `pokemonIndex`.
  - `navigateToDetail` is a one-shot flag in the state, plus `NavigationDoneEvent`, plus a local `_isSubmitting`.
  - `copyWith` resets `failure` to null on every call, so it has different rules from `nameIndexFailure`.
  - `restartable()` on a synchronous handler has no effect.
- **Fix**: Keep validation in the bloc, but drop the flag pair. `SearchSubmitted(input)` validates with `PokemonName` and emits either `searchFailure` or a `pendingNavigation` value object (for example `SearchNavigation(nameOrId)`, compared by identity so two equal searches still emit). The page listens with `listenWhen: (p, c) => p.pendingNavigation != c.pendingNavigation` and navigates. Delete `allPokemonNames`, `NavigationDoneEvent`, the `_isSubmitting` field and the `restartable()` on the sync handler. Use one `copyWith` rule for both failure fields (the `_unset` sentinel).

### O9. Too many fields in `Pokemon`, and unused fields

- **Where**: `entities/pokemon.dart:6-45` (16 sprite fields), `entities/pokemon_species.dart`, `entities/ability_detail.dart`
- **Problem**: These fields are never read above the repository layer: `Pokemon.order`, `PokemonAbility.slot`, `PokemonEncounter.locationAreaName`, species `growthRate`, `genderRate`, `eggGroups`, `isBaby`, `isLegendary`, `isMythical`, and `AbilityDetail.shortEffects`.
- **Fix**: Group the sprite URLs in a `PokemonSprites` value object. Delete the unused fields and their mapping code.

### O10. Four almost identical "Pokémon summary" types

- **Where**: `FavoritePokemon`, `RecentPokemon`, `TeamMember` (`entities/pokemon_team.dart:26-38`), plus `PokemonIndexEntry(detailUrl: '')` built as a hack in `detail_page.dart:116-122, 143-148`
- **Problem**: They all have `{id, name, spriteUrl, types, timestamp}`. The "form types, else base types" list is written 4 times in `detail_page.dart` (`:104-113, :133-142, :183-192, :292-301`).
- **Fix**: One `PokemonSummary {id, name, spriteUrl, types}` (with the timestamp in the wrapper if needed) and one getter `PokemonBlocSuccess.summary`. Keep the JSON keys compatible, or add a small migration in `fromJson`, so stored favorites, history and teams still load.
- **Verify**: The hydrated JSON from the current version still loads (add a test with the old JSON).

### O11. Three ways to choose the mock repository

- **Where**: `lib/main.dart:15-18, 39-43`, `repositories/mock_pokemon_repository.dart` (337 lines)
- **Problem**: The `USE_MOCK` dart-define, the flavor, and the `environment` parameter all choose the DI environment.
- **Fix**: Keep the flavor only. If you never use `--flavor dev`, delete the mock repository and the dev environment.

### O12. `getAllPokemonNames` is dead code

- **Where**: `i_pokemon_repository.dart:36`, `pokemon_repository_impl.dart:291-298`, `mock_pokemon_repository.dart:187`, `i_pokemon_remote_datasource.dart:37`, `pokemon_remote_datasource.dart:165-169`, and its tests
- **Fix**: Delete it from all layers and tests.

### O13. Language setting with extra state

- **Where**: `hydrated_bloc/language_storage.dart`, `_drawer.dart:140-176`, `settings_page.dart:171-215`
- **Problem**: A switch plus radio buttons, `lastManualLanguageId`, and `enable/disableSystemLanguage`. The same UI is written twice (drawer and settings).
- **Fix**: One `SegmentedButton` with System / English / Italiano (like the theme selector), in Settings only. The state is a single `languageId`. Drop `lastManualLanguageId` (read it once in `fromJson` for migration if needed).

### O14. Translation helpers hard-code Italian

- **Where**: `lib/l10n/translation_helper.dart` (every `translateX` checks `== 'it'`), `translateGameVersion` switch (about 60 cases, `:70-…`), `detail_moves_cubit.dart:83-87, 157-164`
- **Fix**: `const Map<String, Map<String, String>> _dbByLocale` per data kind. Use one generic `_translate(kind, slug)`. Make the game names a `Map<String, String Function(AppLocalizations)>`. Move the move-name lookup out of the cubit (see B6).

### O15. Duplicated color helpers

- **Where**: `detail_page.dart:530-546` and `detail_info_tab.dart:31-44` (almost the same "visible type color" code). `type_color_scheme.dart:35, 65-83` (private wrapper, darken/lighten as instance methods).
- **Fix**: One `Color readableOn(Color surface, Brightness b)` extension in `widgets/detail/` or `theme/`. `TypeColorScheme` becomes a static map plus a gradient function.

### O16. Test suite size

- 17,959 test lines for about 20,000 lines of hand-written code. Some tests only cover trivial code (for example `test/release_hardening_test.dart`).
- When you do O1-O12, delete the tests of removed code. Do not rewrite them. Do not add tests only to keep the 70% coverage gate in CI.

---

## 4. Code without a clear shape

### M1. Swallowed provider errors (16 empty `catch (_) {}`, 26 `catch (_)` in total)

- **Where**: `detail_page.dart:132-171, 179-218, 237-249, 288-308`, `detail_info_tab.dart:84-106`, `detail_moves_tab.dart:26-29`, `pokemon_card.dart:124-191`, `comparison_page.dart:159-165, 838-844`, `_drawer.dart:21-23, 37-40`, and more. Also `main.dart:69-80` (`if (getIt.isRegistered<...>())`).
- **Problem**: These exist so that widget tests can pump widgets without the app-level cubits. In the app they hide real mistakes: a missing provider fails silently.
- **Fix**: Add a test helper `pumpApp(widget, {favorites, comparison, preferences, ...})` that provides mock cubits. Remove every try/catch around `context.read/watch/select`, and the `isRegistered` guards.
- **Verify**: `grep -rn "catch (_)" lib` returns only real I/O cases.

### M2. Route strings everywhere

- **Where**: More than 30 `context.push('/…')` calls with string paths. `app_router.dart` defines route names that are never used.
- **Fix**: One `abstract final class AppRoutes { static String pokemon(String id) => '/pokemon/${Uri.encodeComponent(id)}'; … }`. Use it everywhere. Remove the unused `name:` values, or use `goNamed`/`pushNamed`. Pick one style.

### M3. Repeated button and icon styles

- `ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(48, 48)))` is copied 11 times (`_app_bar.dart:39-41, 60-62, …`, `comparison_page.dart:32-34`). The Material 3 default tap target is already 48 dp. Delete them, or set it once in `iconButtonTheme`.
- 120 `Colors.*` literals in presentation (excluding `transparent`). Move them into the theme or `AppPalette` (see A3, A4).

### M4. Nested Scaffold and duplicated header

- `detail_page.dart:221` and `:280` create two `Scaffold`s, one inside the other. Keep one.
- `detail_page.dart:339-363` and `:395-417` build the same `DetailHeader` + `AnimatedCrossFade`. Build it once in a local variable (A1 may remove the landscape branch anyway).

### M5. Stats tab built by hand

- `detail_stats_tab.dart:48-125`: 3 copies of the header cell and 6 hand-written `_buildStatRow` calls. Loop over `StatKind.values`, like `comparison_page.dart:539` already does. Also add a "Total" row, which the detail page does not have and the comparison page does.

### M6. Comments and doc comments in the wrong place

- Spec or ticket references in the code: `detail_info_tab.dart:116, 173, 357, 414, 425, 429` ("§8.4", "Task 11.1"). Remove them.
- Doc comments placed inside the class body, before the constructor: `pages/home/_bloc.dart:7-9`, `pages/detail/_bloc.dart:7-9`. Move them above the class, in English sentences.

### M7. Names that do not match the content

| Now                                   | Problem                                | Better                                    |
| ------------------------------------- | -------------------------------------- | ----------------------------------------- |
| `Detail` (widget)                     | too generic                            | `PokemonDetailPage`                       |
| `PokemonBloc` in `bloc/detail_bloc/`  | folder and class names differ          | `PokemonDetailBloc` or rename the folder  |
| `IsButtonPressedEvent`                | describes the UI, not the intent       | `SearchSubmitted`                         |
| `FetchAllPokemonNamesEvent`           | it loads the index                     | `LoadIndex`                               |
| `hydrated_bloc/language_storage.dart` | contains `LanguageCubit`               | `bloc/language_cubit/language_cubit.dart` |
| `PokemonRemoteDataSource`             | always goes through the cache          | see O2                                    |
| `DataRepository`                      | it is a cache client, not a repository | `PokeApiCache`                            |

### M8. Mixed navigation styles

- `settings_page.dart:326` uses `context.go('/settings/about')`, the other pages use `push`. The drawer uses `Navigator.of(context).pop()` next to go_router. Use `context.push` / `context.pop` everywhere.

---

## 5. Suggested order of work

> **Historical.** This was the plan; steps 1–8 and most of step 9 are done. See the status
> section at the top for what is actually left (O11, O16, the device pass, M3 residue).

Each step should end with `fvm flutter analyze` clean, `fvm flutter test` green, and a device check for UI steps.

1. **Bugs that users see**: B1, B2, B3, B5, B7, B13, B11. Small and safe.
2. **M1** (remove the swallowed provider errors + `pumpApp` helper). This makes later refactors safer, because missing providers will fail loudly.
3. **Theme consolidation**: A3, A4, A10, M3. After this, most `Colors.*` and `fontSize` literals are gone.
4. **Detail page layout**: A1, A2, A7, M4, M5, B8.
5. **Drawer, home, empty states**: B4, A6, A8, A9, O13.
6. **Simplifications in the application layer**: O7, O8, O5, O12, B6.
7. **Data layer**: O1, O2, O3 (and O4 if wanted), O9, O11.
8. **Bigger rewrites**: O6 (comparison, fixes B15), O10 (summary type, with a JSON migration test).
9. **Clean-up**: O14, O15, M2, M6, M7, M8, B9, B10, B12, B14, A5, A11.

Update `README.md` when a step changes something it documents (use cases, flavors, caching, routes).

---

## 6. Follow-ups found while doing the work

- **Two more regressions the refactor introduced, both fixed.**
  1. `DetailHeader` overflowed its box on a 390-high landscape screen (4 dp) and at a 2.0 text
     scale on a 320-wide phone (9.6 dp). The sprite had a hard 64 dp floor inside a
     `FlexibleSpaceBar` background that gets less room than that, and the type chips grew to a
     second line at large text scales. The sprite now shrinks to the available height and the
     chips stay on one line. **A device pass must still confirm the header looks right at 2.0
     text scale** — the fix removes the overflow, it does not prove the result is pretty.
  2. `PokemonRepositoryImpl.getPokemon` called `name.rightOrCrash()` in a non-`async` method, so
     an invalid name threw a `PokemonFailure` *synchronously*, before `_fetch`'s `try` could map
     it. Callers got an exception instead of the `Left` that `IPokemonRepository` promises —
     a regression, since the pre-refactor version wrapped the body in a `try`. The exposed
     caller was `ComparisonCubit._load`, which builds a `PokemonName` from an entry name with no
     `isValid()` guard, so a non-canonical name would crash instead of showing a failure. The
     repository now folds the validation and returns `left(failure)`. Covered by
     `getPokemon failures › an invalid Pokémon name fails before the cache is consulted`.
     `DetailBloc` already guarded with `isValid()` and was unaffected.
- **One reported bug was a false positive — worth remembering.** The detail app-bar action
  buttons looked like they were 40×40, below the 48 dp minimum. They are not:
  `find.byTooltip(...)` matches the `Tooltip` that `IconButton` builds *internally*, whose box
  is the 40 dp icon box, while the `IconButton` itself keeps Material 3's padded 48 dp target. A
  tap 22 dp from the button centre (inside a 48 dp target, outside a 40 dp box) does fire. The
  test was measuring the wrong widget. **When asserting a tap-target size, measure the tappable
  widget, or assert that an edge tap still hits** — do not assert on a tooltip.
- `O12` (`getAllPokemonNames`) was removed from every layer, but the name was still referenced
  from two tests. The test migration deleted those references.
- `PokeApiUrlHelper.typeSpriteUrl` was deleted along with the last `TypeImage` caller (B14), and
  its test expectation with it. A PokeAPI type sprite is still the only way to get a per-type
  *icon*, so if type icons are ever wanted again they must be bundled assets, not PokeAPI
  sprites, because those carry English text.
- `RequestCancelledFailure` and `CancellationToken` are gone (O4). The failure taxonomy is
  smaller now, and the `Request cancelled` ARB strings may be unused — check before reusing.
- The `comparison cap` rule lives in the domain as `kComparisonMaxEntries` but is enforced by
  `ComparisonState.isFull` in the application layer. Assert the constant in `test/domain/` and
  the enforcement in `test/application/`; do not import the application layer from a domain test.
