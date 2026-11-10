---
name: ontology-query
description: Answer business-number questions (LLM/Claude/Gemini spend and tokens by tier, job or day; outbound emails sent by experiment, lane or domain; email-verification spend; warm-up placement; role-inbox tickets; pipeline failures; harness fixes; agent runs in agor_ops; accounting transactions) from the certified semantic layer (NVIDIA auto-ontology, repo ~/.claude/projects/ontology), returning the number WITH its SQL. Use instead of hand-reading JSONL ledgers or psql whenever a count, sum or rate over these sources is needed, including SCORECARD numbers. Never quote a remembered count.
---

# ontology-query

The ontology stack runs locally. The web gateway is `http://localhost:3000`, run from Docker Compose in `~/.claude/projects/ontology`. It answers questions over these sources, all on gbrain-pg and all read-only:
- `ledgers`: `llm_calls`, `gemini_calls`, `pipeline_events`, `harness_fixes`, `outbound_sends`, `email_verify_spend`, `warmup_events`, `role_inbox`
- `agor_ops`
- `accounting`

## Ask
```bash
node ~/.claude/projects/ontology/scripts/ontology-ask.mjs "How many outbound emails were sent in October 2026?" --json
```
- **Exit 0:** you get `{answer, sql, rows, steps, coverage}`. Report the number together with the SQL that produced it.
- **Exit 3:** the question is not covered by the ontology. Say so; don't guess, and don't fall back to an unverified hand count.
- **Exit 1:** the stack is down or errored. Check with `cd ~/.claude/projects/ontology && npm run -s stack -- ps`, and start it with `npm run -s stack -- up -d --wait`.

## Before you report a claim-bearing number
1. Read the SQL. Check its filters (dates are UTC), its tier and status values, and that it uses `sum` where a sum is meant, not `count`.
2. Check whether the rows were truncated (the cap is 100). Re-ask more narrowly if so.
3. Freshness: the JSONL ledgers load nightly (`\Ontology\Nightly`). For today's rows, run `npm run -s load-ledgers` first.

## Fix a wrong definition
Correct the term or SQL attribute in the UI at http://localhost:3000. Then run `node scripts/pipeline/export.mjs` and commit `ontology/`, so the fix is versioned.

## Regression check
`node ~/.claude/projects/ontology/scripts/golden.mjs` asks the golden questions (`golden.json`) and diffs each answer against hand-written SQL.
