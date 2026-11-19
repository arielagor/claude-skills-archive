---
name: publish-post
description: Write and distribute a blog post for modelstack.digital or agor.me, end to end in the main loop: writing the post in the established voice, cross-posting it to X, Facebook and Instagram, and re-importing the RSS feed into Substack. Use when asked to write a blog post, announce or cross-post a post or launch on social, or sync Substack after a new post.
---

# publish-post

One skill for the content chain that used to be three subagents. Do the steps yourself, in order, and only the ones the task needs. Read the matching reference before each step.

## Folded procedures (formerly subagents)

- **blog-content-generator**: write a new blog post for modelstack.digital or agor.me in the established voice. Writes the Markdown/JSON post file, updates the index, rebuilds rss.xml (ModelStack), and flags Substack re-import as a follow-up. Do NOT cross-post to social — that's `social-announcer`. Read `references/blog-content-generator.md`.
- **social-announcer**: cross-post a blog post, product launch, or update to X/Twitter, Facebook, and Instagram from a single source of truth. Prefers claude-in-chrome MCP over API (X API is spend-capped; Facebook/Instagram have friction). Knows the per-account X developer app gotcha. Read `references/social-announcer.md`.
- **substack-syncer**: publishing a new blog post on modelstack.digital or agor.me to re-import the RSS feed into Substack. Substack's "Import from RSS" is a ONE-TIME archive import, not a subscription — every new post requires manual re-import or the publication silently falls behind. Read `references/substack-syncer.md`.
