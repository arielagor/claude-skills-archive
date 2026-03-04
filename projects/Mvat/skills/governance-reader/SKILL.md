---
name: governance-reader
mode: autonomous
escalation_on_ambiguity: governance/escalations/
description: How to read and interpret Mvat governance files. Every agent must check these during initialization.
---

# Governance Reader

> **autonomous** — Never prompt for input. Escalate to `governance/escalations/`.

## Initialization Checks (run in order, all must pass)

1. **Kill Switch** (`governance/kill-switch.json`): `.global_enabled` AND `.departments.{dept}.enabled` AND `.agents.{name}.enabled` — if any false, halt immediately.
2. **Circuit Breakers** (`governance/circuit-breakers.json`): `.agents.{name}.tripped` must be false. `.global.pipeline_paused` must be false. Trips after 3 consecutive failures; 5+ simultaneous trips pause all.
3. **Rate Limits** (`governance/rate-limits.json`): `.agents.{name}.current_hour_actions` < max. Wait for cooldown if at limit.

## File Ownership (`governance/file-ownership.json`)

- `.ownership_rules[]` — `path`, `owner`, `department`. Write only to paths you own.
- `.shared_write_paths[]` — validation-failures, escalations (any agent).
- All agents can READ any path.

## Autonomy Levels (`governance/autonomy-levels.json`)

Check `.decision_matrix` before actions: `auto_execute` (proceed), `flag_for_review` (proceed + flag), `escalate` (request approval), `never` (prohibited).

## Creating Escalations

Write to `governance/escalations/{esc-id}.json`:
```json
{
  "escalation_id": "esc-{YYYYMMDD}-{HHmmss}-{agent}",
  "severity": "critical|high|medium|low",
  "source_agent": "{name}", "department": "{dept}",
  "created_at": "{ISO}", "summary": "{brief}",
  "proposed_action": "{recommendation}",
  "status": "pending"
}
```
