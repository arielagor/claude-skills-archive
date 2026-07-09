---
name: data-and-funnel-analytics
description: Analytics tracking, interpretation, funnel analysis, product metrics, and ROI measurement, built around this vault's real analytics stack (Plausible, Stripe MCP read tools, Dub.co, and a not-yet-authenticated Supermetrics MCP), not a generic GA4/Mixpanel setup. Use when interpreting analytics data, analyzing conversion funnels, calculating ROI, or measuring product engagement across modelstack.digital, agor.me, the iOS apps, or scored.tools. Triggers on "analytics," "GA4," "Plausible," "conversion tracking," "event tracking," "UTM parameters," "Dub.co," "tracking plan," "funnel analysis," "conversion rates," "user flow," "cohort analysis," "retention," "product metrics," "North Star metric," "ROI," "break-even," "payback period," "investment analysis," "validate my funnel," "why isn't my funnel converting," or "executive financial report." For A/B test setup, see ab-test-setup.
---

# Data & Funnel Analytics

## Workspace Context

Read bootstrap context before asking questions: `strategy/brand.md` for brand, audience, offer, channels, tools, constraints, and metrics; `about/me.md` for personal voice; `content/ideas.md` and `content/calendar.md` for content planning. Use legacy product-marketing context files only as fallback. Save generated drafts to `content/<platform>/drafts/YYYY-MM-DD_short-topic-slug.md`, and route durable learnings back to `strategy/brand.md`, `about/me.md`, or `content/ideas.md`.

**Also read the specific property's brief before assuming a funnel shape or an analytics tool.**
This vault covers four properties (`briefs/modelstack.md`, `briefs/agor-consulting.md`,
`briefs/ios-apps.md`, `briefs/scored-tools.md`) and they do not share one funnel or one analytics
stack: modelstack.digital runs Plausible with real wired events (`Checkout Click`, `Email
Signup`), agor.me runs GA4 as an exception (property 540566537) rather than Plausible, the iOS
apps monetize through Apple IAP with no web funnel at all, and scored.tools has no payment rail
yet. Read `data/REMAP.md` and `data/connections.md` for the vault-wide tool inventory, then the
property's own brief for what is actually wired on that specific site, before writing tracking
code or interpreting a number.

## Operating Contract

This skill is self-contained for its frontmatter scope: use its local instructions, references, scripts, and assets as the playbook; ask only for missing task-specific inputs; hand off to adjacent skills instead of expanding scope; and return an actionable artifact, decision, plan, draft, or diagnostic.



End-to-end analytics: set up tracking, interpret data, analyze funnels, measure product engagement, validate conversion paths, and calculate ROI.

**Principle:** Track for decisions, not data — every event should inform an action.

---

## Analytics Tracking

### Event Naming Convention

Format: `object_action` in lowercase snake_case.

```
signup_completed | cta_hero_clicked | checkout_started | onboarding_step_completed
```

Rules: Specific over vague (`cta_hero_clicked` not `button_clicked`), past tense for completed actions, context in properties not event name.

### Tracking Plan

| Category | Event | Key Properties |
|----------|-------|---------------|
| **Marketing** | `page_view` | page_title, page_location, referrer |
| | `cta_clicked` | button_text, location, page |
| | `form_submitted` | form_type, page |
| | `signup_completed` | method, plan |
| **Product** | `onboarding_step_completed` | step_number, step_name |
| | `feature_used` | feature_name, context |
| | `trial_started` | plan, source |
| | `purchase_completed` | plan, value, currency |
| **E-commerce** | `product_viewed` | product_id, category, price |
| | `product_added_to_cart` | product_id, price, quantity |
| | `checkout_started` | cart_value, items_count |

### Standard Properties

- **User context:** user_id, user_type (free/paid/admin), plan_type
- **Attribution:** source, medium, campaign, content, term (UTM params)
- **Page:** page_title, page_location, content_group
- **PII hygiene:** Never send email, name, or phone as event properties. Use hashed user IDs only.

### Implementation: check the property's brief first, this vault runs two different tools

**Plausible is the vault-wide default** (per `data/REMAP.md`), confirmed live on
modelstack.digital with real custom events already wired in `index.html`:

```javascript
// Plausible custom event (matches modelstack.digital's live implementation)
plausible('Checkout Click', { props: { product: productName, price: priceLabel } });
plausible('Email Signup');
```

Plausible is cookieless by design (no consent banner needed for it specifically) and has no
event/funnel builder as rich as GA4 or Mixpanel; treat funnel analysis on a Plausible-only
property as goal-based and qualitative rather than assuming a full event schema exists.

**GA4 is confirmed live only on agor.me** (property 540566537, measurement ID `G-TJFFG9WEKG`, per
`briefs/agor-consulting.md`), as a deliberate exception, not the vault default. Don't assume GA4
exists on any other property without checking that property's brief first:

```javascript
// gtag.js custom event (agor.me only)
gtag('event', 'signup_completed', {
  'method': 'email',
  'plan': 'free',
  'user_id': userId
});
```

**Enhanced Measurement** (enable in GA4, agor.me only): page_view, scroll, outbound_click,
site_search, video_engagement, file_download.

**Conversions (GA4, agor.me only):** Admin, Events, toggle "Mark as conversion." Counting: once
per session (form submit) or every time (purchase).

**No third-party SEO or session-replay tooling exists** (Ahrefs, Semrush, Hotjar, FullStory); see
`data/REMAP.md` Row 2 and Row 3 before implying one is available.

### UTM Parameters

Convention: `utm_source={channel}&utm_medium={cpc|email|organic|social}&utm_campaign={id}&utm_content={variant}&utm_term={keyword}`

- Apply to ALL paid and email links
- Never use on internal links (breaks session attribution)
- Lowercase, hyphens not spaces
- **Wrap the UTM-tagged URL in a Dub.co link** (dashboard `app.dub.co/agor`, API base
  `api.dub.co`) for click-level tracking on top of the UTM attribution; Dub.co is this vault's
  live link-tracking tool (`data/REMAP.md` Row 6), not a generic shortener suggestion
- Document in a UTM tracking sheet

### Privacy & Compliance

- Plausible needs no cookie-consent banner for its own tracking (cookieless, no personal data
  collected); this does not exempt a property from GDPR/CCPA obligations for anything else on the
  page (forms, Stripe, other scripts)
- On agor.me specifically (the one property running GA4): implement consent management, block GA4
  until consent granted, GA4 data retention capped at 14 months max (Admin, Data Settings), IP
  anonymization enabled

---

## Analytics Interpretation

### GA4 Benchmarks

| Metric | Good | Warning | Poor | Action When Poor |
|--------|------|---------|------|------------------|
| Avg Time on Page | >3 min | 1–3 min | <1 min | Improve content depth |
| Bounce Rate | <40% | 40–70% | >70% | Add internal links, improve intro |
| Engagement Rate | >60% | 30–60% | <30% | Review content quality |
| Scroll Depth | >75% | 50–75% | <50% | Add visual breaks |
| Pages/Session | >2.5 | 1.5–2.5 | <1.5 | Improve internal linking |

### Google Search Console Benchmarks

| Metric | Good | Warning | Poor | Action When Poor |
|--------|------|---------|------|------------------|
| CTR | >5% | 2–5% | <2% | Improve title/meta description |
| Avg Position | 1–3 | 4–10 | >10 | Strengthen content, build links |
| Impressions | Growing | Stable | Declining | Refresh content |

### Traffic Quality Matrix

```
                    High Engagement
                          │
           ┌──────────────┼──────────────┐
           │  HIDDEN GEM  │   STAR       │
           │  Low traffic  │   High traffic│
           │  → Promote   │   → Maintain  │
Low ───────┼──────────────┼──────────────┼─── High
Traffic    │  UNDERPERFORM│   LEAKY      │   Traffic
           │  Low traffic  │   High traffic│
           │  → Rework    │   → Optimize  │
           └──────────────┼──────────────┘
                          │
                    Low Engagement
```

### Anomaly Detection

| Metric | Significant Change | Alert Level |
|--------|-------------------|-------------|
| Traffic | ±30% WoW | HIGH |
| CTR | ±1pp WoW | MEDIUM |
| Position | ±5 positions | HIGH |
| Bounce Rate | ±10pp WoW | MEDIUM |

---

## Product Analytics

### North Star Metric

The ONE metric that represents customer value:

| Company | North Star |
|---------|-----------|
| Slack | Weekly Active Users |
| Airbnb | Nights Booked |
| Spotify | Time Listening |
| Shopify | GMV |

Criteria: Represents customer value, correlates with revenue, measurable frequently, rallies the team.

### Key Metrics by Stage

| Stage | Metrics |
|-------|---------|
| **Acquisition** | Traffic sources, CPC, visitor → signup rate |
| **Activation** | Signup → first core action, time to value, onboarding completion |
| **Retention** | DAU/MAU (stickiness), D1/D7/D30 retention, churn rate |
| **Revenue** | MRR/ARR, ARPU, LTV, LTV:CAC ratio |
| **Referral** | Viral coefficient, referral signups, NPS |

### Retention Benchmarks

| Timeframe | Good | Bad |
|-----------|------|-----|
| D1 | 60–80% | <40% |
| D7 | 40–60% | <10% |
| D30 | 30–50% | <2% |

Good = flattening curve. Bad = steep drop-off.

### Dashboard Design

- **Executive:** North Star Metric (big number), revenue (MRR/ARR), key trends
- **Product:** Active users, feature usage, retention cohorts, funnels
- **Marketing:** Traffic sources, conversion rates, CPA, ROI by channel

---

## Funnel Analysis

### Core Workflow

1. Load and merge user journey data
2. Define funnel steps and calculate step-by-step conversion rates
3. Segment by user attributes (device, cohort, plan)
4. Visualize bottlenecks
5. Generate optimization recommendations

### Common Funnel Types

| Funnel | Steps |
|--------|-------|
| **E-commerce** | Promotion → Search → Product View → Add to Cart → Purchase |
| **SaaS Signup** | Landing Page → Sign Up → Email Verify → Onboarding Complete |
| **Content** | Article View → Comment → Share → Subscribe |

### Analysis Patterns

- **Bottleneck identification** — Steps with highest drop-off rates
- **Segment comparison** — Conversion across user groups
- **Temporal analysis** — Conversion over time
- **A/B testing** — Compare funnel variations

See `examples/` for Python implementations with Plotly visualizations.

---

## Funnel Validation (DotCom Secrets)

Score existing funnels against Russell Brunson's framework: **Hook → Story → Offer**.

### Scoring Dimensions

| Dimension | Weight | What It Measures |
|-----------|--------|------------------|
| Hook Strength | 2x | Stops the scroll, grabs attention |
| Story Connection | 1.5x | Creates emotional connection and belief |
| Offer Clarity | 2x | Clear, compelling, irresistible |
| Value Ladder Fit | 1x | Fits the ascension path |
| Traffic Match | 1.5x | Matched to traffic temperature |
| Conversion Path | 1x | Next step obvious and frictionless |

### Rating Scale

| Score | Verdict |
|-------|---------|
| 85–100 | Conversion Machine — Ready to scale |
| 70–84 | Strong Funnel — Fix weak points, then scale |
| 55–69 | Leaky Funnel — Fix before scaling traffic |
| 40–54 | Broken Funnel — Rebuild key components |
| 0–39 | Non-Functional — Start over |

### Traffic Temperature

| Temperature | They Know | Appropriate Funnel |
|-------------|-----------|-------------------|
| Cold | Nothing about you | Lead funnel, value-first content |
| Warm | Problem + your solution | Tripwire, webinar, challenge |
| Hot | Ready to buy | Sales page, order form, call booking |

For complete scoring criteria and examples, see [references/full-guide.md](references/full-guide.md).

---

## ROI Analysis

### Core Metrics

**ROI:** `(Net Profit / Total Investment) × 100%`
- ✅ INVEST: ROI > 100% (realistic case)
- ⚠️ REVIEW: ROI 50–100%
- ❌ REJECT: ROI < 50%

**Break-Even:** `Investment / Monthly Net Profit`
- ✅ INVEST: Break-even < 50% of realistic target
- ❌ REJECT: Break-even > 70%

**Payback Period:** `Investment / Monthly Net Profit`
- ✅ INVEST: < 12 months
- ⚠️ REVIEW: 12–24 months
- ❌ REJECT: > 24 months

### 3-Scenario Analysis

Always model Best / Realistic / Worst:

| Case | Assumptions | Revenue | Profit | ROI | Assessment |
|------|------------|---------|--------|-----|------------|
| **Worst** | Pessimistic | | | | Risk level |
| **Realistic** | Expected | | | | Target |
| **Best** | Optimistic | | | | Upside |

**Decision rule:** If worst-case ROI ≥ 0%, investment is low-risk.

### Executive Summary Template

```
[Investment] achieves [ROI%] ROI at [conversion/growth rate].
Break-even occurs at [threshold], with payback in [months].
Investment is [recommended/not recommended] because [reason].
```

For detailed formulas (NPV, LTV, CAC, sensitivity analysis), see [references/roi-reference.md](references/roi-reference.md).

---

## Validation & QA

### Before Launch
- [ ] Events fire in GA4 DebugView
- [ ] Properties have expected values
- [ ] No duplicate events
- [ ] Conversions marked correctly
- [ ] UTM parameters captured on landing

### Ongoing
- **Weekly:** Check for sudden drops in key events (>20% change = investigate)
- **Monthly:** Audit for new pages/features without tracking
- **Quarterly:** Full tracking plan review — remove stale events, add missing ones

---

## Tools

| Category | Tools |
|----------|-------|
| **Event Tracking** | Mixpanel, Amplitude, PostHog (open-source) |
| **Session Recording** | FullStory, LogRocket, Hotjar |
| **A/B Testing** | Optimizely, VWO |
| **Web Analytics** | GA4, Google Search Console |
| **Tag Management** | Google Tag Manager |

---

## Related Skills

- **ab-test-setup** — A/B test measurement and setup
- **seo-and-aeo-strategy** — Measuring SEO/AEO performance
- **conversion-rate-optimization** — Optimizing conversion after funnel analysis
- **executive-dashboard-generator** — Building dashboards from analytics data
