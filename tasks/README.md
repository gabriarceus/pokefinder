# PokéFinder Remaining Work

Supersedes the deleted `tasks/` folder and `ROADMAP.md`. Verified against
`main` at commit `f883e87` — everything from the old Tasks 01–09 except the
residuals captured in Task 10 below was found implemented in code
(bootstrap + `/pokemon/:nameOrId` routing, failure taxonomy + audio error
states, responsive/a11y search and detail, stale-capable cache with clock +
LRU + schema versioning + deduplication, CI with release build job, browsable
Pokédex + forms discovery, favorites/recents/preferences, species/evolution/
abilities/game-version, release hardening + About screen). It is therefore
safe to delete the old folder and roadmap file; only the work below remains.

> Target platforms are officially **Android and iOS only**. Desktop and Web
> targets are deliberately out of scope.

## Task index

| #        | Document                                                                                                                    | Priority |     Status     |
| -------- | --------------------------------------------------------------------------------------------------------------------------- | -------- | :------------: |
| **10**   | [Task 10: Share Links, Localization Gaps and Architecture Consistency](task_10_share_localization_and_architecture_gaps.md) | P1       | `[x]` Complete |
| **11.1** | [Task 11.1: Artwork & Sprite-Variant Gallery](task_11_1_artwork_sprite_gallery.md)                                          | P2       | `[x]` Complete |
| **11.2** | [Task 11.2: Pokémon Comparison (Side-by-Side)](task_11_2_pokemon_comparison.md)                                             | P2       | `[x]` Complete |
| **11.3** | [Task 11.3: Type Matchup Calculator (Offline)](task_11_3_type_matchup_calculator.md)                                        | P2       | `[x]` Complete |
| **11.4** | [Task 11.4: Local Team Builder (No Cloud)](task_11_4_local_team_builder.md)                                                 | P2       |   `[ ]` Open   |
| **12**   | [Task 12: Accounts, Cloud Sync and Social (Future Epic, Do Not Build Yet)](task_12_accounts_cloud_sync_and_social.md)       | P3       |   `[ ]` Open   |

## Execution order

```mermaid
graph TD
    T10[Task 10: Hardening gaps] --> T111[Task 11.1: Gallery]
    T10 --> T112[Task 11.2: Comparison]
    T10 --> T113[Task 11.3: Matchup calculator]
    T10 --> T114[Task 11.4: Local teams]
    T111 --> T12[Task 12: Accounts/cloud/social - decision only]
    T112 --> T12
    T113 --> T12
    T114 --> T12
```

Task 10 first (small, closes out the shipped app). Tasks 11.1–11.4 after
(new product value, offline-first, independent of each other — any order).
Task 12 is a decision/spike epic — do not implement until demand, backend,
privacy, and cost are validated.

## Global Definition of Done (applies to Tasks 10–11.4; Task 12 is exempt)

- [ ] Loading, empty, partial, stale, success, and failure states handled; recoverable failures have retry.
- [ ] User-visible strings localized in English (`app_en.arb`) and Italian (`app_it.arb`); no ALL-CAPS in ARB or UI slugs.
- [ ] Numbers/units use locale-aware `intl` formatting; metric/imperial preference respected.
- [ ] No overflow on small phones, landscape, keyboard open, or 200% text scaling; touch targets ≥ 48×48 dp; screen-reader labels on custom controls.
- [ ] Network work has timeout, cancellation, and cache behavior where relevant; no raw exception strings in UI.
- [ ] Dependencies point inward (presentation → application → domain ← repository); no new `getIt` calls in presentation (see Task 10 §3 for the one pattern to follow).
- [ ] Unit/widget tests for new or changed logic, passing locally.
- [ ] `fvm dart format`, `fvm flutter analyze` (0 issues), and `fvm flutter test` pass.
- [ ] `CHANGELOG.md` updated under `[Unreleased]`; `README.md` updated if features/setup changed.
- [ ] Conventional commit message prepared (e.g. `Added: ...`, `Fixed: ...`), no commit without explicit user request.
