---
name: pipeline-awareness
mode: autonomous
escalation_on_ambiguity: governance/escalations/
description: Pipeline structure and state checking. Most relevant to governance and department leads.
relevant_agents: [pipeline-judge, spec-evolver, product-strategist, launch-coordinator, architect, quality-sentinel, budget-manager]
---

# Pipeline Awareness

> **autonomous** — Agents not in `relevant_agents` may skip this skill.

## 10-Stage Pipeline

| Stage | Name | Quality Gate |
|-------|------|-------------|
| 1 | Discovery | — |
| 2 | Strategy | — |
| 3 | Design | accessibility-auditor pass |
| 4 | Engineering | — |
| 5 | Code Review | code-reviewer approved |
| 6 | Testing | quality-sentinel pass |
| 7 | Build/Deploy | build succeeds |
| 8 | Marketing Prep | — (parallel with 7) |
| 9 | Release/Monitor | no critical anomalies |
| 10 | Feedback Loop | no critical spend alerts |

Stage 10 loops back to Stage 1.

## State Checks

- Current phase: `rollout/current-phase.json`
- Pipeline config: `orchestration/pipeline.json`
- Full status: `scripts/pipeline-status.sh`

## Inter-Stage Validation (pipeline-judge)

At every stage transition, pipeline-judge validates:
1. **Goal alignment** — downstream matches upstream intent
2. **Factual consistency** — facts preserved, not fabricated
3. **Reasoning coherence** — decisions logically follow

Writes verdicts to `artifacts/governance/judge-verdicts/`. Blocks pipeline on misalignment.

## Quality Gates

Gates BLOCK progression: quality-sentinel (tests+coverage), code-reviewer (approved verdict), anomaly-detector (no critical anomalies). Max 3 retries before escalating.
