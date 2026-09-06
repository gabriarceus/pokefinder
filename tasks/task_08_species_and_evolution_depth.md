# Task 08: Species, Evolution Depth and Form Consistency

- **Status:** Open
- **Roadmap Reference:** [ROADMAP.md §8.1 – §8.5](file:///C:/Users/gabri/Documents/GitHub/pokefinder/ROADMAP.md#L841-L943)
- **Priority:** P2 (Product Depth & Pokémon Mechanics)

---

## 1. Context & Objectives

While PokéFinder displays extensive base stats, moves, and held items, it leaves out crucial Pokédex information:
- The species endpoint is not queried: flavor text descriptions, genus ("The Seed Pokémon"), generation, and habitat are completely absent.
- Evolution chains are not displayed: users cannot see how a Pokémon evolves, what triggers are required (level, trade, item, friendship), or navigate through branching evolution lines (e.g. Eevee, Tyrogue).
- Abilities are displayed as chips without behavior descriptions.
- Alternate forms are inconsistent: changing a form updates the header sprite and types, but stats, moves, and abilities continue showing base-form values.
- Game version contexts are fragmented across tabs: moves use version groups, while encounters and held items show separate, unfiltered lists.

The goal of this task is to fetch species and evolution details, provide on-demand ability descriptions, harmonize alternate form data, and unify game version filtering across the detail screen.

---

## 2. Impacted Files & Architecture Layers

- **Domain Layer:**
  - `PokemonSpecies` entity (flavor text entries, genus, generation, habitat, evolution chain URL)
  - `EvolutionChain` entity (tree structure supporting linear and branched evolutions)
  - `AbilityDetail` entity (localized effect and short description)
- **Data Layer:**
  - `SpeciesRemoteDataSource` & `SpeciesRepository`
  - Evolution chain parser handling nested triggers, items, and special conditions
  - Ability remote data source and caching
- **Application Layer:**
  - `SpeciesCubit` / `EvolutionCubit`
  - `AbilityDetailCubit`
  - Game version context state management
- **Presentation Layer:**
  - New "About / Species" tab or section on detail page (flavor text, genus, generation)
  - Interactive evolution chain widget with tap-to-navigate support
  - Ability detail bottom sheet/dialog
  - Shared version selector dropdown affecting moves, encounters, and items

---

## 3. Action Items

### 3.1 Species Information & Flavor Text (§8.1)
- [ ] Fetch the species endpoint using `Pokemon.speciesUrl`.
- [ ] Extract localized Pokédex flavor text according to active app locale (Italian with English fallback).
- [ ] Clean up legacy formatting artifacts (form feed `\f` and escaped line breaks `\n` common in PokeAPI flavor text).
- [ ] Extract genus (e.g. "Mouse Pokémon"), generation, and habitat.
- [ ] Provide independent loading and retry states: species failure must not hide the main Pokémon detail.

### 3.2 Evolution Chain Visualization (§8.2)
- [ ] Fetch and parse the nested evolution chain tree.
- [ ] Model both linear evolutions (e.g., Bulbasaur → Ivysaur → Venusaur) and branching evolutions (e.g., Eevee, Gloom, Tyrogue).
- [ ] Render evolution triggers: minimum level, evolution stone/item, trade, high friendship, time of day.
- [ ] Allow tapping any Pokémon in the chain to navigate to its canonical `/pokemon/:nameOrId` route.

### 3.3 Ability Descriptions (§8.3)
- [ ] Enable tapping ability chips to open an ability detail bottom sheet.
- [ ] Fetch and display the localized ability description and in-depth battle effect.
- [ ] Cache ability details to avoid repeated network calls.

### 3.4 Alternate Form Consistency (§8.4)
- [ ] Resolve data inconsistency when switching alternate forms:
  - Either fetch full Pokémon data for the specific form, or clearly visually distinguish form-specific changes from base-species data.
- [ ] Surface `formFailure` visibly within the form selection modal with a retry action or safe rollback to the default form.

### 3.5 Unified Game / Version Selector (§8.5)
- [ ] Add an optional detail-wide game version dropdown (e.g., "Scarlet / Violet", "Sword / Shield", "Red / Blue").
- [ ] Synchronize moves, encounter locations, and held items to reflect the selected game version simultaneously.

---

## 4. Acceptance Criteria

- [ ] Pokédex description renders correctly formatted text without odd whitespace or `\f` glyphs.
- [ ] Descriptions adapt to Italian if available, falling back gracefully to English.
- [ ] Branching evolution chains render clearly with appropriate trigger badges.
- [ ] Tapping an evolution in the chain navigates directly to that Pokémon's detail page.
- [ ] Tapping an ability displays its description in a clean modal.
- [ ] Switching forms no longer creates contradictory stats or types.

---

## 5. Testing & Verification Plan

- [ ] **Unit Tests:**
  - Text normalization helper (stripping form feeds, carriage returns).
  - Evolution chain parser unit tests covering:
    - Linear chain (Charmander)
    - Branched chain (Eevee - 8 branches)
    - Complex triggers (Item, Trade, Happiness, Location)
- [ ] **BLoC Tests:**
  - `SpeciesCubit` and `EvolutionCubit` state emissions.
- [ ] **Widget Tests:**
  - Evolution chain rendering and navigation taps.
  - Ability detail sheet presentation.
