---
name: networking-outreach
description: Relationship-first networking skill for identifying the right people to connect with and drafting value-add outreach — not sales, not referral asks. Use when building a network for a job search, career pivot, partnership, or industry access. Covers target identification by purpose, deep LinkedIn + web research on a specific person, brainstorming 10 value-add angles, and drafting three outreach formats: cold networking email (max 200 words), LinkedIn connection request (max 300 characters), and hiring manager follow-up email (120–160 words). Never drafts generic openers or referral asks — always leads with a specific observation and genuine value.
---

# Networking Outreach

## When this fires

Building relationships for the agor.me consulting pipeline, a partnership, or industry access on any property. In this vault that's almost always business relationship building, not a personal job search: Mode 3 of the reference playbook (hiring-manager follow-up) is preserved for the rare case it's genuinely needed, but treat Modes 1 and 2 as the default.

## Workspace context to read first

- `briefs/agor-consulting.md`, the property this skill serves most often (the $15K to $250K consulting pipeline, alongside the twice-weekly automated prospect-research digest it complements); check the matching brief if the outreach targets a different property instead.
- `about/me.md` and `~/.claude/skills/ariel-email-voice/SKILL.md` for voice, on every drafted message, every time.
- `strategy/brand.md` for cross-property positioning if the outreach spans more than one property.

## The real workflow: GBrain first, then draft, then precall-brief, then log back

Upstream's three modes assume a blank-slate contact, pure cold LinkedIn-and-web research. Ariel already has a CRM: GBrain holds 5,400+ people and 368 companies, including the actual history (`emailed_with`, `texted_with`, `works_at` links) behind many of them. Treat GBrain as the first stop, not an afterthought.

### Step 1: target identification runs through GBrain, not blind search

Before generating a fresh target list the upstream way, run:
- `mcp__gbrain__query` (hybrid semantic search) on the stated purpose (for example "AI transformation buyers in mid-market ops," "fintech automation leads") to surface people and companies already in the brain who match.
- `mcp__gbrain__traverse_graph` from any known anchor (a company, a mutual contact, a past client) to find warm paths. A person one hop from someone Ariel already emailed or texted beats a cold LinkedIn stranger every time.
- `mcp__gbrain__get_backlinks` on any promising candidate to see the full history (every conversation, thread, or meeting already linked to them) before treating them as "cold" at all.

Fall back to upstream's Target Persona Matrix and pure web/LinkedIn sourcing (`references/upstream-playbook.md`, Mode 1) only for names that genuinely aren't in GBrain yet. When outreach to a new name converts to a real prospect, file them into GBrain (`put_page`, `add_tag`, `add_link`) so the next session doesn't start from zero.

### Step 2: research a specific person, GBrain history first, web research second

If the target already has a GBrain page, pull `get_page` and `get_backlinks` first. That surfaces real prior context (what was actually said, when, by whom) that no amount of LinkedIn-and-web reconnaissance can fabricate, and it changes the message: this is a warm re-engagement, not a cold open. Only then layer in upstream's web-research step (recent posts, company news) to catch anything that happened since the last touch.

If the target has no GBrain page, upstream's Mode 2 research steps (LinkedIn pull, web search queries, the research checklist) in `references/upstream-playbook.md` apply as written.

### Step 3: draft in Ariel's actual voice, not a generic template

Use upstream's value-add-angle brainstorm and message structures (cold email, LinkedIn connection request, follow-up email) from `references/upstream-playbook.md` for shape, but write the actual draft against `about/me.md` and `~/.claude/skills/ariel-email-voice/SKILL.md`: direct opener, no em-dashes, specific details over vague claims, the right signature block (personal vs. the Agor AI Advisory branded one, depending on which hat the outreach is under). Save the draft as a Gmail MCP draft (`mcp__claude_ai_Gmail__create_draft`); never send it.

### Step 4: when it converts to a meeting, hand off to precall-brief

If the outreach lands a reply and a meeting gets scheduled outside the agor.me chat/voice widget (an email back-and-forth, a text, an in-person ask), the automatic agor.me `AgorMe\BriefSender` cron never sees it, because that pipeline only watches the widget's own calendar bookings. Use `~/.claude/skills/precall-brief/SKILL.md` to run the same grounded, no-fabrication research brief by hand: it emails Ariel immediately and arms a T-30 resend before the call. Don't re-derive meeting prep here; that job belongs to precall-brief.

### Step 5: log the touchpoint back to GBrain

After Ariel sends the draft (his explicit go, never automatic) and after any resulting meeting, record it: `add_timeline_entry` for the touchpoint, `add_tag` for pipeline stage, `add_link` if it connects to a company or another person. This is what makes Step 1 useful next time: GBrain is the CRM of record (`data/REMAP.md` Row 1), not a spreadsheet that restarts from zero each time.

## Reference material

`references/upstream-playbook.md` holds the full upstream playbook: the target persona matrix, the 10-angle value-add brainstorm, the three message structures (cold email, LinkedIn connection request, hiring-manager follow-up) with their word and character limits, the research checklist, and the common-mistakes table. It remains the right source for message shape and the give-before-you-ask discipline; it is not the current source for who to target first (GBrain is) or how a resulting meeting gets prepared (precall-brief is).

## Dry-run rule

Every draft from this skill (cold email, LinkedIn connection request, follow-up) is staged, never sent: a Gmail MCP draft for email, a written-out connection-request string for LinkedIn (posting or connecting on LinkedIn itself runs through the `linkedin` skill or browser automation, not this one). Nothing here auto-sends, auto-connects, or auto-books. Ariel's explicit, in-the-moment go is a separate, later step.

## Related skills

- `outbound-email-strategy`, once the relationship is warm enough to become a sales conversation.
- `linkedin`, for optimizing Ariel's own profile and publishing content that attracts inbound interest, distinct from the outbound connection requests handled here.
