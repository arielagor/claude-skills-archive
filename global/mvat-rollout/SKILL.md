---
name: mvat-rollout
description: "Manage MVAT rollout phases. Advance phases, activate agents, and track phase history."
user_invocable: true
---

# /mvat-rollout — Rollout Phase Management

Manage the phased rollout of agents and capabilities. MVAT uses progressive activation
to prevent overwhelming the system — start with a minimal viable team and expand.

## Commands

### `/mvat-rollout status`
Show current rollout phase and what's active.

**Steps:**
1. Read `rollout/current-phase.json`
2. Read `governance/kill-switch.json` for agent states
3. Present phase overview:

```
MVAT Rollout Status
━━━━━━━━━━━━━━━━━━━
Current Phase: R1 (MVP Foundation)
Started:       2026-03-15
Pipeline Mode: 5-stage simplified

Active Agents (6/39):
  product-strategist, architect, quality-sentinel,
  pipeline-judge, spec-evolver, budget-manager

Next Phase: R2 (Full Team Activation)
  Activates: spec-writer, frontend-engineer, backend-engineer,
             code-reviewer, test-strategist, unit-test-writer,
             aso-optimizer, launch-coordinator, experiment-runner
  Prerequisites: Strategy artifact approved, ADR produced
```

### `/mvat-rollout advance`
Advance to the next rollout phase.

**Phase Progression:**
| Phase | Name | Agents | Pipeline |
|-------|------|--------|----------|
| R1 | MVP Foundation | 6 | 5-stage simplified |
| R2 | Full Team | 15 | 10-stage full |
| R3a | Analytics + Design | 26 | 10-stage full |
| R3b | Full Specialization | 35 | 10-stage full |
| R4 | Store Submission | 37 | 10-stage full |
| R5 | Post-Launch | 38 | 10-stage full |
| R6 | Collective Autonomy | 39 | 10-stage full |

**Steps:**
1. Read `rollout/current-phase.json` for current phase
2. Check prerequisites for next phase:
   - R1→R2: At least one approved strategy doc and one ADR
   - R2→R3a: Code review pass, test coverage > 60%
   - R3a→R3b: Design artifacts approved, accessibility audit pass
   - R3b→R4: All quality gates pass, no critical escalations
   - R4→R5: App submitted to store
   - R5→R6: Post-launch metrics stable for 7 days
3. If prerequisites met:
   - Update `rollout/current-phase.json` with new phase
   - Enable new agents in `governance/kill-switch.json`
   - Add circuit-breaker entries for new agents
   - Add rate-limit entries for new agents
   - Update pipeline mode if changing
   - Append to `rollout/phase-history.json`
   - Trigger retrospective for completed phase
4. If prerequisites NOT met:
   - Report what's missing
   - Suggest actions to meet prerequisites

### `/mvat-rollout history`
Show phase transition history.

**Steps:**
1. Read `rollout/phase-history.json`
2. Read `rollout/retrospectives/` for available retrospectives
3. Present timeline:

```
Phase History
━━━━━━━━━━━━━
  R1 (MVP Foundation)      2026-03-01 → 2026-03-08  [7 days]
  R2 (Full Team)           2026-03-08 → 2026-03-12  [4 days]
  R3a (Analytics + Design) 2026-03-12 → present      [3 days]

Retrospectives available: R1, R2
```

### `/mvat-rollout retro [phase]`
Generate or view a retrospective for a completed phase.

**Steps:**
1. If retrospective exists in `rollout/retrospectives/`, display it
2. If not, generate one by analyzing:
   - Audit logs from the phase period
   - Escalations created during the phase
   - Circuit-breaker trips during the phase
   - Corrections logged during the phase
   - Artifacts produced (count, quality scores)
   - Judge verdicts from the phase
3. Write retrospective to `rollout/retrospectives/{phase}-retrospective.md`
4. Format using `templates/retrospective.template.md`

### `/mvat-rollout set <phase>`
Manually set the rollout phase (override).

**Steps:**
1. Update `rollout/current-phase.json`
2. Enable/disable agents to match the target phase
3. Update pipeline mode
4. Log the override in phase history with reason

## Phase Details

### R1 — MVP Foundation (6 agents)
**Goal:** Produce initial strategy, architecture, and working code.
- product-strategist: Define what to build
- architect: Design and code the system
- quality-sentinel: Verify code quality
- pipeline-judge: Validate stage transitions
- spec-evolver: Improve agent specs from evidence
- budget-manager: Track costs

**Pipeline:** 5-stage simplified (Strategy → Build → Test Gate → Ship → Monitor)

### R2 — Full Team (15 agents)
**Goal:** Dedicated roles replace combined roles.
- spec-writer separates from product-strategist
- frontend-engineer and backend-engineer separate from architect
- code-reviewer, test-strategist, unit-test-writer activate
- aso-optimizer, launch-coordinator, experiment-runner activate

### R3a — Analytics + Design (26 agents)
**Goal:** Analytics monitoring and design specialization.
- Full design team: ux-researcher, ui-designer, interaction-designer, accessibility-auditor, design-system-manager
- Analytics team: metrics-architect, behavior-analyst, crash-reporter, anomaly-detector
- Additional testing: integration-test-writer, auto-healer

### R3b — Full Specialization (35 agents)
**Goal:** All specialist agents active.
- Marketing: content-writer, social-media-manager, ad-operations
- Finance: revenue-tracker, financial-forecaster, spend-alerter
- Engineering: security-engineer, devops-engineer, tech-debt-tracker, mobile-platform-specialist

### R4-R6 — Store Submission through Collective Autonomy
**Goal:** Production deployment and full autonomous operation.
