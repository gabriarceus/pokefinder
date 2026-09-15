# Task 11.3: Type Matchup Calculator (Offline)

- **Status:** Open
- **Priority:** P2 (next product value; offline-first, no backend)
- **Target Platforms:** Android & iOS only
- **Context:** Split from Task 11 (Gallery, Comparison, Matchup Calculator and
  Local Teams) into four standalone files (11.1–11.4). Verified at commit
  `f883e87`. No matchup code exists in code (grep for matchup returns nothing
  product-level). Prerequisite: Task 10 (share-link pattern,
  translation-coverage test, and the `getIt`/use-case pattern decision)
  should land first so this feature reuses canonical routes, localized names,
  and one DI pattern.

**Explicitly out of scope here:** cloud sync, accounts, social — those are
Task 12. Everything in this file works fully offline against the existing
Hive cache.

---

## 1. Type matchup calculator (offline)

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

## Open questions (carried over, not resolved in split)

- [ ] Canonical chart version not pinned (which generation's multipliers are
      the source of truth for the snapshot test).
- [ ] Standalone tool route name/path not specified.
- [ ] "Preset from any detail type chip" interaction not detailed (which chip
      tap behavior wins vs. existing navigation).

---

## Verification

- [ ] Meets the global Definition of Done in `tasks/README.md` (states,
      retry, EN+IT, responsive/a11y, tests).
- [ ] `fvm dart format lib test`, `fvm flutter analyze` (0 issues),
      `fvm flutter test` pass. `CHANGELOG.md` updated.
