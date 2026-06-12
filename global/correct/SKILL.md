---
name: correct
description: Capture a founder correction the moment it happens as a durable feedback memory (+ GBrain page when reachable), so the lesson compounds instead of evaporating at end-of-session. Use when Ariel corrects an approach ("no, do X not Y", "actually never do Z", "that's wrong because..."), confirms a non-obvious approach worked, or says "/correct", "remember this correction", "capture that". Local-first; degrades gracefully when GBrain/Docker is down.
---

# /correct — Ambient correction capture

This skill exists because corrections are the highest-value learning signal and they evaporate if not captured at the moment they happen. The retired MVAT framework's `corrections.jsonl` was 1,852 bytes from a single day because capture relied on end-of-session retros that mostly never ran. Capture must be ambient: one invocation, at the moment of the correction, writing to the loop that is demonstrably alive (feedback memories + GBrain), not to a dead append-only log.

## When to fire

- Ariel corrects an approach: "no, do X not Y", "don't ever do Z", "that's wrong because...", "use A instead of B".
- Ariel confirms a non-obvious approach worked without pushback (a silent success worth recording).
- Explicit: "/correct", "capture that correction", "remember this".

Do NOT fire for trivial typo fixes or one-off transient errors. Capture durable, transferable lessons only — the test is "would a future session do better knowing this".

## Hard rules

- **Validate the before-image. Never fabricate.** Only capture a correction whose "what I was doing wrong" you can point to concretely in this session (a tool call, a file, a stated plan). If you cannot ground the before-state, ask Ariel one clarifying question rather than inventing it. A fabricated correction in the learning signal is the same trust corrosion as a Goodhart-able confidence score.
- **Scoped, not whole-repo.** Capture the named change and its rationale, not a dump of everything that happened.
- **Local-first, degrade gracefully.** The feedback memory file is the source of truth and must always be written. The GBrain page is best-effort: if Docker/the brain/the MCP is unreachable, write the memory file anyway and note "GBrain queued" — never hard-fail the capture because the brain is down.
- **No em-dashes** in anything written for Ariel.

## Steps

1. **Extract the correction** into three parts:
   - `claim` — one falsifiable sentence: the rule to follow going forward.
   - `before` — what was being done wrong (grounded in this session).
   - `why` — the reason the correction matters (the cost of the old way).
   - `how_to_apply` — the concrete trigger + action for a future session.

2. **Write the feedback memory** to `C:\Users\ariel\.claude\projects\C--Users-ariel\memory\feedback_<short-kebab-slug>.md` with this exact frontmatter shape:
   ```markdown
   ---
   name: feedback_<short-kebab-slug>
   description: <the claim, one line>
   metadata:
     type: feedback
   ---

   <the claim, expanded to 2-3 sentences with the grounded before-state.>

   **Why:** <why it matters / the cost of the old way.>

   **How to apply:** <trigger + action for a future session.>

   Related: [[<link to adjacent memory if one exists>]].
   ```
   First check for an existing feedback memory on the same topic (Grep the memory dir by keyword); UPDATE it rather than creating a duplicate.

3. **Add the MEMORY.md index line** under the most relevant section of `C:\Users\ariel\.claude\projects\C--Users-ariel\memory\MEMORY.md`:
   `- **<claim, with date> (YYYY-MM-DD).** <one-line hook.> — [feedback_<slug>.md](feedback_<slug>.md)`
   Keep it to one line under ~200 chars (the index is loaded every session).

4. **GBrain (best-effort).** If `mcp__gbrain__*` tools are available and the brain is reachable, file a `feedback/` or `concepts/` page mirroring the memory (per RESOLVER.md) and tag it. Known issue: `mcp__gbrain__add_link` has an ON CONFLICT upsert bug; skip the link or use the direct-psql workaround, do not fail the capture. If the brain is unreachable, write `<!-- GBrain queued: <slug> -->` as a one-line note at the end of the memory file and move on.

5. **Confirm** to Ariel in one line: what was captured and where, e.g. "Captured: `feedback_<slug>` (memory + MEMORY.md; GBrain filed/queued)."

## Deferred (queued for a watched session)

The original P-07 also proposed adding a PRESENT-BUT-INEFFECTIVE category to `session-retro.mjs` (so the retro emits "already implemented, investigate compliance" instead of re-proposing a landed fix). That edit touches a script ~40 scheduled tasks depend on at session start, so per the council it is queued: make the change additive-only, back up the script, and diff `node session-retro.mjs --days 1 --json` output before/after on the same input to prove no existing path changed. Until then, `/correct` ships skill-only.
