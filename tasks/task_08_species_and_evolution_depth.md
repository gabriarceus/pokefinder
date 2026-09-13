# Task 08: Species, Evolution Depth and Form Consistency

- **Status:** Completed
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
- [x] Fetch the species endpoint using `Pokemon.speciesUrl`.
- [x] Extract localized Pokédex flavor text according to active app locale (Italian with English fallback).
- [x] Clean up legacy formatting artifacts (form feed `\f` and escaped line breaks `\n` common in PokeAPI flavor text).
- [x] Extract genus (e.g. "Mouse Pokémon"), generation, and habitat.
- [x] Provide independent loading and retry states: species failure must not hide the main Pokémon detail.

### 3.2 Evolution Chain Visualization (§8.2)
- [x] Fetch and parse the nested evolution chain tree.
- [x] Model both linear evolutions (e.g., Bulbasaur → Ivysaur → Venusaur) and branching evolutions (e.g., Eevee, Gloom, Tyrogue).
- [x] Render evolution triggers: minimum level, evolution stone/item, trade, high friendship, time of day.
- [x] Allow tapping any Pokémon in the chain to navigate to its canonical `/pokemon/:nameOrId` route.

### 3.3 Ability Descriptions (§8.3)
- [x] Enable tapping ability chips to open an ability detail bottom sheet.
- [x] Fetch and display the localized ability description and in-depth battle effect.
- [x] Cache ability details to avoid repeated network calls.

### 3.4 Alternate Form Consistency (§8.4)
- [x] Resolve data inconsistency when switching alternate forms:
  - Either fetch full Pokémon data for the specific form, or clearly visually distinguish form-specific changes from base-species data.
- [x] Surface `formFailure` visibly within the form selection modal with a retry action or safe rollback to the default form.

### 3.5 Unified Game / Version Selector (§8.5)
- [x] Add an optional detail-wide game version dropdown (e.g., "Scarlet / Violet", "Sword / Shield", "Red / Blue").
- [x] Synchronize moves, encounter locations, and held items to reflect the selected game version simultaneously.

### 3.6 Special Evolution Mechanics & Comprehensive Triggers (§8.2 Extension)
- [x] Support and format all advanced PokéAPI evolution trigger flags in `EvolutionTriggerFormatter`:
  - `turn_upside_down: true` (e.g. Inkay → Malamar: `Lv. 30 (Turn device upside down)`)
  - `needs_overworld_rain: true` (e.g. Sliggoo → Goodra: `Lv. 50 (Rain)`)
  - `relative_physical_stats` (e.g. Tyrogue: `Lv. 20 (Atk > Def)` → Hitmonlee, `(Def > Atk)` → Hitmonchan, `(Atk = Def)` → Hitmontop)
  - `party_species` / `party_type` (e.g. Mantyke → Mantine with Remoraid in party; Pancham → Pangoro with Dark-type in party)
  - `trade_species` (e.g. Karrablast ↔ Shelmet)
  - `gender` constraint (e.g. Combee → Vespiquen Female only, Salandit → Salazzle Female only, Gallade Male only)
  - `min_affection` / `min_beauty` (e.g. Sylveon, Milotic)
- [x] Localize all special condition strings in English and Italian (`app_en.arb`, `app_it.arb`).

### 3.7 Ability Language Strategy & PokéAPI Analysis (§8.3 Technical Note)
- **Data Availability in PokéAPI:**
  - `flavor_text_entries`: Official game ROM descriptions from Nintendo/Game Freak — **fully localized in Italian** (from Gen 6 onwards). Used as the primary Italian summary.
  - `effect_entries`: Detailed competitive battle breakdown written by the community of PokéAPI maintainers — **only written in English (`en`), French (`fr`), and German (`de`)**. PokéAPI does *not* provide Italian `effect_entries`.
- **Strategy & Presentation:**
  - Summary displays the official Italian text (`flavor_text_entries`).
  - Detailed battle breakdown defaults to English (`effect_entries['en']`) when Italian is absent, with a clear fallback indicator if appropriate.

### 3.8 Inline Alternate Forms Gallery (§8.4 Extension)
- [x] Display an inline "Alternate Forms" card/section on the detail screen (e.g. in the Info tab right beneath or alongside the Evolution Chain).
- [x] Visually show all alternate forms (Regional: Alolan, Galarian, Hisuian, Paldean; Mega Evolutions; Gigantamax) with their sprite, formatted form name, and primary/secondary types.
- [x] Allow tapping any form directly from the inline gallery to switch forms without having to open the header modal bottom sheet.

---

## 4. Acceptance Criteria

- [x] Pokédex description renders correctly formatted text without odd whitespace or `\f` glyphs.
- [x] Descriptions adapt to Italian if available, falling back gracefully to English.
- [x] Branching evolution chains render clearly with appropriate trigger badges.
- [x] Tapping an evolution in the chain navigates directly to that Pokémon's detail page.
- [x] Tapping an ability displays its description in a clean modal.
- [x] Switching forms no longer creates contradictory stats or types.
- [x] Advanced evolution triggers (upside-down, rain, stat relations, party species, gender) display descriptive combined badges.
- [x] Alternate forms are displayed directly in an inline section with tap-to-switch capability.

---

## 5. Testing & Verification Plan

- [x] **Unit Tests:**
  - Text normalization helper (stripping form feeds, carriage returns).
  - Evolution chain parser unit tests covering:
    - Linear chain (Charmander)
    - Branched chain (Eevee - 8 branches)
    - Complex triggers (Item, Trade, Happiness, Location)
- [x] **Extended Unit Tests:**
  - Special evolution conditions parser & formatter tests (Inkay turn_upside_down, Sliggoo rain, Tyrogue stats, Combee gender).
- [x] **BLoC Tests:**
  - `SpeciesCubit` and `EvolutionCubit` state emissions.
  - `AbilityDetailCubit` and `DetailGameVersionCubit` state emissions.
- [x] **Widget Tests:**
  - Evolution chain rendering and navigation taps.
  - Ability detail sheet presentation.
  - Game version selector dropdown and tab synchronization.
- [x] **Extended Widget Tests:**
  - Inline Alternate Forms gallery rendering and tap-to-switch verification.
