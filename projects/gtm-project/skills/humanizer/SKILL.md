---
name: humanizer
description: Humanize AI-sounding writing by running it through the anti-ai-narrative-tells skill in audit mode, plus a standing check against Ariel's two hard style rules (no em-dashes, never the banned "load" + hyphen + "bearing" phrase). Use when editing text to sound more natural, less generic, less promotional, less formulaic, or closer to the user's own writing. Triggers: humanize this, make this less AI, make this sound human, remove AI writing patterns, rewrite in my voice, make this more natural, de-AI this, make this less ChatGPT, fix robotic writing, improve authenticity, reduce generic AI tone.
---

# Humanizer

BRIDGE-tier adapter. This skill no longer runs its own AI-tell checklist end to
end; it hands the audit off to `anti-ai-narrative-tells`, run in its Mode 2
(Audit), and restates the two rules that predate the bridge and that the
audit skill doesn't know about.

## Workspace context (read first)

1. `about\me.md` for Ariel's personal voice: direct, warm, dense over safe,
   specific over vague.
2. `strategy\brand.md` for cross-property house style and the receipts rule
   (claims trace to a real, checkable fact).
3. Whatever draft, file, or sample the user hands over. Ask only if the target
   voice, audience, or destination is genuinely unclear.

## What it hands off to

`anti-ai-narrative-tells` (`C:\Users\ariel\.claude\skills\anti-ai-narrative-tells\SKILL.md`)
run in **Mode 2, Audit**. That skill's 30-feature checklist
(`references/storyscope-30-core-features.md`) was built to detect AI in
fiction: plot structure, anachrony, protagonist framing, subplot count,
narrator stance. Most GTM copy (emails, blog posts, listings, social captions)
has no narrative shape, so only part of the checklist transfers. Use these
parts every time:

- vocabulary-cluster tells (the same "delve, crucial, leverage, landscape"
  cluster the two skills share)
- chatbot residue ("here's an overview," "let's dive in," "I hope this helps")
- formulaic-structure patterns (forced threes, "not only X but Y," false
  "from X to Y" ranges)
- the operating-notes warning that surface paraphrasing does not fix a
  structural AI tell, and that sprinkling typos or stylistic quirks is
  performing humanness, not doing the work

Skip the narrative-only checks (anachrony, subplot count, protagonist-driven
resolution, pathetic fallacy) unless the piece is literally a story or a
narrated case study.

## Workflow

1. Skim `anti-ai-narrative-tells/SKILL.md` so the current checklist and its
   operating notes are in view.
2. Run its Mode 2 audit against the draft, restricted to the transferable
   features above. Tally what fires.
3. The original, GTM-specific AI-tell list (inflated significance, promotional
   filler, fake depth, vague attribution, over-styled formatting, and the
   voice-calibration rules) is preserved in
   [references/upstream-playbook.md](references/upstream-playbook.md). Use it
   alongside the audit skill, since it covers marketing-copy patterns the
   fiction-oriented checklist does not.
4. Rewrite once against both lenses. Then check the rewrite against the two
   standing rules below, since neither audit engine enforces them:
   - **Banned phrase:** never write "load" immediately followed by a hyphen
     and "bearing," in any output. Describe the idea another way if it's
     genuinely needed.
   - **No em-dashes, ever.** Recast with a comma, colon, period, or
     parenthetical instead.
5. Return: the rewrite, a short list of which tells fired and were fixed, and
   what's left unresolved if anything is a genuine judgment call.

## Dry-run rule

This skill only edits text already in hand; it never publishes or sends. If
the source lives in `content\<platform>\drafts\`, save the humanized version
back to that same file rather than creating a new one.

## Reference

[references/upstream-playbook.md](references/upstream-playbook.md) carries
the full original humanizer checklist: inflated significance, promotional
filler, fake depth, vague attribution, AI vocabulary clusters, formulaic
structure, chatbot residue, over-styled formatting, voice calibration, and the
output format. Read it whenever the draft is non-narrative marketing or
support copy, since that's the more directly applicable list for this vault's
day-to-day work.
