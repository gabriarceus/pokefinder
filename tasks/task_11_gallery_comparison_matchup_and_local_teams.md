# Task 11: Gallery, Comparison, Matchup Calculator and Local Teams

- **Status:** Open
- **Priority:** P2 (next product value; offline-first, no backend)
- **Target Platforms:** Android & iOS only
- **Context:** Verified at commit `f883e87`. None of these exist in code
  (grep for comparison/matchup/share returns nothing product-level).
  Prerequisite: Task 10 (share-link pattern, translation-coverage test, and
  the `getIt`/use-case pattern decision) should land first so these features
  reuse canonical routes, localized names, and one DI pattern.

**Explicitly out of scope here:** cloud sync, accounts, social — those are
Task 12. Everything in this file works fully offline against the existing
Hive cache.

---

## 1. Artwork & sprite-variant gallery

The domain model already carries unused artwork fields
(`lib/src/3_domain/entities/pokemon.dart:213-214`
`artworkDefault`/`artworkShiny`; raw DTOs carry `official-artwork` + sprites
in `lib/src/4_repository/models/raw_pokemon/attributes/sprites.dart`). The UI
only shows default/shiny + the inline alternate-forms gallery
(`lib/src/1_presentation/widgets/detail/alternate_forms_widget.dart`).

### Action items

- [ ] Audit `Raw` sprite DTOs against PokeAPI (`front/back`, `shiny`,
      female variants, `other/home`, `official-artwork`): model genuinely
      nullable fields as nullable, keep the existing fallback order
      (official artwork → front default → others).
- [ ] Add a detail gallery section (Info tab or its own lightweight strip):
      grid of available variants with labels, tap-to-preview, graceful
      placeholder per image failure (never a raw `:(` or blank hole).
- [ ] Reuse cached images where the platform cache holds them; do NOT build
      a new binary cache — record only URLs + fallback order.
- [ ] Localize variant labels (EN + IT), add semantics (form, shiny state,
      view direction).

### Acceptance criteria

- [ ] A Pokémon with missing optional sprites still renders the full detail
      page; missing variants show placeholders.
- [ ] Fixture tests cover full, partial, and empty sprite payloads.

### Tests

- [ ] Unit: sprite fallback order + nullable mapping fixtures.
- [ ] Widget: gallery renders placeholders on image failure; semantics
      announce variant names.

---

## 2. Pokémon comparison (side-by-side)

### Action items

- [ ] Add a comparison flow: pick 2 Pokémon (cap at 2 for v1) from browse
      cards and/or detail screen; compare base/min/max stats side by side,
      plus types, height/weight (respecting the metric/imperial preference with
      `intl` formatting).
- [ ] Reuse existing stat-bar and type-chip components; share-link each
      compared entry via the Task 10 canonical link pattern.
- [ ] Entry points: long-press / compare action on `PokemonCard`, compare
      action on detail. Clear-all + remove-one controls; empty state explains
      how to add entries.
- [ ] Persist nothing remotely; in-memory for v1 (optionally restore last
      comparison from durable storage — decide during implementation, keep it
      lightweight index refs only).

### Acceptance criteria

- [ ] Two valid Pokémon render aligned stat rows with correct values even
      when API stat arrays arrive reordered (existing by-name mapping).
- [ ] Invalid/failed entries never enter the comparison; failure shows retry
      without destroying the valid side.

### Tests

- [ ] Unit: stat alignment, unit conversion reuse, max-2 enforcement.
- [ ] Widget: add/remove/clear flows, empty state, error state.

---

## 3. Type matchup calculator (offline)

### Action items

- [ ] Add a pure-domain 18-type effectiveness chart (attack × defense
      multipliers), fully offline with unit tests — no network.
- [ ] UI: select 1–2 defending types (preset from any detail type chip),
      display weaknesses / resistances / immunities grouped by multiplier
      (4×, 2×, ½×, ¼×, 0×). Localize all type names via existing chips.
- [ ] Entry point: tap a type chip → "View matchups" + a standalone tool
      route/screen.

### Acceptance criteria

- [ ] Chart matches canonical multipliers for all 324 attack/defense pairs;
      dual-type multiplication (e.g. 4×, ¼×, 0× immunity override) is correct.
- [ ] Works fully offline; screen-reader announces defending types and each
      result group.

### Tests

- [ ] Unit: full chart snapshot + dual-type edge cases (immunity overrides,
      double weakness/resistance).
- [ ] Widget: type selection, result groups, empty state.

---

## 4. Local team builder (no cloud)

### Action items

- [ ] Teams of up to 6 stored locally in durable storage as lightweight
      index refs (`id`, `name`, timestamp) — never duplicate full API payloads.
- [ ] Team list screen + team detail: add/remove from detail and browse
      cards, reorder (or move-to-top), rename team, delete team with confirm.
- [ ] Team summary: type coverage of the 6 members + summed/average base
      stats (reuse comparison components). Warn on duplicates; allow forms as
      distinct members with distinct labels (reuse form-classifier display
      names).
- [ ] Empty states explain how to build a team. All strings EN + IT.

### Acceptance criteria

- [ ] Teams survive restart; 7th member is rejected with guidance; corrupt
      team records are evicted without crashing the list.
- [ ] Team detail deep-links each member via the canonical
      `/pokemon/:nameOrId` route.

### Tests

- [ ] Unit: CRUD, 6-member cap, dedup/form-member rules, corrupt-record
      eviction, coverage summary.
- [ ] Widget: create/rename/delete with confirm, add/remove flows, empty
      states.

---

## Verification

- [ ] Each sub-feature independently meets the global Definition of Done in
      `tasks2/README.md` (states, retry, EN+IT, responsive/a11y, tests).
- [ ] `fvm dart format lib test`, `fvm flutter analyze` (0 issues),
      `fvm flutter test` pass. `CHANGELOG.md` updated.
