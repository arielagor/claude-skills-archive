---
name: pitch-deck-creation
description: Create professional investor pitch decks with structured content and visual design. Use when users need help with pitch deck, investor deck, fundraising deck, startup pitch, deck design, slide design, pitch presentation, pitch deck visuals, investor presentation, Series A deck, seed deck, or VC deck. Covers the full workflow: gathering company info, structuring narrative, generating a PowerPoint via script, and applying visual best practices.
---

# Pitch Deck Creation

## When this fires

Trigger phrases from the description above: pitch deck, investor deck, fundraising deck, deck design, slide design, Series A / seed / VC deck, sales deck, board deck, or "turn this outline into slides." In this vault the most likely caller is `agor-consulting` (an investor or board deck for Agor AI Advisory or Agor AI Ads), but any property can need a sales/BD or product-launch deck. Ask which property and audience it's for if not stated.

## Workspace context to read first

1. `briefs/<property>.md` for the property this deck represents (most often `briefs/agor-consulting.md`; check the matching brief for another property if that's what's asked for) for pricing, positioning, ICP, and current goals that should ground every slide's numbers.
2. `about/me.md`, and for anything carrying the Agor AI voice or letterhead, `~/.claude/skills/ariel-email-voice/SKILL.md`, for tone in slide copy, a cover email, or spoken narrative.
3. `strategy/brand.md` for cross-property positioning language if the deck spans more than one property.

State in your own output that this was done, e.g. "Workspace context: read briefs/agor-consulting.md and about/me.md."

## What this skill does, and what it hands off

This skill is BRIDGE tier: it owns the narrative (what story the deck tells, what goes on which slide, how to size the ask) and hands off the actual file rendering to whichever upstream Ariel skill fits the deliverable:

- **`~/.claude/skills/agor-branded-deck/SKILL.md`** is the default for anything that should read as a real Agor AI Advisory deliverable: an investor pitch, a sales or board deck, or any deck going out on the Agor AI letterhead. It renders a polished 16:9 PDF via xelatex and Beamer (the magenta to violet to blue gradient, AGOR AI wordmark, Georgia and Arial fonts), including the closing-slide signature convention. Hand it a finished Markdown deck outline once the narrative below is settled.
- **`~/.claude/skills/pptx/SKILL.md`** is the choice instead when the deliverable must be an editable `.pptx`, either because the recipient wants to edit slides themselves or the deck isn't an Agor AI Advisory branded artifact.

Work in this order:

1. Gather the inputs (company or property, tagline, problem, solution, market, traction, business model, competition, team, financials, the ask), using `references/upstream-playbook.md` for what to ask and what good looks like per slide.
2. Structure the narrative with the 12-slide framework, the 1-6-6 rule, and the chart-type guide in `references/upstream-playbook.md`. This is the part neither downstream renderer does for you: `agor-branded-deck` and `pptx` render decks, they don't decide what story to tell.
3. Write the outline as Markdown (or the JSON shape the chosen rendering skill expects) and hand it off to `agor-branded-deck` or `pptx`.
4. If neither rendering skill fits (a genuinely quick, unbranded internal draft), the legacy `scripts/create_pitch_deck.py` in this folder still works (`python3 scripts/create_pitch_deck.py pitch_data.json output.pptx`, requires `python-pptx`), but treat it as a fallback, not the primary path.

## Reference material

`references/upstream-playbook.md` holds the full upstream playbook: the 12-slide framework and timing, the information-gathering checklist, the `pitch_data.json` schema, typography, color and layout rules, the chart-type guide, the common-mistakes table, and audience-tailoring guidance (seed vs. Series A vs. sales vs. product-launch decks). Read it before drafting the narrative; it remains the source of truth for content and design judgment even though it no longer owns the render step.

## Dry-run rule

A rendered deck is a deliverable artifact, not an outward action by itself: save it to the relevant project or property location and consider that step done once it renders cleanly. But nothing in this vault emails, shares, or presents a finished deck to an investor, client, or partner without Ariel's explicit, in-the-moment go. If the task includes "send it to X" or "email this deck," stop after rendering and stage the send as a Gmail draft (`mcp__claude_ai_Gmail__create_draft`) instead of sending it.
