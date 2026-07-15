---
name: skill-navigator
description: Use this skill when you need guidance on which GTM Skill Vault skill fits a task. Recommends the right primary skill, useful supporting skills, and the handoff order, using only skills that actually exist in this tailored vault (49 active skills). Also states which skills are thin bridges to existing Ariel assets, and where the vault's boundaries with /ai-ads and /portfolio-pm sit.
---

# Skill Navigator

## Workspace context

Before recommending, read the relevant `briefs\<property>.md` (`modelstack`, `agor-consulting`, `ios-apps`, `scored-tools`, or the `_portfolio` index), plus `strategy\brand.md`, `about\me.md`, and `data\REMAP.md`. Drafts belong in `content\<platform>\drafts\YYYY-MM-DD_topic-slug.md`.

## How to use this navigator

1. Identify the single best primary skill from the catalog below.
2. Suggest at most 2 supporting skills for a multi-step workflow.
3. State the handoff order plainly.
4. Recommend only skills that appear in the catalog below. The 5 parked skills and anything outside this list are not available here.

## Catalog (49 active skills)

### strategy
| Skill | Use when |
|---|---|
| go-to-market-strategy | The core GTM motion, price ladder, and launch sequencing across the portfolio. Start here for "how do we take this to market." |
| marketing-strategy | Positioning execution, competitive intel, sales enablement, market sizing. Defers price-ladder/motion to go-to-market-strategy. |
| growth-strategy | Per-property growth loops and retention. Defers cross-property sequencing to /portfolio-pm. |
| pricing-strategy | Pricing tiers, packaging, freemium-to-paid, grounded in the real $29 to $250K ladder. |
| brand-messaging-and-positioning | Per-property positioning and messaging across a multi-brand portfolio. |
| product-market-fit-analysis | PMF signals grounded in Stripe/ASC/booking data. |
| market-research-analysis | Market/industry research via WebSearch and free sources. |
| competitor-analysis | Competitive landscape via WebSearch and free tools. |
| seo-and-aeo-strategy | SEO/AEO/AI-visibility for Ariel's OWN properties (free tool stack). Client delivery goes to /ai-ads. |
| keyword-research-and-clustering | Keyword research via Google Search Console, autocomplete, WebSearch. |
| free-tool-strategy | Free-tool lead magnets (relevant to scored.tools and template lead magnets). |

### content
| Skill | Use when |
|---|---|
| content-strategy-and-planning | Single-property content strategy and calendar (content/ideas.md, content/calendar.md). |
| content-creation-and-marketing | Multi-channel content; wires the founder-stack:launch loop and the agent roster. |
| copywriting-core | Copy craft; matches voice via about/me.md and the ariel-email-voice skill. |
| blog-writing-specialist | Bridge: hands drafting to the blog-content-generator agent, with a mandatory anti-ai-narrative-tells audit. |
| humanizer | Bridge: delegates to anti-ai-narrative-tells (audit mode). |
| pitch-deck-creation | Bridge: narrative/structure here, rendering to agor-branded-deck or pptx. |
| slide-outline | Slide outlines; hand rendering to agor-branded-deck / pptx. |
| youtube-content | Bridge: video planning here, production/upload to heygen / hyperframes / video-broll-composite / youtube-api-upload. |
| youtube-research | YouTube topic and demand research (free methods). |

### channels
| Skill | Use when |
|---|---|
| social-media-management | Bridge: cross-platform planning; posting via social-announcer and the founder-stack:launch loop. |
| linkedin | Bridge: LinkedIn content frameworks here, posting via social-announcer. |
| newsletter-management | Bridge: newsletter writing here, distribution via the substack-syncer agent (one-time RSS re-import). |
| x-impact-checker | Score and optimize X posts against the published X algorithm heuristics. |
| pr-specialist | PR strategy and pitches (draft-only). |
| app-store-optimization | Bridge: ASO drafting here, listing writes via asc-listing-manager (ios-apps brief). |
| product-hunt-launch | Product Hunt launch playbook (for agor-agents / scored.tools launches). |
| ph-community-outreach | Product Hunt community outreach. |
| ph-content-recycling | Recycling content for Product Hunt. |

### analytics-crm
| Skill | Use when |
|---|---|
| data-and-funnel-analytics | Funnel analysis via Plausible + Stripe MCP; per-property funnels from briefs. |
| executive-dashboard-generator | Portfolio dashboard from live Stripe MCP reads + Plausible. |
| crm-integration | GBrain-as-CRM: contact/company records, backlinks, timeline, pipeline tagging. |
| conversion-rate-optimization | CRO on landing pages; measured via Plausible. |
| landing-page-optimization | Landing-page audits (pairs with gstack /design-review, /browse). |
| ab-test-setup | Experiments via Netlify split tests + Plausible events. |

### sales-outbound
| Skill | Use when |
|---|---|
| outbound-email-strategy | Cold/outbound sequences in Ariel's voice; Gmail create_draft only, never send. |
| lead-generation-and-demand | Bridge: demand strategy here, list sourcing via library-business-prospect-list + GBrain. |
| personalization-at-scale | Personalization sourced from GBrain person/company pages. |
| networking-outreach | Bridge: relationship-first outreach via GBrain + precall-brief + ariel-email-voice. |
| sales-and-revenue-operations | Pipeline/forecast on GBrain + revenue-scorecard + Stripe MCP (real deals). |
| customer-success-and-retention | Support/retention with the Apple-vs-Stripe refund triage and real-customer rule. Draft-only. |
| user-onboarding | Onboarding for the real rails (StoreKit IAP, modelstack Stripe download flow). |

### launch-utilities
| Skill | Use when |
|---|---|
| bootstrap | Set up or refresh property briefs (fill-gaps / new-property / full-refresh modes). Run first when a property has no brief. |
| marketing-automation | Automations via Task Scheduler S4U crons + claude -p + the gated-outward-agent OFF/DRAFT/LIVE pattern. |
| marketing-campaign-management | Campaign planning and coordination. |
| ad-campaign-management | Classic paid social/search (Meta/X/LinkedIn). AI-answer-surface ads go to /ai-ads. |
| utm-builder | UTM-tagged links reporting through Plausible, shortened via Dub.co. |
| qr-code-generator | QR code generation utility. |
| skill-navigator | This skill. |

## Not available here

**Parked** (moved out of discovery, see docs/decisions/0004): `challenge-funnel`, `community-building`, `referral-program`, `webinar-content-and-events`, `issue-reporting`. Do not recommend these.

## Boundaries

- **/ai-ads** owns client-facing AI-visibility (GEO/AEO) delivery. This vault's seo-and-aeo-strategy is for Ariel's own properties only.
- **/portfolio-pm** owns cross-project prioritization and weekly planning. This vault executes marketing once a property is chosen.
- **/gtm** (global router) reaches this vault from sessions started outside this repo.

## Output format

```markdown
# Skill Navigator Output

## Recommended skill
[primary skill and why]

## Supporting skills
[0-2 supporting skills and when]

## Suggested workflow
[ordered steps with handoffs]

## Copy-paste prompt
[one prompt to run next]
```
