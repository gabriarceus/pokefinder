# PokéFinder Product and Engineering Roadmap

> Re-audited against `main` at commit `1efda32` on 2026-08-30.
>
> This document replaces the earlier roadmap, which described an older version of the app. The repository has changed substantially since that audit.

## Executive Verdict

The previous roadmap is **only partially relevant now**.

The overall recommendation is still sound:

> Stabilize the core experience, then turn PokéFinder into a browsable discovery app before considering large features such as team building or accounts.

However, many original gaps have now been addressed. The app is no longer a minimal name-search prototype. It now includes:

- Trimmed, lowercase search normalization.
- Search by name or Pokédex ID through PokeAPI.
- Local prefix autocomplete using a cached Pokémon name index.
- A layered repository/data-source architecture using Dio and Hive.
- Typed DTOs and domain entities.
- Timestamped API response caching.
- A four-tab detail page.
- Base, minimum, and maximum stats.
- Moves grouped by game and learning method.
- On-demand move details.
- Held items, games, and encounter locations.
- Alternate forms and shiny sprites.
- Latest and legacy cry playback.
- System, English, and Italian language options.
- A broader test suite than the original two widget tests.

The product is now best described as a **single-Pokémon reference app**. Its next challenge is not simply adding more fields. It is making the current experience reliable across platforms and expanding it into discovery, offline use, and repeat-use features.

---

# 1. What Changed Since the Original Roadmap

## Completed or substantially completed

| Original recommendation | Current status | Evidence |
| --- | --- | --- |
| Trim and lowercase search input | Completed | `PokemonName` in `lib/src/3_domain/value_objects/pokemon_name.dart` normalizes input. |
| Reject empty searches | Completed | `PokemonName` returns `BadRequestFailure` for empty/whitespace-only input. |
| Support numeric Pokédex IDs | Completed in practice | Normalized non-empty values are passed to PokeAPI’s name-or-ID endpoint. |
| Inject the HTTP client | Completed | `DioApiClient` implements `ApiClient`; Dio is registered in `lib/bootstrap.dart`. |
| Add HTTP timeouts | Completed | Dio has 15-second connect and receive timeouts. |
| Use typed DTOs and domain mapping | Completed | Repository models and `PokemonRepositoryImpl` now perform the mapping. |
| Dispose the home text controller | Completed | `HomePage.dispose()` disposes the controller and focus node. |
| Give audio lifecycle-aware ownership | Mostly completed | `Detail` is stateful and disposes a per-screen `CryAudioController`. |
| Cancel audio subscriptions | Completed | `JustAudioCryController.dispose()` cancels both subscriptions and disposes the player. |
| Follow the system language | Completed | `LanguageCubit` defaults to `Language.system`. |
| Expand English/Italian UI localization | Substantially completed | ARB files now cover most detail, move, form, type, and game labels. |
| Add API response caching | Completed at a basic level | `DataRepository` and `HiveLocalStorage` cache JSON responses. |
| Add a cache-clearing action | Completed | The settings drawer dispatches `ClearCacheEvent`. |
| Add autocomplete | Completed at a basic level | `RawAutocomplete` uses a cached list of Pokémon names. |
| Add base stats | Completed | `DetailStatsTab` shows base/min/max values and bars. |
| Add moves and move detail | Substantially completed | `DetailMovesCubit`, `MoveDetailCubit`, and the move detail bottom sheet exist. |
| Add forms and shiny sprites | Substantially completed | Form selection and shiny toggling exist. |
| Add held items, games, and encounters | Completed at a basic level | `DetailItemsGamesTab` renders all three. |
| Add Android release Internet permission | Completed | The main Android manifest declares `INTERNET`. |
| Add macOS release network entitlement | Completed | `Release.entitlements` declares `com.apple.security.network.client`. |
| Add Android build flavors | Completed at configuration level | `dev` and `prod` flavors are defined. |
| Use generated Injectable registration | Completed | Generated DI now registers the active graph. |
| Expand unit tests | Partially completed | There are now 13 test files across multiple layers. |

## Original claims that are now obsolete

The following statements from the first roadmap no longer describe the repository:

- `IPokemonService` and `PokemonService` are no longer the active data architecture.
- Hive is no longer unused.
- Every lookup no longer requires a live request.
- The detail page is no longer limited to types, abilities, dimensions, sprite, and cry.
- Audio and home-controller disposal are no longer absent.
- English is no longer forced on first launch.
- Localization is no longer limited to a handful of home strings.
- The tests are no longer limited to two files.
- Android release networking is no longer missing.
- Android `prod` and `dev` flavors now exist.
- macOS release networking is now configured.
- Injectable generation is no longer effectively empty.

## Original recommendations that remain relevant

These are still important:

- Robust not-found, offline, timeout, server, and invalid-response failures.
- Retry and edit-search actions.
- Addressable `/pokemon/:nameOrId` routes.
- Web-safe bootstrap and storage.
- Keyboard submission and inline search validation.
- Responsive layouts and accessibility semantics.
- A browsable Pokédex list/grid.
- Type and generation filters.
- Favorites and recent Pokémon.
- Stale offline fallback and cache lifecycle management.
- Species descriptions and evolution chains.
- Theme and measurement preferences.
- Continuous integration.
- Real bundle IDs, signing, icons, and store metadata.
- License, privacy, support, and attribution documentation.

---

# 2. Current Product Snapshot

## Current user-facing functionality

### Home and search

- Search by manually entered name or ID.
- Whitespace and casing normalization before the API request.
- Prefix autocomplete after two typed characters.
- English, Italian, or system language.
- Manual cache clearing.

### Pokémon detail

- Number and formatted form name.
- Default and shiny sprites.
- Alternate form selection.
- Type-based color styling.
- Height and weight.
- Base experience and default-form indicator.
- Abilities and hidden-ability indicator.
- Latest and legacy cries.
- Base/min/max stats.
- Moves filtered by game and acquisition method.
- Search within the move list.
- On-demand move type, class, power, accuracy, PP, and description.
- Encounter locations.
- Wild held items and rarity.
- Game version indices.

### Data and platform foundation

- Dio networking.
- Hive JSON cache.
- `Either<PokemonFailure, T>` repository results.
- BLoC/Cubit state management.
- Injectable/get_it dependency injection.
- Flutter targets for mobile, desktop, and web.

## Current product identity

PokéFinder is strong enough to demonstrate a detailed Pokémon lookup, but it does not yet provide the main reasons users repeatedly open a Pokédex app:

- Browsing without knowing a name.
- Filtering and comparing entries.
- Saving favorites.
- Returning to recent entries.
- Dependable offline access.
- Sharing or bookmarking a Pokémon.

---

# 3. Revised Priorities

## Priority definitions

- **P0 — Reliability/release blocker:** resolve before advertising broad platform support or adding a large feature.
- **P1 — Next product milestone:** highest-value additions after P0.
- **P2 — Product depth:** useful after discovery and persistence are stable.
- **P3 — Optional expansion:** build only after validating demand.

## Recommended order

1. Fix bootstrap, routing, failures, retry, and release configuration.
2. Make current screens responsive and accessible.
3. Harden caching and test the critical data paths.
4. Add a browsable Pokédex using a lightweight Pokémon index.
5. Add favorites and recent Pokémon.
6. Add species descriptions and evolution chains.
7. Add comparison and type tools only after the above are stable.

---

# 4. Milestone 0 — Stabilize the Updated App

**Priority:** P0

**Goal:** Every currently advertised platform can launch, search, display cached/live data, explain failures, and recover without crashing.

## 4.1 Make bootstrap platform-aware

### Current issue

`bootstrap()` in `lib/main.dart` unconditionally calls:

- `getApplicationDocumentsDirectory()` for Hive.
- `getTemporaryDirectory()` for HydratedBloc.

Static inspection indicates that the current dependency graph has native `path_provider` implementations but no web implementation. The web target is therefore expected to fail before `runApp()` unless storage initialization is made platform-aware.

The current storage choices also mix two different concerns:

- API response cache is placed in the application documents directory, even though it is disposable data.
- Language preference is placed in a temporary directory, even though it should be durable user state.

### Add or change

- Introduce a platform-aware application bootstrap service.
- Initialize Hive using a web-compatible strategy on web.
- Put disposable API cache in a cache/support location appropriate for each native platform.
- Put HydratedBloc preferences in a durable support/documents location.
- Surface initialization failure with an actionable startup UI rather than failing before rendering.
- Decide which platforms are officially supported and test only those as release targets.

### Acceptance criteria

- Web reaches the home screen without a missing-plugin/storage exception.
- Language choice survives ordinary OS cache cleanup expectations.
- Cache storage remains disposable and clearable.
- A storage initialization failure renders a recoverable startup state.
- Automated smoke tests cover bootstrap on every officially supported platform.

---

## 4.2 Finish the failure model

### Current issue

The architecture now has `PokemonFailure`, but it only distinguishes:

- Unauthorized.
- Bad request.
- Unexpected.

`DioApiClient` discards `DioException.type`, and `PokemonRemoteDataSource._mapError()` only handles HTTP 400 and 401 explicitly. As a result, 404, offline, timeout, 429, 5xx, cancellation, decoding failures, and cache failures are all too generic.

### Add

At minimum:

- `PokemonNotFoundFailure`.
- `NetworkUnavailableFailure`.
- `RequestTimeoutFailure`.
- `RateLimitedFailure`.
- `ServerFailure`.
- `InvalidResponseFailure`.
- `StorageFailure` where a user action needs to react to cache problems.
- `UnexpectedFailure` only as the final fallback.

Preserve transport information in `ApiException`, such as:

- HTTP status.
- Timeout versus connection error.
- Cancellation.
- Original safe diagnostic context.

### Presentation behavior

- Main detail failure: Retry, Edit Search, and Back.
- Encounter failure: inline Retry.
- Form failure: visible inline message and Retry or rollback.
- Move detail failure: localized message and Retry.
- Audio/image failure: unavailable/fallback state without hiding valid Pokémon data.
- Name-index failure: search still works, but autocomplete displays a non-blocking unavailable/retry state.

### Acceptance criteria

- Searching an unknown Pokémon displays “Pokémon not found.”
- Offline, timeout, rate-limit, server, and invalid-response states are distinct.
- No raw Dio/domain exception string is displayed to the user.
- Each recoverable asynchronous section has a retry action.
- Tests cover all mappings and UI branches.

---

## 4.3 Replace the fragile detail route

### Current issue

The current route is `/detail` and force-casts:

```dart
(state.extra as Map<String, dynamic>)['pokemonName'] as String
```

This cannot safely support browser refresh, bookmarks, direct links, malformed route data, or share links.

### Add or change

- Use `/pokemon/:nameOrId` as the canonical route.
- Parse and validate the path value.
- Add a router-level not-found/error page.
- Use the canonical route from search, autocomplete, favorites, recents, and future list cards.
- Restore the entered query when navigating back.
- Add copy/share-link behavior where supported.
- Update browser page titles for web detail routes.

### Acceptance criteria

- `/pokemon/pikachu` and `/pokemon/25` load directly.
- Refreshing a detail URL on web does not throw.
- Invalid/missing route values render a safe page.
- Browser back/forward behavior works.
- All app entry points use the same route contract.

---

## 4.4 Complete search interaction

### Already done

- Empty values are rejected.
- Values are trimmed and lowercased.
- Autocomplete exists.
- IDs can be requested.

### Still missing

- `TextInputAction.search`.
- Keyboard/desktop Enter submission.
- Inline validation rather than only a Snackbar.
- Disabled search action for invalid input.
- A loading/submission state that prevents duplicate actions.
- Validation for unsupported characters/path-like input.
- Clear behavior around positive numeric IDs.
- A visible autocomplete loading/failure state.
- Query trimming before autocomplete, not only before submission.

There is also duplicated suggestion filtering:

- `HomeBloc` computes `searchSuggestions`.
- `RawAutocomplete` independently filters `allNames`.

The BLoC result is currently unused by the widget.

### Add or change

- Create one authoritative search/autocomplete state.
- Represent search input as name or positive ID.
- Normalize before both suggestions and submission.
- Submit from Enter/search keyboard action.
- Prevent duplicate navigation.
- Preserve query and focus behavior when returning.
- Avoid logging raw input at production log levels.

### Acceptance criteria

- Enter and Search button behave identically.
- Leading spaces do not break suggestions.
- Invalid characters show inline guidance.
- Empty input cannot submit.
- One state source drives suggestions.
- Failed index loading does not prevent direct lookup.

---

## 4.5 Make current screens responsive

### Current issue

The home screen still uses:

- `resizeToAvoidBottomInset: false`.
- A non-scrollable `Column`.
- Fixed 200-pixel search and autocomplete widths.
- Fixed vertical spacing.
- A fixed 200×200 decorative Pokéball.

Detail tab bodies scroll, which is an improvement, but the shell still includes:

- A fixed 160×160 sprite.
- A fixed name/number row.
- Type badges and sprite in one narrow row.
- Four non-scrollable tabs with fixed 11-point labels.
- Stats rows with several fixed-width columns.
- Bottom sheets that may be constrained in short landscape windows.

### Add or change

- Use adaptive width constraints for home.
- Allow keyboard resizing and scrolling.
- Define phone, tablet, and wide-window detail layouts.
- Allow tab labels to scroll or adapt at high text scales.
- Reflow stat values on narrow screens.
- Make form and move-detail sheets scroll-safe.
- Avoid `FittedBox` as the primary answer to user-selected large text.

### Acceptance criteria

- No overflow at common small phone sizes.
- No overflow in landscape.
- No overflow at 200% text scaling.
- Keyboard does not hide search controls.
- Tablet/desktop layouts use available width rather than stretching the phone design.
- Responsive widget tests cover representative sizes.

---

## 4.6 Add deliberate accessibility

### Current issue

Standard Flutter controls provide some built-in semantics, but custom content has little explicit accessibility support.

Examples:

- Type meaning is conveyed through remote images.
- Type images have no semantic label or text fallback.
- Sprite images have no Pokémon/form description.
- Cry icon buttons have no tooltip or explicit play/stop/replay label.
- Type image failure silently disappears.
- Sprite failure displays `:(`.
- Stat progress semantics may announce a normalized percentage rather than the visible stat value.

### Add or change

- Replace or supplement type images with localized text chips.
- Add semantic labels to sprites, cries, forms, stats, and custom cards.
- Add localized tooltips to icon-only controls.
- Exclude decorative images from semantics.
- Provide meaningful image/audio unavailable UI.
- Verify focus order and keyboard operation.
- Test tap targets, labels, contrast, and large text.

### Acceptance criteria

- A screen reader announces Pokémon name, number, types, selected form, and shiny state.
- Cry controls announce their current action.
- Stats announce names and actual values.
- Custom controls meet minimum tap-target guidance.
- Accessibility guideline tests pass.

---

## 4.7 Finish release hardening

### Completed since the old audit

- Android main manifest has Internet permission.
- macOS release has outbound network client entitlement.
- Android has `dev` and `prod` flavors.

### Still missing

- Android namespace/application ID is still `com.example.pokefinder`.
- iOS, macOS, Linux, and Windows retain example/template identities.
- Android release still uses debug signing.
- Android globally allows cleartext traffic despite HTTPS endpoints.
- iOS declares arbitrary network loads, microphone access, local-network access, and background audio without matching features.
- macOS debug/profile has network server permission but not network client permission.
- Web metadata still says “A new Flutter project.”
- Web remains locked to portrait in the PWA manifest.
- Platform icons and branding remain template-like.
- The Android manifest hard-codes `pokefinder`, bypassing flavor-specific `app_name` resources.
- `main()` always configures `Environment.prod`; the dev flavor still uses production DI.
- The combined VS Code release task references a task name that does not exist.
- `post_build.dart` reports tag/push errors but exits successfully.

### Add or change

- Choose owned bundle/application IDs.
- Configure secure release signing outside source control.
- Connect build flavor to DI environment.
- Remove capabilities and transport exceptions that are not required.
- Apply consistent `PokéFinder` branding and icons.
- Fix flavor labels and task dependencies.
- Make release automation fail on any failed prerequisite/tag/push.
- Refuse release tagging from a dirty or unverified worktree.
- Add a documented supported-platform matrix.

### Acceptance criteria

- Every supported target completes a release-mode search smoke test.
- No target uses an example identifier or debug signing.
- Dev flavor uses mock/dev dependencies as intended.
- Only required permissions/capabilities remain.
- Release automation cannot report success after a failed tag or push.

---

# 5. Milestone 1 — Harden Data, Cache, and Tests

**Priority:** P0/P1

**Goal:** Make the current rich detail experience dependable before using the same data layer for a full Pokédex.

## 5.1 Improve offline behavior

### Current behavior

- JSON responses are cached in Hive.
- Pokémon, form, encounter, and move records use cache-first with a 24-hour maximum age.
- The full name list uses a 30-day maximum age.
- Expired data is treated as a miss.
- A user can clear the cache.

### Current limitations

- Expired cached data is not used when offline.
- There is no stale-while-revalidate behavior.
- Cache age/source is invisible to the user.
- Images, type badges, and cries are not cached by this repository.
- There is no cache schema version or migration policy.
- There is no size bound or eviction policy.
- Concurrent requests are not deduplicated.
- Asynchronous cache writes can race with “clear cache.”
- `HiveLocalStorage.read()` does not safely handle every valid-JSON-but-invalid-envelope shape.
- `DateTime.now()` is hard-coded, making expiry tests harder.
- `networkFirst` can treat a cache-write failure as a network failure.

### Add or change

- Return cache metadata with data: fresh, stale, network, or offline fallback.
- Implement stale-while-revalidate or stale-if-error.
- Inject a clock.
- Add cache schema versioning.
- Add size/entry limits and eviction.
- Deduplicate in-flight requests by endpoint.
- Make clear-cache atomic relative to pending writes.
- Separate successful network retrieval from optional persistence failure.
- Validate cache envelopes completely and evict malformed entries.
- Prefer local text/type chips over remote type badge images.

### Acceptance criteria

- A previously viewed Pokémon opens offline even after freshness expires, with a stale indicator.
- A successful network response is returned even if cache persistence fails.
- Clearing cache cannot be silently undone by an older pending write.
- Corrupt cache content cannot prevent startup or lookup.
- Cache strategy and storage behavior have comprehensive unit tests.

---

## 5.2 Restore inward dependency direction

### Current issue

`HomeBloc` imports and depends directly on concrete `DataRepository` solely to clear the cache. This violates the repository’s documented inward dependency direction.

There are also consistency issues:

- Some application logic uses use cases; `MoveDetailCubit` calls `IPokemonRepository` directly.
- Presentation manually resolves some dependencies with `getIt`.
- `ApiClient` and `LocalStorage` documentation describes map-oriented contracts while methods return `dynamic`.
- `Pokemon` keeps legacy `ability1`, `ability2`, and `ability3` alongside the newer `abilities` list.
- Several mapped artwork/back-sprite fields are not used.

### Add or change

- Add a domain/application cache-management interface or `ClearCacheUseCase`.
- Decide whether application BLoCs consistently depend on use cases or repository interfaces.
- Keep runtime-only cubits inline, but inject their static dependencies through a clear factory.
- Replace broad `dynamic` contracts with a typed JSON value abstraction or explicit generic contract.
- Remove legacy duplicate fields after migrating call sites.
- Keep domain entities focused on product behavior rather than every remotely available field.

### Acceptance criteria

- Application code does not import concrete repository-layer classes.
- Cache clear failures are represented and shown to the user.
- Dependency construction follows one documented pattern.
- Domain models do not duplicate the same ability data in two forms.

---

## 5.3 Make parsing tolerant and explicit

### Current issue

Repository mapping assumes:

- At least one type.
- At least one ability.
- Stats arrive in the expected list order.
- Several sprite fields are always non-null in raw DTOs.

Schema or optional-data failures become generic unexpected failures.

### Add or change

- Model nullable remote fields as nullable DTO values.
- Validate required collections before `.first`.
- Map stats by API stat name rather than list position.
- Define sprite fallback order.
- Add `InvalidResponseFailure` with safe diagnostics.
- Add fixture-based parsing tests for normal, partial, null, and malformed payloads.

### Acceptance criteria

- A missing optional sprite does not fail the entire detail page.
- Reordered stats map to the correct labels.
- Empty required collections return a typed invalid-response failure.
- Alternate-form DTOs tolerate absent artwork/sprite variants.

---

## 5.4 Expand tests around real behavior

### Useful tests that now exist

- Pokémon name normalization.
- Failure equality.
- Type, stat, and string helpers.
- Move filtering.
- Detail-state copy behavior.
- Translation helpers.
- Cry button state mapping.
- Limited remote data-source status mapping.
- Isolated image/text widgets.

### Major gaps

- `HomeBloc` event/state tests.
- `PokemonBloc` fetch, encounter, form, retry, and ordering tests.
- `MoveDetailCubit` tests.
- `PokemonRepositoryImpl` mapping tests.
- `DataRepository` strategy tests.
- `HiveLocalStorage` corruption and expiry tests.
- `DioApiClient` timeout/offline/cancellation tests.
- Full home and detail page state tests.
- Language persistence tests.
- Audio controller load/error/disposal tests.
- Accessibility and responsive layout tests.
- Integration tests for search-to-detail.
- Platform bootstrap/release smoke tests.

Some current test names such as `home_page_test.dart` and `detail_page_test.dart` overstate their scope because they test isolated widgets rather than complete pages.

### Add in this order

1. Failure and data repository tests.
2. Home and Pokémon BLoC tests.
3. Repository mapping fixtures.
4. Complete home/detail widget tests.
5. Integration journey tests.
6. Accessibility and responsive tests.
7. Platform bootstrap/release smoke tests.

### Critical integration journeys

1. Valid search → detail.
2. Unknown Pokémon → not found → edit/retry.
3. Offline cached Pokémon.
4. Direct `/pokemon/:nameOrId` route.
5. Form selection success/failure.
6. Move detail success/failure.
7. Language persistence across restart.
8. Cache clear success/failure.

---

## 5.5 Add continuous integration

There is still no CI workflow.

### Add a pull-request workflow that runs

1. Pinned Flutter/FVM setup.
2. Dependency resolution.
3. Formatting verification.
4. `flutter analyze`.
5. Localization generation.
6. Injectable/JSON code generation.
7. Generated-output consistency check.
8. Unit and widget tests.
9. At least one representative release build.
10. Optional platform matrix for all officially supported targets.

### Acceptance criteria

- Pull requests cannot merge with analysis/test failures.
- Stale generated files are detected.
- The workflow uses the same Flutter version as `.fvmrc`.
- Release tags are created only after the release workflow succeeds.

---

# 6. Milestone 2 — Turn Search into Discovery

**Priority:** P1

**Goal:** Let users find Pokémon without already knowing an exact name.

## 6.1 Replace the name list with a Pokémon index

### Current opportunity

Autocomplete downloads all Pokémon using `?limit=100000`, then discards each result URL and retains only the name.

The URL contains an ID that could support a lightweight index without fetching every Pokémon detail.

### Add

Create a domain model such as:

```text
PokemonIndexEntry
- id
- canonicalName
- detailUrl
- optional cached sprite/type summary
```

Use it for:

- Autocomplete.
- Search result rows.
- Pokédex cards.
- Favorites.
- Recent Pokémon.
- Canonical routes.

### Acceptance criteria

- Index entries include IDs and canonical names.
- Name and numeric suggestions use the same index.
- The app does not fetch full details for every Pokémon at startup.
- Index loading has visible loading, cached, failure, and retry states.

---

## 6.2 Add a browsable Pokédex list/grid

### Add

- Paginated or incrementally rendered entries.
- Phone list and tablet/desktop grid layouts.
- Number, name, sprite, and types when available.
- Loading skeletons.
- Empty, error, stale, and retry states.
- Scroll-position restoration after visiting detail.
- Pull-to-refresh on mobile and explicit refresh elsewhere.

### Data strategy

Do not make one uncontrolled detail request for every card. Prefer one of:

1. Lightweight index first, then bounded lazy detail enrichment for visible cards.
2. Persisted summary records populated as Pokémon are viewed.
3. A generated, versioned local index if API startup cost becomes a problem.

### Acceptance criteria

- First content appears without downloading every detail record.
- Pagination does not duplicate entries or requests.
- Existing entries remain visible if the next page fails.
- Selecting a card uses `/pokemon/:nameOrId`.
- List state and scroll position survive detail navigation.

---

## 6.3 Add filters and stronger search

### Add

- Name and ID matching.
- Type filters.
- Generation filter after species metadata is available.
- Optional game/version filter.
- Sort by number or name.
- Clear-all action.
- No-results state distinct from network failure.
- Random Pokémon action.

### Search quality improvements

- Support prefix and contains matching.
- Normalize punctuation and whitespace consistently.
- Decide how alternate forms appear in results.
- Debounce only where remote work is involved.
- Keep filtering local when the index is available.

### Acceptance criteria

- Filters compose predictably.
- Clearing filters restores the previous complete index.
- Search and filter state persist while visiting detail.
- Offline filtering works against the cached index.

---

# 7. Milestone 3 — Add Repeat-Use Features

**Priority:** P1

## 7.1 Favorites

### Add

- Favorite/unfavorite action on detail and Pokédex cards.
- Dedicated favorites screen.
- Persistent lightweight favorite records.
- Sort by number, name, type, or recently added.
- Offline identification and navigation to cached detail.

### Acceptance criteria

- Favorite state is synchronized across all screens.
- Favorites survive restart.
- Favorites do not duplicate full cached API payloads.
- Empty state explains how to add favorites.

---

## 7.2 Recent searches and recently viewed

### Add

- Bounded recently viewed list.
- Optional recent-search query history.
- Deduplication and timestamp updates.
- Remove-one and clear-all controls.
- Setting to clear or disable history.

### Acceptance criteria

- Reopening a Pokémon moves it to the top.
- Invalid searches are not added to viewed history.
- Maximum history size is documented and tested.
- Clear actions persist.

---

## 7.3 User preferences

Current settings only cover language and cache clearing.

### Add

- System/light/dark theme.
- Metric/imperial measurements.
- Cry playback preference or volume.
- Cache size, clear confirmation, and refresh behavior.
- History controls.
- Optional default game/version context.

### Acceptance criteria

- Preferences apply without restart.
- Values persist in durable storage.
- Measurements use locale-aware formatting.
- Defaults follow platform conventions where sensible.

---

# 8. Milestone 4 — Add Species and Evolution Depth

**Priority:** P2

## 8.1 Species information

`Pokemon.speciesUrl` is currently stored but not fetched. The species section only repeats the canonical species name.

### Add from the species endpoint

- Localized Pokédex description.
- Localized genus/category.
- Generation.
- Habitat where available.
- Evolution-chain URL.
- Optional capture rate, base happiness, growth rate, gender ratio, and egg groups if they fit the product audience.

### Acceptance criteria

- Description follows active language with English fallback.
- Embedded newline/form-feed characters are normalized.
- Species failure does not hide base Pokémon detail.
- Species content has independent loading and retry states.

---

## 8.2 Evolution chain

### Add

- Evolution sequence.
- Branching evolutions.
- Trigger details: level, item, trade, friendship, time, location, and other conditions.
- Navigation to each evolution.
- Clear representation of special conditions.

### Acceptance criteria

- Branching chains render correctly.
- Missing sprites/data use fallbacks.
- Selecting an evolution navigates through the canonical route.
- Parsing tests cover simple, branched, and special-condition chains.

---

## 8.3 Ability descriptions

Abilities currently show names and hidden status but no behavior description.

### Add

- On-demand ability detail.
- Localized description with fallback.
- Independent loading, failure, retry, and cache behavior.
- Link or bottom sheet from each ability chip.

---

## 8.4 Make forms consistent

### Current issue

Selecting a form updates the displayed form name, types, and sprite. Other sections continue using the original `Pokemon` record:

- Abilities.
- Stats.
- Moves.
- Held items.
- Cries.
- Encounters.

This can produce a page where the header describes one form and the tabs describe another.

### Decide between

1. Fetch and replace the full Pokémon record for the selected form.
2. Clearly label base-species data versus form-specific data.

Also expose `formFailure`, which is currently stored in state but not rendered in the form sheet.

### Acceptance criteria

- Users can tell exactly which data belongs to the selected form.
- Form failure is visible and recoverable.
- Switching forms cannot apply an out-of-order stale response.

---

## 8.5 Add a shared game/version context

Moves currently select a version group, while encounters, held items, and game indices independently display broader version sets.

### Add

- Optional detail-wide selected game/version context.
- Filter moves, encounter versions, held items, and relevant species text consistently.
- Persist the user’s preferred game if this proves useful.
- Clearly show when data is unavailable for the selected game.

This can make the rich detail page feel coherent rather than like separate API sections.

---

# 9. Newly Identified Engineering Improvements

These items were not visible, or were less important, in the older repository.

## 9.1 Add audio failure state

`CryPlaybackState` supports loading, playing, and completed states but not error/unavailable.

`JustAudioCryController._load()` catches and logs an error, then `toggle()` still calls `play()`.

### Improve

- Add error/unavailable state.
- Do not play after a failed load.
- Add localized retry behavior.
- Add tooltip/semantics for play, stop, replay, loading, and unavailable.
- Test failed loading and disposal.

---

## 9.2 Add request cancellation and concurrency policy

Current asynchronous flows do not clearly propagate Dio cancellation or define BLoC event concurrency.

### Improve

- Cancel detail requests when the screen/BLoC closes where practical.
- Use restartable behavior for searches/form selections that supersede previous work.
- Guard against out-of-order form and encounter responses.
- Deduplicate identical in-flight repository requests.

---

## 9.3 Improve localization quality and performance

Localization coverage is much better, but remaining issues include:

- Raw `kg`, `m`, `XP`, and `%` formatting.
- No imperial units.
- Raw domain failure messages in move detail.
- Held-item names displayed from API slugs.
- Some fallback move/form/learn-method labels remain raw API English.
- Italian location translation can produce mixed-language output.
- Italian copy such as `Cache svuota con successo` needs review.
- Location keys are sorted on every translation call.
- Translation database coverage is not automatically validated.

### Improve

- Use `intl` number/unit formatting.
- Precompute sorted location keys.
- Add translation coverage checks for abilities, moves, items, and locations.
- Document which Pokémon proper names intentionally remain canonical.
- Add copy review for both locales.

---

## 9.4 Clean dependency and lockfile hygiene

Static source inspection found no app usage for several declared dependencies, including likely candidates:

- `flutter_animate`.
- `gap`.
- `pokeball_widget`.
- `flutter_gen`.

`path` and `yaml` appear to be release-script tooling rather than runtime dependencies.

### Improve

- Confirm and remove unused dependencies.
- Move script-only packages to `dev_dependencies`.
- Pin `injectable`, `injectable_generator`, and `intl` intentionally.
- Resolve dependencies using the `.fvmrc` SDK.
- Regenerate and validate generated output after dependency changes.

The working tree currently contains a modified `pubspec.lock` and generated native plugin files. These should be reviewed separately before assuming the lockfile and generated registrations match the pinned SDK.

---

## 9.5 Establish logging policy

Current logging includes raw search input, full URLs, and verbose response bodies in debug mode. The full autocomplete index can therefore create large logs.

### Improve

- Avoid logging user-entered queries at production levels.
- Truncate or summarize large response bodies.
- Define redaction rules before adding accounts or analytics.
- Ensure release logging cannot expose future sensitive data.

---

## 9.6 Add an in-app About and attribution page

The app has an “About” localization key, but it is currently used as a Pokémon information heading.

### Add

- App version/build.
- PokeAPI attribution.
- Pokémon fan-project/trademark disclaimer appropriate to distribution plans.
- Privacy/cache behavior summary.
- License notices.
- Support and source repository links.

---

# 10. Release and Documentation Checklist

Before a public `1.0.0` release:

- [ ] Decide officially supported platforms.
- [ ] Fix web bootstrap or stop advertising web support.
- [ ] Replace every example bundle/application identity.
- [ ] Configure secure Android signing.
- [ ] Review Apple signing and entitlements.
- [ ] Remove Android cleartext traffic unless required.
- [ ] Remove unjustified iOS permissions and arbitrary loads.
- [ ] Add final app icons, splash assets, and consistent naming.
- [ ] Update web title, description, colors, orientation, and icons.
- [ ] Add CI and release build checks.
- [ ] Fix release task names and flavor-to-environment selection.
- [ ] Make tag automation fail correctly.
- [ ] Add release smoke tests.
- [ ] Align `pubspec.yaml`, Git tags, and `CHANGELOG.md` versions.
- [ ] Replace placeholder changelog entries.
- [ ] Add a license.
- [ ] Add contribution guidelines.
- [ ] Add privacy/support/security documentation as appropriate.
- [ ] Add screenshots and supported-platform notes to the README.
- [ ] Add PokeAPI attribution and a reviewed fan-project disclaimer.

---

# 11. Updated Priority Backlog

| Priority | Item | User value | Effort | Why now |
| --- | --- | --- | --- | --- |
| P0 | Platform-aware bootstrap, especially web | Critical | Medium | An advertised target is expected to fail before rendering. |
| P0 | Full failure taxonomy and retry UX | Critical | Medium | Current rich data flows fail generically and cannot recover. |
| P0 | Canonical `/pokemon/:nameOrId` route | High | Small–Medium | Required for web refresh, sharing, and all future entry points. |
| P0 | Responsive home/detail shells | High | Medium | Fixed layouts remain fragile in landscape and large text. |
| P0 | Accessibility semantics and media fallbacks | High | Medium | Custom type/audio/stat meaning is not adequately exposed. |
| P0 | Real IDs, signing, permissions, and branding | Critical for release | Medium | Current release configuration is still template-grade. |
| P0 | Core BLoC/repository/cache tests | High | Medium | Recent complexity is not protected by tests. |
| P0 | CI | High | Medium | Main has no automated quality gate. |
| P1 | Cache stale fallback, migration, bounds, deduplication | High | Medium–Large | “Offline caching” is currently narrower than users may expect. |
| P1 | Search keyboard/inline/loading behavior | High | Small–Medium | Completes the main interaction. |
| P1 | Lightweight Pokémon index | Very high | Medium | Foundation for discovery, routes, favorites, and recents. |
| P1 | Browsable Pokédex list/grid | Very high | Large | Highest-value next product feature. |
| P1 | Type/generation/search filters | High | Medium–Large | Makes the Pokédex useful for discovery. |
| P1 | Favorites | High | Medium | Adds repeat-use value. |
| P1 | Recently viewed Pokémon | Medium–High | Small–Medium | Low-cost repeat navigation. |
| P1 | Theme, units, and cache/history settings | Medium | Medium | Completes the settings surface. |
| P1 | Form-wide data consistency | High | Medium–Large | Current selected form can disagree with tab data. |
| P2 | Species descriptions and genus | High | Medium | Natural next detail expansion. |
| P2 | Evolution chains | High | Large | Strong Pokédex value. |
| P2 | Ability details | Medium–High | Medium | Completes current ability chips. |
| P2 | Shared game/version context | Medium–High | Large | Makes moves/items/encounters coherent. |
| P2 | Artwork gallery and sprite variants | Medium | Medium | Existing model already contains some unused artwork fields. |
| P2 | Pokémon comparison | Medium | Medium–Large | Useful after reusable summary/stat components exist. |
| P2 | Type matchup calculator | Medium | Medium | Fits the data model after type discovery is stable. |
| P3 | Team builder | Potentially high | Very large | Separate product scope; validate demand first. |
| P3 | Accounts/cloud sync | Unproven | Very large | Adds backend, auth, security, privacy, and cost. |
| P3 | Social/community features | Unproven | Very large | Adds moderation and abuse-management requirements. |

---

# 12. Suggested Next Pull Requests

## PR 1 — Cross-platform bootstrap and routing

- Introduce platform-aware storage initialization.
- Make web startup safe.
- Move durable preferences out of temporary storage.
- Add `/pokemon/:nameOrId`.
- Add router-level error handling.
- Add bootstrap and direct-route tests.

**Outcome:** The app can launch and address Pokémon consistently across supported targets.

## PR 2 — Failure taxonomy and recovery

- Preserve Dio error type/status.
- Add not-found, offline, timeout, rate-limit, server, invalid-response, and storage failures.
- Add Retry/Edit Search to main detail failure.
- Add retry for encounters, forms, move detail, and autocomplete index.
- Add media unavailable/error states.
- Add failure mapping and BLoC tests.

**Outcome:** Failures become understandable and recoverable.

## PR 3 — Responsive, accessible search and detail

- Complete keyboard submission and inline validation.
- Remove duplicate suggestion state.
- Make home keyboard-safe and scrollable.
- Adapt detail header, tabs, stats, and sheets.
- Add type text chips, semantics, tooltips, and media fallbacks.
- Add large-text, dimensions, and accessibility tests.

**Outcome:** The current feature set becomes usable across form factors and assistive technologies.

## PR 4 — Cache correctness and architecture

- Add cache-management use case/interface.
- Remove `HomeBloc`’s dependency on concrete `DataRepository`.
- Add stale-if-error behavior and cache metadata.
- Add schema versioning, limits, clock injection, and request deduplication.
- Fix clear/write races and network/cache-write separation.
- Add cache and parsing tests.

**Outcome:** Offline behavior becomes trustworthy and the architecture again points inward.

## PR 5 — Pokémon index and browse screen

- Replace `List<String>` names with `PokemonIndexEntry`.
- Add browsable list/grid and canonical card component.
- Add local name/ID search.
- Preserve scroll/search state around detail navigation.
- Reuse the canonical detail route.

**Outcome:** PokéFinder becomes a discovery app rather than only a lookup screen.

## PR 6 — Favorites and recents

- Add lightweight persistence models.
- Add favorite action to cards/detail.
- Add favorites and recently viewed sections.
- Add settings to clear history.
- Add persistence and interaction tests.

**Outcome:** Users gain a reason to return regularly.

---

# 13. Definition of Done for Future Features

A feature is complete only when:

- Loading, empty, partial, stale, success, and failure states are considered.
- Recoverable failures have a retry path.
- User-visible strings are localized in English and Italian.
- Numbers and units use locale-aware formatting.
- Small screens, landscape, keyboard, large text, and screen readers are supported.
- Network operations have timeout, cancellation, cache, and deduplication behavior where relevant.
- Optional API fields are modeled safely.
- Resource lifecycle and disposal are explicit.
- Domain/repository dependencies continue pointing inward.
- Unit tests cover domain, parsing, repository, and BLoC branches.
- Widget/integration tests cover the primary journey.
- Relevant README, changelog, and release metadata are updated.
- Formatting, analysis, generation checks, and tests pass.
- Affected release targets receive a smoke test.

---

# Final Recommendation

The newer commits completed many of the old roadmap’s detail-oriented goals. The next major product feature should still be a **browsable, searchable Pokédex**, now built on top of the existing autocomplete index and cache.

Before starting that larger feature, complete four foundations:

1. Platform-aware startup and canonical detail routes.
2. Specific failures with retry behavior.
3. Responsive and accessible current screens.
4. Tested, stale-capable, race-safe caching.

After those foundations, prioritize:

1. Pokémon index and browse screen.
2. Favorites and recently viewed.
3. Species descriptions and evolution chains.
4. Form consistency and shared game/version filtering.

This sequence respects the progress already made while addressing the most important newly visible risks introduced by richer data, caching, forms, and multi-platform support.