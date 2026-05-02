---
name: mvat-spec
description: "Create, inspect, and evolve agent specifications. The highest-leverage files in the MVAT framework."
user_invocable: true
---

# /mvat-spec — Agent Spec Operations

Create, inspect, validate, and evolve agent specifications — the highest-leverage
files in the MVAT framework. Agent specs define what each agent can do, how it
operates, and what it produces.

## Commands

### `/mvat-spec create <agent-name> <department>`
Create a new agent specification from the template.

**Steps:**
1. Read `templates/agent-spec.template.md`
2. Prompt for key fields:
   - Agent name and description
   - Department (product, design, engineering, testing, marketing, analytics, finance, governance)
   - Model tier (opus or haiku) — follow tier rules:
     - Opus: writes production code, content, specs, gating decisions, or substantive analysis (default for any agent that produces output)
     - Haiku: read-only analysis and reporting only
   - Tools needed (Read, Write, Edit, Bash, Glob, Grep, Agent)
   - Max turns
3. Fill template with provided values
4. Write to `.claude/agents/{department}/{agent-name}.md`
5. Add entry to `governance/kill-switch.json` (disabled by default)
6. Add file ownership entries to `governance/file-ownership.json`
7. Add circuit-breaker entry to `governance/circuit-breakers.json`
8. Add rate-limit entry to `governance/rate-limits.json`
9. Report new spec path and next steps

### `/mvat-spec inspect <agent-name>`
Deep inspection of an agent spec.

**Steps:**
1. Find spec file in `.claude/agents/*/`
2. Parse frontmatter (name, model, tools, department, version)
3. Extract and present:
   - **Authority Boundaries**: AUTONOMOUS / ESCALATE / NEVER actions
   - **Process**: 6-step workflow
   - **Inter-Agent Interfaces**: RECEIVES FROM / SENDS TO
   - **File Ownership**: Owned paths and access levels
   - **Failure Modes**: Recovery strategies
4. Cross-reference with governance state (enabled, breaker, rate limits)
5. Check for spec quality issues:
   - Ambiguous phrases ("try to", "if possible", "generally")
   - Missing NEVER boundaries
   - Incomplete inter-agent interfaces
   - Model tier violations (haiku writing content, etc.)

### `/mvat-spec validate [agent-name]`
Validate agent spec(s) against MVAT standards.

**Validation checks:**
1. **Frontmatter**: All required fields present (name, description, model, tools, department)
2. **Session Model**: Fresh context section exists
3. **Initialization**: 5 mandatory checks present (CLAUDE.md, kill-switch, circuit-breakers, rate-limits, autonomous mode)
4. **Authority Boundaries**: AUTONOMOUS, ESCALATE, and NEVER sections all present
5. **NEVER section**: Includes mandatory items (no interactive tools, no blocking on input, no self-spec modification)
6. **No ambiguity**: No phrases like "try to", "if possible", "generally", "when appropriate"
7. **Inter-Agent Interfaces**: Both RECEIVES FROM and SENDS TO tables present
8. **File Ownership**: Path table present, paths match `governance/file-ownership.json`
9. **Model tier compliance**: Model matches role requirements
10. **Confidence Gating**: Threshold table present

If no agent specified, validate ALL specs.

**Output:**
```
Spec Validation: architect.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Frontmatter complete
  ✓ Session model defined
  ✓ Initialization checks (5/5)
  ✓ Authority boundaries complete
  ✓ NEVER section has mandatory items
  ✓ No ambiguous phrases
  ✓ Inter-agent interfaces defined
  ✓ File ownership matches governance
  ✓ Model tier correct (opus)
  ✓ Confidence gating present

Result: PASS
```

### `/mvat-spec evolve <agent-name> [evidence]`
Propose a spec evolution based on evidence.

**This follows the spec-evolver pattern:**

1. **Gather evidence** from multiple sources:
   - Judge verdicts mentioning this agent (`artifacts/governance/judge-verdicts/`)
   - Escalation patterns (recurring escalations from this agent)
   - Circuit-breaker trip history
   - Audit log patterns (frequent failures, unusual patterns)
   - Founder corrections (`governance/corrections.jsonl`)
   - User-provided evidence (optional argument)

2. **Analyze patterns**:
   - What is the agent doing wrong repeatedly?
   - What authority does it need that it doesn't have?
   - What authority does it have that it shouldn't?
   - Are its interfaces correct?

3. **Draft revision**:
   - Write a spec revision artifact to `artifacts/governance/spec-revisions/`
   - Include: diff, rationale, predicted impact, rollback plan
   - Set confidence score based on evidence strength

4. **Apply if approved**:
   - If confidence >= 0.85 and no authority boundary changes: auto-apply
   - If authority boundary changes: flag for founder review
   - Write revision to spec file
   - Log in spec revision history

### `/mvat-spec diff <agent-name>`
Show recent changes to an agent spec (git diff).

### `/mvat-spec list`
List all agent specs with summary info.

**Output:**
```
MVAT Agent Specs
━━━━━━━━━━━━━━━━
Product (5 agents):
  product-strategist  v2.1.0  Opus    Lead  — "Defines product strategy"
  spec-writer         v1.0.0  Opus          — "Writes PRDs from strategy"
  ...

Engineering (8 agents):
  architect           v3.2.0  Opus    Lead  — "System architecture and ADRs"
  frontend-engineer   v2.0.0  Opus          — "React Native implementation"
  ...

Total: 39 specs across 8 departments
```

## Spec Quality Standards

### Mandatory Elements
Every agent spec MUST include:
1. YAML frontmatter with name, description, model, tools, department, version
2. Session Model section (fresh context)
3. Initialization section (5 mandatory checks)
4. Authority Boundaries (AUTONOMOUS / ESCALATE / NEVER)
5. Process (6-step workflow)
6. Inter-Agent Interfaces (RECEIVES FROM / SENDS TO)
7. File Ownership table
8. Confidence Gating table
9. Failure Modes & Recovery table

### Forbidden Patterns
- Ambiguous authority phrases: "try to", "if possible", "generally", "when appropriate"
- Missing NEVER boundaries
- Haiku agents with write authority over content/code
- Agents that can modify their own spec
- Interactive tool usage (AskUserQuestion, EnterPlanMode) in pipeline agents

### Model Tier Rules
| Tier | Can Write Code | Can Write Content | Can Gate | Can Analyze |
|------|---------------|-------------------|----------|-------------|
| Opus | ✓ | ✓ | ✓ | ✓ |
| Sonnet | ✗ | ✓ | ✗ | ✓ |
| Haiku | ✗ | ✗ | ✗ | ✓ |
