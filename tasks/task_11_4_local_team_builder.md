# Task 11.4: Local Team Builder (No Cloud)

- **Status:** Open
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

## Open questions (carried over, not resolved in split)

- [ ] Durable-storage mechanism not pinned (presumably Hive via the existing
      `LocalStorage` pattern like favorites, but not stated).
- [ ] Reorder vs. move-to-top undecided.
- [ ] Team summary formula undecided (summed vs. average base stats); duplicate
      warning vs. hard-block wording open.
- [ ] Corrupt-record eviction policy needs definition (silent evict vs. log;
      never crash is the only stated rule).

---

## Verification

- [ ] Meets the global Definition of Done in `tasks/README.md` (states,
      retry, EN+IT, responsive/a11y, tests).
- [ ] `fvm dart format lib test`, `fvm flutter analyze` (0 issues),
      `fvm flutter test` pass. `CHANGELOG.md` updated.
