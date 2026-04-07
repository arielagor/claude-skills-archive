---
name: mvat-pipeline
description: "Run, inspect, and advance the MVAT 10-stage pipeline. Check status, validate transitions, and trigger pipeline stages."
user_invocable: true
---

# /mvat-pipeline — Pipeline Operations

Manage the MVAT 10-stage product lifecycle pipeline.

## Commands

### `/mvat-pipeline status`
Show current pipeline state: active stage, pending quality gates, blocked transitions, and agent activity.

**Steps:**
1. Read `rollout/current-phase.json` for active phase and pipeline mode
2. Read `orchestration/pipeline.json` for stage definitions
3. Scan `artifacts/` for latest artifacts per stage to determine progress
4. Read `governance/circuit-breakers.json` for any tripped breakers
5. Read `governance/escalations/` for unresolved escalations blocking stages
6. Present a formatted status report:

```
MVAT Pipeline Status
━━━━━━━━━━━━━━━━━━━━
Phase: R1 (MVP Foundation)
Mode:  5-stage simplified

Stage Progress:
  [✓] 1. Strategy      — 2 artifacts (approved)
  [→] 2. Build         — 1 artifact (draft), 1 in progress
  [ ] 3. Test Gate     — waiting on Build
  [ ] 4. Ship          — waiting on Test Gate
  [ ] 5. Monitor       — waiting on Ship

Quality Gates:
  Stage 3 (Test Gate):  quality-sentinel — NOT YET RUN
  Stage 5 (Monitor):    budget-manager — NOT YET RUN

Blockers:
  ⚠ esc-20260315-architect: Missing design tokens (medium)

Active Agents: 6/6 enabled
Tripped Breakers: 0
```

### `/mvat-pipeline advance`
Attempt to advance to the next pipeline stage.

**Steps:**
1. Identify current stage from artifact state
2. Check quality gate requirements for the transition
3. If quality gate agent exists, launch it to validate:
   - Stage 2→3: quality-sentinel runs tests
   - Stage 4→5: anomaly-detector checks for critical issues
   - Stage 5→1: pipeline-judge produces synthesis report
4. If gate passes, update stage artifacts to `consumed` status
5. If gate fails, report what's blocking and create escalation if needed

### `/mvat-pipeline run <stage>`
Execute a specific pipeline stage by launching its assigned agents.

**Steps:**
1. Validate the stage number (1-10) or name
2. Check all dependencies are met (prior stages completed)
3. Look up agents assigned to this stage from `orchestration/pipeline.json`
4. Verify all agents are enabled in kill-switch
5. Launch agents in dependency order using the Agent tool
6. Report results and any artifacts produced

### `/mvat-pipeline validate`
Run pipeline-judge validation on the current state.

**Steps:**
1. Launch pipeline-judge agent with read access to all artifacts
2. pipeline-judge applies 3-lens validation:
   - **Goal Alignment**: Do artifacts match stated objectives?
   - **Factual Consistency**: Are facts consistent across departments?
   - **Reasoning Coherence**: Does the logic chain hold?
3. Output judge verdict to `artifacts/governance/judge-verdicts/`
4. Report findings and any drift detected

### `/mvat-pipeline reset`
Reset pipeline to a specific stage (for re-running stages).

**Steps:**
1. Confirm target stage with user
2. Archive artifacts from stages after the target
3. Reset quality gate status for affected stages
4. Update pipeline state

## Pipeline Architecture Reference

### Full 10-Stage Pipeline
| Stage | Name | Department | Quality Gate |
|-------|------|------------|-------------|
| 1 | Discovery | Product | — |
| 2 | Strategy | Product | — |
| 3 | Design | Design | accessibility-auditor |
| 4 | Engineering | Engineering | — |
| 5 | Code Review | Engineering | code-reviewer |
| 6 | Testing | Testing | quality-sentinel |
| 7 | Build/Deploy | Engineering | devops-engineer |
| 8 | Marketing Prep | Marketing | — |
| 9 | Release/Monitor | Analytics | anomaly-detector |
| 10 | Feedback Loop | Analytics+Finance | budget-manager |

### R1 Simplified (5-Stage)
| Stage | Name | Maps To |
|-------|------|---------|
| 1 | Strategy | Full 1-2 |
| 2 | Build | Full 3-4-5 |
| 3 | Test Gate | Full 6 |
| 4 | Ship | Full 7-8 |
| 5 | Monitor | Full 9-10 |

### Stage Transition Rules
- Pipeline-judge validates between every stage pair
- Quality gate agents must produce pass verdict before advancing
- Failed gates create escalations automatically
- Stage 10→1 produces synthesis report (cross-department learning)
