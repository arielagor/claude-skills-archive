---
name: linkedin
description: LinkedIn profile optimization and content creation. Use when auditing or optimizing a LinkedIn profile, writing LinkedIn posts, developing thought leadership content, building personal brand on LinkedIn, analyzing SSI score, improving profile visibility, or crafting hooks and engagement strategy for LinkedIn. Drafts the content and profile plan here; the social-announcer agent handles actual posting mechanics.
---

# LinkedIn (bridge adapter)

This skill is a thin adapter. It plans and drafts LinkedIn work using the
methodology in `references/upstream-playbook.md`, then hands the mechanical
act of posting off to an existing asset instead of reimplementing a browser
or API integration here.

## When this fires

- A profile audit or optimization pass (photo, headline, About, experience, SSI)
- Writing a LinkedIn post, thread of posts, or a batch of drafts
- Developing thought leadership content or a posting cadence

## Workspace context to read first

Before doing any property-specific work, read the matching `briefs\<property>.md`
(most LinkedIn work sits under `agor-consulting`, since personal thought
leadership is Ariel's consulting funnel, but confirm against the actual topic),
plus `strategy\brand.md` for voice and positioning and `about\me.md` for
personal voice. State in an early "Workspace context" line that this was done.

## What this hands off to

Posting mechanics, not content strategy, go to the **social-announcer** agent
(`C:\Users\ariel\.claude\agents\social-announcer.md`). That agent:

- Posts via `claude-in-chrome` MCP (browser automation), not the LinkedIn API
- Knows the account is Ariel's personal LinkedIn profile
- Handles the mechanical draft-into-composer-and-submit step and verifies the
  post actually landed afterward

There are **4 LinkedIn dev apps** live in this stack (see `data\connections.md`):
the general Agor AI app, the Agor AI Press App (CMA-staged, paused on an LLC
blocker), the scored.tools App, and the ModelStack Community App. They are not
interchangeable. Before handing a post to social-announcer, confirm which
property the post is for so the right app/account context applies. None of the
4 currently back an autonomous posting API path in this vault; live posting
still goes through the browser, per the tool-priority rule in the global
CLAUDE.md.

## What stays in this skill

`social-announcer` only handles posting mechanics. It does not know LinkedIn's
hook formulas, post anatomy, profile scoring rubric, or engagement strategy.
That substantive content methodology, unchanged from upstream, lives in
**`references/upstream-playbook.md`**. Read it whenever the task is:

- Writing or scoring a hook
- Structuring a post (story, list, contrarian, observation formats)
- Running a profile audit and producing a scorecard
- Deciding posting cadence or engagement tactics

Also see `references/scoring_framework.md`, `references/metrics_benchmarks.md`,
and the `assets/` templates, all preserved as-is from upstream.

## Dry-run rule

This skill only ever produces a draft. Save generated post copy to
`content\linkedin\drafts\YYYY-MM-DD_short-topic-slug.md`. Save a profile audit
report as a plain artifact, not a live profile edit.

Invoking `social-announcer` to actually publish a post is a live, outward
action (per the global dry-run policy: anything that would send, publish,
spend, or deploy stops and waits for Ariel's explicit, in-the-moment go). Do
not call social-announcer to post until Ariel has reviewed the draft and given
that go-ahead. Profile edits (headline, About, banner) are also live changes
to a public profile; present the recommended copy and let Ariel apply it, or
get explicit confirmation before driving the edit via browser automation.
