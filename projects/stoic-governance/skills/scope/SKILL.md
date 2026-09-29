---
name: scope
description: Set the task scope in .claude/governance/scope.json, confirmed by the user.
disable-model-invocation: true
argument-hint: "[task description]"
---

Task: $ARGUMENTS

1. Read the repo layout (top-level directories, where the code for this task lives, where its tests live).
2. In one message, ask the user to confirm or change these fields, proposing a default for each from the task and the layout:
   - task: one line
   - write_paths: glob list, as narrow as the task allows (e.g. `src/billing/*`)
   - tests_editable: true only if the task is about the tests themselves
   - not_controlled: outcomes the agent can report but not decide
   - abort_if: conditions that mean stop and report
3. Only after the user confirms, write .claude/governance/scope.json with those fields plus "set_by": "user" and "set_at": the current UTC time in ISO 8601. The governance hook will ask for approval of this write; that approval is the user's confirmation.
4. Show the final file.
