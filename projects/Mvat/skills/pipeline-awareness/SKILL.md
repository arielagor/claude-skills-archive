---
name: pipeline-awareness
mode: autonomous
escalation_on_ambiguity: governance/escalations/
description: How the Mvat pipeline works and how to check pipeline state.
---

# Pipeline Awareness

How the Mvat pipeline works and how to check pipeline state.

> **Skill Mode: autonomous** — This skill never requires human input.
> When ambiguity arises, write an escalation to `governance/escalations/` and
> continue with the conservative default. Do NOT prompt for user input.

## 10-Stage Pipeline

| Stage | Name | Department | Quality Gate |
|-------|------|-----------|-------------|
| 1 | Discovery | Product | — |
| 2 | Strategy | Product | — |
| 3 | Design | Design | accessibility-auditor pass |
| 4 | Engineering | Engineering | — |
| 5 | Code Review | Engineering | code-reviewer approved |
| 6 | Testing | Testing | quality-sentinel pass |
| 7 | Build/Deploy | Engineering | build succeeds |
| 8 | Marketing Prep | Marketing | — (parallel with 7) |
| 9 | Release/Monitor | Analytics | no critical anomalies |
| 10 | Feedback Loop | Analytics+Finance | no critical spend alerts |

Stage 10 loops back to Stage 1 with experiment results and revenue data.

## R1 Simplified Pipeline (5 stages)

In rollout phase R1, the 10-stage pipeline is simplified:

| R1 Stage | Name | Maps to Full | Agent |
|----------|------|-------------|-------|
| 1 | Strategy | Stages 1-2 | product-strategist |
| 2 | Build | Stages 3-5 | architect |
| 3 | Test Gate | Stage 6 | quality-sentinel |
| 4 | Ship | Stages 7-8 | aso-optimizer |
| 5 | Monitor | Stages 9-10 | budget-manager |

pipeline-judge validates between every R1 stage transition:
1→2, 2→3, 3→4, 4→5, 5→1

## Checking Current Phase

Read `rollout/current-phase.json`:
```json
{
  "current_phase": "R1",
  "phase_name": "Minimum Viable Team",
  "active_agent_count": 6,
  "active_agents": ["product-strategist", "architect", "quality-sentinel", "aso-optimizer", "budget-manager", "pipeline-judge"]
}
```

## Checking Pipeline State

Run `scripts/pipeline-status.sh` for a full status report including:
- Current rollout phase and active agents
- Kill switch status (enabled/disabled agents)
- Circuit breaker status (any tripped?)
- Unresolved escalation count

## Inter-Stage Validation

At every stage transition, **pipeline-judge**:
1. Reads upstream agent's output artifacts
2. Reads downstream agent's input interpretation
3. Validates alignment across three lenses:
   - **Goal alignment**: Does downstream match upstream intent?
   - **Factual consistency**: Are facts preserved, not fabricated?
   - **Reasoning coherence**: Do decisions logically follow?
4. Writes verdict to `artifacts/governance/judge-verdicts/`
5. If misaligned: blocks pipeline, escalates

## Artifact Flow Between Stages

```
product-strategist → [strategy-docs, prds] → pipeline-judge validates → architect
architect → [adrs, code] → pipeline-judge validates → quality-sentinel
quality-sentinel → [quality-verdicts] → pipeline-judge validates → aso-optimizer
aso-optimizer → [aso-experiments] → pipeline-judge validates → budget-manager
budget-manager → [budget-reports] → pipeline-judge validates → product-strategist (loop)
```

## Quality Gates

Quality gates BLOCK pipeline progression until met:
- **quality-sentinel**: `gate_passed: true` in verdict (tests pass, coverage meets thresholds)
- **code-reviewer** (R2+): `verdict: approved`
- **anomaly-detector** (R3+): no critical anomalies detected

If a gate fails, the upstream agent must fix and re-submit. Max 3 retries before escalating.

## Pipeline Configuration

Full definitions at:
- `orchestration/pipeline.json` — stage definitions, dependencies, quality gates
- `orchestration/departments.json` — department metadata, lead agents
- `orchestration/team-configs/` — pre-built team configurations
- `orchestration/workflows/` — reusable workflow definitions
