---
name: marketing-strategy
description: Positioning and product-marketing execution across Ariel's portfolio. Covers ICP definition, April Dunford positioning, messaging hierarchy, competitive battlecards, sales enablement, market sizing (TAM/SAM/SOM), PMF spectrum mapping, PR/FAQ working-backwards docs, and drafting a per-property brief. For the core GTM motion, price ladder, and launch execution, see go-to-market-strategy. For per-property growth loops and retention, see growth-strategy. Use when defining ICP, developing positioning, creating a messaging hierarchy, building competitive battlecards, planning sales enablement, sizing a market, mapping PMF, writing a PR/FAQ, or drafting a property brief.
---

# Marketing Strategy

## Workspace context

Read the brief before any property-specific work, and say which brief you read in an early "Workspace context" line (operating rule 4): `briefs/_portfolio.md` first, then the matching `briefs/modelstack.md`, `briefs/agor-consulting.md`, `briefs/ios-apps.md`, or `briefs/scored-tools.md`; then `strategy/brand.md` for cross-property voice and `about/me.md` for Ariel's personal voice. Read `data/REMAP.md` before reaching for any external tool. Save drafts to `content/<platform>/drafts/YYYY-MM-DD_topic-slug.md`. Outward actions are draft-gated: nothing sends, posts, or spends without Ariel's explicit go.

## Scope: what this skill owns (and what it does not)

**For the core GTM motion and price-ladder strategy, see `go-to-market-strategy`.** That skill owns motion selection across the real ladder ($29-$197 modelstack templates and bundles to $999, the $299 Agor AI Ads audit, the $1,000 AI Operations Audit, $15K-$250K agor.me consulting, the $0.99-$4.99 iOS apps), channel sequencing, and launch execution.

This skill owns the layer beneath a launch: **positioning execution and campaign-level strategy.** That is, how a property is defined against its alternatives, the message hierarchy that carries it, the competitive intelligence behind it, the sales-enablement assets a human-closed engagement needs, and the per-property brief itself. It does not choose the GTM motion (that is `go-to-market-strategy`), design growth loops or retention (that is `growth-strategy`), or decide which property to work on (that is `portfolio-pm`).

## Operating Contract

This skill is self-contained for its frontmatter scope: use its local instructions, references, scripts, and assets as the playbook; ask only for missing task-specific inputs; hand off to adjacent skills instead of expanding scope; and return an actionable artifact, decision, plan, draft, or diagnostic.

---

## Product Strategy Stack

```
VISION      - Where are we going? (3-10 years)
STRATEGY    - How will we win? (1-3 years)
ROADMAP     - What are we building? (Quarters)
EXECUTION   - How are we building? (Sprints)
```

**Philosophy:** Start with the customer problem, not the solution. Make trade-offs explicit; strategy is choosing what NOT to do. Systems over tactics.

---

## Product-Market Fit Spectrum

```
Level 0: Problem Fit    -> Real problem worth solving
Level 1: Solution Fit   -> Your solution addresses the problem
Level 2: PMF            -> Customers pull the product from you
Level 3: Scale Fit      -> Repeatable growth engine working
Level 4: Moat Fit       -> Defensible competitive advantage established
```

**PMF validation signals:** repeat purchases or bookings from ICP customers, short time-to-value, strong word of mouth, low refund/churn. For a full PMF assessment, hand off to `product-market-fit-analysis`.

---

## ICP and Segmentation

Firmographics differ sharply by property, so pull the real ICP from the brief rather than assuming a SaaS default:

- **modelstack.digital:** founders, operators, consultants, and finance/deal professionals who need a working template now, not a $2K-$10K engagement. IB/M&A and VC categories skew to deal professionals; SOPs and AI-workflow guides to small-business operators; the Consulting Templates category to independent consultants.
- **agor.me consulting:** mid-market and larger operators evaluating AI automation, chatbots, analytics, or a full AI-systems build, not hobbyist or pre-revenue buyers.
- **Agor AI Ads:** ranked segments are B2B SaaS/tools (default beachhead), considered-purchase DTC, local/professional services, then agencies as a later white-label tier.
- **iOS apps:** consumers, discovered in the App Store; not a firmographic ICP at all.

**Reusable buyer-persona lens (for the human-closed rungs):**
- **Economic buyer** (owner/VP): cares about ROI and outcomes -> lead with business results and proof.
- **Technical buyer** (engineer/operator): cares about integration and reliability -> architecture, security, uptime.
- **Champion** (manager): cares about ease and quick wins -> UX, fast time-to-value.

**ICP scoring:** grade fit A (perfect) to D (poor). Focus effort on A/B, disqualify D. Track the grade on the person or company record in GBrain (`mcp__gbrain__put_page`, `add_tag`), the CRM of record for this portfolio, not a SaaS CRM.

---

## Market Opportunity (TAM/SAM/SOM)

| Metric | What It Means | How to Calculate |
|--------|---------------|------------------|
| **TAM** | Everyone who could theoretically buy | Target customers x avg contract value |
| **SAM** | Those you can reach and serve | TAM x geographic/product constraints |
| **SOM** | Realistic near-term share | SAM x 1-5% penetration |

Validate top-down with bottom-up (realistic customers x conversion rate x price). A gap over 3x means revisit assumptions. For a one-operator portfolio, keep SOM honest: reach is bounded by the content engine's output, not a sales team's headcount.

---

## Positioning (April Dunford Method)

1. **Competitive alternatives** - what would the customer do without you? (competitors, spreadsheets, DIY, a $2K-$10K consultant, status quo)
2. **Unique attributes** - what do you have that alternatives don't?
3. **Value mapping** - `Attribute -> Value -> Outcome` (e.g., AI automation -> eliminates manual entry -> save 10 hrs/week)
4. **Best-fit customers** - who values this most? Use real win/loss signals.
5. **Market category** - head-to-head, niche ("templates built by operators, for operators"), or new category.
6. **Trend layer** - the macro trend that makes now the right time (for the AI rungs: AI assistants are becoming the front page).

**Value proposition:** `[Product] helps [Target] [Achieve Goal] by [Unique Approach]`

**Positioning template:**
```
For [target customer]
Who [need/problem]
[Product] is a [category]
That [key benefit]
Unlike [alternatives]
Our product [unique differentiator]
```

**Messaging hierarchy:** one-liner -> 3-5 key benefits -> feature/outcome pairs -> proof points (real named entities, real cited sources, per the Receipts-and-Sources rule; no anonymized stand-ins).

---

## Working Backwards (PR/FAQ)

Write an internal press release BEFORE building. If you can't write a compelling one, you don't have a compelling offer.

**Press release (~1 page):** headline (product + one-sentence benefit) -> opening (who the customer is, what problem is solved) -> problem paragraph -> solution paragraph -> a customer quote -> getting started + CTA.

**FAQ:** external = questions real customers would ask; internal = the hard questions a skeptic would ask.

**Anti-patterns:** writing the PR after building, solution-first thinking, "everyone could use this," skipping the hard internal FAQ, marketing hyperbole instead of specific measurable claims (this violates the portfolio no-fluff rule).

---

## Competitive Intelligence

**Tiers:** direct competitors | indirect/adjacent | status quo (spreadsheets, DIY, do nothing, hire a consultant).

**Intel sources that exist in this stack:** product trials, competitor website monitoring (WebFetch/browser), customer replies and support threads, public reviews and comparison sites, competitor job postings, industry reports via WebSearch. There is no call-recording tool (Gong/Chorus-class) in the stack; when call-based intel is needed, use the meeting notes captured through the `meeting-to-proposal` flow, or flag the gap, rather than implying a recording tool exists.

**Battlecard template (one per competitor):**
```
Competitor | Strengths | Weaknesses | Our advantages
When we win | When we lose
Talk tracks for top 3 objections
Proof points (real case studies, review comparisons)
```
Keep battlecards as files in the repo (or a GBrain page); there is no Notion/Confluence distribution layer here.

**Win/Loss process:** review within about 2 weeks of a close. Record the reason, competitor, price factor, and any product gap on the person/company record in GBrain (`put_page`, `add_timeline_entry`), not a SaaS CRM. Summarize the pattern monthly.

**Competitive moat types:**

| Moat | Description | Examples |
|------|-------------|----------|
| **Network Effects** | Product improves as more users join | Slack, LinkedIn |
| **Switching Costs** | Painful to leave | Salesforce, Workday |
| **Data Advantages** | Proprietary data improves product | Google, Waze |
| **Scale Economies** | Cost advantages at scale | AWS, Stripe |
| **Brand** | Trust and recognition | Apple, Notion |

For Ariel's portfolio the realistic moats are **brand/authority** (the daily-content engine and the AI-native-operator positioning) and **switching costs** on the consulting side (embedded systems). Do not claim network-effect or data moats that the properties do not have.

---

## Sales Enablement (for the human-closed rungs)

The consulting engagements ($1,000 audit through $250K transformation) are human-closed and off-platform, so they are the rungs that need enablement assets. Templates and apps are self-serve and do not.

**Core assets:** a scoped proposal (route to `meeting-to-proposal`), a one-pager per service line, battlecards, a discovery-to-next-step call structure, follow-up email drafts (Gmail drafts, never auto-sent), and an ROI framing.

**Cadence for a one-operator practice:** refresh positioning and battlecards when the market shifts (new AI-answer surface goes live, a competitor repositions), not on a fixed corporate calendar. Keep the pre-call research brief (already automated to `ariel@agor.me`) as the primary just-in-time enablement artifact.

---

## Product Marketing / Property Brief

The per-property brief is this skill's core artifact. When a property has no brief yet, draft `briefs/<property>.md` from conversation context, then read it on every later invocation. Capture:

1. **Offer and pricing** - exact prices and SKUs, checked against `PORTFOLIO_PROPERTIES.md`.
2. **ICP** - who it is for, in that property's real terms.
3. **Positioning one-liner.**
4. **Channels of record** - support address, blog, newsletter, social.
5. **Payment rail and support** - the exact rail (Stripe Payment Link, off-platform, Apple IAP) and how support is handled.
6. **Analytics sources** - the real tools (Plausible, GA4, Stripe MCP, GSC, App Store Connect).
7. **Voice notes** - typography and register, on top of the portfolio house style.
8. **Current goals and hard rules.**

Study the property (site, product catalog, existing copy), draft V1, then ask Ariel: "What needs correcting? What's missing?" The existing briefs are the template.

---

## PMM KPIs (adapt per property)

| KPI | Where it applies | Signal |
|-----|------------------|--------|
| Win rate on scoped proposals | consulting | Proposals sent vs. engagements won |
| Average engagement size | consulting | Trend over time |
| Template attach / bundle rate | modelstack | Bundle vs. single-SKU mix |
| Audit-to-pilot conversion | Agor AI Ads | $299 audits that become pilots |
| Listing conversion / rating | iOS apps | Store impression-to-install, review score |

Report against the property's own brief, not a generic SaaS scorecard.

---

## Key Strategic Questions

1. **Horizontal vs vertical?** - serve many buyer types or dominate one deeply?
2. **High-touch vs self-service?** - already answered per rung; keep the two motions distinct.
3. **Niche vs broad?** - start narrow, expand.
4. **Premium vs budget?** - rarely both in the same offer.
5. **First mover vs fast follower?** - for the AI rungs, being early on a live AI-answer surface is the edge.

---

## Anti-Patterns

- Vision without strategy - an inspiring destination with no map.
- Strategy without trade-offs - if everything is a priority, nothing is.
- TAM theater - unrealistic market sizes.
- Feature-parity obsession - chasing competitors instead of customers.
- Overclaiming a moat the property does not have.
- Marketing fluff - vague, rounded, or softened claims instead of exact, checkable ones.

---

## Related Skills

- `go-to-market-strategy` - GTM motion, price ladder, launch execution (the layer above this one)
- `growth-strategy` - growth loops and retention
- `product-market-fit-analysis` - full PMF assessment
- `pricing-strategy` - pricing decisions
- `competitor-analysis` - deeper competitive research
- `meeting-to-proposal` - scoped consulting proposals
