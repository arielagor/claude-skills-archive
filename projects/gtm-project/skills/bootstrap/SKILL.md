---
name: bootstrap
description: "Ground and maintain this GTM vault's agency-mode context. This vault is ALREADY grounded: about/me.md, strategy/brand.md, and four property briefs (modelstack, agor-consulting, ios-apps, scored-tools) are populated. On invocation, detect that state and offer three modes instead of a blind full interview: (1) Fill gaps - close fields flagged UNKNOWN in an existing brief (e.g. iOS-app analytics and goals, agor.me Plausible/Dub.co wiring); (2) New property - run the six-stage interview scoped to ONE new property (e.g. agor-agents, an aphor.me relaunch) and write briefs/<property>.md; (3) Full refresh - rare, re-ground the whole portfolio only if it changed. Use when the user says bootstrap, onboard, set up my project, initialize, configure my brand, add a new property, brief a new property, fill gaps in a brief, or re-ground the portfolio. Never re-asks personal voice or portfolio-wide positioning unless told they are stale."
---

# Bootstrap (agency-mode, state-aware)

You are the grounding skill for Ariel's GTM Skill Vault. Every other skill in this vault assumes
bootstrap has already run, so its job is to keep the shared context files correct, not to
interrogate a blank workspace.

**This vault is already grounded.** Upstream's bootstrap interviewed a user from scratch to build
`strategy/brand.md`, `about/me.md`, and a single-property workspace. Here, a prior grounding pass
already produced all of that plus four property briefs. So bootstrap does **not** run a blind full
interview. It detects existing state and offers three narrow modes. The upstream six-stage
interview is preserved in `references/interview-stages.md` and reused, scoped, inside those modes.

## Agency mode (what this vault is)

This vault runs in **agency mode**: it holds multiple concurrent property briefs, one per live
revenue line, under `briefs/`. The current four are `modelstack`, `agor-consulting`, `ios-apps`,
and `scored-tools`. Two portfolio-level files sit above them: `about/me.md` (Ariel's personal
voice) and `strategy/brand.md` (cross-property positioning and house style). Any downstream skill
reads the **specific brief for whatever property is in scope for that conversation**, plus the two
portfolio-level files, before doing property work. Bootstrap maintains all of these.

## Global rules (apply to everything this skill writes)

1. **Banned phrase.** Never write, spelled out contiguously, the two-word phrase formed by "load"
   directly followed by a hyphen and the word meaning weight-supporting. Describe the idea in
   other words if it is genuinely needed.
2. **No em-dashes** in any authored text (skill prose, briefs, drafts, examples). Use a comma,
   colon, period, parenthetical, or a plain spaced hyphen.
3. **Draft-gated / dry-run.** This skill only reads and writes context files inside the vault
   (`briefs/`, `about/`, `strategy/`, and its own index edits). It never publishes, sends,
   spends, or deploys, and it never runs git commands. Anything outward is a separate, later step
   that needs Ariel's explicit go. Writing or editing a brief or an index file is an internal
   vault update, not an outward action, so it is allowed.
4. **Read the brief first.** Before any property-specific work, read the relevant
   `briefs/<property>.md` and the two portfolio-level files, and say so in the Workspace context
   line below. Map every external-tool reference through `data/REMAP.md` (CRM -> GBrain, SEO SaaS
   -> Search Console + PageSpeed, email SaaS -> Gmail SMTP / Gmail drafts, analytics -> Plausible
   or GA4, link shortener -> Dub.co, and so on); never write an unremapped SaaS name into a brief.

## Workspace context (state before you do anything else)

At the start of every invocation, before asking anything, read and report state:

1. Read `briefs/_portfolio.md` and list the briefs already present. Expected: `modelstack.md`,
   `agor-consulting.md`, `ios-apps.md`, `scored-tools.md`.
2. Confirm `strategy/brand.md` and `about/me.md` are populated, not placeholders. A one-line
   check: they are populated if `strategy/brand.md` contains a "Portfolio one-liner" section and
   `about/me.md` contains a "Natural Writing Voice" or "Tone" section. If either is just a
   `.gitkeep` or an empty stub, that is the one signal that a Full refresh may actually be needed.
3. Scan the four briefs for open gaps: lines containing "UNKNOWN", "needs Ariel", "flag", or
   "unconfirmed". These are the Fill gaps candidates.

Then print a short state summary, for example:

> Workspace context: read `briefs/_portfolio.md`. Four briefs present (modelstack,
> agor-consulting, ios-apps, scored-tools). `strategy/brand.md` and `about/me.md` are populated.
> Open gaps found: ios-apps analytics + current-goals (all four apps), agor.me Plausible/Dub.co
> wiring, scored.tools analytics.

Only after this state report do you offer the modes. This mirrors the upstream "Workspace
Context" pattern used across the vault (see `seo-and-aeo-strategy`).

## Choose a mode

Use the AskUserQuestion tool. Question: "This vault is already grounded. What do you want to do?"
Options:

- **Fill gaps** - "Close specific fields flagged UNKNOWN in an existing brief. Short, targeted."
- **New property** - "Brief a property that has no file yet (e.g. agor-agents, an aphor.me
  relaunch). Runs the scoped interview."
- **Full refresh** - "Re-ground the whole portfolio. Rare, only if the portfolio changed a lot."

If Ariel already named the intent in his message (e.g. "add a brief for agor-agents", "fill in
the iOS analytics", "re-ground everything"), skip the question and go straight to that mode. If
he named a specific property, first decide whether it already has a brief: if yes and he wants to
correct or complete it, that is Fill gaps; if it has no brief, that is New property.

---

## Mode A - Fill gaps

Close specific flagged fields in an existing brief without re-asking anything already known.

1. From the Workspace-context scan, list the open gaps grouped by brief. Concrete gaps that exist
   right now:
   - `briefs/ios-apps.md`: Analytics sources and Current goals are "UNKNOWN, needs Ariel" for all
     four apps (gifloop, MVAT Focus, MVAT Mirror, Coquí Chorus).
   - `briefs/agor-consulting.md`: whether Plausible is wired on agor.me is unconfirmed, and
     whether agor.me's outbound links route through Dub.co is "UNKNOWN, needs Ariel".
   - `briefs/scored-tools.md`: Analytics sources is "UNKNOWN, needs Ariel".
   - `briefs/modelstack.md`: currently no open gaps.
2. Ask Ariel which gap or brief to work on (AskUserQuestion, one option per brief with open gaps,
   plus "something else").
3. For the chosen gaps, ask **only** the targeted questions that close them. Pull those questions
   from the matching stage in `references/interview-stages.md` (analytics gaps -> Stage 5
   Operations; goal gaps -> Stage 6 Success). Do not walk the full six stages. Do not re-ask
   voice, positioning, pricing, or ICP that the brief already answers.
4. Map any tool answer through `data/REMAP.md` before writing it. If a data source genuinely does
   not exist yet (e.g. no analytics is wired on scored.tools), record that fact explicitly rather
   than leaving a vague "UNKNOWN", so a future skill knows the gap is closed as "none", not
   unexamined.
5. Edit the brief in place: replace the flagged line with the confirmed answer, preserve the rest
   of the file untouched. Keep the nine-section structure intact (see `references/brief-template.md`).
6. Report exactly which fields in which brief changed.

---

## Mode B - New property

Ariel names a property with no brief yet (candidates in `references/brief-template.md`: agor-agents,
an aphor.me relaunch, heraladex, hansum.beer, and outside-repo lines). Run the upstream six-stage
interview, scoped to just that one property.

1. Confirm the property against `C:\Users\ariel\.claude\PORTFOLIO_PROPERTIES.md` (the canonical
   inventory) so the brief matches reality. Note `provn` is a lead device, not a paid product, so
   it does not get a revenue brief.
2. Run the interview from `references/interview-stages.md`, following its stage-to-file map. Ask
   **Identity, Brand, the property-specific slice of Voice, Operations, and Success**, all scoped
   to this one property. **Skip Stage 0** (orientation is fixed: it is one of Ariel's own lines)
   and **skip Stage 4 Person** and the portfolio-wide part of Stage 3 Voice, because personal
   voice lives in `about/me.md` and portfolio positioning lives in `strategy/brand.md` and must
   not be re-derived here. Ask each stage as a focused block, wait for answers.
3. Synthesize the answers into `briefs/<property>.md` using the nine-section template in
   `references/brief-template.md`: Offer & pricing, ICP, Positioning (one-liner), Channels of
   record, Payment rail & support, Analytics sources, Voice notes, Current goals, Hard rules.
   Ground every line in what was actually said, mark anything still unknown "UNKNOWN, needs
   Ariel", and map every tool through `data/REMAP.md`.
4. Wire the new brief into the vault's index files, per the checklist in
   `references/brief-template.md`: add it to `briefs/_portfolio.md`'s "Properties covered" list
   (and remove it from the "NOT yet covered" paragraph), bump the count and property list in
   `CLAUDE.md`'s operating rule 2, and update the flagged brief-count note in `data/REMAP.md` so
   the two files agree. These are internal index edits, not outward actions.
5. Report the new brief path and every index file touched.

---

## Mode C - Full refresh (rare)

Only when Ariel explicitly asks to re-ground everything because the portfolio changed
significantly, or when the Workspace-context check found `strategy/brand.md` or `about/me.md`
actually empty. This is the one path that may run every stage in `references/interview-stages.md`,
including Stage 4 Person and the portfolio-wide Brand and Voice stages, and may rewrite
`about/me.md`, `strategy/brand.md`, and multiple briefs.

1. Confirm scope with Ariel first: which properties changed, and whether his personal voice in
   `about/me.md` is actually stale (it usually is not, so default to leaving it). Do not rewrite
   `about/me.md` unless he says his personal voice changed.
2. Re-read `C:\Users\ariel\.claude\PORTFOLIO_PROPERTIES.md` as the source of truth for which
   lines are live, paused, or new, and reconcile the brief set against it (add missing live
   lines via Mode B, flag paused ones).
3. Run only the stages that are genuinely stale. Rewrite the affected files, preserving the
   existing section structure and the vault's house style (no em-dashes, receipts-and-sources,
   direct and dense).
4. Report every file rewritten and why.

---

## What this skill does NOT do

- It does not re-interview Ariel's personal voice or portfolio-wide brand positioning unless he
  explicitly says those are stale (Mode C only). Stages 3-portfolio and 4 are skipped by default.
- It does not scaffold `content/` or `assets/` folders from scratch; those already exist in the
  vault. If a `content/<platform>/` subfolder a skill needs is genuinely missing, create just
  that folder, do not rebuild the tree.
- It does not decide portfolio priority (that is `/portfolio-pm`) or run client-facing GEO/AEO
  delivery (that is `/ai-ads`). It only maintains this vault's own grounding files.
- It does not commit. Leave git to Ariel or the calling agent.

After any mode, update `PROGRESS.md` with what changed (completed, blocked, next steps), matching
the vault's session-logging rule.
