---
name: fix-until-green
version: 1.0.0
description: |
  Autonomous bug-fixing loop with hypothesis tracking, max-iteration cap,
  regression detection, and stuck-postmortem. Takes a failing test, GitHub
  issue, or bug description; iterates Edit→Run→Read until tests pass.
  Differs from /tdd and /fix-with-tests by being fully autonomous (no
  per-iteration confirmation), bounded (8 iterations max), and producing
  a postmortem on exhaustion. Auto-commits each green iteration.
  Use when the user says "fix until green", "loop until it works", "keep
  trying until tests pass", or wants hands-off bug resolution.
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Glob
  - Grep
triggers:
  - fix until green
  - loop until it works
  - keep trying until tests pass
  - autonomous fix
  - fix and dont stop
---

# Fix Until Green

Bounded autonomous loop. Generates hypotheses, patches, runs tests, evaluates regressions. Surfaces only on success or genuine exhaustion (with a written postmortem).

## Inputs

One of:
- A failing test path (e.g. `tests/payment.test.ts`)
- A GitHub issue URL
- A bug description (Claude writes the failing test first)

Optional flags:
- `max-iterations=N` (default 8)
- `commit-each-green=true` (default true)
- `regression-tests=<glob>` (default: closest sibling test files)

## Loop

```
ITER 0  Establish baseline
        └─ Run target test → confirm it FAILS as expected
        └─ Run regression suite → confirm baseline GREEN
        └─ If baseline already passes, exit "no bug to fix"

ITER N  (1..max-iterations)
        ├─ HYPOTHESIZE: state suspected cause in one sentence + which
        │  file:line you'll edit
        ├─ EDIT
        ├─ RUN target test
        │   ├─ FAIL → log hypothesis as ❌, continue
        │   └─ PASS → continue to regression check
        ├─ RUN regression tests
        │   ├─ NEW FAILURES → REVERT this iteration's edits, log as
        │   │  ❌-regressed, try a different approach
        │   └─ ALL GREEN → log as ✅, commit (if commit-each-green),
        │      exit success
        └─ If iteration N == max-iterations and no green: → POSTMORTEM
```

## Hypothesis log format

Maintain in working memory throughout the loop. Print at end (success or stuck).

```
ITER 1: [HYPOTHESIS] Race condition in webhook handler — stripe.ts:142
        [PATCH]      Add await before getStripe().retrieveSubscription
        [TARGET]     ❌ FAIL — same NPE
        [REGRESSION] —
ITER 2: [HYPOTHESIS] getStripe() returns null at module-eval time — stripe.ts:8
        [PATCH]      Lazy-init via factory function
        [TARGET]     ✅ PASS
        [REGRESSION] ✅ all green
        [COMMIT]     fix(stripe): lazy-init client to avoid module-eval null
        EXIT: success after 2 iterations
```

## Regression detection

After every green target test, run **at minimum**:
- All test files in the same directory as the patched file
- The TypeScript check (`npx tsc --noEmit`) if a .ts file was touched
- The linter on touched files (`eslint <files>` or project equivalent)

If any regress, REVERT the iteration's edits (`git checkout -- <files>`), log as ❌-regressed, and try a different hypothesis. Don't stack patches on top of broken state.

## Postmortem (on exhaustion)

If max-iterations hit without green, write to `~/.claude/stuck/<issue-or-bug-slug>.md`:

```markdown
# Stuck: <bug name>
- Started: <timestamp>
- Exhausted at iteration: <N>
- Test that wouldn't pass: <path>

## Hypotheses tried
1. <hypothesis> — failed because <observed result>
2. <hypothesis> — failed because <observed result>
...

## What I noticed but couldn't connect
- <pattern, anomaly, or smell that may matter>

## What I'd try next with more context
- <approach requiring info I don't have, e.g. "check what the prod env returns for X">

## Files touched and reverted
- <file>: <what was tried>
```

Then surface to the user: "Stuck at iteration N. Postmortem at `~/.claude/stuck/<slug>.md`. Want to keep going, escalate to /codex, or change approach?"

## Anti-patterns to refuse

- ❌ Patching without first reproducing the failure (skip ITER 0).
- ❌ Stacking iterations on broken state (regression must trigger revert).
- ❌ Lying about green — re-run the test command, don't trust prior output. (Wraps `/verify` semantics.)
- ❌ Removing/skipping the failing test to "make it pass."
- ❌ Editing the test to match buggy behavior. (If the test itself is wrong, surface that as a finding, don't mutate silently.)
- ❌ Going past max-iterations without a postmortem.

## Commit message format (when commit-each-green)

```
fix(<scope>): <one-line summary>

Hypothesis: <the one that worked>
Iterations to green: <N>
Tests: <target test path>
Regression check: ✅ <suite name>
```

## When NOT to use

- Bugs that need product/UX judgment (which behavior is correct?).
- Bugs where the test infrastructure itself is broken.
- "Bugs" that are actually feature requests.

In those cases, escalate to the user before looping.
