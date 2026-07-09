---
name: sales-and-revenue-operations
description: |
  Comprehensive sales and revenue operations skill. Use when building a sales team, doing founder-led sales, hiring first sales reps, navigating enterprise deals, implementing product-led sales, designing sales compensation plans, defining ICP, mapping buyer personas, or optimizing the revenue engine (RevOps). Activates for: sales strategy, rev ops, revenue operations, sales enablement, sales compensation, ICP, ideal customer profile, buyer persona, sales process, deal execution, lead scoring, lead routing, lead lifecycle, MQL, SQL, pipeline management, CRM automation, sales qualification, BANT, MEDDIC, founder sales, enterprise sales, product-led sales, startup sales, SDR, AE, quota, ramp, commission plan.
---

# Sales & Revenue Operations

## Workspace Context

Read bootstrap context before asking questions: `strategy/brand.md` for brand, audience, offer, channels, tools, constraints, and metrics; `about/me.md` for personal voice; `content/ideas.md` and `content/calendar.md` for content planning. Use legacy product-marketing context files only as fallback. Save generated drafts to `content/<platform>/drafts/YYYY-MM-DD_short-topic-slug.md`, and route durable learnings back to `strategy/brand.md`, `about/me.md`, or `content/ideas.md`.

For the pipeline and forecast sections specifically, also read `briefs/agor-consulting.md` (the
offer ladder: the $1,000 AI Operations Audit entry point, $15K-$250K engagements, and the Agor AI
Ads $299 audit wedge) and `briefs/_portfolio.md`'s "LIVE - consulting" table before proposing any
pipeline change. Ariel is currently in the founder-led sales stage of this playbook (see
"Founder-Led Sales" below): no reps, no CRM SaaS, deal tracking in a file, not a platform.

## Operating Contract

This skill is self-contained for its frontmatter scope: use its local instructions, references, scripts, and assets as the playbook; ask only for missing task-specific inputs; hand off to adjacent skills instead of expanding scope; and return an actionable artifact, decision, plan, draft, or diagnostic.



Full-stack sales playbook: founder-led sales, team building, enterprise deals, RevOps, ICP definition, buyer personas, and compensation design.

---

## Quick Start

1. **Assess stage**, Founder-led, first reps, or scaling?
2. **Define motion**, Inbound, outbound, PLG, or hybrid?
3. **Build ICP**, Who are you selling to?
4. **Design process**, Discovery → Demo → Close
5. **Instrument RevOps**, Lead lifecycle, scoring, routing

---

## ICP & Buyer Persona

### ICP Stack (build bottom-up)

```
┌─────────────────────────────┐
│       BUYING CENTER          │ ← All decision stakeholders
├─────────────────────────────┤
│       USER PERSONA           │ ← Daily user
├─────────────────────────────┤
│       BUYER PERSONA          │ ← Signs the check
├─────────────────────────────┤
│       COMPANY PROFILE        │ ← Firmographics
└─────────────────────────────┘
```

**Company Profile:** industry/vertical, size (employees/revenue), stage, geography, tech stack

**Buyer Persona:** title/role, seniority, goals & KPIs, decision authority, what they care about

**User Persona:** daily workflow, pain points, tech savviness

**Buying Center Roles:** Champion, Economic Buyer, Technical Evaluator, End User, Blocker

### ICP Scoring

| Factor | Weight |
|--------|--------|
| Problem severity | 25% |
| Budget available | 20% |
| Champion identified | 15% |
| Technical fit | 15% |
| Decision timeline | 15% |
| Expansion potential | 10% |

### The 50-Company Test

List 50 specific companies that fit. Find the buyer's name at 20 of them. Reach out to 10. If you can't do this, your ICP isn't specific enough.

For full persona canvases, buying center maps, interview questions, and fit scoring: see `references/full-guide.md`

---

## Founder-Led Sales

**Core principles:**
- The founder IS the product, your credibility closes deals early competitors can't
- Your biggest competitor is indecision (40-60% of B2B purchases end in no decision)
- Sell before you build, Figma mockups can secure first customers
- Close the laptop, focus on diagnosis, not demos
- Book next meeting on the current one to maintain momentum

**When to hire:** Wait until ~$1M ARR and a repeatable process. Hire in pairs, you need an A/B test.

**Hiring framework:**

| Stage | Who to Hire | When |
|-------|-------------|------|
| Founder-led | Nobody | Before $1M ARR |
| First AEs | 2 reps | After proven repeatability |
| SDRs | 1-2 | When inbound overflows |
| VP Sales | 1 | When 2+ reps hitting quota |

---

## Enterprise Sales

**Buying committee roles:** Champion (internal advocate), Economic Buyer (signs), Technical Buyer (evaluates), End User (uses daily), Blocker (can say no)

**JOLT method for indecision:**
1. **Judge** level of indecision
2. **Offer** a firm recommendation
3. **Limit** exploration by building trust
4. **Take risk off the table**, de-risk the deal

**Key tactics:**
- Identify and arm the champion, they sell internally for you
- Address FOMU (Fear Of Making a Mistake), not just FOMO
- Make procurement's job easy, prepare all documentation upfront

---

## Sales Qualification

**BANT:** Budget · Authority · Need · Timeline

**MEDDIC:** Metrics · Economic Buyer · Decision Criteria · Decision Process · Identify Pain · Champion

**Rule:** Qualify ruthlessly. "No" is a successful outcome. Disqualify on the first call if fit isn't there.

---

## Sales Enablement

### Sales Deck (10-12 slides)
1. Current World Problem, 2. Cost of the Problem, 3. The Shift Happening, 4. Your Approach, 5. Product Walkthrough (3-4 workflows), 6. Proof Points, 7. Case Study, 8. Implementation, 9. ROI/Value, 10. Pricing Overview, 11. Next Steps/CTA

### Demo Structure
Opening (2 min) → Discovery Recap (3 min) → Solution Walkthrough (15-20 min) → Interaction → Close (5 min)

### Objection Handling

| Category | Response Approach |
|----------|-------------------|
| Price | ROI angle, payment terms |
| Timing | Urgency, cost of delay |
| Competition | Differentiation, unique value |
| Authority | Arm the champion |
| Status quo | Cost of inaction |

---

## Revenue Operations

No SaaS CRM or marketing-automation platform sits behind any of this. The tooling is: a
file-based revenue scorecard as the pipeline-of-record, GBrain (`mcp__gbrain__*`) as the contact
and relationship layer (see the `crm-integration` skill for the write patterns), and the Stripe
MCP read tools for realized revenue once a deal actually closes. Everything below is written
against that real stack, not a generic MQL/SQL funnel with marketing, sales, and CS teams handing
off to each other, there is one operator (Ariel) doing founder-led sales end to end.

### Lead Lifecycle Stages (this vault's real stage vocabulary)

The pipeline-of-record (`~/.claude/projects/job-applications/potential consulting projects
clients/README.md`, parsed weekly by `~/.claude/revenue-scorecard/revenue-scorecard.mjs` into a
Monday scorecard email) uses this exact stage vocabulary, one stage per row:

| Stage | Entry Criteria |
|-------|----------------|
| `lead` | Identified as ICP-fit, not yet contacted |
| `outreach-staged` | Draft written, waiting on Ariel's explicit send approval (nothing in this vault sends itself, per the dry-run policy) |
| `outreach-sent` | First touch sent |
| `in-conversation` | Reply received, dialogue underway |
| `call-booked` | A call or meeting is on the calendar |
| `proposal-sent` | A scoped proposal or SOW is in the prospect's hands |
| `won` (terminal) | Signed / engagement started |
| `lost` / `parked` (terminal) | Disqualified, went quiet, or explicitly deferred |

There is no separate MQL/SQL split and no lifecycle handoff between teams: Ariel owns every stage.
If a task references "MQL" or "SQL," translate it into this vocabulary rather than inventing a
parallel stage system.

### Real, current pipeline (worked examples, not invented ones)

| Contact / Company | Opportunity | Stage | Value | Source |
|---|---|---|---|---|
| Paul Schneider, Oncore Digital | "The Yield Desk," agentic CTV/DOOH yield management (35K retail screens) | `proposal-sent` | $6K discovery -> $18K pilot -> $4-6K/mo | Direct relationship, Ariel-sourced |
| Jon Cooper, Veruna Minerals | Operational intelligence layer above Zengate/Palmra; Phase 0 two-week diagnostic | `in-conversation` | $35-60K Phase 0 target, phased build to follow | Direct relationship, Ariel-sourced |
| Rotating prospect list | $299 AI Visibility Audit, the Agor AI Ads on-ramp that ladders into Pilot/Managed (see `briefs/agor-consulting.md`) | `outreach-sent` (varies per prospect) | $299 entry fee, credited toward Pilot | Twice-weekly prospect-research scan, scored against ICP gates (intent/funding/fit/reachability, threshold >= 60) |

Use these three as the default worked examples for any pipeline, forecast, or velocity question
in this skill, instead of a fictional "Acme Corp" deal. Pull current stage and value from the
scorecard file itself before answering, values above will drift as the pipeline moves.

### Lead Scoring

**Explicit (fit):** For the consulting pipeline, this vault already runs an ICP-fit gate inside
the twice-weekly automated prospect-research scan referenced in `briefs/agor-consulting.md`:
funding signals, hiring signals, and a fit score against the AI-transformation ICP, with a >= 60
threshold before a prospect enters `outreach-staged`.

**Implicit (engagement):** Reply received, call booked, proposal requested. Because there is no
product-usage telemetry on a consulting engagement, "engagement" here means conversational
progress through the stage vocabulary above, not app usage.

**Negative:** Prospects who bounce (unverified email pattern-guessed and rejected by the mail
server), explicit "not interested," or a stage that goes stale for multiple weeks with no reply,
demote toward `parked`, don't leave them sitting in `in-conversation` indefinitely.

### Lead Routing

This vault is pre-hire (see "Founder-Led Sales" above: wait for ~$1M ARR and repeatable process
before hiring). Round-robin, territory, and skill-based routing between reps do not apply yet,
there is one rep. "Routing" here means: does a new lead clear the ICP-fit gate, and if so, which
stage of the vocabulary above does it enter. Revisit the team-based routing methods in
`references/routing-rules.md` once the Hiring framework above actually triggers a first hire; until
then, treat that reference file's speed-to-lead benchmarks as the actionable part and its
rep-routing sections as forward-looking, not current state.

**Speed-to-lead still applies to a solo operator:** contact within 5 minutes = 21x more likely to
qualify; after 30 minutes, conversion drops 10x. For a founder-led motion this mostly means:
reply-check cadence and same-day scorecard updates, not an automated routing engine.

### Pipeline Stage Hygiene

- Every send, reply, call, proposal, win, or loss updates the Stage and Last-touch columns in the
  scorecard file the same day it happens; this is a hard rule already stated in that file's own
  "Update discipline" section, not a new one invented here
- Flag stale deals: a row sitting in the same non-terminal stage for an unusually long stretch
  (use the specific deal's own history as the baseline, there isn't yet enough volume in this
  pipeline for a statistically meaningful "2x average time in stage" threshold)
- A stage skip (e.g. `outreach-sent` straight to `proposal-sent` with no `in-conversation` or
  `call-booked` in between) is a signal to double check the row is accurate, not necessarily an
  error. A fast-moving referral can legitimately skip stages
- Never advance a stage, mark something `won`, or log a reply that didn't happen. This mirrors the
  triage rule in `briefs/_portfolio.md`: don't fabricate outcomes

### RevOps Metrics

At this pipeline's current volume (single digits of active opportunities), industry-benchmark
conversion rates are directional context, not a target to grade Ariel's real numbers against yet:

| Metric | Industry benchmark | Where to get Ariel's real number |
|--------|--------------------|-----------------------------------|
| Speed-to-lead | <5 minutes | Scorecard file's Last-touch column vs. lead entry date |
| Win rate | 20-30% | Count `won` vs. `lost`/`parked` rows in the scorecard once there's enough closed volume to be meaningful |
| Deal cycle length | Varies by deal size | Date range between `lead` and `won`/`lost` per row |
| Realized revenue | N/A | **Stripe MCP read tools** (`mcp__stripe__stripe_api_read`, `search_stripe_resources`, `get_stripe_account_info`) against the shared account (`acct_1T09QrAOqOwPWk86`), disambiguated by product/signal phrase per `PORTFOLIO_PROPERTIES.md`. Only the $299 AI Visibility audit and any self-serve `agor-agents` charges actually run through Stripe; the Oncore and Veruna engagements close off-platform and get invoiced manually |

Don't invent a win rate, LTV:CAC, or pipeline-coverage number for this pipeline from thin air; if
asked for one and the scorecard doesn't have enough closed history yet, say so and offer the
industry benchmark as context instead.

For a deeper cut on scoring and lifecycle framing that still generalizes (useful if this playbook
is ever applied to a hired rep or a higher-volume motion), see `references/scoring-models.md`,
`references/lifecycle-definitions.md`. For routing and automation patterns rebuilt around this
vault's actual tools (GBrain, the scorecard, scheduled tasks, and draft-gated sends, not
HubSpot/Salesforce/Zapier), see `references/routing-rules.md` and
`references/automation-playbooks.md`.

---

## Sales Compensation

**Standard structure:** 50% base / 50% variable (OTE). This is a starting point, not a law.

**Modern comp plans align with customer outcomes, not just bookings.** Reps who close churny deals should earn less than those who close sticky customers.

**Ramp periods:** 3-6 months for SMB, 6-12 months for enterprise. Provide guaranteed draw or reduced quotas during ramp.

**Simplicity rule:** If reps can't instantly calculate how an action affects their pay, the plan is too complex.

**Common mistakes:**
- Incentivizing only bookings without customer quality
- Over-complicated plans with too many variables
- No ramp protection for new hires
- Ignoring churn in comp design

For detailed comp frameworks: see `references/guest-insights.md`

---

## Sales Metrics

| Metric | What It Tells You |
|--------|-------------------|
| Win rate | Sales effectiveness |
| Sales cycle length | Process efficiency |
| Pipeline coverage | Forecast reliability (target 3-4x quota) |
| Lead-to-Opportunity | Qualification quality |
| CAC | Acquisition efficiency |
| Quota attainment | Rep performance |

---

## Related Skills

- `crm-integration` - GBrain record-keeping, timeline logging, and pipeline-stage tagging for any
  contact or company this skill's pipeline work touches
- `outbound-email-strategy` - Cold outreach
- `pricing-strategy` - Pricing decisions
- `go-to-market-strategy` - Full launch planning
