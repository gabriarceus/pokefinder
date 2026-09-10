# Task 03: Mobile Responsive Layouts and Deliberate Accessibility (Android & iOS)

- **Status:** Completed
- **Roadmap Reference:** [ROADMAP.md §4.4, §4.5, §4.6](file:///C:/Users/gabri/Documents/GitHub/pokefinder/ROADMAP.md#L303-L430), [PR 3 §12](file:///C:/Users/gabri/Documents/GitHub/pokefinder/ROADMAP.md#L1137-L1147)
- **Target Platforms:** Android & iOS only
- **Priority:** P0 (Release Blocker)

---

## 1. Context & Objectives

Currently, the home screen uses fixed 200-pixel width constraints, `resizeToAvoidBottomInset: false`, and a non-scrollable column. When the mobile virtual keyboard opens or when the screen rotates to landscape, the home screen immediately overflows with layout errors. Search suggestions are duplicated between `HomeBloc` and `RawAutocomplete`, and keyboard search action submission is missing.

On the detail page, elements (sprite dimensions, tab bar text, stat columns, bottom sheets) are hardcoded for standard phone portrait orientation. When system text scaling reaches 200% (Dynamic Type on iOS or Font Scale on Android) or on small devices (e.g. iPhone SE), visual overflow occurs.

In addition, accessibility is sparse: Pokémon types rely exclusively on remote images without text chips or semantic labels, audio playback buttons have no tooltips, and stats announce normalized percentages rather than actual visible numbers.

The goal of this task is to complete the mobile search interaction, ensure robust responsiveness across phones, tablets, and orientations, and introduce comprehensive mobile accessibility semantics.

---

## 2. Impacted Files & Architecture Layers

- **Presentation / Search & Home:**
  - `lib/src/1_presentation/pages/home/home_page.dart`
  - `lib/src/1_presentation/widgets/home/poke_text_field.dart`
  - `lib/src/2_application/bloc/home_bloc/home_bloc.dart`
- **Presentation / Detail Shell & Tabs:**
  - `lib/src/1_presentation/pages/detail/detail_page.dart`
  - `lib/src/1_presentation/pages/detail/tabs/detail_stats_tab.dart`
  - `lib/src/1_presentation/pages/detail/tabs/detail_info_tab.dart`
  - `lib/src/1_presentation/pages/detail/tabs/tabs.dart`
  - `lib/src/1_presentation/widgets/detail/cry_play_button.dart`
  - `lib/src/1_presentation/pages/detail/widgets/form_selection_bottom_sheet.dart`
  - `lib/src/1_presentation/widgets/detail/move_detail_bottom_sheet.dart`
- **UI Components & Theme:**
  - `lib/src/1_presentation/widgets/detail/type_chip.dart` (reusable localized type chip with image fallback)
- **Localization:**
  - `lib/l10n/app_en.arb`, `lib/l10n/app_it.arb` (tooltips, a11y labels)

---

## 3. Action Items

### 3.1 Mobile Search Interaction Ergonomics (§4.4)
- [x] Configure `TextInputAction.search` on the search input field so the mobile virtual keyboard displays a "Search" / blue action button.
- [x] Support keyboard action submission (`onSubmitted`) to trigger search identically to the search icon button.
- [x] Consolidate search suggestion filtering into a single state source (eliminate duplicate filtering between `HomeBloc` and `RawAutocomplete`).
- [x] Provide inline validation feedback below the search field instead of relying solely on transient Snackbars.
- [x] Prevent duplicate submissions by disabling submit action while a search query is in flight.
- [x] Normalize queries (trim whitespace) before computing autocomplete suggestions, not only on submission.

### 3.2 Mobile & Tablet Responsive Screen Layouts (§4.5)
- [x] **Home Page:**
  - Set `resizeToAvoidBottomInset: true` and wrap content in a scrollable view (`SingleChildScrollView`).
  - Replace fixed 200px widths with adaptive layout constraints.
  - Ensure decorative Pokéball scales down gracefully on small screens and landscape orientation.
  - Ensure the virtual keyboard never obscures the search input field or suggestions dropdown.
- [x] **Detail Page:**
  - Adapt header for phone portrait, landscape, and tablet orientations.
  - Make the 4 detail tabs scrollable (`TabBar(isScrollable: true)`) to prevent tab label truncation at high text scales.
  - Reflow stats columns dynamically to prevent horizontal overflow on narrow mobile screens.
  - Ensure form selection and move detail bottom sheets are constrained with `SafeArea` and scroll-safe (`DraggableScrollableSheet` / `SingleChildScrollView`).

### 3.3 Deliberate Accessibility & Media Semantics (§4.6)
- [x] Introduce localized text chips for Pokémon types (text chip with badge color) so types are accessible even if badge images fail to load.
- [x] Add explicit semantic labels (`Semantics` widget with `excludeSemantics: true`) to:
  - Sprites (announce Pokémon name, form, shiny status).
  - Cries button (announce "Play cry for [Pokémon]", "Stop cry", "Cry unavailable").
  - Base stats (announce stat name, current value, min/max values).
  - Form selection chips and shiny toggle buttons.
- [x] Provide localized `tooltip` attributes to all icon buttons (cry, shiny toggle, settings, back).
- [x] Ensure all touch targets meet mobile accessibility minimums (48×48 dp).
- [x] Support system dynamic font scaling up to 200% without layout clipping.

---

## 4. Acceptance Criteria

- [x] Tapping the virtual keyboard "Search" action triggers lookup identically to tapping the search button.
- [x] Entering spaces or leading whitespace does not break autocomplete suggestions.
- [x] No layout overflow occurs on small phones (e.g. 320px width iPhone SE), in landscape orientation, or at 200% system text scaling.
- [x] The virtual keyboard does not hide the search input.
- [x] Screen readers (TalkBack on Android / VoiceOver on iOS) clearly announce Pokémon name, Pokédex number, types, stats, and audio button states.
- [x] If remote type badges fail to load, localized text chips remain readable and accessible.

---

## 5. Testing & Verification Plan

- [x] **Widget Tests:**
  - Mobile search input `onSubmitted` action trigger verification.
  - Responsive layout tests across representative mobile viewports:
    - 320×568 (iPhone SE 1st gen)
    - 390×844 (Standard phone)
    - 844×390 (Phone landscape)
    - 768×1024 (Tablet / iPad)
  - Text scale factor test: verify 0 overflow at `textScaler: TextScaler.linear(2.0)`.
- [x] **Accessibility Tests:**
  - Touch targets meet minimum 48×48 dp requirement.
  - Semantics tree verification for detail page header, stats, and audio button.
