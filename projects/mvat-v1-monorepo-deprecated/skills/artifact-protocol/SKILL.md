---
name: artifact-protocol
mode: autonomous
escalation_on_ambiguity: governance/escalations/
description: How to create, validate, and manage artifacts in the Mvat system.
---

# Artifact Protocol

How to create, validate, and manage artifacts in the Mvat system.

> **Skill Mode: autonomous** — This skill never requires human input.
> When ambiguity arises, write an escalation to `governance/escalations/` and
> continue with the conservative default. Do NOT prompt for user input.

## Artifact Header Format

Every artifact file starts with a JSON header block. Required fields:

```json
{
  "artifact_id": "{type}-{YYYYMMDD}-{short-slug}",
  "artifact_type": "{strategy-doc|prd|adr|quality-verdict|aso-experiment|budget-report|judge-verdict}",
  "author": "{agent-name}",
  "department": "{product|design|engineering|testing|marketing|analytics|finance|governance}",
  "created_at": "{ISO 8601 timestamp}",
  "updated_at": "{ISO 8601 timestamp}",
  "status": "draft",
  "confidence": 0.0,
  "success_criteria": [
    "{measurable criterion 1}",
    "{measurable criterion 2}"
  ],
  "version": "0.1.0",
  "upstream_artifact_id": "{parent artifact ID or null}",
  "tags": ["{tag1}", "{tag2}"]
}
```

## Provenance Tracking

Every artifact SHOULD include a `provenance` field in its header to enable full traceability
from implementation back through ADR, PRD, strategy doc, and market research:

```json
{
  "provenance": {
    "upstream_artifacts": ["strategy-20260302-mvat-focus", "prd-20260302-mvat-focus-mvp"],
    "decision_chain": ["strategy.success_criteria[2]", "prd.US-MVP-3"],
    "modifications": [
      {
        "timestamp": "2026-03-03T10:00:00Z",
        "modifier": "architect",
        "change": "Added error boundary wrapper per ADR recommendation",
        "artifact_id": "adr-20260302-mvat-focus-mvp-architecture"
      }
    ]
  }
}
```

### Provenance Rules

1. `upstream_artifacts` lists ALL artifact IDs that informed this artifact (not just the immediate parent)
2. `decision_chain` traces specific requirements: which success criterion or user story drove this work
3. `modifications` is append-only — every post-creation edit adds an entry with who, what, when, and why
4. pipeline-judge traces claims through provenance chains during factual consistency checks
5. When consuming an upstream artifact, copy its `provenance.upstream_artifacts` and append the upstream artifact's own ID

### Provenance Validation

pipeline-judge validates provenance at stage transitions:
- Every claim in a downstream artifact must trace to an upstream source via `decision_chain`
- Modifications must reference the artifact that prompted the change
- Orphaned artifacts (no upstream and not a Stage 1 root artifact) are flagged as WARNING

## Status Lifecycle

```
draft --> under_review --> approved --> consumed --> archived
  |            |
  |            +--> rejected (returns to draft with feedback)
  |
  +--> abandoned (if deemed unnecessary)
```

| Status | Meaning | Who Sets It |
|--------|---------|------------|
| `draft` | Just created. Not validated. | Author agent |
| `under_review` | Submitted for validation. | Author agent or department lead |
| `approved` | Passed validation. Ready for downstream. | pipeline-judge or founder |
| `consumed` | A downstream agent has used this artifact. | Consuming agent |
| `archived` | No longer active. Retained for audit. | Any agent (>7 days unconsumed) |

### Allowed Transitions

- `draft` → `under_review` (author submits)
- `draft` → `abandoned` (no longer needed)
- `under_review` → `approved` (validator passes)
- `under_review` → `draft` (rejected with feedback)
- `approved` → `consumed` (downstream processes it)
- `consumed` → `archived` (after use)
- Any status → `archived` (stale >7 days unconsumed)

## Validation Rules

When receiving an artifact, validate:

1. **Header exists** — file starts with valid JSON block
2. **Required fields present** — `artifact_id`, `author`, `status`, `confidence`, `success_criteria`
3. **Status is acceptable** — downstream agents require `status: approved` (except quality-sentinel which can evaluate drafts)
4. **Confidence meets threshold** — `confidence >= 0.85` for auto-consumption, `0.65-0.84` check `flagged_for_review`
5. **Success criteria defined** — at least 1 measurable criterion exists

## Rejecting Malformed Artifacts

If validation fails:
1. Do NOT process the artifact
2. Write a rejection record to `artifacts/governance/validation-failures/{failure-id}.json`
3. Include: `artifact_id`, `validator_agent`, `failure_reason`, `timestamp`
4. The upstream agent is responsible for fixing and re-submitting

## Stale Artifact Policy

Artifacts with status `approved` that remain unconsumed for >7 days are eligible for archival:
- Any agent that detects a stale artifact can update its status to `archived`
- Archived artifacts remain in place for audit purposes
- Archival is logged in the audit trail

## Asset Dependency Tracking

When an artifact references non-code assets (images, sounds, fonts, videos):

1. Add an `asset_dependencies` array to the artifact header:

```json
{
  "asset_dependencies": [
    {
      "type": "audio",
      "path": "app/assets/sounds/session-complete.mp3",
      "status": "placeholder",
      "required_for": ["US-R2-2"]
    },
    {
      "type": "image",
      "path": "app/assets/screenshots/dark-mode-timer.png",
      "status": "bundled",
      "required_for": ["ASO screenshot set"]
    }
  ]
}
```

2. Status values: `placeholder` (referenced but not yet bundled), `bundled` (exists in repo), `remote` (hosted externally)

3. **pipeline-judge** validates at Marketing stage: if any referenced assets have status `placeholder`,
   flag as WARNING in verdict and note in launch plan

4. **launch-coordinator** MUST NOT mark launch plan as "ready" if any critical assets have status `placeholder`

5. **code-reviewer** flags code that imports or references asset paths where the file does not exist

## Success Criteria Best Practices

Each criterion must be:
- **Measurable** — can be objectively verified (not "good quality")
- **Specific** — names what exactly must be true
- **Traceable** — links back to a requirement in the upstream artifact

Example good criteria:
- "Defines target market with segment size > 0"
- "All user stories have acceptance criteria"
- "TypeScript compiles with zero errors"

Example bad criteria:
- "High quality code" (unmeasurable)
- "Well designed" (subjective)
- "Works correctly" (vague)
