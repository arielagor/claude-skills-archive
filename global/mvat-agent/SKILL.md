---
name: mvat-agent
description: "Launch, inspect, and manage MVAT agents. Run individual agents, check their status, and view agent specs."
user_invocable: true
---

# /mvat-agent — Agent Operations

Launch, inspect, and manage agents in the MVAT multi-agent framework.

## Commands

### `/mvat-agent launch <agent-name> [task]`
Launch a specific agent to perform work.

**Steps:**
1. Read the agent spec from `.claude/agents/{department}/{agent-name}.md`
2. Verify agent is enabled in `governance/kill-switch.json`
3. Check circuit-breaker state in `governance/circuit-breakers.json`
4. Check rate limits in `governance/rate-limits.json`
5. Determine the correct model tier from the agent spec frontmatter:
   - **Opus** (`claude-opus-4-7`): default for any agent that produces output — architect, frontend-engineer, backend-engineer, code-reviewer, quality-sentinel, pipeline-judge, spec-evolver, product-strategist, spec-writer, ui-designer, test-strategist, content-writer, and all other content/analysis/coding agents
   - **Haiku** (`claude-haiku-4-5-20251001`): read-only analysis only — market-researcher, anomaly-detector, crash-reporter, budget-manager
   - **Sonnet is BANNED** in this stack. Any agent spec that frontmatter-declares Sonnet must be re-tiered to Opus before launch.
6. Launch the agent using the Agent tool with:
   - `subagent_type` matching the agent name
   - `model` matching the tier from the spec
   - A prompt incorporating the task, agent spec context, and any input artifacts
7. Report results and any artifacts produced

**Example:**
```
/mvat-agent launch architect "Design the authentication system architecture"
/mvat-agent launch quality-sentinel
/mvat-agent launch product-strategist "Define MVP strategy for the fitness app"
```

### `/mvat-agent list`
List all agents with their status.

**Steps:**
1. Read `rollout/current-phase.json` for active agents
2. Read `governance/kill-switch.json` for enable/disable state
3. Read `governance/circuit-breakers.json` for tripped state
4. Present formatted table:

```
MVAT Agents — Phase R1
━━━━━━━━━━━━━━━━━━━━━━
Department: Product
  ✓ product-strategist  Sonnet  — enabled
  ○ spec-writer         Sonnet  — R2 (inactive)
  ○ market-researcher   Haiku   — R2 (inactive)

Department: Engineering
  ✓ architect           Opus    — enabled
  ○ frontend-engineer   Opus    — R2 (inactive)
  ○ code-reviewer       Opus    — R2 (inactive)

Department: Testing
  ✓ quality-sentinel    Opus    — enabled

Department: Governance
  ✓ pipeline-judge      Opus    — enabled
  ✓ spec-evolver        Opus    — enabled

Department: Finance
  ✓ budget-manager      Haiku   — enabled

Active: 6/39  |  Tripped: 0  |  Rate-limited: 0
```

### `/mvat-agent inspect <agent-name>`
Show detailed information about an agent.

**Steps:**
1. Read the full agent spec from `.claude/agents/{department}/{agent-name}.md`
2. Read agent's circuit-breaker state
3. Read agent's rate-limit counters
4. Check agent memory at `.claude/agent-memory/{agent-name}/` if it exists
5. Scan `governance/audit-log/` for recent actions by this agent
6. Present:
   - Full spec summary (authority boundaries, process, interfaces)
   - Current governance state (enabled, breaker, rate limits)
   - Recent activity (last 10 actions from audit log)
   - Owned file paths
   - Upstream/downstream agents

### `/mvat-agent enable <agent-name>`
Enable a disabled agent in the kill-switch.

**Steps:**
1. Read `governance/kill-switch.json`
2. Set `.agents.{agent-name}.enabled` to `true`
3. Clear reason field
4. Write updated kill-switch

### `/mvat-agent disable <agent-name> [reason]`
Disable an agent in the kill-switch.

**Steps:**
1. Read `governance/kill-switch.json`
2. Set `.agents.{agent-name}.enabled` to `false`
3. Set reason field
4. Write updated kill-switch

### `/mvat-agent reset <agent-name>`
Reset an agent's circuit breaker and rate limits.

**Steps:**
1. Reset circuit-breaker state (tripped=false, consecutive_failures=0)
2. Reset rate-limit counters to 0
3. Report new state

## Agent Model Tiers

| Tier | Model | Use Case | Agents |
|------|-------|----------|--------|
| Opus | `claude-opus-4-6` | Production code, critical gates | architect, frontend-engineer, backend-engineer, code-reviewer, quality-sentinel, pipeline-judge, spec-evolver |
| Sonnet | `claude-sonnet-4-6` | Content writing, substantive analysis | product-strategist, spec-writer, ui-designer, test-strategist, + 15 more |
| Haiku | `claude-haiku-4-5` | Read-only analysis, reporting | market-researcher, anomaly-detector, budget-manager, + 10 more |

**Rules:**
- Haiku agents MUST NOT write user-facing content, code, or make gating decisions
- Any agent that writes content MUST be Sonnet or higher
- Any agent that writes production code MUST be Opus

## Department Roster

| Department | Lead | Members |
|------------|------|---------|
| Product | product-strategist | spec-writer, market-researcher, user-persona-analyst, prioritization-engine |
| Design | ui-designer | design-system-manager, ux-researcher, interaction-designer, accessibility-auditor |
| Engineering | architect | frontend-engineer, backend-engineer, code-reviewer, security-engineer, devops-engineer, tech-debt-tracker, mobile-platform-specialist |
| Testing | test-strategist | quality-sentinel, unit-test-writer, integration-test-writer, auto-healer |
| Marketing | launch-coordinator | aso-optimizer, content-writer, social-media-manager, ad-operations |
| Analytics | metrics-architect | behavior-analyst, crash-reporter, anomaly-detector, experiment-runner |
| Finance | budget-manager | revenue-tracker, financial-forecaster, spend-alerter |
| Governance | — | pipeline-judge, spec-evolver |
