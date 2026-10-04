# AI documentation maintenance

Edit the sources in this directory, then run `bash scripts/sync-ai-docs.sh` from the
repository root in Bash. The VS Code task `Sync AI docs` selects Git Bash on Windows
and Bash on macOS/Linux. See `README.md` for PowerShell invocation and custom Git paths.

## Sources and outputs

| Source | Generated outputs (gitignored) |
|---|---|
| `context.md` | `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` in the repository root |
| `skills/<name>.md` | `.claude/skills/<name>/SKILL.md`, `.opencode/skills/<name>/SKILL.md` |
| This README | None |

`context.md` is the task index and architecture map. Keep detailed rules in the matching
skill and link to their source paths from the context. Hosts without skill discovery can
read those files directly. Paths inside the context and skills are repository-root relative.

The sync script replaces both generated skill directories. Keep authored content in
`docs/ai/skills/`, never in the output directories. Generated files are local: synchronize
after cloning, pulling source changes or editing AI documentation, before starting a new
agent session. Existing sessions may still hold earlier instructions.

## Adding or changing a skill

1. Create `skills/<name>.md` with a lowercase hyphen-separated filename. Start it with YAML
   frontmatter containing a matching `name` and a `description` that explains when to use it.
2. Add its task and repository-root source path to `context.md`. Keep the task index there;
   this README does not repeat the skill catalogue.
3. Keep current project decisions and behavior in the skill. Put change history in
   `CHANGELOG.md`; do not require agents to read closed reviews.
4. Run the sync script. It warns when the frontmatter name does not match the filename;
   resolve any warning before considering the sync complete.
5. Check referenced paths and symbols, and compare every generated output with its source
   (root context files add a generated-file header). Check for references to removed names.

There is no configured Markdown formatter in this repository. Match the existing Markdown
style and run `git diff --check` on changed documentation.
