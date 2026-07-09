---
name: marketing-automation
description: Use this skill when designing marketing automation for Ariel's own properties - lead scoring models, email sequence design, lifecycle-stage workflows, and the actual mechanism (Windows Task Scheduler crons, claude -p headless runs, and the gated-outward-agent OFF -> DRAFT -> LIVE arming pattern) for anything that acts outward on a schedule or webhook.
---

# Marketing Automation Expert

## Workspace Context

Read bootstrap context before asking questions: `strategy/brand.md` for brand, audience, offer, channels, tools, constraints, and metrics; `about/me.md` for personal voice; `content/ideas.md` and `content/calendar.md` for content planning. Use legacy product-marketing context files only as fallback. Save generated drafts to `content/<platform>/drafts/YYYY-MM-DD_short-topic-slug.md`, and route durable learnings back to `strategy/brand.md`, `about/me.md`, or `content/ideas.md`.

## Operating Contract

This skill is self-contained for its frontmatter scope: use its local instructions, references, scripts, and assets as the playbook; ask only for missing task-specific inputs; hand off to adjacent skills instead of expanding scope; and return an actionable artifact, decision, plan, draft, or diagnostic.



Marketing automation strategy for Ariel's own properties: lead scoring, email sequence design, and
lifecycle workflows, built as code plus cron rather than a SaaS workflow builder. This vault has no
HubSpot, Marketo, ActiveCampaign, Pardot, Mailchimp, Zapier, Make, or n8n account - every
automation here runs as a scheduled script under Ariel's own control. See `data/REMAP.md` Row 5
for the full substitution rationale.

---

## Automation Stack

This vault has no drag-and-drop workflow builder. Automations are code plus cron, built from
three layers:

| Layer | What it is | Use for |
|-------|-----------|---------|
| **Windows Task Scheduler cron** | A scheduled task, always **S4U logon type, never Interactive** | Anything that runs on a timer (daily digest, weekly nurture send, lifecycle check). `Interactive` tasks flash a visible console window on Ariel's desktop while he works; `S4U` runs silently in background session 0 on the same schedule. Build or audit via the `schedule` skill or `hide-cron-windows.ps1`. |
| **`claude -p` headless (Max plan)** | A subprocess call to Claude Code, non-interactive | Any step needing judgment: scoring a lead from free-text context, drafting a sequence email, classifying an inbound reply. **Strip `ANTHROPIC_API_KEY` from the spawn env** before calling - if it is present the call silently bills the paid API instead of the Max plan Ariel already pays for. |
| **`gated-outward-agent` skill pattern** | OFF -> DRAFT -> LIVE arming, escalate-not-block safety gate | Anything the cron or the `claude -p` step would send, post, or act on outward (an email, a customer-visible record update, a webhook reply). Build the whole pipeline in OFF, prove it in DRAFT (real artifacts, zero outward action), and arm LIVE only on Ariel's explicit go, whitelist-scoped. See `~/.claude/skills/gated-outward-agent/SKILL.md`. |

**Selection test for a new automation**: does it run on a timer (Task Scheduler)? Does a step need
reasoning (`claude -p`)? Does any step act outward (`gated-outward-agent`)? Most real automations
in this vault need all three layered together, not a platform choice off a vendor list.

---

## Lead Scoring Model

**MQL threshold**: 100 points. Decay: −10 points after 30 days of inactivity.

### Behavioral Scoring

| Action | Points |
|--------|--------|
| Request demo | +50 |
| Pricing page visit | +30 |
| Case study download | +25 |
| Webinar attendance | +25 |
| Webinar registration | +15 |
| Content download | +10 |
| Email click | +3 (max 5/day) |
| Email open | +1 (max 3/day) |
| Blog visit | +1 (max 5/day) |
| Unsubscribe | −30 |
| Email bounce | −20 |
| Spam complaint | −100 |

### Demographic Scoring

| Attribute | Points |
|-----------|--------|
| C-Level title | +25 |
| VP title | +20 |
| Director | +15 |
| Manager | +10 |
| Target company size (200–1000) | +20 |
| Target industry | +20 |
| Primary market geography | +15 |

### Lead Grading (A–D)

- **A**: Decision maker + target size + target industry + target geo → immediate sales follow-up
- **B**: 3 of 4 criteria met → sales within 24 hours
- **C**: 2 of 4 criteria met → nurture then handoff
- **D**: 1 or fewer criteria → nurture only, no sales routing

---

## Email Sequences

### Welcome Series (6 emails over 14 days)

| Email | Timing | Purpose | CTA |
|-------|--------|---------|-----|
| 1 | Immediately | Welcome + quick win resource | Download resource |
| 2 | Day 2 | Pain point + case study | Read case study |
| 3 | Day 4 | Product overview + benefits | See how it works |
| 4 | Day 7 | Exclusive gated content | Download now |
| 5 | Day 10 | Offer personalized help | Schedule a call |
| 6 | Day 14 | Preference center | Update preferences |

Exit conditions: demo requested, sales conversation started, unsubscribed.

### Lead Nurture (score-triggered tracks)

| Track | Score Range | Cadence | Focus |
|-------|-------------|---------|-------|
| Awareness | 50–69 | 2/week | Educational, industry trends |
| Consideration | 70–89 | 2–3/week | Use cases, ROI calculator, case studies |
| Decision | 90–99 | 3/week | Free trial, demo, competitive comparison |

### Re-engagement (90-day lapse trigger)

4-email sequence over 15 days: "We miss you" → "Is this goodbye?" → "Last chance offer" → "Goodbye for now" with easy re-subscribe. Outcomes: engaged → return to nurture | no action → sunset list.

---

## Automation Workflows

Each workflow below is marketing logic (trigger -> steps -> outcome). The mechanism that runs it
is always one or more of the three Automation Stack layers above, and every step that would act
outward is gated per the pattern in `gated-outward-agent` - never a live send by default.

### Lead Routing Workflow

1. Data enrichment: GBrain MCP lookup (`query`, `get_page`, `get_backlinks`) for any existing
   relationship, company, or prior-conversation context - not a paid enrichment SaaS
2. Lead scoring + grading (see Lead Scoring Model above)
3. Check GBrain for an existing person/company record -> update it if found, `put_page` a new
   one if not
4. Segment assignment (geography -> company size -> industry, or the property-specific
   equivalent)
5. Create a follow-up entry with an SLA (A=15 min | B=2 hrs | C=24 hrs) as a GBrain timeline
   entry or a dated line in the revenue scorecard (`~/.claude/revenue-scorecard/`) - there is no
   sales team to route to, so the "task" is Ariel's own follow-up queue
6. Draft the notification as a Gmail draft (`mcp__claude_ai_Gmail__create_draft`) addressed to
   Ariel - never auto-sent; no Slack integration exists in this stack
7. Add to the appropriate nurture track in the content calendar

### Lifecycle Stage Automation

| Stage | Entry Trigger | Key Automations |
|-------|--------------|-----------------|
| Subscriber | Email opt-in | Welcome series + newsletter |
| Lead | Form submit OR score >20 | Enrich → nurture → sync CRM |
| MQL | Score ≥100 OR demo request | Sales alert + task + pause marketing |
| SQL | Sales qualified in CRM | Update nurture + notify CS |
| Opportunity | Deal created | Pause outbound + enable deal-stage emails |
| Customer | Deal won | Onboarding sequence + remove from prospects |
| Churned | Cancellation | Win-back sequence |

---

## Key Workflows to Build

**1. Demo Request → Sales Handoff**: Form submit → enrich → score/grade → create HubSpot deal → assign to rep → send confirmation email → start sales sequence.

**2. Trial Signup → Activation**: Signup → welcome email → onboarding checklist → day 3/7/14 milestone emails → conversion offer at day 14.

**3. Event/Webinar**: Registration → confirmation email → 3 reminders → post-webinar follow-up (attended) or recording offer (no-show) → add to nurture based on engagement.

**4. Customer Onboarding**: Won deal → CSM assignment notification → welcome email → onboarding checklist → check-in at 30/60/90 days → NPS survey at 90 days.

---

## HubSpot Implementation

**Campaign setup**: Marketing → Campaigns → tag all assets (emails, landing pages, ads) with campaign ID.

**UTM convention**: `utm_source={channel}&utm_medium={cpc|email|organic}&utm_campaign={id}&utm_content={variant}`

**Attribution model**: W-shaped for hybrid PLG/sales-led (first touch + lead creation + close).

**Lead scoring setup**: Settings → Marketing → Lead Scoring. Set behavioral weights, demographic weights, and decay rules. Create MQL automation when score ≥100.

**Reporting cadence**: Daily review of MQLs/SQLs. Weekly channel ROI. Monthly win/loss trends.
