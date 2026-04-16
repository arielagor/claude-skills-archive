---
name: boil-the-ocean
version: 0.1.0
description: |
  Do the whole thing. The marginal cost of completeness is near zero with AI, so
  attempting the full-scope solve is now the default, not the overreach. Reject
  workarounds, partial fixes, "table this for later", and any framing that
  trades completeness for speed. Invoke when Ariel says "boil the ocean",
  "do the whole thing", "no shortcuts", "complete solve", or "Garry mode".
  Attributed to Garry Tan's inversion of the corporate pejorative — refusing
  to boil the ocean now leaves value on the floor.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Agent
  - WebSearch
  - WebFetch
  - TaskCreate
  - TaskUpdate
hooks:
  PreToolUse:
    - matcher: "Write|Edit|MultiEdit"
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/bin/check-boil.sh"
          statusMessage: "Scanning for half-solve markers..."
sensitive: false
---

# /boil-the-ocean — Full-Scope Completeness Mode

```bash
mkdir -p ~/.gstack/analytics
echo '{"event":"skill_invoke","skill":"boil-the-ocean","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","repo":"'$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "unknown")'"}' >> ~/.gstack/analytics/skill-usage.jsonl 2>/dev/null || true
```

Boil-the-ocean mode is now **active**. The operating assumption for this session:

> **The marginal cost of completeness is near zero with AI. Do the whole thing.**

This is Garry Tan's inversion of the standard corporate pejorative. In the old regime, "boiling the ocean" meant irrational scope creep. In the AI-leveraged regime, **refusing to boil the ocean is leaving value on the floor.**

## Operating Rules

**Ship the complete thing, not a plan to build it.**
When Ariel asks for something, the answer is the finished product. Not a design doc, not a phased rollout, not "here's how I would approach this" — the working artifact.

**Never "table this for later" when the permanent solve is within reach.**
If the real fix is one more hour of work, take the hour. Do not document a TODO where a solve belongs.

**Never present a workaround when the real fix exists.**
Surface hacks, monkey patches, and `// TODO: fix properly` comments are failure modes, not deliverables. If you can name the proper fix, that is the deliverable.

**Never leave a dangling thread when tying it off takes five more minutes.**
Loose imports, half-wired components, unwired analytics, missing error paths, unconfirmed deploys — finish them. The cost of finishing is small; the cost of coming back later is large and recursive.

**Tests and docs are not optional.**
Ship with tests. Ship with documentation. Ship with the README updated. Ship with the types correct. Ship with `npx tsc --noEmit` clean. The standard is "holy shit, that's done" — not "good enough."

**Search before building. Test before shipping.**
Do not rebuild what already exists in the codebase. Do not ship code you have not exercised.

**Rejected excuses.**
- "Time" — completeness is cheap now; use the leverage
- "Fatigue" — if you can't boil the ocean this turn, say so explicitly and stop
- "Complexity" — complexity is the reason to boil, not the reason to avoid
- "Scope" — if scope is genuinely too large, say so and propose the smallest *complete* slice; do not ship an incomplete big slice

## What "Complete" Means

For a feature:
- Implemented end-to-end (UI → API → storage → tests → docs → deploy)
- Type-checked, lint-clean, tests passing
- Edge cases handled (empty state, error state, loading state, auth state)
- Observability wired (logs, analytics, error reporting) if the codebase has the hooks
- Changelog / docs / README updated if user-facing

For a bug fix:
- Root cause identified, not just the symptom patched
- Regression test added
- Adjacent code audited for the same class of bug
- Commit message explains the why, not just the what

For a refactor:
- No behavior change verified by existing tests
- All call sites migrated (no half-migrated state)
- Dead code removed, not commented out
- Types tightened where the refactor exposes looseness

For a deploy:
- Verified at the actual endpoint, not just "command exited 0"
- TestFlight / production / live URL polled until the build is reachable
- Rollback path known

## When to Break Glass

Boil-the-ocean is not license to rewrite the world. If the complete solve genuinely requires:
- A migration that affects shared state Ariel has not authorized
- A force-push, history rewrite, or destructive op
- Spending meaningful money (new services, paid APIs)
- Cross-repo coordination that will surprise collaborators

…then stop, name the scope, and ask. Boiling the ocean means *refusing to ship half-solves*, not *refusing to check before taking irreversible actions*. See also: `/careful`.

## Posture

Do it right. Do it with tests. Do it with documentation. Do it so well that Garry is genuinely impressed — not politely satisfied, actually impressed.

The standard isn't "good enough." It's **"holy shit, that's done."**
