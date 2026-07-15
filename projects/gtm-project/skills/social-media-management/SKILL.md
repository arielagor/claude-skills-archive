---
name: social-media-management
description: |
  Cross-platform social media orchestration layer for LinkedIn, Twitter/X, Instagram, Facebook, TikTok, Pinterest, and YouTube. Decides what content goes where, extracts and repurposes a single source of truth across platforms, and plans the content calendar, then hands off the actual posting to the social-announcer agent (or the full image-to-blog-to-Substack-to-social-to-tracked-link loop to founder-stack:launch). Use for: content calendar planning, cross-platform repurposing, hook and pillar strategy, social analytics review, and coordinating a multi-channel content push.
---

# Social Media Management (bridge adapter, orchestration layer)

This skill is a thin adapter, but it is the widest one in this vault: it is
the layer that decides *what* content goes to *which* platform, in *what*
order, and then routes every actual publish action to an existing asset
rather than posting anything itself.

## When this fires

- Planning a week or launch's worth of cross-platform content
- Repurposing one piece of pillar content (blog post, video, announcement)
  into platform-specific versions
- Reviewing social analytics across platforms and deciding what to change
- Coordinating a multi-channel push around a product launch or milestone

## Workspace context to read first

Read the matching `briefs\<property>.md` for the property this content push
is for (one of `modelstack`, `agor-consulting`, `ios-apps`, `scored-tools`),
plus `strategy\brand.md` for cross-property voice and `about\me.md` for
personal voice. Check `content\ideas.md` and `content\calendar.md` for
what is already planned. State that this was done in an early "Workspace
context" line before drafting anything.

## Two hats: planning here, execution elsewhere

This skill wears the planning hat. It decides content pillars, calendar
placement, repurposing angles, and which platforms a piece of content should
reach. It does not carry its own posting integration for any platform. Once a
piece of content is ready to actually go out, one of two existing assets
executes it:

| Situation | Hands off to |
|---|---|
| A single piece needs to become platform-specific copy and get posted to X, Facebook, Instagram, or LinkedIn | **social-announcer** agent (`C:\Users\ariel\.claude\agents\social-announcer.md`) |
| A full launch loop: new image, new blog post, Substack re-sync, cross-platform social, one tracked link | **founder-stack:launch** command (`C:\Users\ariel\.claude\projects\claude-founder-stack\founder-stack\commands\launch.md`) |

`founder-stack:launch` itself calls `social-announcer` as its step 5, so the
two are not competing paths, they are nested: use `founder-stack:launch` when
the starting point is a new creative asset that needs the whole chain,
and call `social-announcer` directly when the content already exists and only
the cross-post step is needed.

## Platform quick reference (for routing decisions only)

Use this table to decide cadence and format expectations when planning; the
full per-platform content frameworks (hook formulas, structure templates,
character limits) live in `references/upstream-playbook.md`, not here.

| Platform | Best for | Frequency | Posting path |
|---|---|---|---|
| LinkedIn | B2B, thought leadership | 3 to 5x/week | social-announcer (browser automation, Ariel's personal profile; see the `linkedin` skill for content depth) |
| Twitter/X | Real-time, community | 3 to 10x/day | social-announcer (browser automation preferred, X API is spend-capped per `data\connections.md`) |
| Facebook | Communities | 1 to 2x/day | social-announcer (Meta dev apps "Agor AI Social" / "MVAT Mirror") |
| Instagram | Visual brands | 1 to 2 posts/day + Stories | social-announcer (image required; "link in bio" phrasing, IG captions do not support clickable links) |
| TikTok / Pinterest / YouTube | Longer-form or vertical video, lifestyle pins | varies | absent from this stack's posting integrations; flag as a gap and propose a manual step rather than inventing a tool |

Note: `social-announcer`'s own channel table (X, Facebook, Instagram,
LinkedIn, Dub.co) does not cover TikTok, Pinterest, or YouTube posting. If a
task needs one of those, say so explicitly rather than assuming coverage.

## Link shortening substitution

`founder-stack:launch`'s own step 4 says "bitly tracked link." In this vault,
substitute **Dub.co** (`app.dub.co/agor`, API base `api.dub.co`) per
`data\REMAP.md` row 6, this vault's default shortener, not Bitly, unless a
task has a hard Bitly-only requirement.

## What stays in this skill (and its reference file)

The substantive per-platform content methodology, repurposing system, content
calendar templates, hook formulas, engagement playbook, and analytics rubric
are unchanged from upstream and live in **`references/upstream-playbook.md`**.
Read it whenever the task needs:

- Platform-specific format and structure (LinkedIn, X threads, Instagram
  captions, TikTok scripts)
- The blog-to-social repurposing workflow and output template
- Content calendar and batching strategy
- Analytics and ROI framing, or reverse-engineering viral content patterns

`references/image-prompt-templates.md` (platform-specific AI image generation
prompts) is also preserved as-is; when an image is actually needed, generate
it with the tool named in `social-announcer`'s own doc (nanobanana /
`gemini-3.1-flash-image-preview`, not Imagen 4) rather than a generic prompt.

## Dry-run rule

This skill's own output stops at a plan: a content calendar, a repurposed set
of platform drafts, or an analytics readout. Save drafts to
`content\<platform>\drafts\YYYY-MM-DD_short-topic-slug.md`.

Both downstream assets perform real, outward actions once invoked:
`social-announcer` posts live via browser automation, and
`founder-stack:launch` publishes a blog post, re-syncs Substack (a real
publish, not a draft, per `data\connections.md`), and cross-posts. Per the
global dry-run policy, do not invoke either one until Ariel has reviewed the
drafted content and given an explicit, in-the-moment go for that specific
push. Producing the plan and drafts is this skill's whole job; pulling the
trigger is a separate, later step.

## Boundary reminders

- This vault does not own client-facing AI-visibility or GEO work; that is
  `/ai-ads`. This skill's cross-platform loop is for Ariel's own properties.
- This skill does not re-decide portfolio priority; `/portfolio-pm` (or Ariel)
  points at a property first.
