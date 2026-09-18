---
name: self-refreshing-data-page
description: |
  Build a PUBLIC page whose data re-verifies itself against external sources on a schedule
  (a pricing comparison, a benchmark league table, a rate card, a status or coverage page),
  without it ever publishing a number nobody checked. Use when: (1) asked for a page, report
  or dashboard that must "stay current" or "auto-update" from vendor docs, leaderboards or
  third-party APIs; (2) an LLM will parse pages that change shape without notice and you need
  it unable to fabricate a value into something public; (3) deciding what an unattended job may
  publish without human review; (4) a cron has run clean for weeks but the deployed page never
  changed; (5) a caption or summary now contradicts the chart beside it because the data moved
  underneath it; (6) a scraped figure turned out to be from the wrong tab, filter or domain.
  Covers the FETCH -> EXTRACT -> VERIFY -> PROSE -> GATE -> COMMIT pipeline, the verbatim-source
  gate that makes hallucinated numbers unpublishable, deriving prose instead of writing it,
  making staleness visible to readers, and six silent-failure traps that each present as success.
  NOT for monitoring a system and alerting on it (see external-system-watchdog), one-off
  verification of a claimed completion (see verify), or post-deploy canaries (see canary).
author: Claude Code
version: 1.0.0
date: 2026-09-18
---

# Self-Refreshing Data Page

## Problem

Someone asks for a page that "keeps itself up to date" from external sources. The naive build
looks fine and fails silently in six different ways, every one of which presents as success:
the cron exits 0, git exits 0, the page renders, and the numbers on it are wrong or frozen.

The hard part is not the scraping. It is that **an unattended job is publishing to a public
surface with nobody reading the diff.** Every guard below exists to make a specific wrong
thing structurally unpublishable rather than merely unlikely.

## Context / Trigger Conditions

- "Add this as a resource page and keep it updated", "refresh it every N days", "make it
  auto-update".
- The data lives on pages you do not control: vendor pricing, leaderboards, benchmark tables,
  status endpoints.
- An LLM is the only practical parser because the sources change shape without notice.
- Symptoms of an existing broken one:
  - The cron reports success for weeks and the live page has not changed.
  - A caption states a ranking the chart above it contradicts.
  - A scraped table is real, but from the wrong tab, domain or filter.
  - A published figure does not appear anywhere on the source page.

## Solution

### The pipeline, as named stages

`FETCH -> EXTRACT -> VERIFY -> PROSE -> GATE -> COMMIT`

Each stage is independently runnable and independently observable. Give the script a flag that
stops after stage 1 (`--fetch-only`), because stage 1 is the one that actually breaks and you
want to test it without spending an LLM budget.

### 1. The verbatim gate is the whole idea

An LLM is the right parser and a bad source of truth. Resolve it by splitting the two roles:
**the LLM chooses WHICH number, the source decides whether it is REAL.**

After extraction, walk every number in the returned JSON and require it to appear as a literal
substring of that page's fetched text. Try several renderings, because a page may write the same
price as `3`, `3.0`, `3.00` or `$3.00`. If any number fails, reject **that whole source's
extraction** and keep the previous values. Other sources still publish.

A hallucinated figure then cannot reach the page no matter how the source was reworded.

This is a fourth layer on top of the usual three (pre-flight shape check, try/catch soft
rejection, schema validation). Those three all validate SHAPE, and none of them can catch a
well-formed wrong value.

### 2. Guard a scraper on structure, never on a value

Assert that a structural string is present (`"Live API"`, `"Overall pass@1"`). Never assert a
price or score is present. Asserting `$12.00` makes the scraper hold precisely when the vendor
CHANGES the price, which is the one event the whole pipeline exists to catch.

### 3. Assert you scraped the right view

A leaderboard or table with tabs, filters or domains will hand you a real table from the wrong
one, and it looks entirely plausible. After clicking into the view you want, assert a string
that only that view renders. Fail the source rather than publish.

Worked example: taubench.com defaults to its Telecom domain tab, whose scores differ from
Overall by up to 11 points for the same model, and a plain `curl` of the voice URL returns the
Banking leaderboard regardless of query string.

### 4. Find a source that publishes both sides of a conversion, and use it as a test

If any vendor publishes the same quantity in two units (per token and per minute, per request
and per month), that vendor is a **test oracle, not just an input**. Compute one from the other
and assert it reproduces their published figure. If the identity breaks, your conversion
constants are stale and the run should hold rather than publish.

### 5. Derive prose, do not write it

Anything asserting a RELATIONSHIP in refreshing data must be computed. A hand-written caption
saying "X is second here" survives a reordering that puts X first, and then contradicts its own
chart. Compute rank and margin from the data.

Keep a separate stable `note` field for editorial context, and hold it to one rule: **nothing
order-dependent and no specific scores**, or the staleness returns through the back door.

If an LLM writes the surrounding copy, give it its own gate: reject any `$` or `%` figure in the
generated prose that is absent from the structured data.

### 6. Make staleness visible to the reader, not just to you

A promise-shaped field (`lastVerified`) advances only on a fully clean run. A partial run
publishes what it verified, records `sourcesOk / sourcesTotal`, and leaves the date alone.

Render a banner on the page itself past some threshold ("these figures are N days old"). A dead
cron then becomes visible to readers instead of quietly serving stale prices, which is the
failure a monitoring dashboard will not catch because nothing errored.

### 7. Publish gaps as content

Data that does not exist is often the finding. When an item has no value on the main axis, give
the unknown its own visible region rather than dropping the item. A "no public price" rail and a
"priced but not yet rated" panel turn two absences into the most useful thing on the page.

## Verification

Before trusting it:

1. **Run stage 1 alone** and check per-source anchors, including one that proves the LAST row of
   a lazily-hydrated table rendered, not just the first screenful.
2. **Run the conversion identity.** It should reproduce the vendor's own published figure exactly.
3. **Run the full pipeline in `--dry-run`** and read the change list. On a correctly seeded page
   the first dry run should report **zero field changes** for sources whose values you entered by
   hand, which cross-validates both your data and your scraper.
4. **Build, do not just typecheck.** See the trap below.
5. After the first live run, verify the DEPLOYED artifact changed, not that the job exited 0.

## Six traps, each of which fails silently

1. **The build skips the diff.** Many deploy setups skip builds whose diff only touches certain
   paths (`scripts/`, `docs/`). If the updater writes its data file next to its own script, it
   pushes happily forever while the deployed page never changes, and nothing errors. Put the data
   where the build watches.
2. **You scraped the wrong tab.** See solution 3.
3. **A plain fetch is refused.** Some vendor doc sites reject a non-browser client at the network
   layer ("fetch failed", no status code). A headless browser gets the same page fine. Do not
   conclude the URL is wrong.
4. **`typecheck` is not `build`.** A client component importing a module that imports `fs`
   passes `tsc --noEmit` and fails at bundle time ("Module not found: Can't resolve 'fs'" in the
   Client Component Browser trace). Split the module: pure isomorphic types and math in one file,
   the filesystem loader in another. Add the `server-only` package to the loader if available; it
   is the canonical guard and produces a clearer build-time error. The split is what fixes it,
   `server-only` is what makes the failure legible.
5. **`git push origin HEAD` in a cron.** If the repo can be left on a feature branch, a bare HEAD
   push publishes that branch instead of the site, and every git command still exits 0. Guard the
   branch BEFORE any fetching or LLM spend, and push the branch by name.
6. **A static caption over refreshing data.** See solution 5.

## Example

```js
// stage 3: VERIFY. The LLM picked these numbers; the source decides if they are real.
function numberVariants(n) {
  const v = new Set(); const num = Number(n);
  for (const d of [0,1,2,3,4]) v.add(num.toFixed(d));
  v.add(String(num));
  for (const s of [...v]) v.add(`$${s}`);
  return v;
}
const bad = collectNumbers(extracted)
  .filter(n => ![...numberVariants(n)].some(variant => sourceText.includes(variant)));
if (bad.length) throw new Error(`${bad.length} number(s) not found verbatim in source`);

// solution 5: the caption is computed, so it cannot contradict its own chart.
function panelFoot(panel) {
  const sorted = [...panel.bars].sort((a,b) => b.v - a.v);
  const i = sorted.findIndex(b => b.highlighted);
  const parts = [];
  if (i === 0) parts.push(`#1, by ${(sorted[0].v - sorted[1].v).toFixed(1)} points over ${sorted[1].l}.`);
  else if (i > 0) parts.push(`Places ${i+1} of ${sorted.length}, behind ${sorted[0].l} (${sorted[0].v}${panel.unit}).`);
  if (panel.note) parts.push(panel.note); // stable, order-independent, score-free
  return parts.join(" ");
}
```

## Notes

- **Decide autonomy explicitly and say so.** Three defensible settings: refresh data only and
  freeze the analysis; refresh and open a PR; refresh and rewrite the analysis. Only the third
  needs the prose gate. Whichever is chosen, numbers should stay deterministic.
- **Fork the target repo's existing cron runner rather than writing one.** It already encodes
  the scheduler lessons (no registry-resolving launcher under a scheduler, kill the process TREE
  on timeout, drain both child pipes, strip any env var that routes to paid billing).
- **Read the target repo's CLAUDE.md before authoring the cron**, not after. Repo-level docs are
  disproportionately about automation hazards and will already name the branch trap and the
  build-skip paths.
- On Windows, the scheduled task must use the **S4U** logon type or it flashes a console window
  on the desktop. `Hidden=true` does not suppress it.
- See also: `external-system-watchdog` (monitors an external system and ALERTS; this skill
  PUBLISHES from one, and the failure modes differ: alert noise versus silently shipping a wrong
  number), `verify` (one-off confirmation of a claimed completion), `heuristic-detector-hygiene`
  (scanning your own repo rather than someone else's page).

## References

- [Next.js: Server and Client Components](https://nextjs.org/docs/app/getting-started/server-and-client-components) — the `server-only` package and the build-time error it produces.
- [vercel/next.js discussion #54176](https://github.com/vercel/next.js/discussions/54176) — "Module not found: Can't resolve 'fs'", the exact symptom of trap 4.
- Reference implementation: `agor.me/scripts/refresh-voice-pricing.mjs` and
  `agor.me/docs/decisions/2026-09-18-voice-pricing-resource-page.md`.
