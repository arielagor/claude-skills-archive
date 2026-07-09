---
name: customer-success-and-retention
description: Comprehensive customer success and retention expertise combining onboarding, health scoring, churn prevention, retention strategies, and LTV maximization. Use when designing customer onboarding flows, reducing churn, building health scores, creating retention systems, designing upsells, or improving customer lifetime value. Covers proactive engagement, cancel flows, dunning, re-engagement, and the full customer lifecycle.
metadata:
  version: 1.0.0
  merged_from:
    - customer-success-manager
    - customer-success
    - churn-prevention
    - retain
    - retention-engine
---

# Customer Success & Retention

## Workspace Context

Read `briefs\_portfolio.md` first, always, before touching any support, refund, or retention
content: it holds the shared Stripe-account rule and the customer triage rule that this skill's
Payment Rail Triage section below is built directly from. Then read the property brief that
matches the inbound message: `briefs\modelstack.md` (Stripe, shared account), `briefs\agor-consulting.md`
(no Stripe checkout for the consulting engagement itself), `briefs\ios-apps.md` (Apple IAP for
all four apps, plus MVAT Focus's separate Stripe web tier), or `briefs\scored-tools.md`. Fall
back to `about/me.md` for personal and support voice and `strategy/brand.md` for cross-property
voice. `content/ideas.md` and `content/calendar.md` remain the content-planning references. Save
generated drafts to `content/<platform>/drafts/YYYY-MM-DD_short-topic-slug.md`, and route durable
learnings back to the relevant brief, `strategy/brand.md`, or `about/me.md`.

## Payment Rail Triage: Read This Before Any Refund or Support Draft

This section exists because a prior automated run once misclassified a real modelstack.digital
customer (a double-paid purchase of the "M&A Valuation Model") as fraud and fabricated a support
reply in response. That failure mode must never repeat. Three rules govern everything below,
and they take priority over any generic churn-prevention or dunning template further down in
this file.

### Rule 1: Apple and Stripe are never interchangeable

- **Apple App Store In-App Purchase (IAP)** is the payment rail for all four iOS apps: gifloop,
  MVAT Focus (its lifetime-unlock IAP), MVAT Mirror, and Coqui Chorus / co-kee. **Every refund on
  these rails goes through Apple, never Stripe, never Ariel directly.** Do not draft a Stripe
  refund path, a discount code, or a "resend the download" flow for an IAP complaint; the correct
  drafted reply points the customer to Apple's own refund request flow
  (reportaproblem.apple.com) and, where relevant, the app's own support inbox
  (`support@mvat.ai` or `support@co-kee.com`) for anything Apple's flow does not cover.
- **Stripe** is the payment rail for modelstack.digital (every template and bundle), the MVAT
  Focus **web tier** ("Pro," $4.99/mo or $39.99/yr, separate from its IAP unlock), and any other
  Stripe-rail product on the shared account (`acct_1T09QrAOqOwPWk86`, per `briefs\_portfolio.md`).
  **Every refund on this rail routes to Ariel for manual handling**, never auto-resolved here.
- **MVAT Focus is the one property with both rails at once.** A support message about it must be
  triaged to the correct rail before drafting anything: an IAP complaint (the $0.99 one-time
  unlock) routes to Apple; a web-tier complaint (the $4.99/mo or $39.99/yr Stripe subscription)
  routes to Ariel via Stripe. Never conflate the two rails in a single drafted reply.
- **agor.me consulting has no Stripe checkout at all.** A payment question tied to a consulting
  engagement is always a manually invoiced, off-platform matter for Ariel, never a refund this
  skill can resolve through either rail.

### Rule 2: "I double-paid, please advise" is a real-customer pattern, never an assumed scam

A polite message reporting a double charge, a missing download, or "I paid for X and didn't get
it" is, per `briefs\_portfolio.md`'s customer triage rule, a real-customer pattern, not a scam
indicator. "I don't recognize this product" from an internal reviewer is never, by itself,
sufficient evidence to call an inbound payment inquiry fraudulent; Ariel runs many revenue lines
at once, and a real customer can easily reference a product name that does not ring a bell out
of context. Before drafting any response to a payment or refund inquiry:

1. Match the message to a property using the signal-phrase table in
   `C:\Users\ariel\.claude\PORTFOLIO_PROPERTIES.md` (for example, "M&A template," "M&A Valuation
   Model," "financial model," or "LBO" all point to modelstack.digital, where a real Stripe
   product exists under exactly that name).
2. Reserve actual scam suspicion for the real tells: unrelated transfer links, credential
   requests, mismatched names, payment-method-change requests, or urgency pressure. None of
   these resemble a routine support question about a real product.
3. If the message cannot be matched to any known property or signal phrase after checking the
   inventory, say so explicitly in the drafted output and flag it to Ariel as unmatched, rather
   than defaulting to either "definitely a customer" or "definitely a scam."

### Rule 3: This skill drafts, it never sends

Every cancel-flow message, dunning email, re-engagement email, save offer, refund reply, or
retention touchpoint produced from this skill (including everything in Parts 4 through 7 below)
is a **draft only**, saved under `content\<platform>\drafts\` (or returned inline if the user
asks for inline-only output). This skill never sends an email, issues a refund, applies a
discount code, or replies to a support thread itself; those are Ariel's actions to take manually
after reviewing the draft. This holds even for messages that look time-sensitive: a polite
"please advise" support email does not justify skipping the review step. If asked to "just send
it," decline the send, produce the draft, and say the send step belongs to Ariel.

## Operating Contract

This skill is self-contained for its frontmatter scope: use its local instructions, references, scripts, and assets as the playbook; ask only for missing task-specific inputs; hand off to adjacent skills instead of expanding scope; and return an actionable artifact, decision, plan, draft, or diagnostic.



Comprehensive framework for customer success, retention, and lifetime value maximization.

## Quick Reference

| Situation | Use This Skill For |
|-----------|-------------------|
| Designing onboarding flows | Onboarding Excellence |
| Reducing churn | Churn Prevention & Recovery |
| Building health monitoring | Health Score Models |
| Improving LTV | Retention & Ascension |
| Cancel flow optimization | Cancel Flow Design |
| Payment failures | Dunning & Recovery |

---

## Part 1: Core Principles

### Time to Value Is Everything

The faster users get value, the more likely they stick. Measure and optimize time to first value moment. Remove every obstacle between signup and aha moment.

### Proactive Beats Reactive

Reach out before problems escalate. Health scores predict churn before it happens. Intervention when metrics dip is worth 10x intervention after cancellation request.

### Segment for Relevance

Not all customers are the same. High-touch for enterprise, tech-touch for SMB, self-serve for individuals. Match effort to customer value and needs.

### Measure Leading Indicators

Revenue is a lagging indicator. Track: engagement, feature adoption, support tickets, NPS changes.

### Make Expansion Natural

Upselling should feel like helping, not selling. When customers outgrow their tier, expansion is a solution.

---

## Part 2: Customer Onboarding Design

### Onboarding Workflow

1. Map customer goals and success criteria
2. Define key milestones and timeline
3. Create onboarding checklist
4. Design enablement content
5. Set up automated touchpoints
6. Define handoff from sales
7. Measure time-to-value

### Activation Milestones

| Milestone | Target Time | D30 Retention Impact |
|-----------|-------------|---------------------|
| Account created | T+0 | Baseline |
| Profile complete | T+5 min | +8% |
| First core action | T+24 hr | +15% |
| First value experience | T+3 days | +25% |
| 3-day active streak | T+7 days | +35% |

### Onboarding Patterns

| Approach | Best For | Risk |
|----------|----------|------|
| Product-first | Simple products, B2C | Blank slate overwhelm |
| Guided setup | Products needing personalization | Friction before value |
| Value-first | Products with demo data | May not feel "real" |

---

## Part 3: Health Scoring

### Customer Health Score (100 points)

| Dimension | Weight | Signals |
|-----------|--------|---------|
| Usage frequency | 25% | DAU/MAU ratio, sessions, last login |
| Feature depth | 20% | Feature adoption %, core feature use |
| Engagement | 20% | Time on app, actions per session |
| Satisfaction | 15% | NPS, CSAT, support sentiment |
| Growth | 10% | Seat additions, plan upgrades |
| Relationship | 10% | Community participation, referrals |

### Health Score Thresholds

| Score | Status | Action |
|-------|--------|--------|
| 80-100 | Healthy | Upsell opportunities |
| 60-79 | Stable | Monitor |
| 40-59 | At Risk | Automated intervention |
| 0-39 | Critical | Human outreach |

### Churn Risk Scoring

| Level | Score | Action |
|-------|-------|--------|
| Low | 0-29 | Continue normal engagement |
| Medium | 30-49 | Automated re-engagement |
| High | 50-69 | Personalized intervention |
| Critical | 70+ | Human outreach (call/email) |

---

## Part 4: Churn Prevention

### Churn Types & Solutions

| Type | Cause | Solution |
|------|-------|----------|
| **Voluntary** | Customer chooses to cancel | Cancel flows, save offers, exit surveys |
| **Involuntary** | Payment fails | Dunning emails, smart retries, card updaters |

Voluntary churn is typically 50-70% of total. Involuntary is 30-50% but easier to fix.

### Risk Signals

| Signal | Risk Level | Timeframe |
|--------|-----------|-----------|
| Login frequency drops 50%+ | High | 2-4 weeks before cancel |
| Key feature usage stops | High | 1-3 weeks before cancel |
| Support tickets spike then stop | High | 1-2 weeks before cancel |
| Billing page visits increase | High | Days before cancel |
| Team seats removed | High | 1-2 weeks before cancel |
| Data export initiated | Critical | Days before cancel |
| NPS score drops below 6 | Medium | 1-3 months before cancel |

### Proactive Interventions

| Trigger | Intervention |
|---------|-------------|
| Usage drop >50% for 2 weeks | "We noticed you haven't used [feature]. Need help?" email |
| Approaching plan limit | Upgrade nudge |
| No login for 14 days | Re-engagement email with product updates |
| NPS detractor (0-6) | Personal follow-up within 24 hours |

---

## Part 5: Cancel Flow Design

### The Cancel Flow Structure

```
Trigger → Survey → Dynamic Offer → Confirmation → Post-Cancel
```

### Exit Survey Design

| Reason | What It Tells You |
|--------|-------------------|
| Too expensive | Price sensitivity, may respond to discount |
| Not using it enough | Low engagement, may respond to pause/onboarding |
| Missing a feature | Product gap, show roadmap |
| Switching to competitor | Competitive pressure |
| Technical issues | Product quality, escalate to support |
| Temporary / seasonal | Usage pattern, offer pause |

### Save Offer Mapping

| Cancel Reason | Primary Offer | Fallback Offer |
|---------------|---------------|----------------|
| Too expensive | Discount (20-30% for 2-3 months) | Downgrade |
| Not using | Pause (1-3 months) | Free onboarding |
| Missing feature | Roadmap preview | Workaround guide |
| Competitor | Competitive comparison + discount | Feedback session |
| Technical issues | Escalate to support | Credit + priority fix |

### Save Offer Types

- **Discount**: 20-30% for 2-3 months (avoid 50%+)
- **Pause**: 1-3 months max, 60-80% eventually return
- **Downgrade**: Show what they keep vs. lose
- **Feature unlock**: Extend trial of higher tier
- **Personal outreach**: For high-value accounts

---

## Part 6: Involuntary Churn (Dunning)

### The Dunning Stack

```
Pre-dunning → Smart retry → Dunning emails → Grace period → Hard cancel
```

### Pre-Dunning (Prevent Failures)

- Card expiry alerts: 30, 15, 7 days before
- Backup payment method prompt at signup
- Card updater services (Visa/MC auto-update)
- Pre-billing notification for annual plans

### Smart Retry Logic

| Decline Type | Retry Strategy |
|-------------|----------------|
| Soft decline | Retry 3-5 times over 7-10 days |
| Hard decline | Don't retry — ask for new card |
| Authentication required | Send customer to update payment |

### Dunning Email Sequence

| Email | Timing | Content |
|-------|--------|---------|
| 1 | Day 0 | "Your payment didn't go through. Update your card." |
| 2 | Day 3 | "Quick reminder — update your payment." |
| 3 | Day 7 | "Your account will be paused in 3 days." |
| 4 | Day 10 | "Last chance to keep your account active." |

---

## Part 7: Re-engagement & Retention

### Re-engagement Triggers

| Trigger | Condition | Channel | Max Frequency |
|---------|-----------|---------|---------------|
| Early dormancy | 3-7 days inactive | Push | 4×/month |
| Mid dormancy | 7-14 days inactive | Email | 2×/month |
| Onboarding drop | Incomplete onboarding | Email | 3×/month |
| Feature discovery | Unused high-value feature | In-app | 1×/month |
| Streak at risk | Streak expires in 6 hours | Push | As needed |

### Habit Formation (Hook Model)

| Phase | Goal | Examples |
|-------|------|----------|
| **Trigger** | Create the cue | Push notifications, email digest |
| **Action** | Minimum viable behavior | One-click action, simple daily task |
| **Variable Reward** | Unpredictable value | Social recognition, progress unlocks |
| **Investment** | User commits something | Profile data, settings, connections |

### Gamification Elements

- **Badge rarity**: Common → Rare → Epic → Legendary
- **Progress levels**: 5 levels with XP ranges
- **Streak systems**: 7-day → 30-day → 100-day → 365-day

---

## Part 8: LTV Maximization

### The LTV Equation

```
LTV = (Average Revenue Per Customer × Average Customer Lifespan) - CAC
```

**To maximize LTV:**
- **INCREASE** Revenue Per Customer (upsells, cross-sells)
- **INCREASE** Customer Lifespan (reduce churn)
- **DECREASE** CAC (get referrals)

### Ascension Ladder

```
Level 1: Entry Offer → Solves first problem
    ↓
Level 2: Core Offer → Deeper solution
    ↓
Level 3: Premium Offer → Advanced/faster results
    ↓
Level 4: Done-For-You → They pay you to do it
    ↓
Level 5: Ongoing Relationship → Retainer/subscription
```

### Retention Levers

1. **Onboarding Excellence** — Get them a win in first 24-48 hours
2. **Engagement Systems** — Keep them using regularly
3. **Success Milestones** — Make progress visible and celebrated
4. **Community/Connection** — Create belonging
5. **Ascension Triggers** — Move to next level at right time

---

## Part 9: Metrics & Measurement

### Key Metrics

| Metric | Formula | Target |
|--------|---------|--------|
| Monthly churn rate | Churned / Start-of-month | <5% B2C, <2% B2B |
| Revenue churn (net) | (Lost MRR - Expansion) / Start MRR | Negative |
| Cancel flow save rate | Saved / Total cancel sessions | 25-35% |
| Dunning recovery rate | Recovered / Total failures | 50-60% |
| Time to cancel | Days from signal to cancel | Track trend |

### Cohort Analysis

Segment by:
- Acquisition channel
- Plan type
- Tenure
- Cancel reason
- Save offer type

---

## Part 10: Segmentation Strategy

### Customer Segment Approach

```
├── Enterprise (high-touch)
│   ├── Dedicated CSM
│   ├── Custom success plans
│   └── Executive sponsors
├── Mid-market (mid-touch)
│   ├── Pooled CSM model
│   ├── Templated playbooks
│   └── Regular check-ins
└── SMB (tech-touch)
    ├── Automated journeys
    ├── Self-service resources
    └── Trigger-based outreach
```

---

## Common Mistakes

1. **No cancel flow** — Even simple survey + offer saves 10-15%
2. **Same offer for every reason** — Match offer to reason
3. **Discounts too deep** — 50%+ trains customers to cancel-for-deals
4. **Ignoring involuntary churn** — Often 30-50% of total
5. **No dunning emails** — Letting payment failures silently cancel
6. **Guilt-trip copy** — Damages brand trust
7. **Pausing too long** — Beyond 3 months rarely reactivates

---

## Related Skills

- **marketing-automation**: For onboarding and win-back sequences
- **conversion-rate-optimization**: For in-app upgrade moments
- **pricing-strategy**: For plan structure
- **user-onboarding**: For activation optimization
- **data-and-funnel-analytics**: For churn signal events
