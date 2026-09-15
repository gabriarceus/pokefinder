# Task 11.2: Pokémon Comparison (Side-by-Side)

- **Status:** Open
- **Priority:** P2 (next product value; offline-first, no backend)
- **Target Platforms:** Android & iOS only
- **Context:** Split from Task 11 (Gallery, Comparison, Matchup Calculator and
  Local Teams) into four standalone files (11.1–11.4). Verified at commit
  `f883e87`. No comparison code exists in code (grep for comparison returns
  nothing product-level). Prerequisite: Task 10 (share-link pattern,
  translation-coverage test, and the `getIt`/use-case pattern decision)
  should land first so this feature reuses canonical routes, localized names,
  and one DI pattern.

**Explicitly out of scope here:** cloud sync, accounts, social — those are
Task 12. Everything in this file works fully offline against the existing
Hive cache.

---

## 1. Pokémon comparison (side-by-side)

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

## Open questions (carried over, not resolved in split)

- [ ] Persistence: in-memory for v1 vs. optionally restoring last comparison
      from durable storage (lightweight index refs only) — decide during
      implementation.
- [ ] Entry UX: long-press vs. explicit compare action on `PokemonCard` —
      both listed, final choice open.
- [ ] Depends on the Task 10 canonical link pattern landing first for
      per-entry share links.

---

## Verification

- [ ] Meets the global Definition of Done in `tasks/README.md` (states,
      retry, EN+IT, responsive/a11y, tests).
- [ ] `fvm dart format lib test`, `fvm flutter analyze` (0 issues),
      `fvm flutter test` pass. `CHANGELOG.md` updated.
