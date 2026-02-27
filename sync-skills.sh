#!/bin/bash
# Syncs all SKILL.md files from ~/.claude into this repo and auto-commits changes.
# Called by Claude Code PostToolUse hook or manually.

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

# --- Sync global skills ---
GLOBAL_SRC="$CLAUDE_DIR/skills"
GLOBAL_DST="$REPO_DIR/global"

if [ -d "$GLOBAL_SRC" ]; then
  mkdir -p "$GLOBAL_DST"
  for skill_dir in "$GLOBAL_SRC"/*/; do
    skill_name="$(basename "$skill_dir")"
    if [ -f "$skill_dir/SKILL.md" ]; then
      mkdir -p "$GLOBAL_DST/$skill_name"
      cp "$skill_dir/SKILL.md" "$GLOBAL_DST/$skill_name/SKILL.md"
    fi
  done
fi

# --- Sync project-level skills ---
PROJECTS_SRC="$CLAUDE_DIR/projects"
PROJECTS_DST="$REPO_DIR/projects"

if [ -d "$PROJECTS_SRC" ]; then
  # Find all SKILL.md files inside project .claude directories (skills or commands)
  find "$PROJECTS_SRC" -maxdepth 6 -path "*/.claude/*/SKILL.md" ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/claude-skills-archive/*" -print 2>/dev/null | while read -r skill_file; do
    # Extract: projects/<project>/.claude/<path>/SKILL.md
    rel="${skill_file#$PROJECTS_SRC/}"
    project_name="${rel%%/*}"
    # Get the skill path after .claude/
    after_claude="${rel#*/.claude/}"
    # Could be skills/<name>/SKILL.md or <name>/SKILL.md
    skill_rel_dir="$(dirname "$after_claude")"

    dest_dir="$PROJECTS_DST/$project_name/$skill_rel_dir"
    mkdir -p "$dest_dir"
    cp "$skill_file" "$dest_dir/SKILL.md"
  done
fi

# --- Remove skills from repo that no longer exist at source ---
# Global
if [ -d "$GLOBAL_DST" ]; then
  for repo_skill in "$GLOBAL_DST"/*/SKILL.md; do
    [ -f "$repo_skill" ] || continue
    skill_name="$(basename "$(dirname "$repo_skill")")"
    if [ ! -f "$GLOBAL_SRC/$skill_name/SKILL.md" ]; then
      rm -rf "$GLOBAL_DST/$skill_name"
    fi
  done
fi

# --- Auto-commit if there are changes ---
cd "$REPO_DIR"
git add -A
if ! git diff --cached --quiet; then
  # Build a commit message listing what changed
  changed_files="$(git diff --cached --name-only)"
  added="$(echo "$changed_files" | grep -c '^' || true)"
  git commit -m "Sync $added skill file(s)

$(echo "$changed_files" | head -20)
$([ "$(echo "$changed_files" | wc -l)" -gt 20 ] && echo "... and more")"
fi
