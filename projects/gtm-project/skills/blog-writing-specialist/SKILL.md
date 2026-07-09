---
name: blog-writing-specialist
description: "Blog writing skill for Ariel's two live blogs (modelstack.digital, agor.me): drafts technical posts, brain-dump transformations, and category-aware AEO content in Ariel's voice, then hands the draft to the blog-content-generator agent's format conventions, with a mandatory anti-ai-narrative-tells audit pass before any draft counts as done. Use when: (1) writing, editing, or proofreading a blog article or post, (2) transforming unstructured brain dumps into polished posts, (3) building tutorials, deep dives, postmortems, benchmarks, or architecture posts, (4) writing for modelstack.digital or agor.me specifically. Triggers: blog post, blog writing, technical blog, dev tutorial, brain dump, article, content writing, developer article, engineering blog, programming blog, coding tutorial, documentation post, technical writing, blog editing, proofreading, developer content."
---

# Blog Writing Specialist

BRIDGE-tier adapter. The drafting methodology stays local; the live-repo
mechanics (file format, index, feed rebuild, Substack) belong to the
blog-content-generator agent, and every draft gets a mandatory anti-AI audit
before it's done.

## Workspace context (read first)

1. `strategy\brand.md` for cross-property positioning, house style, and the
   receipts-and-sources rule (every claim traces to a real, cited source).
2. `about\me.md` for Ariel's personal voice: direct, dense over safe, no
   hedging, no em-dashes ever.
3. `content\ideas.md` and `content\calendar.md` if present, so a new draft
   doesn't repeat a recent topic.
4. Which property this post is for: modelstack.digital or agor.me, since each
   has its own repo format and tone (modelstack: DM Serif/DM Sans, finance-store
   register; agor.me: Cognexus/connectionism theme, consulting register).

## What it hands off to

**blog-content-generator** (`C:\Users\ariel\.claude\agents\blog-content-generator.md`)
knows the two blogs' real mechanics: modelstack's `blog/posts/<slug>.json` +
`blog/index.json` + `rss.xml` rebuilt via `scripts/build-rss.mjs`, and agor.me's
Next.js MDX posts under `src/app/blog/` with a dynamic feed route. It also
knows the image pipeline (nanobanana / `gemini-3.1-flash-image-preview`,
cognexus connectionism style for AI content) and hands cross-posting to
`social-announcer` and RSS re-import to `substack-syncer`.

## Workflow

1. Draft the post using the full upstream methodology: pick the right post type
   (tutorial, deep dive, postmortem, benchmark, architecture), structure,
   word-count target, and voice rules. Full detail (all six parts: technical
   writing, brain-dump transformation, Jarad's voice, category-aware AEO
   frontmatter, diagram guidance, distribution table, common mistakes) is
   preserved in
   [references/upstream-playbook.md](references/upstream-playbook.md).
2. Match the target blog's real field names and conventions from
   blog-content-generator's own notes (`title`, `date`, `slug`, `excerpt`,
   `body`, `tags` for modelstack; MDX frontmatter mirrored from an existing post
   for agor.me), so the draft drops in cleanly later without reformatting.
3. **Mandatory anti-AI audit.** Before the draft counts as done, run it through
   `anti-ai-narrative-tells` (`C:\Users\ariel\.claude\skills\anti-ai-narrative-tells\SKILL.md`,
   skim it first). That skill was built for fiction (plot structure, anachrony,
   protagonist framing), so most of its 30-feature checklist will not apply to a
   blog post; use its transferable parts instead: vocabulary-cluster tells,
   chatbot residue ("here's an overview," "let's dive in"), formulaic-structure
   patterns (forced threes, "not only X but Y"), and its core warning that
   surface paraphrasing does not fix structural AI tells. Note which of those
   fire and fix them. If the draft still reads synthetic after that pass, run
   this vault's own `humanizer` skill on it as a second lens.
4. Save the finished draft to `content\blog\drafts\YYYY-MM-DD_topic-slug.md`.
   Do not write to the live modelstack.digital or agor.me repo, do not touch
   `blog/index.json` or `rss.xml`, and do not trigger `substack-syncer` from
   this skill. Those are blog-content-generator's live-repo actions and only
   happen on Ariel's explicit go, as a separate step outside this pass.

## Dry-run rule

This skill never commits, pushes, or publishes. Its only output is a Markdown
draft file plus the anti-AI audit notes. Publishing (invoking
blog-content-generator against the real repo, rebuilding the feed, cross-posting,
re-importing to Substack) is a later, explicit action Ariel takes or approves.

## Reference

[references/upstream-playbook.md](references/upstream-playbook.md) carries the
full original blog-writing methodology: technical post types and structure,
brain-dump transformation process, Jarad's voice guide, the category-aware AEO
frontmatter system, diagram guidance, the distribution table, and the common
mistakes table. `references/voice-tone.md` and `references/story-circle.md`
(Nick Nisi voice and the Story Circle framework) are unchanged and still load
on demand exactly as the upstream playbook describes.
