# Task 11.1: Artwork & Sprite-Variant Gallery

- **Status:** Complete
- **Priority:** P2 (next product value; offline-first, no backend)
- **Target Platforms:** Android & iOS only
- **Context:** Split from Task 11 (Gallery, Comparison, Matchup Calculator and
  Local Teams) into four standalone files (11.1–11.4). Verified at commit
  `f883e87`. This gallery does not exist in code. Prerequisite: Task 10
  (share-link pattern, translation-coverage test, and the `getIt`/use-case
  pattern decision) should land first so this feature reuses canonical routes,
  localized names, and one DI pattern.

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

- [x] Audit `Raw` sprite DTOs against PokeAPI (`front/back`, `shiny`,
      female variants, `other/home`, `official-artwork`): model genuinely
      nullable fields as nullable, keep the existing fallback order
      (official artwork → front default → others).
- [x] Add a detail gallery section (Info tab or its own lightweight strip):
      grid of available variants with labels, tap-to-preview, graceful
      placeholder per image failure (never a raw `:(` or blank hole).
- [x] Reuse cached images where the platform cache holds them; do NOT build
      a new binary cache — record only URLs + fallback order.
- [x] Localize variant labels (EN + IT), add semantics (form, shiny state,
      view direction).

### Acceptance criteria

- [x] A Pokémon with missing optional sprites still renders the full detail
      page; missing variants show placeholders.
- [x] Fixture tests cover full, partial, and empty sprite payloads.

### Tests

- [x] Unit: sprite fallback order + nullable mapping fixtures.
- [x] Widget: gallery renders placeholders on image failure; semantics
      announce variant names.

---

## Open questions (carried over, resolved during implementation)

- [x] Gallery placement: Info tab vs. its own lightweight strip — decided:
      Info tab section after Alternate Forms (reuses `spriteTitle` header).
- [x] "Reuse cached images where the platform cache holds them" is pinned to
      `Image.network` (platform image cache); only URLs + fallback order are
      recorded, no new binary cache.
- [x] Full variant-label list (EN + IT) enumerated: 14 `gallery*` ARB keys
      (official artwork, front/back, shiny, female, Home combinations).

---

## Verification

- [x] Meets the global Definition of Done in `tasks/README.md` (states,
      retry, EN+IT, responsive/a11y, tests).
- [x] `fvm dart format lib test`, `fvm flutter analyze` (0 issues),
      `fvm flutter test` pass. `CHANGELOG.md` updated.
