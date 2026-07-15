---
name: council
description: >-
  Convene a 3-agent decision council (operator, skeptic, strategist) that independently argues to
  consensus, or to the best option after 3 rounds, on any recommended decision. Use when the user
  types /council, or asks to "run a council", "have the agents decide", "argue this out across
  perspectives", "get a multi-lens decision", "council this", or "replace my judgment with the
  council". Runs the proven engine from the Agor AI Ads venture (headless claude -p, $0 on the Max
  plan, full transcript logged). The council decides WHAT to do; irreversible or outward actions
  still get a human checkpoint.
---

# /council — the 3-agent decision council

Three advisors with deliberately different lenses take an independent position on a decision, then
argue across up to 3 rounds. Unanimous and the council proceeds with it; no consensus after 3 rounds
and it proceeds with the **best non-unanimous choice** (the plurality winner, weighted by confidence)
regardless. The point is to replace a human judgment call with a fast, multi-perspective, auditable
decision. Generalized from the Agor AI Ads venture, where it published index rankings and chose the
go-live architecture autonomously.

> **Guardrail.** The council decides *what* to do. It does NOT remove the checkpoint on irreversible
> or outward actions: charging a card, spending real money, publishing named content, sending to a
> third party, force-pushing, destructive ops. Run the council to decide; still confirm those before
> they execute.

## When the user types `/council`

1. **Get the decision.** From the user's message, extract the decision as a single question and, if
   they gave them, the options. If the decision or the options are unclear, ask once with
   AskUserQuestion: the decision statement, the candidate options (or "open" for an open-ended
   decision), and any context the advisors need (constraints, goal, what already exists).
2. **Run the council** (claude -p, $0; the engine strips ANTHROPIC_API_KEY per call):
   ```bash
   node ~/.claude/skills/council/bin/council.mjs \
     --q "<the decision as one question>" \
     --ctx "<context: constraints, goal, what exists, the honesty/risk bar>" \
     --opt "id1:Short label:one-line summary of the tradeoff" \
     --opt "id2:Short label:one-line summary" \
     --rounds 3 --slug "<kebab-case-decision>" \
     --project "<the current project name>" \
     --logdir "data/council"
   ```
   Omit all `--opt` for an OPEN decision (advisors propose; candidates freeze after round 1).
3. **Report the verdict.** Read the printed summary and the transcript JSON (`--logdir`). Tell the
   user: the decision, whether it was unanimous or best-of-N, each advisor's position + the
   load-bearing rationale, and (if non-unanimous or held) the tradeoff that did not resolve.
4. **Act on it.** Proceed per the verdict for reversible work. For any irreversible/outward step,
   surface it for the human checkpoint per the guardrail above.

Good fits: architecture choices, pricing, naming/branding, go/no-go gates, "publish this or hold",
sequencing, which-approach-of-N. Not for trivial mechanical edits.

## Standalone (project automation / cron)

The engine is plain ESM with zero dependencies. Use it inside a venture's own automation to make a
recommended decision without a human, exactly as Agor AI Ads does for index publishing:

```js
import { deliberate, summarizeVerdict } from '~/.claude/skills/council/lib/index.mjs'
const v = await deliberate({
  question: 'Is this ranking fair and safe to publish?',
  context: draftBrief,
  options: [{ id: 'publish', label: 'Publish' }, { id: 'hold', label: 'Hold' }],
  rounds: 3, slug: 'index-publish', project: 'my-app', logDir: 'data/council',
})
if (v.decision === 'publish') { /* ... */ }
```

Or from a spec file: `node ~/.claude/skills/council/bin/council.mjs --file decision.json`.

## The three lenses (`lib/personas.mjs`)

| Lens | Optimizes for |
| --- | --- |
| **Operator** | Shipping the working thing by the simplest, fastest path; reuse what exists. |
| **Skeptic** | What breaks: irreversibility, real-money cost, legal/reputation/security/honesty exposure, rollback. |
| **Strategist** | Durable advantage and second-order effects; brand, moat, alignment to the project's goals. |

Lens diversity is the whole point. Three identical voters is redundancy; three genuinely different
lenses is deliberation. Swap or extend the lenses for a project by editing `personas.mjs`.

## How it decides

- Each round runs the three advisors **in parallel**. Rounds 2+ show each advisor the others'
  anonymized positions and ask them to rebut, concede, or move. Consensus is the goal; caving on a
  real risk just to agree is discouraged.
- **Unanimous** (all back the same choice) at any round → proceed with it.
- **No consensus after `--rounds`** → proceed with the plurality winner, weighted by confidence
  (the "best non-unanimous choice"), regardless.
- An advisor whose output will not parse, or whose choice does not match a fixed option, is recorded
  as an **abstention** (excluded from the tally) rather than guessed. It never crashes a run.
- Every run writes a full transcript + verdict to `--logdir` so each autonomous decision is
  auditable after the fact.

## Verify

`cd ~/.claude/skills/council && node --test` (8 tests, zero model spend; the LLM runner is injected).
