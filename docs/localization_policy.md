# Localization policy

How user-visible text is translated in PokeFinder (English + Italian).

## Two systems

- **UI strings**: `lib/l10n/app_en.arb` (template) + `lib/l10n/app_it.arb`,
  generated into `AppLocalizations` via `fvm flutter gen-l10n`. Never put
  ALL-CAPS text in ARB files; apply `.toUpperCase()` in Dart when uppercase
  display is needed.
- **Bulk data translations**: `lib/l10n/*_db.dart` maps keyed by PokeAPI
  value — `abilitiesDb`, `movesDb`, `itemsDb`, `locationsDb`. `itemsDb` was
  generated from the PokeAPI `/item` endpoint's Italian `names`; re-run the
  same approach (fetch `names` where `language.name == 'it'`) to extend it.

## Fallback rule (documented)

Every slug translator (`translateAbility`, `translateMove`, `translateItem`,
`translateLocation`, `translateGameVersion`, `translateType`) returns a
database hit when one exists and otherwise falls back to title case via
`toDisplayCase()`. Unknown slugs must **never** render as raw hyphenated
slugs or ALL-CAPS text. `test/widget/translation_coverage_test.dart`
enforces this: it fails CI on silent raw-slug rendering, so adding a new
slug without a translation (or an accepted fallback) breaks the build.

## Canonical vs localized names

- **Stay canonical** (proper names, never translated): Pokémon species and
  form names (e.g. `pikachu`, `ho-oh`), trade/party species in evolution
  triggers. Uppercase styling of these in Dart (badges, headers) is allowed.
- **Must be localized**: types, game versions and version groups, abilities,
  moves, held/evolution items, locations and encounter areas, learn methods,
  damage classes, and evolution-trigger sentence templates (ARB). Embedded
  item/move/type names inside trigger badges are localized through the same
  databases; species names inside them stay canonical title case.
