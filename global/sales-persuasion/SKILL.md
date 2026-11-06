---
name: sales-persuasion
description: Ariel's sales and persuasion playbook, the rules for all sales and marketing copy on agor.me, scored.tools and modelstack.digital. Use before writing or reviewing any sales email, cold outreach, follow-up, win-back, offer, offer page, landing page, pitch, proposal, ad, or sales reply, or when a generator prompt for any of these changes. Gives the hard bans and points to the playbook.
---

# Sales and persuasion

**Source of truth:** `C:\Users\ariel\.claude\projects\agor-company\docs\playbooks\sales-persuasion.md`. Read it before writing. It has the twelve rules, the recipes (cold first touch, follow-up, win-back, inbound reply, offer page, placement buyers) and what not to build on. This file does not replace it.

A written Ariel ruling beats the playbook. Known conflicts: `docs/decisions/2026-11-06-playbook-wiring.md` in agor-company.

## Fix in this order

Inbox, person, offer, words. Wording comes last. Our volume cannot prove a wording win, so never declare one on a few replies.

## Hard bans

- Invented facts, urgency, scarcity, deadlines, discounts ending, or counts. The only deadlines stated are real terms, such as a credit window or a link's real expiry.
- Invented testimonials, logos, "trusted by", or inflated value and "was" prices.
- Fake personalisation, such as praise for something not read.
- "Re:" or "Fwd:" on a message that is not a real reply.
- Guilt, or debt attached to a gift.
- Pressure on anyone in distress. A paid offer inside a dispute, or alongside a score below 7.
- Promising rankings or dofollow value. Selling a link without its required `rel` disclosure.
- Denying being an AI when someone sincerely asks. AI-voice or auto-dialled calls to prospects. (Agents are treated as employees: no disclosure line, seat persona or Ariel's name is fine.)
- Commercial mail without a postal address and a working opt-out.
- Tracking pixels on cold touches.

## Enforcement

`lintDraft` in agor-company runs the PB rules (`ops/lib/playbook-core.mjs`, `COMPLIANCE.md`). PB-1 to PB-5 fail a draft; PB-6 to PB-10 only warn. Everything a machine cannot see is a reviewer duty. Prompts reuse `PLAYBOOK_PROMPT` or `PLAYBOOK_BANS` from that module, never a copy.

Anything sent as Ariel also follows `ariel-email-voice`.
