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
# Only sync from real project directories (skip C-- encoded config mirrors).
# Look for skills at .claude/<name>/SKILL.md and .claude/skills/<name>/SKILL.md
# but NOT deeper (avoids recursive nesting artifacts).
PROJECTS_SRC="$CLAUDE_DIR/projects"
PROJECTS_DST="$REPO_DIR/projects"

if [ -d "$PROJECTS_SRC" ]; then
  for proj_dir in "$PROJECTS_SRC"/*/; do
    proj_name="$(basename "$proj_dir")"

    # Skip encoded config mirrors and this archive repo
    [[ "$proj_name" == C--* ]] && continue
    [[ "$proj_name" == "claude-skills-archive" ]] && continue

    claude_dir="$proj_dir/.claude"
    [ -d "$claude_dir" ] || continue

    # Pattern 1: .claude/<skill-name>/SKILL.md (direct skills)
    for skill_file in "$claude_dir"/*/SKILL.md; do
      [ -f "$skill_file" ] || continue
      skill_name="$(basename "$(dirname "$skill_file")")"
      # Skip if this "skill" dir itself contains another SKILL.md (it's a wrapper, not a real skill)
      # Just take the top-level one
      dest_dir="$PROJECTS_DST/$proj_name/$skill_name"
      mkdir -p "$dest_dir"
      cp "$skill_file" "$dest_dir/SKILL.md"
    done

    # Pattern 2: .claude/skills/<skill-name>/SKILL.md
    if [ -d "$claude_dir/skills" ]; then
      for skill_file in "$claude_dir"/skills/*/SKILL.md; do
        [ -f "$skill_file" ] || continue
        skill_name="$(basename "$(dirname "$skill_file")")"
        dest_dir="$PROJECTS_DST/$proj_name/skills/$skill_name"
        mkdir -p "$dest_dir"
        cp "$skill_file" "$dest_dir/SKILL.md"
      done
    fi
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

# Project - remove stale project dirs
if [ -d "$PROJECTS_DST" ]; then
  for repo_proj in "$PROJECTS_DST"/*/; do
    [ -d "$repo_proj" ] || continue
    proj_name="$(basename "$repo_proj")"
    if [ ! -d "$PROJECTS_SRC/$proj_name/.claude" ]; then
      rm -rf "$repo_proj"
    fi
  done
fi

# --- Auto-commit if there are changes ---
cd "$REPO_DIR"
git add -A
if ! git diff --cached --quiet; then
  changed_files="$(git diff --cached --name-only)"
  count="$(echo "$changed_files" | grep -c '^' || true)"
  git commit -m "Sync $count skill file(s)

$(echo "$changed_files" | head -20)
$([ "$(echo "$changed_files" | wc -l)" -gt 20 ] && echo "... and more")"
  git push origin master 2>/dev/null || true
fi
