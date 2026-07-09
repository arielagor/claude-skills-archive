---
name: newsletter-management
description: Create, curate, and grow email newsletters. Use when working on newsletter issues, curated content, subscriber engagement, or content distribution for modelstack.digital or agor.me. Covers 6 newsletter formats, editorial structure, curation, and growth methodology in the reference file. Actual distribution runs through Substack via the substack-syncer agent, a manual RE-IMPORT that must be repeated per post, not an automatic subscription.
---

# Newsletter Management (bridge adapter)

This skill is a thin adapter. It plans, curates, and writes newsletter issues
using the methodology in `references/upstream-playbook.md`, then hands the
actual Substack distribution mechanics off to an existing agent.

## When this fires

- Writing or curating a newsletter issue in one of the 6 formats
- Deciding sending cadence, subject lines, or growth tactics
- Checking whether a newly published blog post has actually reached
  subscribers on Substack

## Workspace context to read first

Read the matching `briefs\<property>.md` (`modelstack` or `agor-consulting`,
whichever publication this issue is for), `strategy\brand.md` for voice, and
`content\ideas.md` / `content\calendar.md` for what is already planned. State
that this was done in an early "Workspace context" line.

## No bulk-send platform exists in this stack

Per `data\REMAP.md` row 3: there is no Mailchimp, ConvertKit, SendGrid, or
Klaviyo in this stack, and no subscriber list/segmentation tool. Newsletter
distribution happens exclusively through the two live Substack publications
(ModelStack, Agor AI). One-off outreach that looks newsletter-shaped but is
really a single email goes through a Gmail draft (`mcp__claude_ai_Gmail__create_draft`),
never a send tool, and never to a list.

## What this hands off to

Once an issue's content is written and (for ModelStack) the source blog post
is published, the **substack-syncer** agent
(`C:\Users\ariel\.claude\agents\substack-syncer.md`) does the distribution
mechanics:

| Site | Feed | Publication |
|---|---|---|
| modelstack.digital | `https://modelstack.digital/rss.xml` (static, rebuilt by `scripts/build-rss.mjs`) | `modelstack.substack.com` |
| agor.me | `https://agor.me/feed/blog` (dynamic, no rebuild needed) | agor.me's Substack |

**Critical fact to carry into every invocation, stated explicitly because it
is the whole reason this agent exists:** Substack's "Import from RSS" is a
**ONE-TIME archive import**, not a subscription. Substack never re-polls the
feed on its own. Every single new post needs a fresh, manual re-import (or the
agent's semi-automated API path) or the publication silently drifts behind,
exactly as it already did once (feed had 53 posts, Substack had 30, per that
agent's own documented incident). Do not assume that publishing a blog post
also gets it onto Substack. It does not, until this hand-off runs.

## What stays in this skill

`substack-syncer` only does the sync mechanics (verify feed is current,
diff against Substack's published count, re-import). It does not know
newsletter formats, issue structure, curation judgment, subject line
formulas, or growth strategy. That methodology, unchanged from upstream,
lives in **`references/upstream-playbook.md`**. Read it whenever the task is:

- Choosing or writing one of the 6 formats (curated roundup, story-driven,
  educational deep dive, interview, data-driven, personal update)
- Structuring a full issue
- Sourcing and filtering content worth curating
- Writing commentary that adds a genuine take, not a restatement
- Picking a subject line, sending day, or growth tactic

## Dry-run rule

This skill's own output stops at a drafted issue, saved to
`content\newsletter\drafts\YYYY-MM-DD_short-topic-slug.md`.

Both the blog publish step and the Substack re-import are real, live actions.
Per `data\connections.md`: "RSS 'Import' publishes live immediately, not as a
draft, treat any Substack action as a real publish, gate it accordingly." Do
not invoke `substack-syncer` until Ariel has reviewed the issue content and
confirmed he wants it distributed now. If asked to "send this newsletter to
subscribers," remember there is no list to send to outside Substack's own
subscriber base, the only lever here is getting the post correctly imported.
