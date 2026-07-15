---
name: gtm
description: GTM Skill Vault router for Ariel's portfolio. Use when Ariel types "/gtm", asks for go-to-market or marketing strategy, growth planning, positioning, pricing strategy, keyword or SEO/AEO work for his OWN properties (modelstack.digital, agor.me, the iOS apps, scored.tools), outbound email campaigns, content calendars, launch plans, competitor analysis, funnel analytics, a marketing exec dashboard, or names any GTM Skill Vault skill (go-to-market-strategy, keyword-research-and-clustering, outbound-email-strategy, pricing-strategy, etc.) from OUTSIDE the gtm-project workspace. Routes the work into C:\Users\ariel\.claude\projects\gtm-project, whose 49 project-scoped vault skills load natively only there. NOT for client-facing AI-visibility delivery (use /ai-ads) and NOT for cross-project portfolio prioritization (use /portfolio-pm).
---

# GTM Skill Vault router

The GTM Skill Vault is 49 marketing/GTM skills living at `C:\Users\ariel\.claude\projects\gtm-project\.claude\skills\`. They are **project-scoped**: Claude Code loads them automatically only in a session whose working directory is that repo. This router makes the vault reachable from any other session without permanently loading 49 skill descriptions into every context.

## First, locate

Check the current working directory.

- **If cwd is already inside `gtm-project`:** the vault skills are loaded natively. Do not route. Read `.claude\skills\skill-navigator\SKILL.md` to pick the right skill, then use it directly. Stop reading this router.
- **If cwd is anywhere else:** route by direct file execution (below). Project skills will not auto-load mid-session in a different repo, so you invoke a vault skill by reading its file and following it, with `gtm-project` as the working directory for every artifact you produce.

## Route (from any other cwd)

1. Identify which vault skill fits the request. If unsure, read the catalog:
   `C:\Users\ariel\.claude\projects\gtm-project\.claude\skills\skill-navigator\SKILL.md`.
2. Read that skill's file: `C:\Users\ariel\.claude\projects\gtm-project\.claude\skills\<name>\SKILL.md` (and its `references\` as the skill directs). Follow it verbatim.
3. Read the workspace context the skill asks for before acting: the relevant `briefs\<property>.md`, `strategy\brand.md`, `about\me.md`, and `data\REMAP.md`, all under `gtm-project`.
4. Write every artifact into `gtm-project` (drafts go to `content\<platform>\drafts\YYYY-MM-DD_topic-slug.md`), not into the cwd you happened to start in.

For a heavy multi-skill session (a full launch, a strategy sprint), it is cleaner to start a fresh `claude` session inside `C:\Users\ariel\.claude\projects\gtm-project` so all 49 skills load natively. Tell Ariel that when the task is large.

## Orient

The vault covers six areas:

- **strategy** — go-to-market-strategy, marketing-strategy, growth-strategy, pricing-strategy, brand-messaging-and-positioning, product-market-fit-analysis, market-research-analysis, competitor-analysis, seo-and-aeo-strategy, keyword-research-and-clustering, free-tool-strategy
- **content** — content-strategy-and-planning, content-creation-and-marketing, copywriting-core, blog-writing-specialist, humanizer, pitch-deck-creation, slide-outline, youtube-content, youtube-research
- **channels** — social-media-management, linkedin, newsletter-management, x-impact-checker, pr-specialist, app-store-optimization, product-hunt-launch, ph-community-outreach, ph-content-recycling
- **analytics-crm** — data-and-funnel-analytics, executive-dashboard-generator, crm-integration, conversion-rate-optimization, landing-page-optimization, ab-test-setup
- **sales-outbound** — outbound-email-strategy, lead-generation-and-demand, personalization-at-scale, networking-outreach, sales-and-revenue-operations, customer-success-and-retention, user-onboarding
- **launch-utilities** — bootstrap, marketing-automation, marketing-campaign-management, ad-campaign-management, utm-builder, qr-code-generator, skill-navigator

The five property briefs are `modelstack`, `agor-consulting`, `ios-apps`, `scored-tools`, and the `_portfolio` index. If `briefs\_portfolio.md` is missing or a property has no brief yet, run the vault's `bootstrap` skill first.

## Rules carried everywhere

- **Dry-run by default.** Every vault skill produces drafts. Nothing is published, sent, spent, or deployed without Ariel's explicit, in-the-moment go. This router does not relax that.
- **Voice and style.** Match `about\me.md` / the `ariel-email-voice` skill. Never write the phrase meaning structurally-critical (the "load" + hyphen + "bearing" contiguous phrase). No em-dashes in authored text.
- **Payment-rail truth.** Apple handles iOS IAP refunds; Stripe/Ariel handles Stripe-rail refunds (MVAT Focus has both; never conflate them). A polite "I double-paid, please advise" is a real-customer pattern, routed to Ariel, never auto-answered.
- **Boundaries.** `/ai-ads` owns client-facing AI-visibility delivery; `/portfolio-pm` owns cross-project prioritization; this vault owns Ariel's own marketing execution.
