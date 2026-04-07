---
name: mvat-govern
description: "Inspect and manage MVAT governance state. View kill-switches, circuit breakers, rate limits, escalations, and corrections."
user_invocable: true
---

# /mvat-govern — Governance Operations

Inspect and manage the MVAT governance layer — the JSON-based control plane that
enforces rules across all agents.

## Commands

### `/mvat-govern status`
Show full governance state overview.

**Steps:**
1. Read all governance files:
   - `governance/kill-switch.json`
   - `governance/circuit-breakers.json`
   - `governance/rate-limits.json`
   - `governance/autonomy-levels.json`
   - `governance/assumption-registry.json`
2. Count pending escalations in `governance/escalations/`
3. Count corrections in `governance/corrections.jsonl`
4. Present formatted report:

```
MVAT Governance Status
━━━━━━━━━━━━━━━━━━━━━━
Global Kill-Switch: ✓ ENABLED
Departments:        8/8 enabled
Agents:             6/39 enabled (R1 phase)

Circuit Breakers:
  Tripped: 0/6
  Pipeline Paused: No
  Global Threshold: 5 simultaneous

Rate Limits (current hour):
  architect:           4/150 actions, 2/80 writes
  product-strategist:  12/120 actions, 8/60 writes

Autonomy Level: L4 (Full with guardrails)
  Auto-execute:  >= 0.85 confidence
  Flag/review:   0.65-0.84
  Escalate:      < 0.65

Assumptions: 3 active, 0 weakened, 0 invalidated
Escalations: 2 pending, 5 resolved
Corrections:  3 logged
```

### `/mvat-govern kill-switch [action] [target]`
Manage the kill-switch.

**Actions:**
- `status` — Show current kill-switch state (default)
- `disable <agent|department|global>` — Disable a target
- `enable <agent|department|global>` — Enable a target

**Examples:**
```
/mvat-govern kill-switch disable architect "Maintenance window"
/mvat-govern kill-switch enable product
/mvat-govern kill-switch status
```

### `/mvat-govern breakers [action]`
Manage circuit breakers.

**Actions:**
- `status` — Show all breaker states (default)
- `reset <agent-name>` — Reset a tripped breaker
- `reset-all` — Reset all tripped breakers
- `trip <agent-name> [reason]` — Manually trip a breaker

### `/mvat-govern rate-limits [action]`
View and manage rate limits.

**Actions:**
- `status` — Show current rate-limit counters
- `reset <agent-name>` — Reset an agent's counters
- `set <agent-name> <limit-type> <value>` — Set a new limit

### `/mvat-govern escalations [action]`
Manage escalations.

**Actions:**
- `list` — List all pending escalations (default)
- `resolve <id> [notes]` — Mark an escalation as resolved
- `create <severity> <summary>` — Manually create an escalation

**Steps for `list`:**
1. Glob `governance/escalations/esc-*.json`
2. Read each, filter by status=pending
3. Sort by severity (critical > high > medium > low), then by date
4. Present formatted list

### `/mvat-govern assumptions [action]`
Manage the assumption registry.

**Actions:**
- `list` — List all assumptions with status and confidence
- `add <text> [confidence]` — Register a new assumption
- `weaken <id> [evidence]` — Weaken an assumption with evidence
- `invalidate <id> [evidence]` — Invalidate an assumption
- `history <id>` — Show confidence trajectory for an assumption

### `/mvat-govern corrections [action]`
Manage the corrections log.

**Actions:**
- `list` — Show recent corrections
- `log <type> <description>` — Log a new correction (append to corrections.jsonl)

### `/mvat-govern ownership`
Show file ownership map.

**Steps:**
1. Read `governance/file-ownership.json`
2. Present formatted table of paths → owning agents
3. Highlight any shared write paths

### `/mvat-govern audit [agent] [date]`
View audit log entries.

**Steps:**
1. Read `governance/audit-log/{date}.jsonl` (default: today)
2. Filter by agent if specified
3. Show summary of actions: reads, writes, bash commands
4. Highlight any failures

## Governance Architecture

### Enforcement Model
- **PreToolUse hook** (`governance-gate.sh`): Checks kill-switch, circuit-breakers, rate-limits, file-ownership before EVERY tool call
- **PostToolUse hook** (`audit-logger.sh`): Logs every action to audit trail
- **Fail-open** on missing files (warn but allow)
- **Fail-closed** on explicit disable

### Autonomy Levels
| Level | Description |
|-------|------------|
| L1 | Human approves every action |
| L2 | Human approves significant actions |
| L3 | Agent acts, human reviews after |
| L4 | Full autonomy with guardrails (current) |
| L5 | Full autonomy, no guardrails |

### Circuit Breaker Logic
```
consecutive_failures >= 3 → TRIP breaker
simultaneous_trips >= 5 → PAUSE pipeline
auto_reset after 30 minutes
```

### File Ownership Rules
- Each artifact path has **exactly one writer**
- Shared write paths: escalations, validation-failures, assumption-registry
- Phase overrides allow temporary expanded ownership (e.g., R1: architect writes code)
- Cross-modification invariant: no agent can modify its own spec
