---
name: mvat-dashboard
description: "Founder dashboard — overview of pipeline, agents, governance, artifacts, and project health at a glance."
user_invocable: true
---

# /mvat-dashboard — Founder Dashboard

Single-command overview of your entire MVAT project state. Designed for the founder/operator
to quickly understand what's happening, what needs attention, and what's next.

## Usage

### `/mvat-dashboard`
Generate the full dashboard (default).

### `/mvat-dashboard brief`
Generate a condensed one-screen summary.

## Dashboard Sections

### Section 1: Project Identity
Read `products/active-product.json` and `rollout/current-phase.json`:
```
┌─────────────────────────────────────────┐
│  MVAT Dashboard — mvat-mirror           │
│  Phase: R6 (Store Submission)           │
│  Pipeline: Full 10-stage                │
│  Date: 2026-03-15                       │
└─────────────────────────────────────────┘
```

### Section 2: Pipeline Progress
Read `orchestration/pipeline.json` and scan `artifacts/` for stage progress:
```
Pipeline Progress
━━━━━━━━━━━━━━━━
  [✓] Discovery    ██████████ 100%
  [✓] Strategy     ██████████ 100%
  [✓] Design       ████████░░  80%
  [→] Engineering   ██████░░░░  60%
  [ ] Code Review  ░░░░░░░░░░   0%
  [ ] Testing      ░░░░░░░░░░   0%
  [ ] Build/Deploy ░░░░░░░░░░   0%
  [ ] Marketing    ░░░░░░░░░░   0%
  [ ] Release      ░░░░░░░░░░   0%
  [ ] Feedback     ░░░░░░░░░░   0%
```

### Section 3: Agent Health
Read governance files for agent status:
```
Agent Health
━━━━━━━━━━━━
  Active:       39/39
  Tripped:       0 circuit breakers
  Rate-limited:  0 agents
  Disabled:      0 agents
```

### Section 4: Governance Alerts
Read escalations, circuit-breakers, and corrections:
```
Governance Alerts
━━━━━━━━━━━━━━━━━
  🔴 Critical:  0 escalations
  🟡 High:      1 escalation — "Missing design tokens" (architect)
  🟢 Medium:    2 escalations

  Circuit Breakers: All clear
  Recent Corrections: 1 in last 24h
```

### Section 5: Artifact Summary
Scan all artifact directories:
```
Artifacts
━━━━━━━━━
  Total:        47
  Draft:         3
  Under Review:  2
  Approved:     35
  Consumed:      5
  Archived:      2
  Stale (>7d):   1 ⚠
```

### Section 6: Assumption Health
Read `governance/assumption-registry.json`:
```
Assumptions
━━━━━━━━━━━
  Active:      8 (avg confidence: 0.78)
  Weakened:    1 — "Users want social features" (0.45)
  Invalidated: 0
  Unreviewed:  2 (>14 days old)
```

### Section 7: Recent Activity
Read today's audit log from `governance/audit-log/`:
```
Recent Activity (last 24h)
━━━━━━━━━━━━━━━━━━━━━━━━━
  architect:          23 actions (15 writes)
  product-strategist: 12 actions (8 writes)
  quality-sentinel:    8 actions (3 writes)
  pipeline-judge:      5 actions (2 writes)
  Total:              48 actions
```

### Section 8: Recommended Next Actions
Based on current state, suggest what to do next:
```
Recommended Actions
━━━━━━━━━━━━━━━━━━━
  1. Resolve escalation: esc-20260315-missing-tokens (high)
  2. Review stale artifact: prd-20260308-onboarding (7 days)
  3. Update assumption assume-004 (14 days, no evidence)
  4. Run /mvat-pipeline advance to attempt Stage 4→5
```

## Data Sources

| Section | Files Read |
|---------|-----------|
| Project Identity | `products/active-product.json`, `rollout/current-phase.json` |
| Pipeline Progress | `orchestration/pipeline.json`, `artifacts/**/*` |
| Agent Health | `governance/kill-switch.json`, `governance/circuit-breakers.json`, `governance/rate-limits.json` |
| Governance Alerts | `governance/escalations/*.json`, `governance/corrections.jsonl` |
| Artifacts | `artifacts/**/*` headers |
| Assumptions | `governance/assumption-registry.json` |
| Recent Activity | `governance/audit-log/{today}.jsonl` |
