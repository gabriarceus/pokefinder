#!/usr/bin/env bash
# Builds per-provider AI files from the canonical sources in docs/ai/.
# Sources (tracked): docs/ai/context.md and docs/ai/skills/*.md.
# Generated (gitignored, do not edit by hand):
#   docs/ai/context.md      -> CLAUDE.md, AGENTS.md, GEMINI.md
#   docs/ai/skills/<n>.md   -> .opencode/skills/<n>/SKILL.md
#                              .claude/skills/<n>/SKILL.md
# Usage: ./scripts/sync-ai-docs.sh
set -euo pipefail

cd "$(dirname "$0")/.."

# --- Provider context files (verbatim copy of the single context source) ---
HEADER="<!-- GENERATED from docs/ai/ - do not edit by hand. Edit docs/ai/, then run ./scripts/sync-ai-docs.sh. -->"

for target in CLAUDE.md AGENTS.md GEMINI.md; do
  {
    echo "$HEADER"
    echo ""
    cat docs/ai/context.md
  } > "$target"
  echo "wrote $target"
done

# --- Project skills (one source file per skill, rebuilt from scratch so that
# --- deleted sources disappear instead of lingering as stale output) ---
shopt -s nullglob

rm -rf .opencode/skills .claude/skills
mkdir -p .opencode/skills .claude/skills

for src in docs/ai/skills/*.md; do
  skill="$(basename "$src" .md)"
  if ! grep -q "^name: $skill\$" "$src"; then
    echo "warning: $src frontmatter 'name:' does not match filename ($skill)" >&2
  fi
  for dest in .opencode/skills .claude/skills; do
    mkdir -p "$dest/$skill"
    cp "$src" "$dest/$skill/SKILL.md"
  done
  echo "wrote skill $skill"
done
