---
name: youtube-content
description: Plan YouTube videos for Ariel's properties with optimized titles, thumbnails, hooks, and a research-backed content plan, then hand production and upload to the existing video pipeline. Use when planning a video, writing or reviewing opening hooks, generating title and thumbnail concepts, or building a production-ready plan. This is a strategy and planning layer only; actual production and upload run through the heygen, hyperframes, video-broll-composite, and youtube-api-upload skills.
---

# YouTube Content (bridge adapter)

This skill is a thin adapter. It does the strategy and planning (research, angle, titles, thumbnails, hook, outline) using the methodology in `references/upstream-playbook.md`, then hands the actual production and upload off to the existing video skills. It does not produce or upload video itself.

## When this fires

- Planning a new video: topic, angle, working title, thumbnail concept, hook, outline
- Reviewing or rewriting an opening hook
- Generating title and thumbnail variations for an existing plan
- Deciding what to make before any production tool is opened

## Workspace context to read first

Read the matching `briefs\<property>.md` (for example `agor-consulting` for Agor AI thought-leadership video, or `ios-apps` for an app demo), `strategy\brand.md` for voice, `about\me.md` for on-camera tone, and `content\ideas.md` / `content\calendar.md` for what is already planned. State that this was done in an early "Workspace context" line.

## What this hands off to

Once a plan is written, the production and upload pipeline lives in existing skills, not here:

| Job | Skill | Path |
|---|---|---|
| Avatar / talking-head video from a script | `heygen` | `C:\Users\ariel\.claude\skills\heygen` |
| HTML-based composition, captions, title cards, animated graphics | `hyperframes` (+ `hyperframes-cli`, `hyperframes-media`) | `C:\Users\ariel\.claude\skills\hyperframes` |
| Talking-head plus screen-capture b-roll composited with ffmpeg | `video-broll-composite` | `C:\Users\ariel\.claude\skills\video-broll-composite` |
| Upload the finished file to a YouTube channel via the Data API | `youtube-api-upload` | `C:\Users\ariel\.claude\skills\youtube-api-upload` |

Pick the production skill by video type: scripted presenter piece goes to `heygen`; a graphics-driven explainer goes to `hyperframes`; a screen-demo with a face goes to `video-broll-composite`. Do not reimplement any of that here.

## What stays in this skill

The planning and optimization methodology, unchanged from upstream, lives in **`references/upstream-playbook.md`**. Read it whenever the task is:

- Researching the topic and validating demand
- Writing a title that earns the click without baiting
- Designing a thumbnail concept that extends the title rather than repeats it
- Writing an opening hook that holds the first 30 seconds
- Structuring the full video outline and retention beats

## Dry-run rule

This skill's own output stops at a written plan, saved to `content\youtube\drafts\YYYY-MM-DD_short-topic-slug.md`: title options, thumbnail concept, hook, outline, and which production skill should build it.

Production and especially the `youtube-api-upload` step are real, live actions. A publish to a live channel is outward and irreversible in effect. Do not invoke `youtube-api-upload` until Ariel has reviewed the finished video and confirmed he wants it published now. This skill never uploads on its own.
