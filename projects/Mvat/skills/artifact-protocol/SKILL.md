---
name: artifact-protocol
mode: autonomous
escalation_on_ambiguity: governance/escalations/
description: How to create, validate, and manage artifacts in the Mvat system.
---

# Artifact Protocol

> **autonomous** — Never prompt for input. Escalate to `governance/escalations/`.

## Header Format (required on every artifact)

```json
{
  "artifact_id": "{type}-{phase}-{run}-{seq}",
  "artifact_type": "{type}",
  "author": "{agent-name}",
  "department": "{dept}",
  "phase": "{R1-R6}",
  "stage": 0,
  "created_at": "{ISO 8601}",
  "status": "draft",
  "confidence": 0.0,
  "success_criteria": ["{measurable criterion}"],
  "dependencies": ["{upstream artifact IDs}"],
  "consumers": ["{downstream agents}"]
}
```

## Status Lifecycle

`draft` → `under_review` → `approved` → `consumed` → `archived`
- `under_review` → `draft` (rejected with feedback)
- Any → `archived` (stale >7 days unconsumed)
- Downstream agents require `status: approved` before consuming

## Validation (on receiving any artifact)

1. Header exists with required fields: `artifact_id`, `author`, `status`, `confidence`, `success_criteria`
2. Status is `approved` (except quality-sentinel which evaluates drafts)
3. Confidence ≥ 0.85 for auto-consumption; 0.65-0.84 flagged for review
4. At least 1 measurable success criterion exists
5. If validation fails: reject, write failure to `artifacts/governance/validation-failures/`

## Success Criteria Rules

Each criterion must be **measurable**, **specific**, and **traceable** to upstream requirements.
Good: "TypeScript compiles with zero errors" — Bad: "High quality code"
