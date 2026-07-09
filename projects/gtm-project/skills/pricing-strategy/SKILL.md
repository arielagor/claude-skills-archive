---
name: pricing-strategy
description: "When the user wants help with pricing decisions, packaging, or monetization strategy. Use when the user mentions 'pricing,' 'pricing model,' 'pricing tiers,' 'freemium,' 'free trial,' 'packaging,' 'price increase,' 'value metric,' 'Van Westendorp,' 'willingness to pay,' 'monetization,' 'pricing strategy,' 'pricing experiments,' 'price anchoring,' 'enterprise pricing,' 'GTM pricing,' 'price setting,' 'value-based pricing,' 'revenue optimization,' or 'pricing psychology.' This skill covers pricing research, tier structure, packaging strategy, discount frameworks, upsell mechanics, and pricing experiments."
---

# Pricing Strategy

## When this fires

Any pricing, packaging, or monetization decision for a property in `PORTFOLIO_PROPERTIES.md`. Upstream framing assumes a venture-funded B2B SaaS with recurring MRR; Ariel's portfolio is mostly ONE-TIME pricing (digital templates, App Store IAP Pro unlocks, consumable credit packs) plus a productized-service wedge that scales to bespoke consulting, with only two true subscriptions (MVAT Focus web Pro and the pre-launch Agor Agents). Apply the SaaS and MRR frameworks below only where a subscription actually exists; use one-time-purchase and productized-service framing everywhere else. Every worked example in this skill is a real portfolio price point, not a hypothetical.

## Workspace context to read first

- `briefs/<property>.md` for the property being priced: `briefs/modelstack.md` (template store), `briefs/agor-consulting.md` (consulting plus the Agor AI Ads section), `briefs/ios-apps.md` (four apps), `briefs/scored-tools.md` (pre-revenue affiliate).
- `strategy/brand.md` for the "no marketing fluff, prices exact and checkable" house rule, and `about/me.md` for voice on any pricing-page or price-change copy drafted here.
- `data/REMAP.md`: Stripe is the source of truth for actual revenue via the Stripe MCP read tools (`mcp__stripe__stripe_api_read`, `fetch_stripe_resources`, `search_stripe_resources`), never a dashboard CSV export; ONE shared account (`acct_1T09QrAOqOwPWk86`) serves every product, so disambiguate by signal phrase. Analytics of record is Plausible (modelstack) and GA4 (agor.me), not the GA4/Mixpanel/Amplitude stack upstream assumes. There is no rich pricing-experiment or funnel platform in this stack, so keep A/B claims qualitative.

## Portfolio price ladder (the real worked examples)

Ground every framework below in these actual prices. Never round, soften, or invent a figure; verify against the property's brief and Stripe.

| Property / SKU | Model | Real price points |
|---|---|---|
| modelstack templates | One-time digital download | 35 templates $29 to $197; 6 bundles $119 to $999 (Complete Collection $999, listed worth $2,267); free lead magnet (Unit Economics Calculator) |
| MVAT Focus | Freemium app, two paid rails | Free 25-min cap; App Store IAP lifetime unlock $0.99; Stripe web Pro $4.99/mo or $39.99/yr |
| MVAT Mirror | Consumable IAP credit packs | $1.99 Starter, $4.99 Full History |
| gifloop | Freemium app, one-time unlock | Free tier (reinstall-proof export trial counter); Pro unlock ~$4.99 (Apple IAP) |
| Coquí Chorus (co-kee) | Freemium app, one-time unlock | Free tier; Pro unlock ~$4.99 (Apple IAP) covering all species, mixer, presets |
| Agor AI Ads | Productized service ladder | AI Visibility Audit $299 fixed fee (credits toward Pilot); Pilot (small agreed budget); Managed (retainer, optional capped outcome-share) |
| agor.me consulting | Productized wedge to bespoke | $1,000 AI Operations Audit entry; $15K focused automation projects; $50K to $250K+ transformations |
| scored.tools | Affiliate (no owned price) | Pre-revenue; ElevenLabs affiliate live (22% recurring, lifetime, 60-day cookie) |

The portfolio runs three pricing archetypes at once, and the right framework depends on which one a task touches:
1. **One-time digital** (modelstack, three of the apps' Pro unlocks): value-based against the do-it-yourself or hire-a-pro alternative; no churn, so the metrics are units, refund rate, and average order value.
2. **Freemium with a paid unlock or credit pack** (MVAT Focus, MVAT Mirror, gifloop, Coquí Chorus): a free tier removes the barrier, a charm-priced unlock or consumable converts at the moment of value.
3. **Productized service scaling to bespoke** (Agor AI Ads, agor.me): a fixed-fee wedge (a $299 or $1,000 audit) de-risks the buyer and credits toward a larger, value-priced engagement.

## Before Starting

Identify the property and its archetype from the ladder above, then gather: the "against" alternative the buyer would otherwise use, the current price and where it sits on the ladder, actual units/revenue from Stripe (or App Store Connect for IAP), and the goal (more conversions vs higher average order value vs opening the high-touch ladder).

---

## Pricing Fundamentals

**Three axes**: Packaging (what's in each tier) + Value metric (what you charge for) + Price point (the amount).

**Core principle**: 1% improvement in pricing = 11% improvement in profit (McKinsey). Price to value, not cost.

**Value-based pricing (modelstack worked example)**: modelstack's own copy states the value anchor out loud, "Consultants charge $2K to $10K... sometimes you just need the template." The template is priced against that alternative, not against its near-zero marginal cost to serve.

```
Perceived value (an M&A model built by an analyst or consultant): $2,000 to $10,000
Next best alternative (hire it out, or build from scratch):        $2,000+   <- the anchor
modelstack price (M&A Financial Model & Valuation):                $197      <- capture a fraction, still the top of the range
Cost to serve (a signed download link, fully automated):           ~$0       <- a floor, never the basis
```

The apps use the same logic at consumer scale: a ~$4.99 gifloop or Coquí Chorus Pro unlock is priced against the annoyance of a web tool or generic white noise, not against per-export compute.

**Value calculation template (for the consulting and Agor AI Ads wedges)**:
```
Time saved by the automation:   [hours/week x loaded hourly rate x 52]
Revenue unlocked or recovered:  [deals or answer-visibility gained x value]
Cost or error avoided:          [manual-process cost removed per year]
Total annual value:             $____

Wedge price: $1,000 (agor.me AI Operations Audit) or $299 (Agor AI Ads Visibility Audit),
a fixed-fee diagnostic that credits toward the value-priced engagement ($15K to $250K, or the Pilot then Managed ladder).
```

---

## Pricing Models

| Model | Pros | Cons |
|-------|------|------|
| **Flat Rate** ($99/mo, unlimited) | Simple to sell | Leaves money on table |
| **Tiered** (Starter/Pro/Business) | Captures segments, clear upsell | Anchor pricing matters |
| **Usage-Based** ($0.01/call) | Perfect value alignment, low barrier | Unpredictable revenue |
| **Hybrid** ($49/mo + $0.50/extra user) | Predictable base + scales | More complex to explain |

---

## Value Metrics

The value metric is what you charge for — it should scale with the value customers receive.

| Metric | Best For | Examples |
|--------|----------|---------|
| Per user/seat | Collaboration tools | Slack, Notion |
| Per usage/consumption | Variable workloads | AWS, Twilio |
| Per contact/record | CRM, email tools | Mailchimp, HubSpot |
| Per transaction | Payments, marketplaces | Stripe, Shopify |
| Flat fee | Simple, bounded products | Basecamp |
| Revenue share | High-value outcome tools | Affiliate platforms |

**Choosing your metric**: Analyze which usage patterns predict retention and expansion in your highest-LTV customers. If "more of X = more value," X is your metric.

---

## Pricing Research Methods

### Van Westendorp Price Sensitivity Meter

Ask 100–300 respondents four questions:
1. Too expensive — would not buy
2. Too cheap — would question quality
3. Expensive but would consider
4. Bargain / great value

**Key intersections**:
- PMC (Point of Marginal Cheapness): "Too cheap" × "Expensive" → lower bound
- PME (Point of Marginal Expensiveness): "Too expensive" × "Cheap" → upper bound
- OPP (Optimal Price Point): "Too cheap" × "Too expensive" → best price
- IDP (Indifference Price Point): "Expensive" × "Cheap" → acceptable midpoint

**Acceptable range**: PMC → PME. **Optimal zone**: OPP → IDP.

### MaxDiff / Feature Importance

Show sets of 4–5 features; ask "most important" and "least important." Results rank features by utility score:

| Utility | Packaging Decision |
|---------|-------------------|
| Top 20% | Include in all tiers (table stakes) |
| 20–50% | Use to differentiate tiers |
| 50–80% | Higher tiers only |
| Bottom 20% | Cut or premium add-on |

### Willingness to Pay

- **Gabor-Granger**: Show price → "Would you buy at $X?" (Yes/No). Vary price across respondents to build demand curve.
- **Conjoint analysis**: Show bundles at different prices; respondents choose preferred option.

---

## Tier Structure

**The Rule of 3**: a good-better-best ladder still applies, but read it against the portfolio's real ladders, not a generic three-tier SaaS grid.

**Anchor pricing** works portfolio-wide: modelstack's Complete Collection is listed at $999 "worth $2,267 individually," which anchors every smaller bundle and single template as the reasonable choice. MVAT Focus anchors its $39.99/yr against the $4.99/mo (pay yearly, get roughly four months free).

```
modelstack good-better-best:  single template $29 to $197  ->  category bundle $119 to $449  ->  Complete Collection $999 (anchor)
MVAT Focus freemium ladder:   free 25-min cap  ->  $0.99 lifetime IAP  ->  $4.99/mo or $39.99/yr web Pro (longer sessions, cloud sync, themes)
Agor AI Ads service ladder:   Audit $299  ->  Pilot (small agreed budget)  ->  Managed retainer
agor.me consulting ladder:    Audit $1,000  ->  focused project $15K  ->  transformation $50K to $250K+
```

### Good-Better-Best Framework

| Tier | Purpose | Price | Target |
|------|---------|-------|--------|
| **Good** (Starter) | Remove barriers to entry | Low, accessible | Small teams, trial converts |
| **Better** (Pro) | Where most customers land | Anchor price | Growing teams |
| **Best** (Business) | Capture high-value customers | 2–3× Better | Larger teams, power users |

### Feature Gating

**What to gate (real portfolio examples):**
- Scale or volume limits: MVAT Focus caps free sessions at 25 minutes (Pro unlocks up to 120); gifloop meters free exports with a reinstall-proof counter; MVAT Mirror meters analysis with consumable credit packs ($1.99 Starter, $4.99 Full History).
- Sophistication: MVAT Focus Pro adds cloud sync, themes, and sounds; Coquí Chorus Pro unlocks all species, the mixer, and presets.
- Access to the full set: modelstack sells each template as one complete download (no gating), so its lever is bundling, not feature-gating.

**Never gate**: core functionality (a free Pomodoro must still time a session), the on-device privacy guarantee (MVAT Mirror never trades that for a tier), or a customer's own data and export.

---

## Freemium vs. Free Trial

| | Freemium | Free Trial |
|-|----------|-----------|
| **Best for** | PLG, wide top of funnel | Sales-led, high-ACV |
| **Conversion** | 2–5% free → paid | 15–25% trial → paid |
| **Risk** | Free riders, support cost | Shorter window to prove value |
| **Use when** | Network effects, viral growth | Complex product needing onboarding |

**Which the portfolio actually uses:** the four iOS apps are all **freemium** (a free tier plus a one-time unlock or credit pack), not free-trial; conversion is a charm-priced IAP at the moment of value (an export, a longer session, a full personality read). The consulting side inverts this: the $299 and $1,000 audits are **paid** wedges, a low-risk productized entry that de-risks a $15K to $250K engagement and converts far better than a free consult would. modelstack has neither, it sells the finished template outright and uses a 7-day no-questions refund promise as the risk-reversal.

---

## Pricing Psychology

- **Anchor effect**: modelstack's $999 Complete Collection ("worth $2,267") anchors every cheaper option; show it first.
- **Charm pricing**: the portfolio lives on charm prices, $0.99, $1.99, $4.99, $39.99, $197, $299. Keep them.
- **Decoy pricing**: category bundles ($119 to $449) sit between single templates and the $999 Complete Collection so the mid bundle reads as the obvious buy.
- **Annual vs. monthly**: MVAT Focus offers $39.99/yr against $4.99/mo (about a third off, roughly four months free); surface it at signup and at renewal.
- **Fixed-fee wedge as de-risker**: the $299 and $1,000 audits remove the "what will this cost me" anxiety that blocks a cold $15K+ consulting ask.

---

## Pricing Experiments

**What to A/B test**: price points, bundle composition, unlock price, the audit wedge fee, which tier is badged "most popular."

**Reality check on tooling (`data/REMAP.md`)**: there is no rich pricing-experiment platform in this stack. Plausible (live on modelstack) tracks checkout-click and email-signup events; the Stripe MCP read tools are the source of truth for actual conversions and revenue on the shared account. At modelstack's traffic a clean 5% A/B read is unlikely, so treat price tests as sequential and qualitative (change one thing, watch Plausible and Stripe for a few weeks), not a powered experiment. Never fabricate a sample size or a lift number.

**Metrics to track**: for one-time products, units sold, refund rate, average order value; for the two subscriptions (MVAT Focus web Pro, Agor Agents), trial-to-paid, churn, and expansion.

**Price increases**: modelstack can raise as new templates and bundles add value; give existing buyers of a bundle the prior price. There are no recurring modelstack customers to grandfather, since purchases are one-time.

---

## Revenue Expansion

**Upsell triggers**:
- User hits usage limit → show upgrade prompt immediately
- User clicks locked feature → show upgrade at moment of value
- User active 30+ days on starter → "power user" upgrade nudge

**Add-ons** (use when a feature has standalone value not everyone needs):
```
Base plan: $99/mo
+ Extra users: $10/user/mo
+ Advanced analytics: $49/mo
+ White label: $99/mo
+ Priority support: $199/mo
```

---

## Pricing by Segment

| Segment | Price Point | Sales Motion | Decision Maker | Sales Cycle |
|---------|-------------|--------------|----------------|-------------|
| SMB | $29–99/mo | Self-serve | End user/team lead | Minutes–days |
| Mid-Market | $99–999/mo | Self-serve + light touch | Dept head | Days–weeks |
| Enterprise | $1,000+/mo | High-touch sales | VP/C-level | Weeks–months |

---

## Key Metrics

| Metric | Healthy Benchmark |
|--------|------------------|
| Trial → Paid conversion | >15% |
| MRR Growth (early stage) | >10%/month |
| Churn Rate | <5%/mo (SMB), <1%/mo (enterprise) |
| LTV:CAC | >3:1 |
| Payback Period | <12 months |
| Net Revenue Retention | >100% |

---

## Discount Framework

| Type | Trigger | Range |
|------|---------|-------|
| Volume | Commitment to scale | 10–30% |
| Term | Annual commitment | 15–25% (2 months free) |
| Competitive | Switching from competitor | 20–40% |
| Strategic | Reference customer / logo value | Up to 50% |

**Never discount when**: customer hasn't articulated value, no competitive pressure, early in negotiation, or deal doesn't meet minimum size.

**Alternatives to discounting**: extended payment terms, additional services/training, extended trial, success milestone unlocks, multi-year lock-in.

**Portfolio note**: modelstack's bundles ARE its volume discount (buy the category, save 20 to 40% vs single templates; the $999 Complete Collection against $2,267 individually). Beyond bundles, avoid ad-hoc discount codes on one-time templates, they erode the "prices are exact and checkable" house rule; prefer adding a template to a bundle over cutting a single price. On the consulting side the audit fee crediting toward the engagement is the built-in discount, so a further cut is rarely needed.

---

## Common Pricing Mistakes

- Pricing on cost, not value
- Too many tiers (analysis paralysis — stick to 3)
- Feature gates customers don't care about
- Gating core functionality (lock what makes your product worth using)
- Complex value metric (users shouldn't need a calculator for their bill)
- Ignoring price sensitivity by segment
- Never testing or iterating on pricing
- Burying the price page (hiding = distrust)

---

## Price Increase Playbook

1. **Quantify value** delivered since last price (new features, outcomes, benchmarks)
2. **Grandfather existing customers** for 3–6 months (or 12 months for best customers)
3. **Communicate early** (60-day notice minimum)
4. **Frame as investment** not cost increase — tie to ROI
5. **Offer annual lock-in** before increase date to capture cash
6. **Monitor churn** closely for 90 days post-increase

---

## Checklists

**Launching pricing**:
- [ ] Pick value metric; design 3 tiers with anchor prices (3–4× between tiers)
- [ ] Package features (60% / 85% / 100%); offer 14-day trial; set up billing

**Optimizing pricing**:
- [ ] Track conversion rates by tier; survey customers on pricing perception
- [ ] A/B test price points; add annual billing option; create in-app upgrade prompts
- [ ] Monitor NRR; review pricing every 6–12 months

---

*Deep-dive on pricing models, discount structures, and services pricing: see `references/pricing.md`*
