---
name: heuristic-detector-hygiene
description: |
  Build a code scanner, repo classifier, linter, or triage detector that does not produce
  confident false positives. Use when: (1) writing anything that greps a codebase to decide
  what it IS (has a queue, uses auth, is serverless, needs X), (2) a detector reported
  something a repo demonstrably does not have, (3) a detector missed something obviously
  present, (4) you are about to trust synthetic fixtures as proof a scanner works. Covers
  evidence-vs-guess confidence, stripping comments before word-matching (a comment can state
  the opposite of what you detect), auditing the input set before the match logic, skipping
  build output, and proving a regression by reverting the fix. For the case where a REAL
  validator exists, use that instead — see feedback-gate-broken-detectors-on-real-validator.
author: Claude Code
version: 1.0.0
date: 2026-08-21
---

# Heuristic detector hygiene

## Problem

Some questions have no validator to defer to. "Does this repo have a queue?" has no parser
that answers it. You must use heuristics, and heuristics fail **silently and confidently**:
they assert a fact about a codebase that is not true, and nothing errors.

## Trigger conditions

- Writing a scanner that classifies a repo, or a rule that fires on grep output.
- A detector reported a gate/feature a repo does not have, or missed one it does.
- You are relying on fixtures you wrote yourself as evidence the scanner works.

## Solution

**1. Separate evidence from a guess, and report which.**
A declared dependency or a config file is evidence. A word appearing in source is a guess.
Emit `confident` vs `possible`, and make the caller confirm guesses rather than acting on
them. `controller.enqueue(chunk)` is the Web Streams API, not a job queue.

**2. Strip comments before any word-matching.**
The sharpest failure. A comment can state the **opposite** of what you are detecting:

- `// lost update: no onlyIfMatch` matched an `onlyIfMatch` detector and inverted its meaning
- `// enqueue an SMS delivery` fired a queue detector on a repo with no queue

Build a comment-stripped corpus for word matchers; keep the full text for config/syntax
matchers. Require usage syntax (`onlyIfMatch\s*[:=]`), not the bare word.

**3. Audit the input set before debugging the match logic.**
A missed cron looked like a cron-detector bug. It was not: `.mts` was absent from the
file-extension list, so the file was **never read at all**. Before asking why a pattern did
not match, print what you actually read. Include `.mts/.cts`, `.astro`, `.svelte`, `.vue`.

**4. Skip build output, not just `node_modules`.**
`.netlify/`, `.next/`, `.vercel/`, `.output/`, `.turbo/`, `dist/`, `target/` contain
**vendored third-party code**, which produces confident false positives sourced from
somebody else's library.

**5. Read every ecosystem's manifest.**
Reading only `package.json` made a Python project's `celery` and `apscheduler` invisible and
silently downgraded a confident gate to a guess. Watch non-greedy regex on manifests:
`\[([\s\S]*?)\]` truncates a dependency list at the `]` inside `psycopg[binary]`.

**6. Synthetic fixtures prove nothing about coverage.**
Three hand-written fixtures passed every assertion while **five detectors were broken**. One
real repo found all five in a single run. Run against real repos first; then backfill a
fixture that mirrors the *shape* of what broke, so it cannot regress.

## Verification

**Prove the regression, do not assert the fix.** Temporarily revert the fix, show the
detector fails, restore, show it passes:

```js
const orig = fs.readFileSync(p, 'utf8');
fs.writeFileSync(p, orig.replace(/m\?ts\|c\?ts\|tsx/, 'ts|tsx'));   // simulate the old bug
console.log('old ->', /cron/.test(run()) ? 'detected' : 'NO  <- the bug');
fs.writeFileSync(p, orig);
console.log('fix ->', /cron/.test(run()) ? 'detected' : 'NO');
```

Beware exit codes here: `cmd | head` returns `head`'s status, so a crashing scanner can
report `EXIT=0`. Check the real status.

## Notes

- A watch list is still a recommendation. Applying the smell test only to the "active"
  output and not to the advisory output lets the same wrong claim through a side door.
- When a detector fires correctly but the specific item cannot apply (a serverless gate
  activating `connection-pooling` on a project with no database), that is a **structural
  n/a**, not a deferral. Model the two separately.
- See also: `feedback-gate-broken-detectors-on-real-validator-not-heuristic` — when a real
  validator exists, this skill does not apply; use the validator.
- Reference implementation: `~/.claude/projects/production-discipline/scripts/gate.mjs`
  and its `verify-fixtures.mjs` regression assertions.

## References

First-hand measurement rather than published sources: every failure above was observed
building `production-discipline` on 2026-08-21 and is reproducible from that repo's history.
