---
name: mvat-review
description: "Multi-lens review combining MVAT's pipeline-judge validation with battle-tested CEO/Eng review rigor. Catches drift, hallucinations, security gaps, and silent failures."
user_invocable: true
---

# /mvat-review — Multi-Lens Review

Combines MVAT's 3-lens pipeline validation with gstack's 10-section CEO review methodology.
The result: a review system that catches everything from goal drift to silent SQL failures.

## Commands

### `/mvat-review code [path]`
Deep code review using combined MVAT + gstack methodology.

**Phase 1: MVAT 3-Lens Validation**

1. **Goal Alignment** — Does the code match its stated objectives?
   - Read the upstream PRD/ADR for acceptance criteria
   - Check AC reference annotations (`// AC-{story}.{criterion}`) are present
   - Verify each AC is covered by implementation
   - Flag code that doesn't trace to any requirement

2. **Factual Consistency** — Is the code consistent with the rest of the system?
   - Check imports resolve to real modules
   - Verify API contracts match between caller and callee
   - Ensure types are consistent across boundaries
   - Flag hardcoded values that should come from config/tokens

3. **Reasoning Coherence** — Does the implementation logic hold?
   - Review error handling for completeness
   - Check edge cases are addressed
   - Verify state management is sound

**Phase 2: Pre-Landing Checklist (from gstack)**

Run two-pass review against the diff:

**Pass 1 — CRITICAL (blocks shipping):**
- **SQL & Data Safety**: String interpolation in SQL, TOCTOU races, update_column bypassing validations, N+1 queries
- **Race Conditions**: Read-check-write without uniqueness constraint, find_or_create_by without unique DB index, non-atomic status transitions
- **LLM Output Trust Boundary**: LLM-generated values written to DB without format validation, structured tool output accepted without type/shape checks
- **XSS vectors**: `html_safe` on user-controlled data, `raw()`, string interpolation into html_safe output

**Pass 2 — INFORMATIONAL:**
- Conditional side effects (code paths that forget side effects on one branch)
- Magic numbers & string coupling
- Dead code & consistency (variables assigned but never read, stale comments)
- Test gaps (negative-path tests missing side-effect assertions)
- Crypto & entropy (truncation instead of hashing, `rand()` for security values)
- Type coercion at boundaries (Ruby→JSON→JS type changes)

**Output format:**
```
MVAT Code Review: src/auth/login.ts
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MVAT 3-Lens:
  Goal Alignment:     ✓ 3/3 AC covered
  Factual Consistency: ⚠ 1 hardcoded timeout
  Reasoning Coherence: ✗ Password in URL params

Pre-Landing Review: 3 issues (1 critical, 2 informational)

  CRITICAL:
  - [src/auth/login.ts:42] Password sent via URL params — use POST body
    Fix: Move credentials to request body

  Issues:
  - [src/auth/login.ts:15] Magic number 5000ms — extract to config
  - [src/auth/login.ts:28] Missing .expects(:mailer).never on failure path

Verdict: NEEDS_REVISION (1 critical)
```

### `/mvat-review plan [mode]`
CEO/founder-level plan review — the most thorough review mode.

**Three modes (ask user to choose):**
- **SCOPE EXPANSION**: Dream big. Find the 10-star product. Push scope UP.
- **HOLD SCOPE**: Lock scope. Maximum rigor on architecture, security, edge cases.
- **SCOPE REDUCTION**: Ruthless minimalism. Strip to essentials.

**Context defaults:** Greenfield → EXPANSION. Bug fix → HOLD. Refactor → HOLD. >15 files → suggest REDUCTION.

**Critical rule:** Once mode is selected, COMMIT. Never silently drift.

**Pre-Review System Audit:**
```bash
git log --oneline -30                    # Recent history
git diff main --stat                     # What's already changed
git stash list                           # Stashed work
```
Read CLAUDE.md, any TODOS.md, existing architecture docs.

**Step 0: Nuclear Scope Challenge**
- Is this the right problem to solve?
- What existing code already solves each sub-problem?
- Dream state mapping: CURRENT → THIS PLAN → 12-MONTH IDEAL
- Temporal interrogation: What decisions will need to be made during implementation?

**10 Review Sections (one issue = one AskUserQuestion, never batch):**

1. **Architecture** — System design, data flow (all 4 paths: happy, nil, empty, error), state machines, coupling, scaling, security architecture, rollback posture. ASCII diagrams mandatory.

2. **Error & Rescue Map** — For EVERY method/service/codepath that can fail:
   ```
   METHOD/CODEPATH      | WHAT CAN GO WRONG        | EXCEPTION CLASS
   ExampleService#call  | API timeout              | TimeoutError
                        | API returns 429          | RateLimitError
   ```
   Rules: `rescue StandardError` is always a smell. Every rescued error must retry, degrade gracefully, or re-raise with context.

3. **Security & Threat Model** — Attack surface expansion, input validation (nil, empty, type mismatch, injection), authorization, secrets, dependency risk, audit logging.

4. **Data Flow & Interaction Edge Cases** — For every new data flow, trace: INPUT → VALIDATION → TRANSFORM → PERSIST → OUTPUT with shadow paths (nil? empty? wrong type? timeout? conflict?). For interactions: double-click, navigate-away-mid-action, slow connection, stale state, back button.

5. **Code Quality** — DRY violations, naming quality, cyclomatic complexity (flag >5 branches), over/under-engineering.

6. **Test Review** — Diagram ALL new UX flows, data flows, codepaths, background jobs, integrations, error paths. For each: what test covers it? Happy path? Failure path? Edge case? "What's the test that makes you confident shipping at 2am Friday?"

7. **Performance** — N+1 queries, memory usage, database indexes, caching, background job sizing, connection pool pressure.

8. **Observability & Debuggability** — Logging, metrics, tracing, alerting, dashboards, runbooks. "If a bug is reported 3 weeks post-ship, can you reconstruct what happened from logs alone?"

9. **Deployment & Rollout** — Migration safety, feature flags, rollout order, rollback plan, deploy-time risk window, smoke tests.

10. **Long-Term Trajectory** — Technical debt introduced, path dependency, knowledge concentration, reversibility (1-5 scale), ecosystem fit.

**Required Outputs:**
- "NOT in scope" section
- "What already exists" section
- Error & Rescue Registry (complete table)
- Failure Modes Registry (CODEPATH | FAILURE | RESCUED? | TEST? | USER SEES? | LOGGED?)
- TODOS updates (each as individual AskUserQuestion)
- Diagrams (system architecture, data flow, state machine, error flow, deployment, rollback)
- Completion Summary table

### `/mvat-review eng`
Engineering manager review — streamlined version of plan review.

**Three options after scope challenge:**
1. **SCOPE REDUCTION**: Propose minimal version
2. **BIG CHANGE**: Interactive, one section at a time (Architecture → Code → Tests → Performance), max 8 issues per section
3. **SMALL CHANGE**: Compressed — Step 0 + single combined pass, one top issue per section

**Same question protocol:** One issue = one AskUserQuestion. Lead with recommendation. Map to engineering preferences. Present 2-3 lettered options.

### `/mvat-review pipeline`
Full pipeline state review (MVAT pipeline-judge style).

**Steps:**
1. Read all artifacts across all stages
2. Apply 3-lens validation across stage boundaries
3. Check for drift patterns:
   - **Goal drift**: Objectives shifting without explicit decision
   - **Scope creep**: Features appearing that weren't in PRD
   - **Cascading hallucination**: Error in one artifact propagated downstream
4. Produce judge verdict at `artifacts/governance/judge-verdicts/`

### `/mvat-review assumptions`
Review all assumptions for staleness and risk.

### `/mvat-review drift`
Trace objectives through strategy → PRD → ADR → code → tests. Flag: preserved, narrowed, expanded, lost, mutated.

## Review Verdict Format

| Verdict | Meaning | Action |
|---------|---------|--------|
| `PASS` | All checks pass | Proceed |
| `PASS_WITH_NOTES` | Minor issues, non-blocking | Proceed, address later |
| `NEEDS_REVISION` | Issues must be fixed | Block, return for fixes |
| `CRITICAL_FAILURE` | Fundamental problems | Halt, escalate immediately |

## Question Protocol (from gstack)

Every AskUserQuestion MUST:
1. Present 2-3 concrete lettered options
2. State recommended option FIRST
3. Explain WHY in 1-2 sentences
4. One issue per question — NEVER batch
5. Label with NUMBER + LETTER (e.g., "3A", "3B")
6. Escape hatch: if no issues or fix is obvious, state what you'll do and move on

## Suppressions — DO NOT flag

- Redundancy that aids readability
- "Add a comment explaining this threshold"
- "This assertion could be tighter" when it already covers the behavior
- Consistency-only changes
- Anything already addressed in the diff being reviewed
