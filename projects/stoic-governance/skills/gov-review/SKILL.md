---
name: gov-review
description: End-of-task review. Delegates to the stoic-reviewer subagent and records the lesson.
disable-model-invocation: true
---

1. Delegate to the stoic-reviewer subagent. Pass it the final report from this session verbatim, and the governance session id from the session context.
2. Append one line to .claude/governance/logs/review.jsonl:
   {"schema": "stoic-review/1", "source": "reviewer", "session_id": "<governance session id>", "ended_at": "<UTC ISO time>", "verdict": ..., "findings": {...}, "lesson": "<reviewer lesson or null>"}
   Write it with `python -c` using json.dumps and mode "a", so the existing lines are kept.
3. Show the user the verdict and any findings. Do not fix findings unless the user asks.
