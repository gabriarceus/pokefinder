# AI docs — source of truth

This folder feeds every AI provider from one place. Edit files here, then run
`./scripts/sync-ai-docs.sh` (VS Code task: `Sync AI docs`). Never hand-edit the
generated files — the script overwrites them.

## Layout

- `context.md` — project overview for AI assistants. Generates `CLAUDE.md`,
  `AGENTS.md`, `GEMINI.md` in the repo root (all gitignored).
- `skills/<name>.md` — one file per project-specific skill (general project
  knowledge plus any future per-area skills). Each file must be a complete
  `SKILL.md`: open with frontmatter where `name` matches the filename, and
  include a `description` covering what the skill does and when to trigger it.
  Generates `.opencode/skills/<name>/SKILL.md` and `.claude/skills/<name>/SKILL.md`
  (both gitignored). Gemini has no project-skill equivalent; it is covered by
  `GEMINI.md`.
- This `README.md` — documentation only, synced nowhere.

## Adding a project skill

1. Create `skills/<name>.md` (lowercase hyphen-separated name), e.g.
   `skills/flutter-project-conventions.md`:

   ```markdown
   ---
   name: flutter-project-conventions
   description: Use when writing or editing Dart in this repo. Applies the
     project's architecture, Bloc, and style conventions.
   ---

   # Flutter project conventions

   (body)
   ```

2. Run `./scripts/sync-ai-docs.sh`. It warns if frontmatter `name:` does not
   match the filename (a mismatch means the skill is silently ignored).
3. Restart the AI tool so it picks up the new skill.
