---
name: app-store-optimization
description: Use this skill when optimizing app store listings, researching keywords, or reviewing mobile app performance for Ariel's four iOS apps (gifloop, MVAT Focus, MVAT Mirror, Coqui Chorus / co-kee). Produces draft keyword/metadata/competitor-analysis recommendations, then hands off the actual listing edit to the asc-listing-manager agent and the review-submission step to the asc-promoter agent. Triggers: ASO, app store optimization, app store ranking, app keywords, app metadata, play store optimization, app store listing, improve app rankings, app visibility, app store SEO, mobile app marketing, app conversion rate.
---

# App Store Optimization (ASO)

BRIDGE-tier adapter. This skill does the ASO thinking (keyword research, metadata
drafting, competitor analysis, launch/A-B-test planning) and then hands the actual
App Store Connect write off to two existing Ariel agents instead of touching ASC or
a live repo itself.

## Workspace context (read first)

1. `briefs\ios-apps.md` for the four apps and their App Store IDs: gifloop
   (`id6761496920`), MVAT Focus (`id6760048027`), MVAT Mirror (`id6760195883`),
   Coqui Chorus / co-kee (`id6760567046`), plus each app's pricing, ICP, support
   inbox, and hard rules (Apple handles all IAP refunds, never Stripe).
2. `strategy\brand.md` for cross-property positioning and house style.
3. `about\me.md` for voice, in case any listing copy or review reply needs it.

State which app this run is for before drafting anything; if it's ambiguous, ask.

## What it hands off to

- **asc-listing-manager** (`C:\Users\ariel\.claude\agents\asc-listing-manager.md`):
  the agent that actually edits `docs/app-listing.json` in the target app's own repo
  and pushes it to ASC via `fill_listing.py` / `push_listing.py`. It is the only
  thing allowed to touch the live manifest.
- **asc-promoter** (`C:\Users\ariel\.claude\agents\asc-promoter.md`): the agent that
  attaches a processed TestFlight build to an editable version and submits it for
  Apple review. It has its own precondition checklist (build VALID, export
  compliance, screenshots present, on-device smoke test passed per the global
  CLAUDE.md pre-submission rule).

## Workflow

1. Do the research and drafting locally: keyword research, metadata rewrite,
   competitor gap analysis, launch or A/B-test planning. Full methodology (workflow
   steps, evaluation tables, character limits, before/after examples, the bundled
   scripts and reference docs) is preserved in
   [references/upstream-playbook.md](references/upstream-playbook.md); the original
   `scripts/`, `references/`, and `assets/` subdirectories are unchanged and still
   the right inputs for that methodology.
2. Save the proposed listing (title, subtitle, keywords, description, promotional
   text) as a draft: `content\app-store\drafts\YYYY-MM-DD_<app-slug>-listing.md`.
   Do not edit any app repo's `docs/app-listing.json` directly from this skill.
3. When Ariel gives an explicit go to apply the change, invoke asc-listing-manager,
   pointed at the specific app repo, with the drafted copy as its input.
4. Do not invoke asc-promoter from this skill. Submitting a build for Apple review
   is a release action, not a GTM action, and only happens after Ariel has
   confirmed the mandatory pre-submission device-testing checklist in the global
   CLAUDE.md. If a conversation drifts into "is this build ready to submit," say so
   and point at asc-promoter rather than attempting any part of that workflow here.

## Dry-run rule

Every output of this skill is a draft recommendation, not a live change. No ASC
field, no app repo file, and no build state changes as a result of running this
skill on its own; only a later, explicit invocation of asc-listing-manager (and,
separately, asc-promoter) touches anything live.

## Reference

[references/upstream-playbook.md](references/upstream-playbook.md) carries the
full original ASO playbook: keyword research workflow and scoring, metadata
optimization workflow and platform character limits, competitor analysis workflow,
app launch workflow, A/B testing workflow, before/after copy examples, and the
tool/script/reference index.
