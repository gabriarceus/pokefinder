# Task 06: Pokémon Index and Discovery (Browsable Pokédex)

- **Status:** Open
- **Roadmap Reference:** [ROADMAP.md §6.1, §6.2, §6.3](file:///C:/Users/gabri/Documents/GitHub/pokefinder/ROADMAP.md#L673-L776), [PR 5 §12](file:///C:/Users/gabri/Documents/GitHub/pokefinder/ROADMAP.md#L1159-L1168)
- **Target Platforms:** Android & iOS only
- **Priority:** P1 (Product Discovery Milestone)

---

## 1. Context & Objectives

Currently, PokéFinder is strictly a lookup tool for users who already know a specific Pokémon's name or ID. The autocomplete endpoint retrieves thousands of entries via `?limit=100000` but discards the resource URL, keeping only raw strings.

Users cannot browse the Pokédex, filter by type, or explore entries without knowing exact names. 

The objective of this task is to evolve PokéFinder into a browsable discovery mobile app by:
1. Transforming the raw name cache into a structured `PokemonIndexEntry` domain model (capturing ID and name from PokeAPI resource URLs).
2. Introducing a browsable, paginated Pokédex mobile screen (list/2-column cards on phones, adaptive grid on tablets) with loading skeletons, pull-to-refresh, and scroll restoration.
3. Adding mobile-friendly filtering (by type chips, generation picker, sorting by ID/name) and a "Random Pokémon" action.

---

## 2. Impacted Files & Architecture Layers

- **Domain Layer:**
  - `lib/src/3_domain/entities/pokemon_index_entry.dart`
  - Index repository interface & search/filter specifications
- **Data Layer:**
  - Index remote and local data source mapping (extracting numeric IDs from API resource URLs)
  - Caching strategy for the Pokémon index
- **Application Layer:**
  - `PokedexBloc` / `BrowseCubit` (handling pagination, active filters, search queries, sort order)
- **Presentation Layer:**
  - `lib/src/4_presentation/pages/pokedex_browse_page.dart`
  - Reusable mobile `PokemonCard` widget (renders number, name, sprite, types)
  - Mobile filter modal bottom sheet (type chips, generation picker, sorting options)
  - Loading skeleton widgets
  - Native `RefreshIndicator` integration

---

## 3. Action Items

### 3.1 Pokémon Index Model (§6.1)
- [ ] Define `PokemonIndexEntry` domain entity containing:
  - `id` (integer extracted from PokeAPI resource URL)
  - `name` / `canonicalName`
  - `detailUrl`
  - Optional sprite URL derived from ID
- [ ] Update index data source to parse both ID and name without fetching full Pokémon detail records for every item.
- [ ] Unify search suggestions and autocomplete to consume `PokemonIndexEntry`.
- [ ] Implement index loading states: show progress indicator, cached indicator, and non-blocking retry on failure.

### 3.2 Browsable Mobile Pokédex (§6.2)
- [ ] Create a browsable Pokédex view with responsive mobile layouts:
  - Phones: 1-column or 2-column card list.
  - Tablets (iPad / Android tablets): Multi-column adaptive grid.
- [ ] Implement lazy loading/pagination: render cards incrementally without hammering PokeAPI.
- [ ] Provide loading skeletons for initial page load and bottom pagination indicators.
- [ ] Implement native mobile pull-to-refresh (`RefreshIndicator`).
- [ ] Preserve scroll position and filter state when navigating to detail and returning.

### 3.3 Mobile Filters and Enhanced Search (§6.3)
- [ ] Implement mobile filter bottom sheet:
  - Type filters (multi-select filter chips for all 18 Pokémon types).
  - Generation filter (Gen 1 to Gen 9).
  - Sort order (by Pokédex ID ascending/descending, by Name A-Z/Z-A).
- [ ] Support both prefix and contains text searching against index entries.
- [ ] Add a "Random Pokémon" action.
- [ ] Provide an explicit "No Pokémon found matching your filters" state with a one-tap "Clear Filters" action.

---

## 4. Acceptance Criteria

- [ ] Initial Pokédex list displays smoothly without downloading full detail payloads for all Pokémon.
- [ ] Selecting any card navigates to the canonical `/pokemon/:nameOrId` route.
- [ ] Returning from a detail screen restores the user's previous scroll position and active filter selections.
- [ ] Pull-to-refresh triggers a fresh index fetch.
- [ ] Filtering by type (e.g. "Fire" + "Flying") immediately filters the list locally when index is cached.
- [ ] Offline filtering works seamlessly against the cached index.
- [ ] A search query yielding no results displays a distinct empty-search UI rather than a network error.

---

## 5. Testing & Verification Plan

- [ ] **Unit Tests:**
  - `PokemonIndexEntry` parsing from resource URLs.
  - Local index filter logic (type filtering, generation bounds, text search, sorting).
- [ ] **BLoC Tests:**
  - `PokedexBloc` pagination, query changes, filter toggle, reset filters.
- [ ] **Widget Tests:**
  - Card rendering, skeleton loaders, error retry UI, empty search results view.
  - Pull-to-refresh interaction and scroll position restoration.
  - Mobile phone and tablet layout verification.
