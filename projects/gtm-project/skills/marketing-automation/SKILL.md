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
| Subscriber | Email opt-in | Welcome series + newsletter (drafted, Ariel sends) |
| Lead | Form submit OR score >20 | GBrain enrich -> nurture track -> `put_page`/`add_tag` |
| MQL | Score >=100 OR demo request | Draft alert to Ariel + revenue-scorecard entry + pause automated nurture |
| SQL | Ariel manually qualifies | Update nurture + GBrain timeline entry |
| Opportunity | Deal created in GBrain | Pause outbound automation + enable deal-stage email drafts |
| Customer | Deal won | Onboarding sequence (drafts) + GBrain tag update |
| Churned | Cancellation | Win-back sequence (drafts) |

---

## Key Workflows to Build

**1. Demo Request -> Draft Handoff**: Form submit -> GBrain enrich -> score/grade -> `put_page` a
GBrain deal record -> draft a confirmation email (Gmail MCP, unsent) -> log to the revenue
scorecard.

**2. Trial Signup -> Activation**: Signup -> draft welcome email -> onboarding checklist -> day
3/7/14 milestone email drafts -> conversion-offer draft at day 14.

**3. Event/Webinar**: Registration -> confirmation email draft -> reminder drafts -> post-event
follow-up draft (attended) or recording-offer draft (no-show) -> add to nurture based on
engagement.

**4. Customer Onboarding**: Won deal -> welcome email draft -> onboarding checklist -> check-in
drafts at 30/60/90 days -> NPS survey draft at 90 days.

Every "draft" above is a real Gmail draft or a file under `content/<platform>/drafts/`: the cron
produces it, it never sends. Ariel reviews and sends manually, per the vault's dry-run policy.

---

## Automation Implementation

**Build sequence for any new automation** (mirrors the `gated-outward-agent` recipe):

1. Write the pipeline as named stages (for example POLL -> SCORE -> ROUTE -> DRAFT -> GATE ->
   OUTPUT), each independently testable, per the global CLAUDE.md architecture rule.
2. Default mode `OFF` in a `.env` the cron reads. `DRAFT` produces real Gmail drafts and GBrain
   writes with zero outward action. `LIVE` is armed only after Ariel's explicit go, and only for
   whitelisted recipients/scopes.
3. Register the Task Scheduler job **S4U, Hidden=true**, for example:
   `New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType S4U -RunLevel Limited`.
   Never `Interactive` - see `data/REMAP.md` Row 5 and the global CLAUDE.md Scheduled Tasks
   section.
4. Any reasoning step shells out to `claude -p` with `ANTHROPIC_API_KEY` stripped from the spawn
   env, `stdio: ["ignore","pipe","pipe"]`, and a pinned `--model`.
5. Every action that would touch the outside world routes through the safety gate described in
   `gated-outward-agent`: kill switch, mode check, whitelist, the structural never-act class
   (pricing, contract, legal, commitment, unknown first-contact), sender verification, rate
   limit, quiet hours, and a veto window before anything fires.
6. Any live link inside a drafted sequence is tracked with Dub.co (`app.dub.co/agor`), not a
   HubSpot campaign ID. UTM convention:
   `utm_source={channel}&utm_medium={cpc|email|organic}&utm_campaign={id}&utm_content={variant}`.
7. Log every run: what fired, what was drafted versus sent, and where. A scheduled automation
   with no record of its own actions is not verifiable, per the global CLAUDE.md verification
   rule.

**Reporting cadence**: Pull automation health (queue depth, drafts pending, errors) into
`executive-dashboard-generator` alongside Stripe/Plausible data rather than a HubSpot reporting
view - there isn't one.

**Reference build**: the Chief of Staff inbox agent, described in the Example section of
`~/.claude/skills/gated-outward-agent/SKILL.md`, is the worked instance of this exact sequence,
armed to LIVE with a verified self-send and idempotency proof.
