---
name: gemini-decisions-api
description: Use before any code that classifies, routes, gates, answers yes/no or scores with an LLM, and before moving such a call to the Gemini Decisions API (gemini-decision-1). Covers the only allowed entry point (~/.claude/scripts/lib/lean-decide.mjs), the bench-first rule, the data-scope limits (mail yes, texts and dating and job-search no), shadow wiring, and the per-site verdict registry. Triggers: "use the Decisions API", "make this classifier cheaper", "swap this to Gemini decide", "lean-decide", "decide-bench", "shadow this classifier".
---

# Gemini Decisions API

The Decisions API returns calibrated probabilities for choice, yes/no (`noul`) and score questions over one shared input. It is cheap ($0.10 per 1M input tokens, nothing for output) and fast (about 250 to 650 ms). On our own bench it beat Claude on only 2 of 13 call sites. Cheap is not the same as right, so **bench first**.

## Rules (always)

1. **One entry point.** Call `decide()` from `~/.claude/scripts/lib/lean-decide.mjs`. Never write a literal `gemini-decision-N` id or POST to `/v1*/decisions` yourself; the `lean-seam-gate` hook denies both. The model id lives only in the `model-tiers.json` `decisions` block.
2. **Bench before swapping.** Check `~/.claude/scripts/decide-bench/VERDICTS.json`. A site not listed has not been benched: write a site adapter under `scripts/decide-bench/sites/`, run `node scripts/decide-bench/run.mjs --site <name>`, and have the disagreements judged before anyone wires it. Results are gitignored and never committed.
3. **Data scope (Ariel, 2026-11-12).** Mail yes. Texts, SMS, iMessage, keepclose, dating content and job-search mail never go to Google. `data-scope.mjs` enforces the job denylist (`googleDenied`) and the content filter (`mailScopeFilter`). Any job that reads a mailbox passes `scopeFilter: mailScopeFilter`. Mixed personal inboxes (`cos`, `inbox-warden`) are refused in `live` mode and refused without a filter.
4. **Shadow before live.** New sites run `mode: 'shadow'` with `fallback` returning Claude's already-computed answer (no extra Claude call). Log ids, labels and confidences only, never mail text. Give the shadow a kill-switch env var and a cap and time budget, and make it never throw into the production path.
5. **Live flips are Ariel's call, per site.** Bring him the shadow scoring (agreement, coverage at the threshold, every risky row read by hand) and a recommendation. Record each flip in the repo's `docs/decisions/` and in `VERDICTS.json`.

## Calling it

```js
const lib = pathToFileURL(join(homedir(), '.claude', 'scripts', 'lib')).href
const { decide } = await import(`${lib}/lean-decide.mjs`)
const { mailScopeFilter } = await import(`${lib}/data-scope.mjs`)
const r = await decide({
  job: 'my-site-decide', caseId: msgId, input: text,
  questions: {
    class: { type: 'choice', instructions: '...', criteria: { order: '...', other: '...' } },
    urgent: { type: 'noul', instructions: '...' },
    priority: { type: 'score', instructions: '...', criteria: ['low', 'medium', 'high'] },
  },
  thresholds: { class: 0.9 }, mode: 'shadow',
  fallback: async () => claudeAnswer, scopeFilter: mailScopeFilter,
})
// shadow: r.answers = Claude's, r.decisions = raw Decisions answers; filtered mail -> r.filtered, decisions null
```

## Traps

- `choice` criteria are a map `{option: description}`. `score` criteria are an ordered ARRAY of level strings; a map is rejected.
- There is no abstain option, so gate on confidence. Name the catch-all `other` (keys sort by bytes).
- Score confidence runs low by nature (about 0.46 on sensible answers), so never apply a global floor to scores.
- Adjacent text blocks are joined with no separator; put your own newlines in the input.

## Live references

- Shadow examples: agor-company `ops/lib/inbound-money-decide-shadow.mjs`; scored.tools `scripts/discovery/triage-decide-shadow.mjs`.
- Ledger: `~/.claude/logs/llm-ledger.jsonl` rows with `auth: 'gemini-decide'`, statuses `OK | FALLBACK | ERROR | DATA_SCOPE_DENIED | SCOPE_FILTERED`.
- Memory: `reference_gemini_decisions_api`, `feedback_gemini_data_scope_mail_yes_texts_no`.
