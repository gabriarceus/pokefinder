# Task 10: Share Links, Localization Gaps and Architecture Consistency

- **Status:** Open
- **Priority:** P1 (closes out the shipped app before new features)
- **Target Platforms:** Android & iOS only
- **Context:** Verified at commit `f883e87`. The old Tasks 01–09 work is
  present in code (canonical `/pokemon/:nameOrId` route in
  `lib/src/1_presentation/router/app_router.dart`, failure taxonomy,
  responsive/a11y detail, stale-capable cache, CI with release build in
  `.github/workflows/ci.yml`, log sanitizer + payload truncation). The items
  below are the verified residuals — each was grep-checked and found missing
  or inconsistent.

---

## 1. Canonical share / copy-link

No share or copy-link code exists (grep for `Share`, `share_plus`, copy-link
returns nothing outside a styling comment).

### Action items

- [ ] Add a share/copy action on the detail screen (app bar or header) that
      shares the canonical identifier (`/pokemon/:nameOrId`, e.g.
      `/pokemon/pikachu`, `/pokemon/25`).
- [ ] Use clipboard copy as the baseline; add OS share sheet (`share_plus`
      or equivalent) only if it pulls no unjustified permissions.
- [ ] Handle the incoming link: cold-start deep link / app link / universal
      link resolving to the existing canonical route with the not-found fallback
      for invalid values.
- [ ] Localize all strings (EN + IT), add tooltip + screen-reader label, meet
      48×48 dp target.

### Acceptance criteria

- [ ] Tapping share on a detail screen produces the canonical link for the
      currently displayed Pokémon/form.
- [ ] Opening that link cold-resolves to the same Pokémon; invalid values hit
      the router error screen, never a cast crash.
- [ ] No new permissions declared on Android or iOS for this feature.

### Tests

- [ ] Unit: link build/parse round-trip (names, numeric IDs, invalid input).
- [ ] Widget: share button renders label/tooltip, invokes share-or-copy;
      incoming-link navigation resolves and preserves back behavior.

---

## 2. Held-item slugs and translation coverage

`lib/src/1_presentation/pages/detail/tabs/detail_items_games_tab.dart:316-318`
renders held items as:

```dart
item.name.replaceAll('-', ' ').toUpperCase()
```

That is an ALL-CAPS API slug (e.g. `KINGS ROCK`), unlocalized, and violates
the repo rule (no ALL-CAPS; uppercase in Dart only, never raw slugs in UI).

### Action items

- [ ] Add an item-name translation database alongside the existing
      `lib/l10n/*_db.dart` files (abilities/moves/locations pattern), EN + IT,
      with a title-case fallback (never UPPER).
- [ ] Audit and fix the same class of bug wherever it remains: raw domain
      failure strings reaching move detail, fallback move/form/learn-method
      labels stuck in raw API English, mixed-language location output.
- [ ] Add an automated translation-coverage test (abilities, moves, items,
      locations): every key rendered by the app has EN + IT entries or an
      explicitly documented fallback; test fails on silent raw-slug rendering.
- [ ] Document which proper names intentionally stay canonical (e.g.
      Pokémon species names) vs. which must be localized.

### Acceptance criteria

- [ ] Zero ALL-CAPS slug rendering in detail tabs; held items read like
      localized names with title-case fallback.
- [ ] Coverage test exists and passes; adding a new slug without a
      translation (or documented fallback) fails CI.

### Tests

- [ ] Unit: slug → display-name mapping (known EN/IT, unknown fallback,
      no UPPER output).
- [ ] Widget: held-items section with unknown item renders fallback, never
      a raw slug in caps.

---

## 3. Architecture consistency: `getIt` in presentation + `MoveDetailCubit`

Two inconsistencies remain (both grep-verified):

1. `lib/src/2_application/bloc/move_detail_cubit/move_detail_cubit.dart:9-12`
   takes `IPokemonRepository` directly, while sibling flows
   (species/evolution/ability) go through use-cases
   (`GetPokemonSpeciesUseCase`, `GetEvolutionChainUseCase`,
   `GetAbilityDetailUseCase`).
2. Presentation calls `getIt<...>()` in 9 places:
   `ability_detail_bottom_sheet.dart:47`, `evolution_chain_widget.dart:36`,
   `move_detail_bottom_sheet.dart:42`, `pokedex_browse_page.dart:24`,
   `detail_page.dart:30`, `home/_bloc.dart:24`, `detail/_bloc.dart:22`,
   `detail_info_tab.dart:50`, `detail_moves_tab.dart:37`.

### Action items

- [ ] Decide ONE documented pattern and apply it: either introduce
      `GetMoveDetailUseCase` and inject cubits via a factory/constructor
      (preferred — matches the codebase's use-case convention), or document why
      the direct-interface exception exists. Do not leave both patterns.
- [ ] Remove raw `getIt` calls from presentation: resolve through constructor
      injection or a single documented factory wrapper. Runtime-data cubits
      (e.g. `DetailMovesCubit(moves: ...)`) stay created inline with
      `BlocProvider` — only their static deps change.
- [ ] `ApiClient`/`LocalStorage` contracts are already generic/typed
      (`Future<T> get<T>`, `schemaVersion`) — no action; just don't regress to
      `dynamic`.

### Acceptance criteria

- [ ] `MoveDetailCubit` path follows the same use-case-or-documented-exception
      rule as species/evolution/ability.
- [ ] No unexplained `getIt<...>()` in `lib/src/1_presentation/`; the one
      allowed construction pattern is written down (one paragraph in README or
      `CLAUDE.md`).

### Tests

- [ ] Unit: `GetMoveDetailUseCase` (or documented equivalent) success/failure
      mapping, including cancellation.
- [ ] Widget: move-detail sheet builds through the new construction path and
      retries after failure.

---

## 4. Logging / redaction policy (documentation only)

Code already sanitizes (`lib/src/2_application/helpers/log_sanitizer.dart`)
and truncates payloads (`lib/src/4_repository/interceptors/logging_interceptor.dart:96-98`).
No written policy exists.

### Action items

- [ ] Write a one-page policy (README section or `docs/logging_policy.md`):
      what is redacted (user queries at release level), payload truncation
      limits, debug vs release behavior, and the rule for future sensitive data
      (accounts/analytics must update this doc first).

### Acceptance criteria

- [ ] Policy doc exists; release-mode log sample contains no raw query and
      no full response body.

---

## Verification

- [ ] `fvm dart format lib test`, `fvm flutter analyze` (0 issues),
      `fvm flutter test` pass.
- [ ] `CHANGELOG.md` `[Unreleased]` updated.
