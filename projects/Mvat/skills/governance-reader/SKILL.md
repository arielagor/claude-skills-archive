---
name: governance-reader
mode: autonomous
escalation_on_ambiguity: governance/escalations/
description: How to read and interpret Mvat governance files. Every agent must check these during initialization.
---

# Governance Reader

How to read and interpret Mvat governance files. Every agent must check these during initialization.

> **Skill Mode: autonomous** — This skill never requires human input.
> When ambiguity arises, write an escalation to `governance/escalations/` and
> continue with the conservative default. Do NOT prompt for user input.

## Kill Switch — `governance/kill-switch.json`

Check in this order (all must be true):
1. `.global_enabled` — if `false`, ALL agents are disabled
2. `.departments.{your-dept}.enabled` — if `false`, entire department is down
3. `.agents.{your-name}.enabled` — if `false`, you specifically are disabled

```bash
# Quick check with jq
jq '.global_enabled and .departments.product.enabled and .agents["product-strategist"].enabled' governance/kill-switch.json
```

If any check is `false`, halt immediately. Log the reason from `.agents.{name}.reason`.

## Circuit Breakers — `governance/circuit-breakers.json`

Check:
1. `.agents.{your-name}.tripped` — if `true`, you are halted
2. `.global.pipeline_paused` — if `true`, all pipelines are paused

If tripped:
- Check `.agents.{name}.tripped_at` for when it tripped
- Check `.agents.{name}.auto_reset_minutes` (default 30)
- Do NOT self-reset — use `scripts/reset-circuit-breakers.sh` or wait for auto-reset
- Trip happens after `.max_consecutive_failures` (default 3) consecutive failures

Global pause triggers when 5+ agents trip simultaneously (`.global.max_simultaneous_trips`).

## Rate Limits — `governance/rate-limits.json`

Check remaining capacity:
- `.agents.{name}.current_hour_actions` < `.agents.{name}.max_actions_per_hour`
- `.agents.{name}.current_hour_writes` < `.agents.{name}.max_write_actions_per_hour`
- `.agents.{name}.current_hour_bash` < `.agents.{name}.max_bash_actions_per_hour`

If at limit, wait for cooldown: `.agents.{name}.cooldown_minutes` (varies by agent, 10-20 min).

The governance-gate.sh hook enforces these automatically — counters are incremented on each tool call.

## File Ownership — `governance/file-ownership.json`

Look up which paths you can write to:
- `.ownership_rules[]` — each entry has `path`, `owner`, `department`
- `.shared_write_paths[]` — paths any agent can write to (validation-failures, escalations)
- `.phase_overrides.R1[]` — temporary ownership changes for R1 phase

Your agent can only WRITE to paths where you are the `owner` (or `temporary_owner` in phase overrides).
All agents can READ any path.

## Autonomy Levels — `governance/autonomy-levels.json`

Before taking an action, look it up in `.decision_matrix`:
- `auto_execute` — proceed without approval
- `flag_for_review` — proceed but mark output for review
- `escalate` — request human approval before proceeding
- `never` — absolutely prohibited

Confidence thresholds: `.confidence_thresholds`
- `auto_execute`: >= 0.85
- `flag_for_review`: 0.65 - 0.84
- `escalate`: < 0.65

## Correction Log — `governance/corrections.jsonl`

Append-only log of founder corrections. Each line is a JSON object:

```json
{
  "timestamp": "2026-03-05T10:00:00Z",
  "corrected_artifact_id": "strategy-20260302-mvat-focus",
  "correction_type": "artifact_edit",
  "old_value": "...",
  "new_value": "...",
  "rationale": "Clarified scope boundaries",
  "affected_agents": ["product-strategist", "architect"]
}
```

Types: `verdict_override`, `artifact_edit`, `escalation_resolution`, `spec_edit`, `assumption_update`, `config_change`

Corrections are the highest-signal evidence for spec improvement — they represent explicit founder feedback. spec-evolver reads this file as a primary trigger source.

## Creating Escalations

Write to `governance/escalations/{escalation-id}.json`:

```json
{
  "escalation_id": "esc-{YYYYMMDD}-{HHmmss}-{agent}",
  "severity": "critical|high|medium|low",
  "source_agent": "{your-agent-name}",
  "department": "{your-department}",
  "created_at": "{ISO timestamp}",
  "summary": "{brief description}",
  "proposed_action": "{what you recommend}",
  "blocking_artifacts": ["{artifact-id-1}"],
  "status": "pending",
  "resolved_at": null,
  "resolution_notes": null
}
```

Severity guide:
- **critical** — system is broken or producing wrong output, immediate attention needed
- **high** — significant issue that blocks pipeline progression
- **medium** — issue that should be addressed but doesn't block current work
- **low** — minor concern, can wait for next review cycle
