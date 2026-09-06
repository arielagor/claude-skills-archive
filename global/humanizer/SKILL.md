---
name: humanizer
description: >-
  Strip the machine tells out of generated text so it reads as written by a
  person. Use when writing or reviewing any published prose — a blog post,
  newsletter, podcast script, social post, product review, landing page, email
  — and whenever a draft "sounds like AI" or needs a voice check before it
  ships. Also the shared engine every content cron on agor.me,
  modelstack.digital and scored.tools runs its output through, so use it when
  changing what those pipelines are allowed to say, when adding a banned word
  or sentence shape, or when a post got published carrying a tell.
---

# humanizer

One definition of the house voice, enforced in three places: the prompt that
generates the text, the linter that grades it, and the repair pass that fixes
it. All three read the same rule files, so the instructions and the grader
cannot drift apart.

## When to reach for this

- Writing anything that gets published under Ariel's name or a property's name.
- Reviewing a draft that "reads like AI" but you cannot say why.
- Adding or relaxing a voice rule for one or every property.
- A post shipped with a tell in it and you want to know how it got through.

## The quickest useful thing

```bash
node ~/.claude/skills/humanizer/lib/cli.mjs lint <file> --property agor.me
```

Exit 0 clean, 1 violations, 2 error. It prints `file:line` for every hit with
the fix. To repair in place:

```bash
node ~/.claude/skills/humanizer/lib/cli.mjs fix <file> --property agor.me --write
```

`fix` refuses to write a file that still fails, unless you pass `--force`.

## How it works

Four stages, in the order a pipeline needs them.

| Stage | Call | Cost | What it does |
|---|---|---|---|
| 0. Typography | `stripTypography()` | free | Em- and en-dashes to commas. Deterministic, so it never burns a retry. Never touches `---`. |
| 1. Instruct | `promptFragment()` | free | Renders the rules into the generation prompt. |
| 2. Grade | `lint()` | free | Regex + density check. Returns hits with line numbers and a ready-to-paste `retryHint`. |
| 3. Repair | `rewrite()` | 1-2 Max-plan calls | Surgical edit of only what failed. Re-grades afterwards. |

`enforce()` runs all four and is what the crons call.

### Severities

- **block** — an unambiguous tell. One hit fails.
- **warn** — real but context-dependent ("robust cash flow" is fine). One is
  noise, many is a voice problem, so warns fail collectively through a density
  ceiling rather than individually.
- **shape** — habits, not words. Tricolons, em-dash density, colon-splice punch
  lines. Capped per 1000 words.

Every rate uses a denominator floored at 400 words. Without that, one tricolon
in a 150-word LinkedIn post scores 6.7/1000 against a ceiling of 3 and fails,
while the same single tricolon in a 3,000-word essay passes. Short copy is
judged on counts, long copy on rate.

### Per-property overrides

`rules/lexicon.mjs` → `PROPERTY_OVERRIDES`. modelstack demotes `leverage`,
`robust` and `ecosystem` because finance writing uses them as terms of art.
scored.tools demotes `ecosystem` and `seamless` and skips blockquotes, because
a tool review quotes vendor marketing. agor.me relaxes nothing.

Keep the override lists short and justified. An override list that grows
without explanation is how a shared standard quietly becomes three standards
again.

## Where the rules live

| File | Holds |
|---|---|
| `rules/lexicon.mjs` | ~150 banned words and phrases, with severity, category, and the plain-English replacement shown to the repair pass. |
| `rules/formulations.mjs` | Sentence SHAPES — the negation-contrast family, rhetorical-question pivots, reader-bucketing, self-referential AI framing. Plus density-capped `SHAPES`. |
| `lib/humanizer.mjs` | The engine. Node stdlib only, because three repos with different dependency trees import it. |
| `lib/cli.mjs` | Shell access for non-JS pipelines. |
| `tests/humanizer.test.mjs` | Fixtures. `node --test tests/humanizer.test.mjs` |

**To add a rule:** add the entry, add a fixture proving it fires AND a clean
sentence proving it does not over-fire, run the tests. Every property picks it
up on its next run with no other change.

## What is wired to it

Installed 2026-09-06. All of these run through the same engine:

| Property | Pipeline | Cron | Mode |
|---|---|---|---|
| agor.me | daily blog | `AgorMe\DailyBlog` | prompt + gate + retry loop + salvage repair |
| agor.me | The Memo newsletter | `AgorMe\WeeklyNewsletter` | prompt + repair on body, lint on subject/thesis |
| agor.me | podcast script | `AgorMe\EpisodeCheck` | prompt + regenerate-on-fail (2 rounds) |
| agor.me | LinkedIn copy | daily blog step | prompt + repair |
| modelstack.digital | daily blog | `ModelStack\DailyBlog` | prompt + repair |
| modelstack.digital | newsletter | `ModelStack\WeeklyNewsletter` | prompt + repair on body |
| modelstack.digital | LinkedIn copy | daily blog step | prompt + repair |
| scored.tools | articles | `ScoredTools\DailyPublish` | prompt + repair |
| scored.tools | tool reviews | `ScoredTools\ProcessCandidate` | prompt + repair on tagline/verdict |
| scored.tools | social copy | distribution step | prompt + repair, X under a length ceiling |

Each repo has a thin `scripts/lib/humanizer.mjs` shim that dynamic-imports this
engine and pre-binds the property. The import is dynamic and outside the repo
on purpose: a `file:` dependency pointing at `~/.claude/skills` breaks every
Netlify build, and these scripts only ever run from the local cron.

## Rules the pipelines follow

**Never block the presses.** Every wired pipeline publishes its best version
and logs what still failed. A daily post that does not go out is worse than one
carrying a soft tell. The one exception is agor.me's blog, which was already
binding before this existed and stays that way — the salvage repair makes it
fail less often, not more.

**Regenerate structured text, repair prose.** The podcast script is a labeled
`LEO:` / `MAYA:` transcript whose parser depends on line structure, so it
regenerates with the violations fed back rather than being handed to a
free-text repair that might merge two turns.

**Repair only free prose fields.** Not slugs, dates, categories, ratings or
URLs. A rewritten slug breaks a collision check; a rewritten date breaks a
schema.

## Evidence, not configuration

`~/.claude/governance/humanizer-log/YYYY-MM.jsonl` gets one line per run:
counts before and after, repair rounds, the model used, and which rules fired.

```bash
node ~/.claude/skills/humanizer/lib/cli.mjs stats
```

"The gate is installed" and "the gate fires" are different claims and only the
log supports the second one. Measured on a deliberately bad 182-word draft:
27 blocking hits and a warn density of 15 went to 0 in two repair rounds, with
frontmatter, headings, sources, the URL and every number preserved.

## Costs

Lint and prompt injection are free. The repair pass is 1-2 `claude -p` calls on
the Max plan, so flat-rate. `ANTHROPIC_API_KEY` and the cloud-provider flags
are stripped from the child env — with any of them set, Claude Code's
precedence is API key over OAuth and the call lands silently on the metered
API. Override the model with `HUMANIZER_MODEL`; it defaults to
`claude-sonnet-5`, then the CLI default if that id is unknown.

## Known limits

- The lexicon is tuned for English business and technical prose. It has not
  been calibrated against fiction; `anti-ai-narrative-tells` covers that.
- Running `lint` over the 389 already-published posts fails 68% of them, mostly
  on em-dashes that `enforce` strips before grading. That number describes the
  back catalogue, not new output.
- A post genuinely ABOUT ecosystems will fight the `ecosystem` ban. That is
  what `PROPERTY_OVERRIDES` and `--max-warn-density` are for; do not weaken a
  rule globally to fix one post.
