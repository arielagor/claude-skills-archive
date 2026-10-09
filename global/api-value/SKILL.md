---
name: api-value
description: |
  Price Ariel's Claude Code usage at Anthropic API list rates for ANY time window, set it
  against what the Claude plan cost over the same span, and publish it as a private
  artifact in the AI Plan Value Ledger design (hero multiple, stacked value over time,
  per-day or per-month bars vs fee, average hour of day, token mix, per-model table,
  subagents vs main sessions, top sessions). Use when Ariel types "/api-value", or asks
  "what was my usage worth last week", "API value for <period>", "redo the value ledger
  for <dates>", "how much did Claude Code save me this month", or wants the weekly-reset
  version of the ledger. Default window when none is given: the last completed weekly
  reset (Thursday 06:00 PT to Thursday 06:00 PT).
---

# /api-value

One deterministic pipeline, no LLM calls: `scripts/run.mjs`, stages **price -> shape -> render**.

| stage | does | writes |
|---|---|---|
| price | runs `~/.claude/scripts/usage-audit/api-value.mjs` over every transcript under `~/.claude/projects` (about 2 min) | `priced.json`, `priced.md` (full text report: sessions, subagents, projects, hours) |
| shape | buckets by hour (window up to 14 days) or day, bars by day (up to 45 days) or calendar month, adds plan fee per hour from `plans.json`; throws if the buckets do not sum to the priced total | `data.json` |
| render | injects data into `template.html`, syntax-checks the page script | `api-value-<from>_<to>.html` |

Outputs land in `~/.claude/cache/api-value/<from>_<to>/`. Re-run one stage with `--stage shape` or `--stage render` (e.g. after a template edit) without re-pricing.

## 1. Resolve the window

All times are **Pacific wall clock** (`America/Los_Angeles`, DST handled by the script).

- No period given, "last week", "last reset", "last week's Thursday reset to yesterday's/this Thursday's": `--preset last-week` (the most recent completed Thu 06:00 -> Thu 06:00).
- "This week so far": `--preset this-week` (last Thu 06:00 to the current hour).
- Anything else: translate to `--from "YYYY-MM-DD HH:MM" --to "YYYY-MM-DD HH:MM"`. Calendar day/month boundaries are 00:00; the end is exclusive ("September" = `--from "2026-09-01 00:00" --to "2026-10-01 00:00"`). Use today's date from context; don't guess the year.
- If the phrase is genuinely ambiguous (e.g. "last month" on the 1st), pick the obvious reading and state it in the reply; do not ask.

## 2. Run

```bash
node ~/.claude/skills/api-value/scripts/run.mjs --preset last-week
node ~/.claude/skills/api-value/scripts/run.mjs --from "2026-09-01 00:00" --to "2026-10-01 00:00"
```

Run it with a 600000 ms timeout (pricing scans ~1,600 files). The last lines print the window, the shaped total, plan cost, multiple, and the rendered file path. If the shape stage throws "models with no family mapping" or the price stage lists `UNPRICED` models, add the model's price to the `PRICES` table in `api-value.mjs` (from the claude-api skill, never from memory) and its family to `famOf` in `run.mjs`, then re-run.

## 3. Publish

Publish the rendered HTML with the Artifact tool: `file_path` = the printed path, `icon: "chart"`, a one-sentence `description` naming the window. Each window gets its own file name, so each run makes a new private artifact; to refresh an existing one (e.g. "this-week" later in the week), publish with that artifact's `url`. The page is a recreation of the lifetime ledger design (https://claude.ai/artifact/RR3vsP7AbHnvHFw1skBcuv); don't restyle it per run.

## 4. Report

Give Ariel the link plus, from `data.json` and `priced.md`: API value vs plan cost and the multiple, the model split, the biggest day, the subagent share, and the top 1-3 sessions. Say plainly what is not counted (claude.ai chat and apps, other machines, untranscribed scheduled runs, other AI services). Compare to the previous run if one is in context.

## Facts the pipeline relies on

- **Plan cost** comes from `plans.json`: explicit renewals (Pro $20 to Feb 13 2026, Max 20x $249.99 from then, renewing on the 14th since April), then a monthly `recurring` rule. Each renewal is spread evenly over its billing period, the same method as the lifetime ledger. **If Ariel changes plan or price, edit `plans.json`** or every later window is wrong.
- **Session names** shown are custom titles only; an untitled session shows "(untitled session)", never its first prompt (which can be private). The page is private by default; it names sessions, so mention that before Ariel shares it.
- **Old windows read low**: Claude Code deletes old transcripts, so the count only covers files that still exist. The lifetime ledger used the `/stats` cache instead, so its totals for the same dates can differ slightly.
- Output tokens: `api-value.mjs` keeps each streamed message's max `output_tokens` (the first line is a partial). See memory `reference_usage_audit_api_value.md`.
