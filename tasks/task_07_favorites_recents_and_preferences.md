# Task 07: Repeat-Use Features and User Preferences

- **Status:** Completed
- **Roadmap Reference:** [ROADMAP.md §7.1, §7.2, §7.3](file:///C:/Users/gabri/Documents/GitHub/pokefinder/ROADMAP.md#L777-L840), [PR 6 §12](file:///C:/Users/gabri/Documents/GitHub/pokefinder/ROADMAP.md#L1169-L1178)
- **Priority:** P1 (Retention & Personalization Milestone)

---

## 1. Context & Objectives

Currently, PokéFinder offers no repeat-use retention mechanics:
- Users cannot bookmark or save favorite Pokémon.
- There is no history of recently viewed Pokémon or recent search queries.
- Settings are limited to language selection and raw cache clearing; there is no theme toggle (light/dark/system), no unit preference (metric vs imperial), and no storage usage summary.

The goal of this task is to provide persistent favorites, bounded recent history, and expanded user preferences stored reliably in durable storage.

---

## 2. Impacted Files & Architecture Layers

- **Domain Layer:**
  - `FavoritePokemon` entity / repository contract
  - `RecentPokemon` entity / repository contract
  - User preferences entity (ThemeMode, UnitSystem, CryVolume)
- **Data Layer:**
  - Local persistence for favorites and recent history (lightweight IDs and timestamps, avoiding duplicate full API payloads)
- **Application Layer:**
  - `FavoritesCubit` / `FavoritesBloc`
  - `RecentHistoryCubit`
  - `PreferencesCubit` (persisted via HydratedBloc in durable storage)
- **Presentation Layer:**
  - Dedicated Favorites screen
  - Home screen "Recent Searches" and "Recently Viewed" horizontal shelf/chips
  - Detail page favorite toggle button (app bar heart/star icon)
  - Expanded Settings screen / drawer with theme, unit selection, history management, and cache metrics
- **Localization:**
  - English & Italian strings for all new settings, units, and empty states

---

## 3. Action Items

### 3.1 Favorites Management (§7.1)
- [x] Add a favorite toggle icon button in the detail screen app bar and on Pokédex cards.
- [x] Persist favorite records as lightweight items (`id`, `name`, `timestamp`) in durable local storage.
- [x] Synchronize favorite state reactively across all screens (changing a favorite on detail immediately reflects on Pokédex browse cards and favorites screen).
- [x] Build a dedicated Favorites screen with sorting (by Pokédex ID, name, date added).
- [x] Design an empty state with clear illustration and instructions on how to add favorites.

### 3.2 Recently Viewed & Search History (§7.2)
- [x] Maintain a bounded list of recently viewed Pokémon (e.g. maximum 20 entries).
- [x] Update timestamps and move entries to the top when revisited (deduplication).
- [x] Show a "Recently Viewed" quick-access shelf on the home screen.
- [x] Add controls to remove individual entries and clear entire history.
- [x] Provide a preference toggle to pause or clear recent history.

### 3.3 Expanded User Preferences (§7.3)
- [x] **Theme Settings:** Add System / Light / Dark theme toggle; apply theme immediately without restart.
- [x] **Measurement Units:** Add Metric (m, kg) vs Imperial (ft/in, lbs) preference toggle.
  - Implement conversion helpers and format with locale-aware `intl` formatting.
- [x] **Audio Preferences:** Add audio preference (auto-play cry on detail open toggle, volume control).
- [x] **Storage & Cache Metrics:** Display approximate cache size with a confirmation dialog before clearing.

---

## 4. Acceptance Criteria

- [x] Toggling a favorite on a detail screen is immediately reflected when navigating back to the list.
- [x] Favorites and recently viewed lists persist across application restart.
- [x] Invalid or failed searches are never added to the viewed history.
- [x] Switching between metric and imperial immediately updates height and weight displays on detail tabs.
- [x] Theme changes apply instantaneously across all open screens.
- [x] History adheres strictly to the defined maximum capacity (oldest items evicted).

---

## 5. Testing & Verification Plan

- [x] **Unit Tests:**
  - Unit conversion helpers (kg to lbs, m to feet/inches) with boundary values.
  - Bounded history queue (deduplication, capacity limit eviction, clear).
  - Favorites repository CRUD operations.
- [x] **BLoC Tests:**
  - `FavoritesCubit` and `RecentHistoryCubit` state persistence and hydration.
  - `PreferencesCubit` theme and unit state transitions.
- [x] **Widget Tests:**
  - Empty favorites screen state.
  - Favorite toggle button interactions on detail page.
  - Settings page toggles and confirmation dialog.
