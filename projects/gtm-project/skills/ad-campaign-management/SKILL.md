---
name: ad-campaign-management
description: Use when creating, managing, or optimizing paid advertising campaigns across any platform. Covers ad copy generation, ad creative strategy, campaign management, and competitive intelligence. Triggers on: ad copy, ad creative, paid ads, paid advertising, Facebook ads, LinkedIn ads, Google ads, Meta ads, ad campaign, ad strategy, ad testing, competitive ads, competitor ads, ad library, ad analysis, ad creative generation, campaign management, ROAS, CPC, CTR. Use this skill whenever the user mentions ads, paid channels, ad campaigns, ad copy, ad performance, or wants to analyze competitor advertising.
---

# Ad Campaign Management

## Scope Boundary: Classic Paid Ads vs. AI-Answer-Surface Ads

This skill covers classic paid social and paid search: Meta (Facebook/Instagram), X/Twitter,
LinkedIn, Google Ads, TikTok, using the dev apps and ad accounts listed in `data\connections.md`
(the Meta dev apps "Agor AI Social" and "MVAT Mirror," the four LinkedIn dev apps, the
spend-capped X/Twitter dev app). Use it for ad copy, creative strategy, campaign structure, and
ad-library competitor research on those surfaces.

It does NOT cover advertising on AI-answer surfaces: ChatGPT, Perplexity, Google AI Mode / AI
Overviews ad slots, Copilot, or any other AI-assistant ad placement. That work belongs to the
`/ai-ads` skill (`C:\Users\ariel\.claude\skills\ai-ads\SKILL.md`, Agor AI Ads, the
answer-visibility agency). If a request is about getting a brand recommended, cited, or
advertised inside an AI assistant's answer, stop here and route to `/ai-ads`. Per
`briefs\agor-consulting.md`, Agor AI Ads is Ariel's own offer under the Agor AI Advisory brand;
this vault's brief covers marketing that offer (positioning, pricing, GTM sequencing), while the
actual campaign delivery mechanics (the eight-stage pipeline, the AI Visibility Audit, the rank
tracker) live entirely in `/ai-ads`, not here.

## Workspace Context

Read `briefs\_portfolio.md` first, always, for the cross-property triage rules, signal-phrase
table, and channel map. Then read the property brief that matches the task at hand:
`briefs\modelstack.md` for modelstack.digital paid social/search, `briefs\agor-consulting.md`
for agor.me (marketing the Agor AI Ads offer itself, per the boundary above, not running client
campaigns), `briefs\ios-apps.md` for any of the four iOS apps, or `briefs\scored-tools.md` for
scored.tools. Fall back to `strategy/brand.md` for cross-property voice and `about/me.md` for
personal voice when a brief does not cover the specific question. Save generated drafts to
`content/<platform>/drafts/YYYY-MM-DD_short-topic-slug.md`, and route durable learnings back to
the relevant brief, `strategy/brand.md`, or `about/me.md`.

## Operating Contract

This skill is self-contained for its frontmatter scope: use its local instructions, references, scripts, and assets as the playbook; ask only for missing task-specific inputs; hand off to adjacent skills instead of expanding scope; and return an actionable artifact, decision, plan, draft, or diagnostic.



End-to-end paid advertising: write ad copy, develop creative strategy, manage campaigns, and analyze competitor ads.

Use the Workspace Context above first; only ask for ad-platform inputs not covered there.

---

## 1. Ad Copy Creation

### Platform Constraints

| Platform | Element | Limit |
|----------|---------|-------|
| Google Ads (RSA) | Headline | 30 chars × 15 |
| Google Ads (RSA) | Description | 90 chars × 4 |
| Meta (FB/IG) | Primary text | 125 chars visible |
| Meta (FB/IG) | Headline | 40 chars |
| LinkedIn | Intro text | 150 chars recommended |
| LinkedIn | Headline | 70 chars recommended |
| TikTok | Ad text | 80 chars recommended |
| Twitter/X | Tweet | 280 chars |

For full format specs, see [references/platform-specs.md](references/platform-specs.md).

### Copywriting Frameworks

**AIDA** — Attention → Interest → Desire → Action
**PAS** — Problem → Agitate → Solution
**4Ps** — Promise → Picture → Proof → Push
**Before-After-Bridge** — Current pain → Desired state → Your solution

### Headlines That Work

- Specific over vague: "Cut reporting time 75%" not "Save time"
- Benefits over features: "Ship code faster" not "CI/CD pipeline"
- Include numbers when possible: "3x faster," "in 5 minutes," "10,000+ teams"
- Each RSA headline must stand alone — they're combined randomly
- Include at least: 1 keyword headline, 1 benefit headline, 2–3 CTA headlines

### Platform Best Practices

**Google**: Include keywords; use numbers/stats; power words (Free, Proven, New)
**Meta**: Hook in first 3 words; ask questions; social proof performs well; emojis B2C only
**LinkedIn**: Professional but not boring; lead with value; stats resonate with B2B
**TikTok**: Casual/authentic tone; hook in 1–2 seconds; strong CTA at end

### A/B Testing Variables

- Headlines: Question vs. statement; benefit-led vs. feature-led; with/without numbers
- Primary text: Short vs. long; problem-focused vs. solution-focused; with/without social proof
- CTAs: Direct ("Buy Now") vs. soft ("Learn More"); benefit-based vs. action-based
- **Protocol**: One variable at a time; min 7 days or 1,000 impressions; 95% significance before declaring winner

### Output Format

Organize by angle with character counts:

```
## Angle: [Pain Point — Manual Reporting]

### Headlines (30 char max)
1. "Stop Building Reports by Hand" (29)
2. "Reports Done in 5 Min" (21)

### Descriptions (90 char max)
1. "Marketing teams save 10+ hours/week. Start free." (49)
```

Offer CSV format for 10+ variations:
```csv
headline_1,headline_2,description_1,platform
"Stop Manual Reporting","Automate in 5 Min","Save 10+ hrs/week. Start free.","google_ads"
```

---

## 2. Creative Strategy

### Define Angles First

Before writing copy, establish 3–5 distinct angles (different reasons someone clicks):

| Category | Example |
|----------|---------|
| Pain point | "Stop wasting time on X" |
| Outcome | "Achieve Y in Z days" |
| Social proof | "Join 10,000+ teams who..." |
| Curiosity | "The secret top companies use" |
| Comparison | "Unlike X, we do Y" |
| Identity | "Built for [specific role]" |
| Contrarian | "Why [common practice] doesn't work" |

### Generate Variations Per Angle

Vary: word choice, specificity (numbers vs. general), tone (direct/question/command), structure (short punch vs. full benefit).

### Iterating from Performance Data

1. **Analyze winners** — identify winning themes, structures, word patterns by CTR/CVR/ROAS
2. **Analyze losers** — find what falls flat (too generic, wrong tone, too long)
3. **Generate new creative** — double down on winning themes, test 1–2 new angles, avoid loser patterns
4. **Document iterations**:

```
## Iteration Log
- Round: [N] | Date: [date]
- Top performers: [list with metrics]
- Winning patterns: [summary]
- New angles tested: [list]
- Angles retired: [list]
```

### Generating Ad Visuals

Primary path: invoke the `image-generator` subagent
(`C:\Users\ariel\.claude\agents\image-generator.md`). It always uses the current Gemini Flash
image model (nanobanana, currently `gemini-3.1-flash-image-preview`), never Imagen 4, and
already knows the per-property style direction (cognexus connectionism for agor.me and AI
content, clean business graphics for modelstack, playful for gifloop, and so on). Use it for ad
hero images and static creative instead of standing up a separate image-gen integration.

For video ad creative, check the `hyperframes` skill (composition, captions, transitions)
before reaching for a new paid video generator. Third-party generators (Veo, Kling, Runway,
Sora, Seedance, Higgsfield) and voice tools (ElevenLabs, already a paid subscription per global
CLAUDE.md, so prefer it over OpenAI TTS for voiceover) remain listed in
[references/generative-tools.md](references/generative-tools.md) as options, but per the Cost
Preference rule in global CLAUDE.md, flag any new paid tool or account to Ariel before creating
one, and confirm `image-generator` or `hyperframes` does not already cover the need.

---

## 3. Campaign Management

### Key Metrics

| Type | Metrics |
|------|---------|
| Cost | CPM, CPC, CPL, CPA/CAC |
| Performance | CTR, CVR, ROAS, LTV:CAC |

### Campaign Structure

**Google Ads**: Account → Campaign (budget, geo) → Ad Group (keyword theme) → Keywords + Ads

**Meta Ads**: Campaign (objective) → Ad Set (audience, placement, budget) → Ads (creative, copy)

**Bidding strategies**:
- Target CPA — optimize for conversions at target cost
- Target ROAS — optimize for conversion value
- Maximize conversions — spend budget for max conversions
- Manual — full control, time-intensive

### Audience Targeting

**Meta**:
- Core: demographics, interests, behaviors, location
- Custom: website visitors, customer lists, engagement audiences
- Lookalike: based on high-value customers, 1–10% similarity

**LinkedIn**:
- Company: industry, size, name
- Job: title, function, seniority
- Professional: skills, groups, interests

### Optimization Cadence

**Daily**: Budget pacing, cost metrics, major anomalies
**Weekly**: CTR/CVR trends, top/bottom performers, search term review (Google)
**Monthly**: Overall ROAS/ROI, audience performance, creative fatigue, strategic adjustments

### Quick Optimization Wins

1. Pause underperforming ads
2. Increase bids on top performers
3. Add negative keywords (Google)
4. Refine audience targeting
5. Refresh fatigued creative

### Budget Allocation

- **Testing phase**: 10–20% on new ideas
- **Proven performers**: 60–70% of budget
- **Retargeting**: 10–20% of budget
- **Scaling**: increase budget gradually (max 20%/week) on winning audiences/creative

---

## 4. Competitive Intelligence

Use ad libraries (Facebook Ad Library, LinkedIn Ad Library) to extract and analyze competitor ads.

### Extraction Process

Ad libraries (Facebook Ad Library, LinkedIn Ad Library) are free public tools, not SaaS
placeholders, so they stay as-is (the same "Do NOT remap" logic `data\REMAP.md` applies to
other free, no-lock-in tools). No scraping SaaS or ad-library API client exists in this stack:
drive extraction through the `claude-in-chrome` MCP (browser automation), per the tool priority
in global CLAUDE.md and `data\connections.md`, not a hypothetical paid API. Google Ads and
TikTok: no live ad account or API integration is confirmed in `data\connections.md`, so treat
any live execution ask on either platform as a gap, draft copy and strategy only, and flag
actual account access to Ariel.

```
Extract all current ads from [Competitor] on Facebook Ad Library
Scrape ads from [Company A], [Company B], [Company C] — compare approaches
Get LinkedIn ads from [Competitor] — analyze their B2B positioning
```

### Analysis Output

For each competitor, deliver:

```
# [Competitor] Ad Analysis

## Overview
- Total ads: [N] active | Primary themes: [breakdown]
- Ad formats: [static/video split] | CTA patterns: [list]

## Key Problems They're Highlighting
1. [Pain point] ([N] ads) — Copy: "..." — Why it works: [reason]

## Successful Creative Patterns
- Pattern 1: [description + frequency]
- Pattern 2: [description + frequency]

## Best Headlines
1. "[headline]" → [why it works]

## Recommendations for Your Ads
1. [Actionable insight based on their patterns]
```

### What to Analyze

- **Messaging**: What problems they emphasize, how they position vs. competitors
- **Creative patterns**: Visual styles, video vs. static, layout trends
- **Copy formulas**: Headline structures, CTA patterns, length and tone
- **Campaign strategy**: Seasonal campaigns, retargeting patterns, feature announcements

### Competitive Intelligence Workflows

**Ad Campaign Planning**: Extract competitor ads → identify patterns → note messaging gaps → draft test variations

**Positioning Research**: Analyze 5 competitors → map their positioning → find underserved angles → develop differentiated messaging

**Trend Tracking**: Compare competitor ads across quarters to spot messaging evolution

### Legal & Ethical

✓ Use for research and inspiration only
✓ Adapt patterns — don't copy ads directly
✓ Respect intellectual property
✗ Don't plagiarize copy or steal designs

---

## 5. References

- [references/platform-specs.md](references/platform-specs.md) — Full character limits and format specs for all platforms
- [references/generative-tools.md](references/generative-tools.md) — AI image/video/audio tools for ad creative production
