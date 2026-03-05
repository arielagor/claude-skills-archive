---
name: cross-synthesis
mode: autonomous
escalation_on_ambiguity: governance/escalations/
description: Cross-agent synthesis — how to produce and consume synthesis reports that capture cross-departmental patterns.
---

# Cross-Agent Synthesis

Cross-agent synthesis reports capture patterns that no single agent can see.
They are produced by pipeline-judge at Stage 10->1 transitions and consumed
by product-strategist at Stage 1.

> **Skill Mode: autonomous** — This skill never requires human input.
> When ambiguity arises, write an escalation to `governance/escalations/` and
> continue with the conservative default. Do NOT prompt for user input.

## Synthesis Report Structure

Written to `artifacts/governance/synthesis-reports/`:

```json
{
  "artifact_id": "synth-{YYYYMMDD}-run-{N}",
  "artifact_type": "synthesis-report",
  "author": "pipeline-judge",
  "department": "governance",
  "created_at": "{ISO timestamp}",
  "status": "draft",
  "confidence": 0.0,
  "success_criteria": [
    "Covers all judge verdicts from the run range",
    "Identifies at least 1 cross-department pattern or confirms none exist",
    "Correction patterns are traced to affected specs",
    "Assumption trajectories are analyzed",
    "Recommended priority shifts are actionable"
  ],
  "run_range": {"from": 1, "to": 3},
  "cross_department_patterns": [
    {
      "pattern": "Integration gaps between design and engineering",
      "departments": ["design", "engineering"],
      "frequency": 4,
      "evidence": ["jv-...", "esc-..."],
      "recommended_action": "Add integration verification step to code-reviewer spec"
    }
  ],
  "assumption_trajectory": [
    {
      "assumption_id": "assume-009",
      "direction": "declining",
      "confidence_history": [0.70, 0.40],
      "risk": "May invalidate PRD scope assumptions"
    }
  ],
  "correction_patterns": [
    {
      "correction_type": "artifact_edit",
      "frequency": 3,
      "common_cause": "Strategy docs under-specify scope boundaries",
      "affected_agents": ["product-strategist"],
      "recommended_spec_change": "Add mandatory scope boundary section to strategy template"
    }
  ],
  "compounding_improvements": [
    "R2 bug count 40% lower than R1 after architect spec revision",
    "Cross-department handoff quality improved with provenance tracking"
  ],
  "recommended_priority_shifts": [
    {
      "from": "Add more test coverage",
      "to": "Improve integration verification at handoff points",
      "evidence": "4 integration gaps vs 0 coverage gaps in last 3 runs"
    }
  ]
}
```

## Who Produces Synthesis Reports

**pipeline-judge** produces a synthesis report at every Stage 10->1 transition
(feedback loop close). The report synthesizes:

1. All judge verdicts from the last 3 pipeline runs
2. All escalations and their resolutions
3. All entries in `governance/corrections.jsonl`
4. All assumption registry changes (using `history` arrays for trajectory)
5. All spec revisions and their outcomes
6. Pattern analysis from retrospectives

## Who Consumes Synthesis Reports

**product-strategist** reads the latest synthesis report at Stage 1 (Discovery)
as required input alongside market data. This closes the feedback loop:
production data and system learning inform the next strategy cycle.

**spec-evolver** reads synthesis reports as an additional evidence source
alongside its existing triggers. Cross-department patterns identified in
synthesis reports may reveal spec improvements that single-agent evidence misses.

## Reading a Synthesis Report

When consuming a synthesis report:

1. Check `recommended_priority_shifts` first — these are the highest-signal items
2. Check `correction_patterns` — these represent direct founder feedback
3. Check `assumption_trajectory` — declining assumptions may invalidate your work
4. Check `cross_department_patterns` — these reveal systemic issues
5. Check `compounding_improvements` — these confirm what's working (keep doing it)

## Frequency

One synthesis report per Stage 10->1 transition. In practice, this means
one per pipeline run cycle. Reports accumulate in `artifacts/governance/synthesis-reports/`
and provide a temporal record of system learning.
