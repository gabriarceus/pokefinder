# AI context

PokeFinder is a personal Flutter app for Android and iOS, backed by PokeAPI v2.
The UI supports English and Italian.

## Task instructions

Paths below are relative to the repository root, including when reading a generated copy.
Read the matching source file directly if the host does not list the skill.

| Task | Read |
|---|---|
| Write, edit, refactor or review Dart, translations or tests | `docs/ai/skills/flutter-project-conventions.md` — always before the task |
| Run the app, control the emulator with MCP, take screenshots or verify a UI change | `docs/ai/skills/verifying-ui-on-device.md` |
| Configure or troubleshoot native Android emulator MCP on Windows, macOS or Linux | `docs/ai/skills/configuring-mobile-mcp.md` |
| Edit or synchronize AI documentation | `docs/ai/README.md` |

Apply any available personal Flutter conventions too. Project choices take precedence over
personal defaults; neither overrides the user's explicit request or host permission rules.

## Architecture

`lib/src/` has four layers. Dependencies point presentation → application → domain ← repository.

- `1_presentation/`: pages, shared widgets, extensions, `theme/app_palette.dart`,
  `router/app_router.dart`, `router/app_routes.dart` and `di/presentation_bloc_factory.dart`.
- `2_application/`: blocs and cubits under `bloc/`, plus application helpers.
- `3_domain/`: entities, value objects, pure helpers, `PokemonFailure` and
  `IPokemonRepository`. No Flutter imports. Blocs and cubits call the repository directly;
  there is no use case layer.
- `4_repository/`: `ApiClient` and `LocalStorage` abstractions and implementations,
  `PokeApiCache`, repositories, `Raw*` JSON models, services and interceptors.
  There is no separate remote data source.
- `lib/bootstrap.dart`: get_it/injectable setup. `lib/main.dart`: startup and app providers.
  `lib/bootstrap/mobile_storage_initializer.dart`: Hive and hydrated storage.

## Runtime configuration

- `--flavor dev` uses `MockPokemonRepository` with fixed data. Add
  `--dart-define=USE_MOCK=false` to use live PokeAPI in a dev build.
- `--flavor prod` uses `PokemonRepositoryImpl` with live PokeAPI.
- `configureDependencies` takes injectable's `Environment.dev` or `Environment.prod` string.
- Durable user state lives in the documents directory; the disposable API cache lives in
  the temporary directory. Clearing the cache must preserve favorites, teams and history.

## Commands and verification

Use FVM; the SDK is pinned in `.fvmrc`. There is no Melos setup.

| Action | Command |
|---|---|
| Resolve dependencies | `fvm flutter pub get` |
| Generate DI and JSON code | `fvm dart run build_runner build` |
| Generate translations | `fvm flutter gen-l10n` |
| Format touched Dart files | `fvm dart format <file1.dart> <file2.dart>` |
| Analyze | `fvm flutter analyze --fatal-infos` |
| Test | `fvm flutter test` |
| Local gates | `bash scripts/verify.sh` |
| Coverage gate | `bash scripts/coverage.sh 70` |
| Run (a flavor is always required) | `fvm flutter run --flavor dev` |
| Synchronize AI docs | `bash scripts/sync-ai-docs.sh` |

Use Bash for `.sh` scripts. VS Code tasks select Git Bash on Windows; see `README.md`
for PowerShell invocation and custom Git paths. The Format task formats whole directories,
so use explicit filenames for focused changes.

- For code changes, format touched Dart files, run analysis and `fvm flutter test`.
- After changing ARB files or annotated classes, run both generation commands, check
  `untranslated_messages.txt` is `{}`, and inspect `git status` for generated changes.
- For UI changes, follow the device skill. Report any verification you could not complete.
- For documentation-only changes, check paths, references and generated copies;
  Flutter analysis and tests are not needed.
- CI also checks formatting across the repository, generated-file consistency, 70% coverage
  and a release build. `verify.sh` only checks formatting, analysis and tests.

## Commands requiring an explicit request

- `scripts/post_build.dart` and the VS Code task "Build Appbundle + Post build" create
  and push a Git tag.
- `scripts/generate_canonical_table.dart` calls PokeAPI and rewrites canonical species data.
- Release builds: `flutter build … --release`.

## Generated files and documentation ownership

Never hand-edit `*.g.dart`, `lib/bootstrap.config.dart`, `lib/l10n/app_localizations*.dart`
or `lib/src/3_domain/helpers/canonical_species_data.dart`. Update the source and regenerate.

AI sources live in `docs/ai/`. `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.claude/skills/`
and `.opencode/skills/` are generated copies. Follow `docs/ai/README.md` after editing sources.
Update the relevant documentation when a change affects a documented contract or workflow.
