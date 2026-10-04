# Changelog

All notable changes to this project will be documented in this file, following the “Keep a Changelog” standard.

## [Unreleased]

### Added

- `docs/logging_policy.md` (redaction, truncation, debug vs release) and `docs/localization_policy.md` (canonical vs localized names, fallback rule).
- AI contributor docs consolidated under `docs/ai/` (`context.md` superseding `CLAUDE.md`, plus skills guide).
- Browsable Pokédex `/pokedex`: paginated grid, pull-to-refresh, skeleton loaders, scroll/filter restore, multi-type (18) / generation (1-9) / sort (ID, Name) filters, contains + numeric-ID search, Random Pokémon.
- Detail artwork & sprite-variant gallery (Info tab): grid of available variants (official artwork, front/back, shiny, female, Home) with localized labels (EN + IT), tap-to-preview dialog, placeholder icons on missing or failed images, and screen-reader variant names. Records URLs + fallback order only (official artwork → front default → others); image bytes stay in the platform cache. Raw sprite DTOs now model female variants and `other/home` as nullable.
- Detail depth: species flavor text (IT with EN fallback), genus, generation, habitat; branching evolution chain with full trigger badges and tap-to-navigate; on-demand ability sheet; unified game-version selector syncing moves, encounters, items; inline forms gallery with tap-to-switch.
- Detail share action: copies the canonical `/pokemon/:nameOrId` link for the displayed Pokémon/form to the clipboard (clipboard only, no new permissions); `pokefinder:///pokemon/:nameOrId` deep links on Android and iOS resolve to the canonical route with the router error fallback for invalid values.
- First-class alternate forms: Mega / Primal / Regional (Alola, Galar, Hisui, Paldea) / G-Max / battle-mode classification with O(1) parent mapping, interleaved ordering under parent species, form badges, localized titles (`Mega Charizard X`, `Alolan Vulpix` / `Vulpix di Alola`), keyword search (`mega`, `alola`, …), dual generation context.
- Foundation: canonical `/pokemon/:nameOrId` deep-link route with error page; durable prefs vs. disposable cache storage split; startup retry screen.
- Italian item-name database (`lib/l10n/items_db.dart`, generated from PokeAPI) with `translateItem` title-case fallback, plus `translation_coverage_test` failing CI on raw-slug or ALL-CAPS rendering.
- Local team builder `/teams` (offline, no cloud): teams of up to 6 stored durably as lightweight index refs (id, name, timestamp) via a hydrated `TeamsCubit`, surviving restart. Team list with create/rename/delete (delete confirmed), team detail with add/remove from Pokédex cards and the detail screen, drag-reorder plus move-to-top, and per-member deep links to the canonical `/pokemon/:nameOrId` route. Team summary shows type coverage plus summed and average base stats, reusing the comparison stat components; the members load through one `PokemonListCubit` (offline cache, no encounters) so one failure shows inline retry without destroying the summary. Duplicate slugs warn inline but stay allowed, so forms (distinct slugs, classifier display names) remain distinct members; the 7th member is rejected with guidance; corrupt records are evicted with a log and never crash the list. Entry via drawer, EN + IT strings, empty states included.
- MIT license (`LICENSE.md`) covering the project source.
- Mobile UX: safe layouts from 320px phones to tablets, landscape and 200% text scaling; 48×48 dp targets; screen-reader semantics; keyboard Search action with inline validation.
- Offline type matchup calculator `/matchups` (Gen VI onward 18-type chart): pure-domain `TypeMatchupChart` with all 324 attack/defense multipliers, dual-type multiplication (4×, ¼×, immunity override), and grouped results (4×, 2×, ½×, ¼×, 0×) with localized type names. Select 1–2 defending types with 48dp targets and screen-reader announcements; empty state included. Entry via drawer tool and tappable detail type chips (preset with the Pokémon's 1–2 types, `?types=` query), EN + IT strings, no network.
- Personalization: Favorites `/favorites` with reactive sync and ID / Name / Date sorting; Recently Viewed (20) + Recent Searches (10) with shelf, dedup and pause/clear; System / Light / Dark theme; Metric / Imperial units; cry autoplay + volume; Settings `/settings` and About `/settings/about` (version, PokeAPI credit, trademark disclaimer, licenses).
- Quality gates: GitHub Actions CI (pinned FVM, format, `analyze --fatal-infos`, codegen check, coverage, release APK), 8 critical-journey integration tests, `verify.sh` / `coverage.sh`, release-hardening tests.
- Resilience: full `PokemonFailure` taxonomy (not found, offline, timeout, rate-limited, server, invalid response, storage, cancelled); Retry + Edit Search recovery; inline retry for encounters / forms / move sheet; cry `unavailable` state and sprite / type-chip fallbacks; request cancellation + deduplication; stale-cache indicator; stat-by-name mapping and sprite fallback chain.
- Side-by-side Pokémon comparison `/compare` (max 2, in-memory): pick entries from Pokédex card compare action / long-press or the detail compare action; dual entries render in one shared card with side-by-side headers, sprites, type chips, and localized metric/imperial height/weight that stay side by side on phone portrait, plus an aligned `[first] <stat> [second]` stat table driven by `buildComparisonStatRows` with leader highlighting and a shared total row. Single entries reuse the shared `CompactStatRow` with the detail screen. Each side loads on its own, so a failure shows inline retry without destroying the valid side; per-entry canonical share links, guarded sprite placeholders, compare-button tooltips, remove-one, clear-all, empty state, EN + IT strings, and Pokédex badge navigation included.

### Changed

- `PokemonBloc*` state, event and provider names now use the `PokemonDetail*` prefix, like `PokemonDetailBloc`.
- `PokemonFormClassifier` hides the `-mega` entries the Pokédex index ships for species without a Mega Evolution (curated `kMegaEvolutionSpecies`).
- A corrupt stored favorite, history or team record is dropped with a log and the rest still loads. "Clear cache" reports a failure in Settings instead of showing success.
- Applied tall-style formatter; moved `path`, `yaml` to `dev_dependencies`; upgraded dependencies; replaced `com.example` IDs with production IDs; `post_build.dart` aborts on dirty worktree / failure.
- Blocs and cubits call `IPokemonRepository` directly. The nine pass-through use cases (one line each, and not used consistently anyway) are gone.
- Data layer collapsed from seven layers to two. `PokeApiCache` is a cache-first JSON client (24 h window, stale-if-error, per-URL request sharing) and `PokemonRepositoryImpl` parses, maps to entities and maps every error in one place. The double error mapping and the per-endpoint copy-paste fetch methods are gone. The cache-epoch write guard stays: a "clear cache" that runs during a request can no longer be undone by that request's late write.
- Decoupled `HomeBloc` via `ClearCacheUseCase`; consolidated URL / asset helpers into `PokeApiUrlHelper`; flavor-to-DI mapping (`dev` → mock, `prod` → live).
- Detail: fixed full-width tabs, one weight/height row, sprite gallery as a horizontal strip, header sprite placeholder, the redundant "Species" section removed, and `showCheckmark: false` on selectable type chips.
- English tab label "Items" is now "Locations", to match the content (Italian "Luoghi"). Tonal buttons and selected chips on the detail page use the type color like the rest of the content card.
- Evolution trigger badges localize embedded item/move/type names in Italian; unknown learn methods and generation codes fall back to title case.
- Favorites, history, teams and comparison key on the exact form (`PokemonSummary.id`) and keep the form lineage across a JSON round trip.
- Home search keeps the pending navigation as a `SearchNavigation` value instead of a bool flag, and the index is loaded with a single `LoadIndex` event.
- Language is a single System / English / Italiano segmented button in Settings; the duplicate drawer UI and the extra `lastManualLanguageId` / system-language state are gone.
- One `PokemonSummary` (id, name, sprite, types) replaces the four near identical favorite / recent / team / comparison-entry types, and `Pokemon` groups its 16 sprite URLs in a `PokemonSprites` value object. Stored favorites, history and teams still load: the JSON keys are unchanged.
- Pokédex filters live in one `PokedexFilters` value object. The in-memory pagination that sliced an already-loaded list is gone, along with its scroll listener, bottom spinner and load-more event; the lazy `SliverGrid` renders the filtered entries directly.
- Presentation blocs/cubits resolve exclusively through `lib/src/1_presentation/di/presentation_bloc_factory.dart` (single documented construction point); no raw `getIt` calls remain in `1_presentation/`.
- Production logging redacted (queries) and truncated (payloads); measurements and stats use locale-aware `intl` formatting; Italian copy polish.
- Routes are built with the `AppRoutes` helpers instead of ~30 string literals; the per-type `TypeColorScheme` is one opaque color map, and text legibility on a colored surface goes through one `readableOn` helper.
- Tests of deleted code were deleted rather than rewritten, and the suite was migrated to the new APIs. Widget tests share one `pumpApp` helper (`test/helpers/pump_app.dart`) instead of about 30 hand-built app shells, `InMemoryHydratedStorage` moved from `lib/` to `test/helpers/`, and tests of trivial code (defaults, `props`, constants) were deleted.
- The comparison page loads its own details through `ComparisonCubit` with `getPokemon` only. It went from 1079 lines to 278 plus a separate stat table widget, and no longer nests one detail bloc per side. The team summary uses the same loading state (`PokemonLoad`) through `PokemonListCubit`.
- Typography uses `textTheme` roles throughout: no `fontSize:` literals remain in the presentation layer, and repeated section-heading styles became `SectionTitle`.

### Fixed

- `getPokemon` threw synchronously on an invalid name instead of returning a `Left`, breaking the `IPokemonRepository` contract: the comparison page could crash on a non-canonical entry name instead of showing a failure. The validation is now folded into the result.
- `pikachu-*-cap` was badged as a regional (ALOLA) form. Costumes are classified as cosmetic before the regional check.
- Accessibility and UI: redundant / missing screen-reader announcements, 48dp touch targets, Italian badge localization, Hive LRU bloat and jank.
- After a language change, the Moves tab kept sorting by the old language.
- An offline (stale) copy of the Pokédex index was kept for the whole session, so alternate forms did not refresh when the network came back.
- Comparing Pokémon and opening a team downloaded each member's encounters, which neither page shows.
- Crashes and logic: version-selector assertion on Pokémon switch, evolution trigger shadowing (item / trade / gender lost with level), form type filtering, autocomplete false positives on `canonical`, pull-to-refresh unmount crash, cancelled-request surfacing as failure.
- Detail app bar icons and title were always white because the background was passed as `Colors.transparent`: the real type color and its contrasting text color are used now.
- Detail header no longer collapses: the page is a `NestedScrollView` with a pinned `SliverAppBar`, so the Moves tab is not limited to three rows.
- Detail page played the cry and re-recorded history on every state emission (data, encounters, form loading, form loaded). Side effects now run once per Pokémon.
- Drawer reported "Cache size: 0 B" and raced its own clear-cache action. The cache and language blocks left the drawer (Settings owns both) and the drawer is navigation only.
- Empty states, section titles and app bars differed per page. Shared `EmptyStateView` and `SectionTitle` widgets, one theme-driven color scheme and one app bar style replace the per-page copies.
- Held items rendered as ALL-CAPS raw API slugs; they now show localized names with title-case fallback.
- Italian detail page showed "Generation I" and English habitat names; both are localized now.
- Mega Venusaur, Blastoise, Garchomp, Abomasnow and Audino were hidden as vestigial index entries.
- Mixed-language labels: `Gen N` and `XP` are localized ARB strings, the half-translated location names are fully translated or fall back to English, and the English-text PokeAPI type sprites (`TypeImage`) are gone in favour of the localized `TypeChip`.
- Moves were sorted by English API slug in an inconsistent comparator, so the Italian list looked random. Sorting is now by method group, then level for level-up moves, then the localized name, with the display name injected through a `MoveNameResolver` instead of reaching into l10n from the application layer.
- Pokédex card type chips could paint outside the card on a narrow screen; they share one row and shorten the label instead.
- Pokédex search ignored the generation, type and form filters for any entry whose name or number matched the query.
- Pokédex type filter showed "No Pokémon found" on a slow or failing type request: the selection is now applied immediately with a loading marker on the chip, the type ids load in the background, a failure deselects the type again and is reported in a SnackBar instead of looking like zero results. A search or filter change made while the type loads is kept after a failure, and a second tap on a loading type cancels it instead of selecting it again with a second request.
- Returning to Home from a detail page reopened the keyboard and the suggestion overlay over the buttons: the field is unfocused before navigating.
- Searching by number (`25`) opened the Pokémon with only its default form; the forms list now matches a search by name.
- Selecting a matchup defending type grew the chip and pushed the others onto other rows; selection is shown with fill and border only, at a fixed size.
- Sprite gallery duplicated official artwork under "Front (default)": the front pixel sprite is now retained as `spriteFrontDefault` and shown as its own variant; preview dialog scrolls on compact landscape and large text scaling; gallery tiles expose a single screen-reader announcement.
- Store compliance: Android INTERNET-only, no cleartext traffic, flavor labels, adaptive icons; iOS plist stripped (mic, local network, arbitrary loads, background audio).
- Swallowed provider errors: 26 silent `catch (_)` around `context.read` hid missing providers. They are gone, so a broken provider tree now fails loudly.
- The compact Stats tab showed the total in a three-column row without its header; it is one line now.
- The detail header overflowed its box on a short landscape screen and at a 2.0 text scale on a compact phone: the sprite had a hard 64 dp minimum it could not shrink below, and the type chips wrapped to a second line. The sprite now shrinks to the space the collapsing app bar gives it and the chips stay on one line.
- The detail header type chip was centered in its column, so it floated ~44dp right of the name; it is left-aligned with the name now.
- The disabled "Search" label was white on light grey, because the color was forced on the `Text`. The button owns its foreground color now.
- The error page's illustration sat behind a translucent card and covered the "Edit search" button, and the retry button was unreadable in dark mode. The image is now a normal element above the card and the action is a `FilledButton`.
- The filter sheet had two close actions that did the same thing ("Apply" only closed it) and a near-invisible close icon: one clear way to close.
- The form sheet showed the selected form in the raw type color (yellow on a light sheet for Electric); it uses the readable accent now, and the shiny switch follows the theme.
- The loading detail page had no way back; it keeps a plain app bar now.
- The Pokédex had two conflicting game-version selectors, one of them inert on Stats. There is now one selector, shown only on the tabs that use it, and "all versions" falls back to the Pokémon's latest version group.
- VS Code script tasks explicitly use Git Bash on Windows and Bash on macOS/Linux, with the workspace as their working directory. The post-build task also handles workspace paths containing spaces.

### Removed

- The use case layer, `DataRepository`, `IPokemonRemoteDataSource` / `PokemonRemoteDataSource`, `FetchStrategy`, `CacheMetadata`, `DataResponse`, `DataFetchException`, `RequestDeduplicator`, `CancellationToken` (and with it `RequestCancelledFailure`), the `DetailState.map` helper, the `PokemonBloc` / `HomeBloc` builder wrappers, `getAllPokemonNames`, the Pokédex pagination, the drawer's cache and language blocks, and `TypeImage`.
- Unused runtime deps (`flutter_animate`, `gap`, `pokeball_widget`, `flutter_gen`); redundant `WAKE_LOCK` permission; dead test-only constructors and hydration calls.

## [1.0.0-rc1] - 2026-09-02

### Added

- Autocomplete suggestions while typing a Pokémon name.
- Detail screen with a tabbed layout: info, stats, moves, items & games.
- Encounter locations, held items and game indices.
- Hive-backed local storage, and a feature-agnostic `DataRepository` exposing `cacheFirst`, `networkFirst` and `networkOnly` fetch strategies.
- Italian translation databases for abilities, moves and locations, with a translation helper.
- Language selection from the settings drawer, and a clear-cache action.
- Mock repository, registered under its own dependency injection environment.
- Move detail sheet, and selection of alternate forms and shiny sprites.
- Pokémon cry playback, behind a `CryAudioController` domain abstraction.
- Pokémon stats with computed minimum and maximum values.
- Test suite covering domain helpers, blocs, repositories and widgets.
- Typed `json_serializable` models for the PokeAPI payloads.

### Changed

- Replaced `http` with `dio`, adding a logging interceptor for API calls.
- Replaced magic strings with enums: `StatKind`, `LearnMethod`, `PokemonType`.
- Replaced stringly-typed errors with a sealed `PokemonFailure` carried through bloc states, mapping HTTP status codes to typed failures.
- Restructured the project into numbered Clean Architecture layers.
- Split the monolithic detail page into per-tab widgets and shared components.
- Upgraded the pinned Flutter SDK and the project dependencies.

### Fixed

- Bloc not provided to the form selection bottom sheet.
- Internet permission missing in release builds.
- iOS playback of `.ogg` cries, using media_kit as the audio backend.
- Pokémon name shown when displaying alternate forms.
- Resource leaks, network and cache robustness, and search input normalization.

### Removed

- `http` dependency, superseded by `dio`.
- Unknown form entry from the API fetch.

## [0.1.0] - 2025-04-25

### Added

- Detail view for individual Pokémon.
- Initial public release of PokéFinder.
- Language switching support (English/Italian) with HydratedBloc persistence.
- Routing with GoRouter.
- Search functionality for Pokémon by name.

### Changed

- Organized dependency injection in `main.dart`.
- Refactored `language.dart` for simpler `Language` model.
- Updated UI layout for home and detail pages.

### Fixed

- Correct initialization of `WidgetsFlutterBinding` before HydratedBloc storage setup.
- Fixed navigation edge cases in `HomeBloc` listener.
- Resolved language persistence issue on app restart.
