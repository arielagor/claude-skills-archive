#!/bin/bash
# PostToolUse hook: triggers skill sync when a SKILL.md file is written/edited.
# Receives tool input as JSON on stdin.

INPUT="$(cat)"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')"

# Only act on SKILL.md files inside ~/.claude/
if [[ "$FILE_PATH" == *"SKILL.md"* ]] && [[ "$FILE_PATH" == *".claude"* ]]; then
  # Don't trigger on edits inside the archive repo itself
  if [[ "$FILE_PATH" == *"claude-skills-archive"* ]]; then
    exit 0
  fi
  bash "$HOME/.claude/projects/claude-skills-archive/sync-skills.sh" &>/dev/null &
fi

exit 0
