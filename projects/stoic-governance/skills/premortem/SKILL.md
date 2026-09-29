---
name: premortem
description: Run before any git push, migration, deploy, deletion, or other hard-to-reverse step. Records likely failure causes, checks, abort conditions and rollback.
---

1. State the action in one line, including the exact command.
2. Assume it is two hours later and this action failed badly. Write the three most likely causes. For each, name a check you can run now.
3. Run the checks. Record each result.
4. Write abort conditions ("stop if ...") and the exact rollback command. If there is no rollback, say so; that makes the action one the user must approve.
5. Get the current Unix time with `python -c "import time; print(int(time.time()))"`, then write this file:
   .claude/governance/premortem/latest.json
   {"ts": <unix seconds>, "action": "...", "causes": [{"cause": "...", "check": "...", "result": "..."}], "abort_if": ["..."], "rollback": "...", "proceed": true}
6. Report in at most 8 lines. If any check failed, set "proceed": false and stop.
