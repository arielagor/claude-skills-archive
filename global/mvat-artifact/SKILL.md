---
name: mvat-artifact
description: "Create, validate, and manage MVAT artifacts. The structured communication protocol between agents."
user_invocable: true
---

# /mvat-artifact — Artifact Operations

Create, validate, inspect, and manage artifacts — the structured handoff protocol
that connects all MVAT agents.

## Commands

### `/mvat-artifact create <type> [title]`
Create a new artifact with proper header and structure.

**Steps:**
1. Determine artifact type and destination path from the type:
   | Type | Path | Template |
   |------|------|----------|
   | `prd` | `artifacts/product/prds/` | `templates/prd.template.md` |
   | `strategy` | `artifacts/product/strategy-docs/` | — |
   | `adr` | `artifacts/engineering/adrs/` | `templates/adr.template.md` |
   | `test-plan` | `artifacts/testing/` | `templates/test-plan.template.md` |
   | `verdict` | `artifacts/governance/judge-verdicts/` | — |
   | `escalation` | `governance/escalations/` | `templates/escalation.template.json` |
   | `persona` | `artifacts/product/personas/` | — |
   | `ux-audit` | `artifacts/design/ux-audits/` | — |
   | `market-report` | `artifacts/product/market-reports/` | — |
   | `budget-report` | `artifacts/finance/budget-reports/` | — |
   | `custom` | User-specified | — |

2. Generate artifact ID: `{type}-{YYYYMMDD}-{slug}`
3. Generate JSON header:
   ```json
   {
     "artifact_id": "{type}-{YYYYMMDD}-{slug}",
     "artifact_type": "{type}",
     "author": "{agent-or-user}",
     "department": "{department}",
     "created_at": "{ISO-8601}",
     "updated_at": "{ISO-8601}",
     "status": "draft",
     "confidence": 0.0,
     "success_criteria": [],
     "version": "0.1.0",
     "upstream_artifact_id": null,
     "provenance": {
       "chain": [],
       "root_source": null
     },
     "tags": [],
     "assumptions": []
   }
   ```
4. Apply template if one exists for the type
5. Write to the appropriate path
6. Report artifact ID and path

### `/mvat-artifact validate [path-or-id]`
Validate artifact(s) against the MVAT protocol.

**Validation checks:**
1. **Header completeness**: All required fields present (artifact_id, artifact_type, author, status, confidence, success_criteria)
2. **Status validity**: Must be one of: draft, under_review, approved, consumed, archived
3. **Confidence range**: Must be 0.0-1.0
4. **Success criteria**: Must be non-empty array of strings
5. **Author exists**: Author must be a known agent or "founder"
6. **Path ownership**: File path must be owned by the declared author (check `governance/file-ownership.json`)
7. **Provenance chain**: If upstream_artifact_id is set, verify it exists
8. **Staleness**: Flag artifacts > 7 days old that are still in draft/under_review

**Output:**
```
Artifact Validation: prd-20260315-auth-system
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Header complete
  ✓ Status valid (draft)
  ✓ Confidence valid (0.82)
  ✓ Success criteria defined (3 criteria)
  ✓ Author valid (product-strategist)
  ✓ Path ownership correct
  ⚠ No provenance chain
  ✓ Not stale (created today)

Result: PASS (1 warning)
```

### `/mvat-artifact list [filter]`
List artifacts with optional filtering.

**Filters:**
- `--status <status>` — Filter by status (draft, approved, etc.)
- `--department <dept>` — Filter by department
- `--author <agent>` — Filter by author
- `--type <type>` — Filter by artifact type
- `--stale` — Show only stale artifacts (>7 days unconsumed)

**Steps:**
1. Glob all artifact files across `artifacts/` and `governance/escalations/`
2. Read headers from each
3. Apply filters
4. Present formatted table sorted by updated_at descending

### `/mvat-artifact advance <id> <new-status>`
Advance an artifact through the status lifecycle.

**Valid transitions:**
```
draft → under_review → approved → consumed → archived
draft → abandoned
under_review → draft (rejected, with feedback)
```

**Steps:**
1. Find artifact by ID
2. Validate the transition is legal
3. Update status and updated_at
4. If moving to `approved`, verify confidence >= 0.65
5. If moving to `consumed`, record consuming agent
6. Write updated artifact

### `/mvat-artifact trace <id>`
Trace an artifact's full provenance chain.

**Steps:**
1. Read artifact, extract upstream_artifact_id and provenance chain
2. Recursively follow chain to root
3. Present visual trace:
```
Provenance Chain: adr-20260315-auth
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  strategy-20260310-mvat-focus (product-strategist)
    └→ prd-20260312-auth-system (product-strategist)
       └→ adr-20260315-auth (architect)  ← you are here
          └→ [no downstream yet]
```

### `/mvat-artifact archive-stale`
Auto-archive stale artifacts (>7 days unconsumed).

**Steps:**
1. Scan all artifacts for status=draft or status=under_review
2. Filter those older than 7 days
3. Move status to `archived` with note "auto-archived: stale"
4. Report what was archived

## Artifact Protocol Reference

### Required Header Fields
| Field | Type | Description |
|-------|------|-------------|
| artifact_id | string | Unique ID: `{type}-{YYYYMMDD}-{slug}` |
| artifact_type | string | Category of artifact |
| author | string | Agent name or "founder" |
| department | string | Owning department |
| status | string | Lifecycle status |
| confidence | float | 0.0-1.0 confidence score |
| success_criteria | string[] | Explicit completion conditions |

### Confidence Gating
| Threshold | Action |
|-----------|--------|
| >= 0.85 | Auto-execute downstream |
| 0.65-0.84 | Flag for review, proceed with caution |
| < 0.65 | Escalate, do not consume |

### Status Lifecycle
```
draft ──→ under_review ──→ approved ──→ consumed ──→ archived
  │            │
  │            └──→ draft (rejected + feedback)
  └──→ abandoned
```
