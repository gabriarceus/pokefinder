# Logging & redaction policy

One-page policy for what PokeFinder logs. Code references:
`lib/src/2_application/helpers/log_sanitizer.dart`,
`lib/src/4_repository/interceptors/logging_interceptor.dart`.

## What is redacted

- **User queries are redacted at release level.** Search input and Pokémon
  names typed by the user go through `sanitizeQueryForLog`, which emits
  `[REDACTED]` when `kReleaseMode` is true and the raw text otherwise.
  Release-mode logs therefore never contain what the user searched for.
- Request/response **lines** (HTTP method, URL, status code, elapsed time)
  are always logged. URLs can contain a searched Pokémon name as a path
  segment (e.g. `/pokemon/pikachu`); this is API addressing, not free-form
  user input, and stays within the app's own log output.

## Payload truncation

- Request headers/bodies and response/error bodies are logged **only** in
  verbose mode, and each payload is truncated to
  `LoggingInterceptor.maxPayloadLength` (1000 chars) with a
  `... [truncated N chars]` marker. Full response bodies are never logged.

## Debug vs release behavior

- `verbose` is wired to `kDebugMode` in `lib/bootstrap.dart`: debug builds
  log headers and truncated bodies at `debug` severity; release builds log
  request/response/error lines only, with queries redacted.
- Severity convention: `info` for request/response lines, `debug` for
  payloads, `error` for failures. All calls go through `en_logger` with a
  stable prefix (`static const _prefix = 'HTTP'`).

## Rule for future sensitive data

Accounts, analytics, or any new PII-adjacent data must update this document
**first**, before any logging call ships: state exactly what is collected,
where it is redacted, and which severity carries it. Changes to redaction
behavior must extend `test/release_hardening_test.dart` (redaction +
truncation + manifest/plist assertions) so CI enforces them.
