---
name: hand-drawn-video
description: End-to-end production of a hand-drawn video, from brief to public YouTube playlist. Every line, arc and fill in the video is constructed on screen by an engraved draughtsman's hand (fountain pen against an ivory rule, compass from a pinpricked centre, marker fills). The pipeline covers authoring timed beats, Lyria score, deterministic 1080p60 recording, Agor watermark, cutting into ~3-minute parts, review sheets, and uploading each part publicly to YouTube in a series playlist as each recording finishes. Proven on Animation vs. Euclid (six books, 14 parts, 2026-10-21). Use when Ariel types /hand-drawn-video, or asks for a "hand-drawn video", a video "drawn before your eyes", "constructed as it would be in reality", "with the drawing hand", "like the Euclid videos", or wants a new topic or series (any genre) made and published that way.
---

# /hand-drawn-video: brief to published playlist

The look itself (the hand, the compass rules, Ariel's notes on it) lives in the **constructed-drawing** skill:
read `~/.claude/skills/constructed-drawing/SKILL.md` before touching any hand code. This file is the production
pipeline around it. Repo: `C:\Users\ariel\.claude\projects\animation-vs` (engine `engine-byrne/`, tools `tools/`).
Read the newest `docs/decisions/` entry and `HANDOFF.md` there first.

## Standing constraints (Ariel's, carry them into every run)
- Time matters: the earlier a correct result lands, the better. Don't spend time that can be avoided; run
  independent stages (score generation, recordings of different episodes) in parallel.
- Parts of ~3 minutes each, or ~1 minute vertical shorts when that suits the topic.
- Music is atmospheric: describe the sound in the Lyria prompt (crackle, rain, muffled 2-step, sub-bass, warm pads,
  wordless vocal textures); never name an artist.
- Captions are one short line in the margin. No letters on the canvas (no point labels), and captions never
  name points by letter.
- Agor watermark is burned in (record.mjs applies it; `tools/watermark.mjs <slug>` re-burns an old MP4).
- Public YouTube upload only once Ariel has asked for it on that series. After that, upload each part as soon as
  it is cut, until the series is done.
- No Workflow tool unless Ariel opts in. My own self-review loops stop after 2 rounds. Ariel's notes on the look
  are not capped; keep going until he approves.

## Pipeline (named stages; each runs and checks on its own)
| # | Stage | Command / file | Check before moving on |
|---|-------|----------------|------------------------|
| 1 | Episode | `episodes/<slug>/episode.json` (`"engine":"byrne"`, `"beats":true`, title, description, about), `book.js`, `beats/pNN.js`, `assemble.js`. Copy an existing book as the template. | `node tools/timeline.mjs <slug>` prints every beat and END |
| 2 | Beats | One beat = one self-contained construction, `BEAT({n,num,dur,cap,fig,draw,...})`, `draw(τ)` a pure function of time. Draw only through `rule`/`circ`/`plate`/`wedge` (or a new primitive with `treg` + `ov`), so the hand layer finds it. Grow strokes in real construction order. Contract: `engine-byrne/CONTRACT.md` and the header of `book.js`. | `node tools/build.mjs <slug> --only pNN` and look at frames |
| 3 | Look check | `node tools/build.mjs <slug>`, then `node tools/frames.mjs <page.html> <outDir> <t...>` at ~45% and ~82% of each beat; tile them into a contact sheet | the tool sits on the growing stroke; no hand over the captions |
| 4 | Score | `episodes/<slug>/score-prompts.json` (cues ≤ ~2:20, timestamped section lines) → `node tools/gen-score.mjs <slug>` (Lyria 3.5, `GEMINI_API_KEY`); `cues.json` lists `{file,dur,covers}` with slot durations summing to END and cut at beat boundaries; `node tools/score.mjs <slug>` → `score.mp3` | score length = END (ffprobe). If a cue misses its slot, stretch it with ffmpeg `atempo` and keep the raw file as `cueN-raw.mp3` |
| 5 | Record | `node tools/build.mjs <slug>` then `node tools/record.mjs <slug> *> <slug>-run.status` in the background (deterministic capture, foley, score, watermark) | status file ends in `wrote ...`; ffprobe duration = END |
| 6 | Parts | `episodes/<slug>/parts.json` `[{first,last,title}]` (beat numbers inclusive, ~3 min each) → `node tools/cut-parts.mjs <slug>` → `dist/<slug>-partN.mp4` | each part plays, fades in and out, duration as planned |
| 7 | Review | Contact sheet from the recorded MP4 (a few frames per part) | hand present and correct; no black frames |
| 8 | Publish | `node tools/youtube-euclid.mjs <slug>`: uploads each part public (Education, tags, description, thumbnail from 45% of the part), inserts it into the series playlist in order, writes ids to `episodes/<slug>/youtube.json` immediately so reruns never double-upload. For a new series, copy it and change the playlist key, title, description text and tags | query the API, not the script's output: the playlist holds every part, in order, `public`, upload `processed` |
| 9 | Report | Send Ariel the playlist link and every part link as a table, and say which parts were still processing | links open |

Unattended publishing: `tools/publish-as-done.ps1` watches the `*-run.status` files and runs stages 6 and 8 for
each book as its recording finishes. It is idempotent, so rerun it if it dies. Copy and edit it for a new series.

## Timing and capacity (measured on Euclid)
- Recording takes about 7.4 s of wall clock per second of video with the hand layer on (Book I: 736 s of video
  recorded in 5466 s). Plan from that: a 10-minute book is ~75 minutes.
  Run up to three recordings at once as chains; more risks Chrome memory.
- The probe cache keeps only the last 2 beats (`HCACHE` in tools.js). Without that limit, Book I died at frame
  1800 (TargetCloseError, Chrome OOM).
- Chrome orphans pile up after crashed renders: `tools/reap-chrome.ps1`, which is also scheduled every 6 hours.
- YouTube quota covered 14 uploads plus thumbnails and playlist inserts in one morning.
- SendUserFile caps at 30 MiB. Send YouTube links or 720p previews, never full parts.

## Credentials
- Gemini (sprites and Lyria): `GEMINI_API_KEY` in env.
- YouTube: OAuth client `~/.gbrain/google-oauth.json` plus token `~/.gbrain/youtube-token-agorme.json` (agor.me
  channel); the uploader is `~/.gbrain/youtube-upload.mjs`. For another channel, see the youtube-api-upload skill.
  Never ask Ariel to log in for these.

## New genre (not Euclid)
The engine and hand work for any figure built from lines, arcs and fills: physics diagrams, maps, logos,
architecture, infographics. Keep the four inks and the paper unless Ariel asks for another palette, and if he
does, regenerate the tint masks rather than recolouring sprites by hand. Write a new `book.js`-style header for
the topic, pilot one ~1-minute beat, and get Ariel's approval on that pilot before authoring the rest (the
Euclid remake went pilot → approve → all six books). A stick figure can share the stage (Ariel kept the
Geometer alongside the hand).

## After a run
Update `HANDOFF.md`, add a decision entry in `docs/decisions/` (plus its INDEX row), commit (the auto-push hook
reports the push outcome; report it truthfully), and close any commitment with evidence.
