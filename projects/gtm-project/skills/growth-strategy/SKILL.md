---
name: growth-strategy
description: Per-property growth-loop mechanics and retention for Ariel's portfolio. Covers designing and instrumenting growth loops, acquisition-channel compounding, network effects, PLG-as-a-loop, growth experimentation, and retention for a single property. For the core GTM motion and price ladder, see go-to-market-strategy. For cross-property prioritization and portfolio cross-promo, defer to portfolio-pm. For SEO audits use seo-and-aeo-strategy; for page/form CRO use conversion-rate-optimization; for A/B test design use ab-test-setup. Use when building a growth loop, planning acquisition channels, evaluating network effects, deciding when to scale, or improving retention on one property.
metadata:
  version: 1.0.0
  merged_from:
    - growth
    - growth-strategy
    - growth-loops
---

# Growth Strategy

## Workspace context

Read the brief before any property-specific work, and say which brief you read in an early "Workspace context" line (operating rule 4): `briefs/_portfolio.md` first, then the matching `briefs/modelstack.md`, `briefs/agor-consulting.md`, `briefs/ios-apps.md`, or `briefs/scored-tools.md`; then `strategy/brand.md` and `about/me.md`. Read `data/REMAP.md` before reaching for any external tool. Save drafts to `content/<platform>/drafts/YYYY-MM-DD_topic-slug.md`. Outward actions are draft-gated: nothing sends, posts, or spends without Ariel's explicit go.

## Scope: what this skill owns

**For GTM fundamentals (motion selection, the price ladder, launch execution), see `go-to-market-strategy`.** This skill starts after the motion is chosen and works on the compounding: the loop each property runs, and the retention that keeps the loop fed.

**For cross-property prioritization and cross-promo across properties, defer to `portfolio-pm`.** It owns what to work on next across the revenue portfolio and its synergy mode (`/pm sync`). Do not re-implement portfolio orchestration here: this skill owns the growth-loop mechanics and retention of one property at a time, and hands the "which property, and how do they promote each other" question to `portfolio-pm`.

Route tactical work to the specialists the description names: SEO to `seo-and-aeo-strategy`, page/form CRO to `conversion-rate-optimization`, experiment execution to `ab-test-setup`.

## Operating Contract

This skill is self-contained for its frontmatter scope: use its local instructions, references, scripts, and assets as the playbook; ask only for missing task-specific inputs; hand off to adjacent skills instead of expanding scope; and return an actionable artifact, decision, plan, draft, or diagnostic.

---

## Part 1: Core Principles

- Growth follows product-market fit, never precedes it.
- Retention is the foundation; acquisition without retention is a leaky bucket.
- The best growth is product-driven and content-driven, not paid-driven.
- Compound effects beat linear efforts.
- Every channel eventually saturates.
- One primary loop per property; others supplement.
- For a one-operator portfolio, the compounding asset is the daily-content-plus-authority engine, not a headcount-driven growth team.

---

## Part 2: Growth Loops Framework

### Why Loops, Not Funnels

**Funnels** are linear: pour effort in, get results out, start over. **Loops** turn each cycle's output into the next cycle's fuel. The shift is from "how do we get more users?" to "how does each user (or each piece of content) generate the next?"

### Loop Types

| Loop Type | Mechanism | Compounding fuel |
|-----------|-----------|------------------|
| **Content** | Content ranks and gets shared, attracts readers, some convert, wins fund more content | Indexed pages, organic traffic |
| **Viral / shareable-output** | Users share a result the product produced | Invites, shared artifacts |
| **Sales/revenue** | Revenue funds more acquisition or more content | CAC payback |

### Critical Patterns

| Pattern | Insight |
|---------|---------|
| Funnels vs Loops | Funnels are linear; loops compound |
| Paid is not a loop | Paid acquisition buys users, it does not compound. Invest 80%+ in earned/owned |
| Founder-led first | The growth model can't be outsourced before it's found |
| Product owns growth | Not a marketing-only function |
| One primary loop | Others supplement but won't save you |

### Platform Cycles

New platforms open, then close. Early: high reach, low competition. Mid: reach peaks, competition grows. Late: high competition, diminishing returns. Time the bet.

---

## Part 3: Per-Property Growth Loops

The real loops running (or buildable) in the portfolio. Pick the one primary loop per property and instrument it; do not run five loops badly.

| Property | Primary loop | How it compounds | Where it leaks |
|----------|--------------|------------------|----------------|
| **modelstack.digital** | Content -> SEO -> template sale | Daily blog post feeds Search Console keywords, ranks, drives organic buyers; the free Unit Economics Calculator captures email for nurture | One-time purchases: no recurring loop after the sale, so the loop must keep acquiring |
| **agor.me consulting** | Authority content -> inbound booking | Daily blog + Leo-voiced audio + weekly episodes build authority; the chat/voice widget captures the booking; delivered work becomes referrals and case studies | Long consideration cycle; inbound depends on cadence not breaking |
| **Agor AI Ads** | Audit -> pilot -> managed | The $299 audit produces a concrete result; the fee credits toward a pilot; a clean-attribution pilot becomes a managed retainer that expands | Attribution must be clean before the retainer rung, or the loop stalls |
| **iOS apps** | Store discovery -> ratings -> ranking | ASO plus review velocity lifts category ranking, which lifts discovery; shareable outputs (a gifloop GIF, an MVAT Mirror result) can seed light virality | Ratings decay; and for MVAT Focus's Stripe web Pro tier, subscription churn (the other apps are one-time IAP, not subscriptions) |
| **scored.tools** | Tool submissions + reviews -> content -> traffic | Submitted tools and review pages create indexed content that draws searchers, some of whom submit or click affiliate links | Pre-revenue; affiliate is the only rung and only one program is live |

Cross-promo between these properties (a modelstack reader to the consulting offer, one app to another) is real, but sequencing it across the portfolio is `portfolio-pm`'s `/pm sync` job. Design the single-property loop here; hand the cross-property weave to `portfolio-pm`.

---

## Part 4: Retention

Retention is the foundation, and it looks different per rung. Be honest about where there is no recurring relationship to retain.

- **modelstack (one-time digital goods):** there is no subscription to retain. "Retention" here is repeat purchase and list engagement: bundle upsell, newsletter open/click, and cross-sell into the consulting rungs. Do not model it as SaaS churn; model it as reactivation and lifetime value across multiple one-time buys.
- **agor.me consulting:** retention is repeat engagements, retainer continuation, and referral. The pre-call brief and delivery quality are the retention levers.
- **Agor AI Ads managed retainer:** the marquee recurring-revenue rung on the consulting side. Track net revenue retention and attribution health; a retainer only survives if the reported result stays clean.
- **MVAT Focus web Pro tier (Stripe):** the one live consumer subscription in the portfolio. Watch trial-to-paid, early churn, and habit formation (streaks, daily use); it bills and refunds through Stripe, not Apple. The other iOS apps are one-time Apple IAP (MVAT Mirror sells consumable credit packs, not a subscription), so their "retention" is repeat purchase and daily-use habit, not subscription churn.

Fix activation before pouring on acquisition: a leaky bucket wastes the content engine's output.

---

## Part 5: Network Effects (be honest)

| Type | Description |
|------|-------------|
| **Direct** | More users -> more value (social networks) |
| **Indirect** | More users -> more options -> more value (marketplaces) |
| **Data** | More data -> better product -> more users |

Most of Ariel's properties do **not** have real network effects, and the marketing rule is to never claim a moat the property lacks. The closest real dynamics are the two-sided pull on `scored.tools` (tools submit, searchers arrive) and light shareable-output virality on the consumer apps. The durable advantage across the portfolio is brand and authority, not a network effect. Build for it, don't overclaim it.

---

## Part 6: Product-Led Growth as a Loop

PLG applies to the self-serve rungs (modelstack, the Agor AI Ads audit, the iOS apps), not the human-closed consulting engagements. Treat it as a loop, not a motion (motion selection is `go-to-market-strategy`'s job):

- Product as the acquisition driver: the free lead magnet, a shareable app output, a low-price audit.
- Self-serve onboarding with a fast, obvious first value.
- In-product or in-output sharing where it exists.

| Signal | Rough target | Applies to |
|--------|--------------|-----------|
| Time to first value | Minutes, not days | modelstack download, app first session |
| Activation (used the core action once) | High | apps, audit |
| Repeat/expansion | Bundle attach, subscription renewal | modelstack, iOS subs |

---

## Part 7: Growth Experimentation

### ICE Framework

| Factor | Question |
|--------|----------|
| **Impact** | Could this meaningfully move the primary loop? |
| **Confidence** | How sure are we it works? |
| **Ease** | How fast can one operator ship it? |

Score each 1-10, rank, run the top items. For a one-operator portfolio, weight **Ease** heavily: an experiment that needs a team never runs.

### Test Discipline

- Write the hypothesis and the primary + guardrail metric before starting.
- Run a full cycle (1-2 weeks minimum) before reading results.
- Hand the actual A/B mechanics and significance math to `ab-test-setup`.

### What NOT to Test

- Button colors before understanding the real objection.
- Copying a competitor blindly.
- Optimizing a step without the loop context around it.

---

## Part 8: Measurement

Use the tools that exist (`data/REMAP.md`), never a paid SaaS the stack lacks:

- **Traffic and referrers:** Plausible (modelstack, live), GA4 for agor.me, App Store Connect for apps.
- **Loop revenue:** Stripe MCP read tools on the shared account (`acct_1T09QrAOqOwPWk86`), disambiguating product by signal phrase; App Store Connect for IAP.
- **Organic (the content loop's output):** Google Search Console indexation and ranking, plus the weekly Search-Console pull feeding the blog keyword queue. No Ahrefs/Semrush-style score exists; do not fabricate one.
- **Link attribution:** Dub.co on shared links.

There is no session-replay or heatmap tool. Keep loop-drop-off analysis qualitative and flag the gap rather than implying a tool provides it.

---

## Common Mistakes

1. **Premature scaling** - pouring on growth before PMF burns the one-operator's time.
2. **Acquisition without retention** - a leaky bucket, especially where there is a recurring rung to keep.
3. **Chasing channels** without understanding the property's one primary loop.
4. **Vanity metrics** - impressions without the loop's real output (sales, bookings, renewals).
5. **Overclaiming a moat** the property does not have.
6. **Re-deciding portfolio priority here** - that is `portfolio-pm`'s job.

---

## Related Skills

- `go-to-market-strategy` - GTM motion, price ladder, launch execution
- `portfolio-pm` - cross-property prioritization and cross-promo (owns portfolio orchestration)
- `marketing-strategy` - positioning and competitive intelligence
- `product-market-fit-analysis` - PMF assessment
- `conversion-rate-optimization` - page/form CRO
- `seo-and-aeo-strategy` - SEO/AEO audits
- `ab-test-setup` - experiment design
- `customer-success-and-retention` - retention execution
