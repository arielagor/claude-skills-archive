---
name: mvat-init
description: "Initialize the MVAT multi-agent framework in any project. Scaffolds governance, pipeline, agents, hooks, and artifact directories."
user_invocable: true
---

# /mvat-init — Scaffold MVAT Framework

Initialize the full MVAT autonomous multi-agent framework in the current project.
This command creates all required directories, governance files, hooks, templates,
and a starter set of agent specs — turning any repo into an MVAT-managed project.

## What It Creates

### Directory Structure
```
.claude/
  agents/{product,design,engineering,testing,marketing,analytics,finance,governance}/
  skills/{artifact-protocol,governance-reader,cross-synthesis,pipeline-awareness,product-conventions}/
  hooks/
  agent-memory/
artifacts/
  product/{strategy-docs,prds,market-reports,personas,backlogs}/
  design/{ux-audits,component-specs,interaction-contracts,design-tokens,accessibility-reports}/
  engineering/{adrs,firebase-architecture,platform-audits,build-configs,security-reports,tech-debt-ledger}/
  testing/{quality-verdicts,coverage-reports,healing-logs}/
  marketing/{aso-experiments,content-drafts,social-calendars,ad-briefs}/
  analytics/{kpi-definitions,behavior-reports,crash-digests,anomaly-alerts,experiment-results}/
  finance/{budget-reports,revenue-snapshots,forecasts,spend-alerts}/
  governance/{judge-verdicts,spec-revisions,synthesis-reports,validation-failures}/
governance/
  escalations/
  audit-log/
orchestration/
  workflows/
  team-configs/
rollout/
  retrospectives/
templates/
scripts/
products/
```

### Governance Files (JSON state)
- `governance/kill-switch.json` — global and per-agent enable/disable
- `governance/circuit-breakers.json` — failure tracking, auto-reset
- `governance/rate-limits.json` — per-agent hourly action limits
- `governance/autonomy-levels.json` — L4 confidence-based autonomy
- `governance/file-ownership.json` — artifact path ownership
- `governance/complexity-profiles.json` — compute allocation guidance
- `governance/assumption-registry.json` — tracked assumptions with history
- `governance/corrections.jsonl` — append-only founder correction log

### Hooks
- `.claude/hooks/governance-gate.sh` — PreToolUse enforcement of all governance rules
- `.claude/hooks/audit-logger.sh` — PostToolUse action logging

### Templates
- `templates/artifact-header.template.json`
- `templates/agent-spec.template.md`
- `templates/prd.template.md`
- `templates/adr.template.md`
- `templates/escalation.template.json`
- `templates/test-plan.template.md`
- `templates/retrospective.template.md`

## Execution Steps

When invoked, perform these steps:

### Step 1: Check for Existing MVAT Installation
```bash
if [ -f "governance/kill-switch.json" ]; then
  echo "MVAT framework already initialized in this project."
  echo "Use /mvat-govern to manage governance state."
  exit 0
fi
```
If `governance/kill-switch.json` exists, inform the user MVAT is already set up. Offer to reinitialize specific components only.

### Step 2: Determine Project Type
Read the project to determine:
- **Language/Framework**: Check for `package.json` (Node/React), `Cargo.toml` (Rust), `pyproject.toml` (Python), `go.mod` (Go), etc.
- **Existing CI/CD**: Check for `.github/workflows/`, `Dockerfile`, etc.
- **Existing Claude config**: Check for `.claude/` directory

### Step 3: Create Directory Structure
Create all directories listed above. Use `mkdir -p` to create nested structures idempotently.

### Step 4: Generate Governance Files
Create all governance JSON files with sensible defaults:

**kill-switch.json** — All departments enabled, global enabled. Start with a minimal agent set based on project type:
- Solo developer: 6 core agents (product-strategist, architect, quality-sentinel, pipeline-judge, spec-evolver, budget-manager)
- Small team: 15 agents (add design, testing leads)
- Full: All 39 agents

**circuit-breakers.json** — All agents untripped, 3-failure threshold, 30-min auto-reset.

**rate-limits.json** — Default 100 actions/hour, 50 writes/hour, 30 bash/hour. Higher limits for architect (150/80/50).

**autonomy-levels.json** — L4 full autonomy with confidence gating (0.85/0.65 thresholds).

**file-ownership.json** — Map artifact paths to owning agents. Each path has exactly one writer.

**assumption-registry.json** — Empty assumptions array, ready for use.

**corrections.jsonl** — Empty file, append-only.

### Step 5: Generate Core Skills
Create the 5 core skills in `.claude/skills/`:
1. **artifact-protocol** — Structured artifact communication protocol
2. **governance-reader** — Governance file reading and enforcement
3. **cross-synthesis** — Cross-department synthesis reports
4. **pipeline-awareness** — 10-stage pipeline architecture
5. **product-conventions** — Product-specific convention discovery

Each skill uses the standard frontmatter:
```yaml
---
name: {skill-name}
mode: autonomous
escalation_on_ambiguity: governance/escalations/
description: {description}
---
```

### Step 6: Generate Hooks
Create governance enforcement hooks:
- `.claude/hooks/governance-gate.sh` — PreToolUse hook checking kill-switch, circuit-breakers, rate-limits, file-ownership, cross-modification invariant
- `.claude/hooks/audit-logger.sh` — PostToolUse hook logging all actions

Both must be `chmod +x`.

### Step 7: Generate Templates
Copy all templates from the MVAT scaffold templates into `templates/`.

### Step 8: Generate Starter Agent Specs
Based on rollout phase R1, create the 6 core agent specs:
- `product-strategist.md` — Product department lead
- `architect.md` — Engineering department lead
- `quality-sentinel.md` — Testing quality gate
- `pipeline-judge.md` — Independent cross-department validator
- `spec-evolver.md` — Autonomous spec revision
- `budget-manager.md` — Finance tracking

### Step 9: Generate Pipeline Configuration
Create `orchestration/pipeline.json` with the full 10-stage pipeline and R1 simplified 5-stage variant.

### Step 10: Generate Rollout Configuration
Create `rollout/current-phase.json` starting at R1 with 6 active agents.

### Step 11: Generate CLAUDE.md Section
Append the MVAT framework section to the project's `CLAUDE.md` (create if not exists). Include:
- Agent session model
- Governance overview
- Artifact protocol
- Confidence gating
- Pipeline overview
- Anti-drift rules
- File structure
- Learning architecture

### Step 12: Generate products/active-product.json
Create a product configuration pointing to the current repo in monorepo mode:
```json
{
  "name": "{project-name}",
  "repo_path": ".",
  "app_dir": "{detected-app-dir}",
  "platform": "{detected-platform}"
}
```

### Step 13: Create Utility Scripts
Generate helper scripts in `scripts/`:
- `pipeline-status.sh` — Show full framework status
- `reset-circuit-breakers.sh` — Reset tripped breakers
- `validate-governance.sh` — Consistency checks
- `founder-dashboard.sh` — Daily digest

All scripts must be `chmod +x`.

### Step 14: Summary
Print a summary of what was created:
```
MVAT Framework initialized successfully!

  Governance:  7 state files + 2 hooks
  Agents:      6 core specs (R1 phase)
  Pipeline:    10-stage (R1 simplified: 5-stage)
  Skills:      5 core skills
  Templates:   7 document templates
  Scripts:     4 utility scripts

Next steps:
  /mvat-pipeline status     — Check pipeline state
  /mvat-agent launch <name> — Launch an agent
  /mvat-rollout advance     — Progress to next phase
  /mvat-dashboard           — View founder dashboard
```

## Customization Options

The user can pass arguments to customize initialization:
- `--phase R2` — Start at a later rollout phase with more agents
- `--agents minimal|standard|full` — Control initial agent count
- `--platform expo|next|django|rails|generic` — Pre-configure for a specific platform
- `--no-hooks` — Skip hook generation (for manual governance)
- `--product-name <name>` — Set the product name

## Important Notes
- All governance files are JSON — versionable, diffable, rollbackable via git
- Hooks fail-open on missing files but fail-closed on explicit disable
- The framework is product-agnostic — it wraps any codebase
- Agent specs are the highest-leverage files — treat with production-code rigor
