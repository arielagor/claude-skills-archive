---
name: go-to-market-strategy
description: |
  Go-to-market strategy and launch execution for Ariel's own portfolio. Reasons across the real price ladder: $29-$197 modelstack templates (bundles to $999), the $299 Agor AI Ads visibility audit, the $1,000 AI Operations Audit entry, $15K-$250K agor.me consulting engagements, and the $0.99-$4.99 iOS consumer apps as a separate lower-tier motion. Use when planning a launch, feature announcement, market entry, price-ladder or cross-sell sequencing, or release strategy. Activates for: go to market, GTM, product launch, launch strategy, launch plan, launch execution, launch marketing, GTM playbook, launch readiness, beta launch, early access, waitlist, Product Hunt, feature release, announcement, how do I launch this, launch checklist, market entry, GTM motion, price ladder, cross-sell, offer ladder, launch marketing pack, template store launch, consulting offer launch, app launch.
---

# Go-to-Market Strategy

## Workspace context

Read the brief before any property-specific work, and say which brief you read in an early "Workspace context" line of your output (operating rule 4). Order of reading:

1. `briefs/_portfolio.md` - the cross-property index, shared Stripe rule, and customer-triage rule.
2. The matching property brief: `briefs/modelstack.md`, `briefs/agor-consulting.md` (includes the Agor AI Ads section), `briefs/ios-apps.md`, or `briefs/scored-tools.md`.
3. `strategy/brand.md` for cross-property voice and positioning themes; `about/me.md` for Ariel's personal voice.
4. `data/REMAP.md` and `data/connections.md` before reaching for any external tool, so you use what actually exists in the stack (GBrain, Plausible, Stripe MCP read tools, Google Search Console, Dub.co, Gmail drafts, the social-announcer subagent) and not an upstream SaaS.

Save drafts to `content/<platform>/drafts/YYYY-MM-DD_topic-slug.md`. Every outward action is draft-gated: nothing sends, posts, spends, or deploys without Ariel's explicit, in-the-moment go.

## Operating Contract

This skill is self-contained for its frontmatter scope: use its local instructions, references, scripts, and assets as the playbook; ask only for missing task-specific inputs; hand off to adjacent skills instead of expanding scope; and return an actionable artifact, decision, plan, draft, or diagnostic.

For ICP, positioning, and messaging, hand off to `marketing-strategy`. For per-property growth-loop mechanics and retention, hand off to `growth-strategy`. For which property to work on next, that is `portfolio-pm`'s call, not this skill's.

---

## Core Philosophy

**A launch is a campaign, not an event.** Build momentum before, peak at launch, sustain after. Ariel runs a multi-line, one-operator portfolio, so a "launch" is usually a new template, a new consulting on-ramp, a new app version, or a repositioning, not a company-defining single moment. The engine that carries all of them is the daily-content-plus-authority flywheel already running on modelstack.digital and agor.me, not a one-day spike.

---

## The Portfolio Price Ladder

Ariel's portfolio is not a single freemium-to-enterprise SaaS funnel. It is a ladder of distinct offers, some self-serve, some human-closed, plus a separate consumer-app motion that does not share the B2B audience. Reason about GTM per rung, and about the handoffs between rungs.

| Rung | Offer | Price | Motion | Close / rail | Brief |
|------|-------|-------|--------|--------------|-------|
| Free wedge | Unit Economics Calculator lead magnet | $0 | Email capture into modelstack list | Netlify Forms | modelstack |
| Self-serve entry | modelstack templates (35 SKUs, 6 bundles) | $29-$197, bundles $119-$999 | Product-led, content + SEO flywheel | Stripe Payment Link | modelstack |
| Productized wedge | Agor AI Ads Visibility Audit | $299 | Productized on-ramp, partly self-serve | Stripe Checkout | agor-consulting |
| Productized consulting entry | AI Operations Audit | $1,000 | Productized diagnostic, human-delivered | Off-platform, manual invoice | agor-consulting |
| High-ticket | agor.me consulting engagements | $15K focused automation, $50K-$250K+ transformation | Human-closed, boutique, inbound-led | Off-platform, chat/voice widget to a call | agor-consulting |
| Consumer (separate motion) | iOS apps: gifloop, MVAT Focus, MVAT Mirror, Coquí Chorus | $0.99-$4.99, plus small IAP subscription tiers | App Store discovery + ASO | Apple IAP (refunds via Apple) | ios-apps |

`scored.tools` sits alongside as a pre-revenue, content-and-affiliate top-of-funnel property (channel of record `hello@scored.tools`); treat it as authority and discovery surface that can feed the other rungs, not as a paid rung yet.

**Ladder rules:**

- **The two live engines are modelstack (self-serve) and agor.me (human-closed).** Do not over-index launch effort on the iOS apps or scored.tools at the expense of these two without Ariel's direction.
- **The iOS apps are a separate ladder, not the bottom of the B2B one.** Different audience (consumers), different rail (Apple IAP), different discovery (App Store + ASO). Do not force a cross-sell from a Pomodoro-app user to a $15K consulting engagement.
- **Every rung's price is exact and checkable against its brief.** Quote $299 for the AI Ads audit and $1,000 for the AI Operations Audit even where site copy lags; flag the lag to Ariel rather than rounding.

---

## GTM Motion by Rung

Replace the generic "PLG under $5K, sales-led over $25K" table with the motion each real rung actually uses.

| Rung | Motion | Primary lever | What moves the needle |
|------|--------|---------------|-----------------------|
| modelstack templates | Product-led, content-fed self-serve | Organic discovery to instant checkout | Daily blog + SEO flywheel, bundle upsell, free lead magnet to email nurture |
| Agor AI Ads audit ($299) | Productized wedge, partly self-serve | A cheap, concrete first result | Positioning around what is LIVE on AI-answer surfaces, audit-fee-credits-toward-pilot offer |
| AI Operations Audit ($1,000) | Productized consulting entry | A paid diagnostic that de-risks the big engagement | Turning audit findings into a scoped $15K+ proposal |
| agor.me consulting ($15K-$250K+) | Authority-led inbound, human-closed | Trust built by a real conversation | Chat/voice widget bookings, pre-call research brief, content authority, referrals |
| iOS apps | App Store discovery + ASO | Store ranking and ratings | Listing optimization, category ranking, review velocity, subscription retention |

**Decision shortcut:**

```
Digital good, buyer can self-serve now?   -> product-led self-serve (modelstack, AI Ads audit, iOS)
Outcome needs a human to scope/deliver?    -> authority-led inbound, close off-platform (consulting)
Consumer, discovered in a store?           -> ASO-led (iOS apps), separate motion
```

There is no enterprise SDR/outbound-sales machine here. The consulting engine is inbound-first (the chat/voice widget on agor.me), supplemented by the twice-weekly prospect-research digest for qualified outbound (score >= 60 on intent/funding/ICP-fit/reachability). Draft outbound, never send it autonomously.

---

## Cross-Sell and Ladder Handoffs

The rungs feed each other when the audience overlaps:

- **modelstack -> consulting.** A buyer of the M&A, VC, or Consulting-Templates categories is a deal or services professional who may later need done-for-you work. The template is the low-commitment first touch; the AI Operations Audit is the natural next rung. Surface this in content, not as a hard-sell in the download email.
- **Agor AI Ads audit -> pilot -> managed.** The $299 audit is the on-ramp; the audit fee credits toward a pilot; the pilot, once attribution is clean, becomes a managed retainer. This is the clearest built-in ladder in the portfolio.
- **AI Operations Audit -> full engagement.** The $1,000 diagnostic is designed to expand into a $15K-$250K engagement when the findings justify it.
- **iOS apps stay in their lane.** Cross-promote between the apps (a gifloop user to Coquí Chorus is plausible); do not bolt consulting or templates onto a consumer app flow.

Keep the AI Ads scope boundary: this vault markets Agor AI Ads as Ariel's own offer. Running a client's GEO/AEO campaign belongs to the `/ai-ads` skill, not here.

---

## Per-Property Launch Playbooks

### modelstack.digital (new template or bundle)

1. Confirm product-map consistency first (a new SKU must land in `index.html`, `product.html`, `blog.html`, the Stripe webhook product map, `thank-you.html`'s name lookup, the blog generator topics list, `products/`, and a real Stripe product/price/payment link). A launch on a broken purchase or download flow is worse than no launch.
2. Announce through the existing engine: a blog post (respect the one-post-per-UTC-date invariant), the weekly newsletter digest, Substack re-import, and social via the social-announcer subagent (X through browser automation, Facebook, LinkedIn; Instagram is disabled).
3. Track with Plausible (checkout-click and email-signup events are already wired) and confirm real sales in Stripe via the MCP read tools. Never assume a number.

### agor.me consulting and the AI Operations Audit

1. This closes off-platform. Never draft or imply a Stripe checkout link for the consulting engagement itself.
2. The launch surface is authority content: a blog post with Leo-voiced audio, the weekly episode pipeline (Wed/Sat), and LinkedIn in the "Plain-Strange" register. The call to action is a booking through the chat/voice widget, not a buy button.
3. Measure inbound: bookings to `ariel@agor.me`, and GA4 (property 540566537) for site traffic. Flag, do not assume, a Plausible dashboard for agor.me until confirmed.

### Agor AI Ads (the $299 audit and up)

1. Market only around what is actually LIVE on a given AI-answer surface; label announced-but-not-shipped ad formats as such.
2. Lead with the productized audit as the concrete, low-risk first result. Pilot and Managed are the follow-on rungs.
3. Carry the honesty and public-information-only guardrails from the brief. Human approves every dollar of spend.

### iOS apps

1. This is App Store discovery, not a web launch. Route listing metadata work to `app-store-optimization` and the asc-listing-manager pattern.
2. Growth is store ranking, review velocity, and subscription retention (MVAT Focus, MVAT Mirror). Refunds go through Apple.
3. Cross-promote within the app family only.

### Product Hunt (optional, for modelstack or an app)

Product Hunt can amplify a modelstack bundle or an app milestone. Defer the detailed mechanics to the `product-hunt-launch`, `ph-community-outreach`, and `ph-content-recycling` skills rather than duplicating them here. Treat launch day as an all-day event, respond to every comment, and capture traffic into the modelstack email list or an app install.

---

## Launch Timeline (adapt per rung)

A lean sequence that fits a one-operator cadence:

- **Before:** finalize the message and price against the brief, produce the content set (blog, social, newsletter, listing copy), set the success metric, and confirm the purchase/download/booking path actually works end to end.
- **Launch:** publish the blog post and any landing change, send the announcement (Gmail draft, then Ariel sends), post through the social-announcer subagent, and monitor.
- **After:** share proof (first sales, first bookings, first reviews), fold the announcement into the roundup, and plan the next launch moment. A launch that goes silent the next day wastes the built momentum.

For high-ticket consulting the "timeline" is content cadence plus inbound response, not a dated countdown.

---

## Channel Strategy (Owned, Rented, Borrowed)

**Owned (highest return, build first):** the modelstack email list and weekly newsletter, both blogs (modelstack + agor.me), the two Substack publications, and the agor.me chat/voice widget as the consulting capture point.

**Rented (speed, not stability):** X (via browser automation, the API is spend-capped), LinkedIn (4 dev apps), Facebook, YouTube. Use to drive traffic into owned surfaces. Track links with Dub.co.

**Borrowed (shortcut to audiences):** podcast/interview appearances, guest posts, Product Hunt, and co-marketing. The weekly NotebookLM episode pipeline is a borrowed-to-owned bridge.

Strategy: use rented and borrowed reach to capture into owned (email list, bookings), then nurture there.

---

## Metrics and Success Criteria (define before launch)

Use the tools that exist, per `data/REMAP.md`:

- **Awareness:** Plausible pageviews and referrers (modelstack, live), GA4 for agor.me, App Store impressions for apps.
- **Acquisition:** modelstack checkout-click and signup events (Plausible), consulting bookings to `ariel@agor.me`, audit checkouts (Stripe MCP read tools), app installs.
- **Revenue (source of truth):** Stripe MCP read tools on the shared account (`acct_1T09QrAOqOwPWk86`), always disambiguating the product by signal phrase; App Store Connect for IAP.
- **Organic:** Google Search Console (indexation, ranking, coverage) and the weekly Search-Console pull feeding the blog keyword queue. No paid SEO SaaS exists; do not fabricate a Domain Authority or Ahrefs-style score.

There is no session-replay or heatmap tool. Keep funnel-drop-off analysis qualitative and flag it as a gap rather than implying a tool provides it.

---

## Launch Marketing Pack

For any major launch, produce these 7 deliverables:

1. **Context snapshot** - what is launching, which rung, who it is for, goal, date, constraints.
2. **Launch Marketing Brief** - message, hook, proof points, CTA, audience segment.
3. **Launch Motion + Channel Plan** - which rung's motion, sequencing, channel table, asset mapping.
4. **Outreach / PR Kit** - target outlets or partners, pitch and follow-up drafts (Gmail drafts, never sent).
5. **Asset + Readiness Kit** - asset checklist, landing or listing outline, FAQ, objections, and the purchase/booking-path check.
6. **Measurement + Experiment Plan** - the metric per the tools above, and what to double down on.
7. **Risks / open questions / next steps.**

For launch marketing templates: see `references/TEMPLATES.md`
For the full launch workflow: see `references/WORKFLOW.md`
For pre-launch and launch-day checklists: see `references/CHECKLISTS.md`
For deeper guidance: see `references/GUIDE.md`

---

## GTM Execution Checklist

### Pre-Launch
- [ ] Brief read; message and exact price confirmed against it
- [ ] Purchase / download / booking path verified end to end (product-map consistency for modelstack)
- [ ] Owned channels ready (email list, blog, newsletter, widget)
- [ ] 1-2 rented channels queued via the social-announcer subagent
- [ ] Launch assets drafted to `content/<platform>/drafts/`
- [ ] Metric defined and its tool wired (Plausible / Stripe MCP / GSC / App Store Connect)

### Launch Day
- [ ] Announcement email drafted (Ariel sends)
- [ ] Blog post published (one per UTC date max)
- [ ] Social posts queued through the subagent
- [ ] Substack re-import flagged as follow-up
- [ ] Ready to respond

### Post-Launch
- [ ] Proof shared (sales, bookings, reviews)
- [ ] Feedback collected and triaged (payment inquiries routed to Ariel, never a fabricated refund/download)
- [ ] Next launch moment planned

---

## Common GTM Mistakes

- **Treating the portfolio as one SaaS funnel** - it is a ladder of distinct offers plus a separate consumer motion.
- **Forcing a cross-sell across audiences** - a consumer app user is not a $15K consulting lead.
- **Launching on a broken flow** - verify checkout, download, and booking paths first.
- **One-day launch, then silence** - the content engine should sustain the moment.
- **Everything everywhere** - pick the 2-3 channels that fit the rung.
- **Fabricated numbers or unsupported claims** - Stripe is the revenue source of truth; ground every claim in the brief.
- **Autonomous outward action** - every send, post, and spend waits for Ariel's go.

---

## Related Skills

- `marketing-strategy` - ICP, positioning (April Dunford), messaging, competitive intelligence, sales enablement
- `growth-strategy` - per-property growth loops and retention
- `pricing-strategy` - pricing and ladder economics
- `product-hunt-launch`, `ph-community-outreach`, `ph-content-recycling` - Product Hunt mechanics
- `app-store-optimization` - iOS listing and ranking
- `portfolio-pm` - which property to prioritize (owns cross-project sequencing)
- `sales-and-revenue-operations` - revenue operations and ICP
