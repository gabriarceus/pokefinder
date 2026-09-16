# Task 11.4: Local Team Builder (No Cloud)

- **Status:** Complete
- **Priority:** P2 (next product value; offline-first, no backend)
- **Target Platforms:** Android & iOS only
- **Context:** Split from Task 11 (Gallery, Comparison, Matchup Calculator and
  Local Teams) into four standalone files (11.1–11.4). Verified at commit
  `f883e87`. No team code exists in code. Prerequisite: Task 10 (share-link
  pattern, translation-coverage test, and the `getIt`/use-case pattern
  decision) should land first so this feature reuses canonical routes,
  localized names, and one DI pattern.

**Explicitly out of scope here:** cloud sync, accounts, social — those are
Task 12. Everything in this file works fully offline against the existing
Hive cache.

---

## 1. Local team builder (no cloud)

### Action items

- [x] Teams of up to 6 stored locally in durable storage as lightweight
      index refs (`id`, `name`, timestamp) — never duplicate full API payloads.
- [x] Team list screen + team detail: add/remove from detail and browse
      cards, reorder (or move-to-top), rename team, delete team with confirm.
- [x] Team summary: type coverage of the 6 members + summed/average base
      stats (reuse comparison components). Warn on duplicates; allow forms as
      distinct members with distinct labels (reuse form-classifier display
      names).
- [x] Empty states explain how to build a team. All strings EN + IT.

### Acceptance criteria

- [x] Teams survive restart; 7th member is rejected with guidance; corrupt
      team records are evicted without crashing the list.
- [x] Team detail deep-links each member via the canonical
      `/pokemon/:nameOrId` route.

### Tests

- [x] Unit: CRUD, 6-member cap, dedup/form-member rules, corrupt-record
      eviction, coverage summary.
- [x] Widget: create/rename/delete with confirm, add/remove flows, empty
      states.

---

## Open questions (resolved during implementation)

- [x] Durable-storage mechanism: hydrated `TeamsCubit` (same pattern as
  favorites) — survives restart via documents storage.
- [x] Reorder vs. move-to-top: both — drag-reorder via `ReorderableListView`
  plus a per-row move-to-top action.
- [x] Team summary formula: both — per-stat summed and average rows plus
  summed and average totals, reusing comparison components.
- [x] Duplicate warning vs. hard-block: warn, don't block — duplicates stay
  allowed with an inline banner; forms (distinct slugs) are distinct members.
- [x] Corrupt-record eviction policy: log via `EnLogger` and skip the record
  (per team, per member); never crash.

---

## Verification

- [x] Meets the global Definition of Done in `tasks/README.md` (states,
      retry, EN+IT, responsive/a11y, tests).
- [x] `fvm dart format lib test`, `fvm flutter analyze` (0 issues),
      `fvm flutter test` pass. `CHANGELOG.md` updated.
