---
name: hyperframes-longform-video
description: |
  Produce a polished long-form (>4 min) talking-head + b-roll video using HeyGen HyperFrames
  for the GRAPHICS without fighting its short-clip limits. Use when: (1) building a methodology /
  walkthrough / explainer video longer than ~240s with captions, lower-thirds/chyrons, intro/outro
  cards, progress bar; (2) a HyperFrames render of a long composition stalls, times out
  ("Runtime.callFunctionOn timed out" / "Navigation timeout"), renders at ~0.5-1.5 fps, freezes
  frames ("sparse keyframes"), shows BLACK video panels, or produces a multi-GB file. Encodes the
  HYBRID pattern: ffmpeg builds the video base, HyperFrames renders transparent graphics overlays
  (segmented <240s streaming chunks), ffmpeg composites. Pairs with hyperframes / hyperframes-cli skills.
author: Claude Code
version: 1.0.0
date: 2026-06-01
---

# HyperFrames long-form video — the HYBRID pattern

> **Run the build under `video-canvas-method`** for the production-management layer (canvas-as-repo,
> asset cards, six approval gates). Relevant here: G3, approve a still per graphic/scene before
> rendering it, and `video-canvas-method/scripts/sheet.py` for the low-res verification pass that
> catches drift, empty tails and mirrored textures before you spend a full 1080p render.

## Problem
HeyGen HyperFrames renders video by seeking headless Chrome frame-by-frame. It is built for SHORT
clips. A 9-minute multi-video composition fights it hard: timeouts, ~9-hour renders, black panels,
multi-GB files. But its GRAPHICS authoring (captions, chyrons, cards, progress, brand) is excellent.
The fix is to use HyperFrames only for the graphics and ffmpeg for everything else.

## When to use
Long-form (>~4 min) talking-head + screen-cap b-roll video where you want HyperFrames-quality
branded graphics. Also any time a long HF render exhibits the failure modes below.

## The HyperFrames limits you WILL hit (and the fix for each)
1. **240s streaming gate is the master constraint.** HF logs `streaming-encode gate {enabled:false,
   maxDurationSeconds:240}` for comps >240s → slow CAPTURE path (~0.5-1.5 fps; a 9-min video ≈ 9 hrs).
   Under 240s → STREAMING path (~6-7 fps). No CLI flag raises the gate. **→ segment into <240s chunks.**
2. **Videos in a long comp → `Runtime.callFunctionOn timed out` (30s protocol timeout) at "Starting
   frame capture".** No `--protocolTimeout` flag. `--workers >1` makes it WORSE (workers freeze). A
   VIDEOLESS comp of the same duration clears the timeout. **→ keep videos out of HF; do them in ffmpeg.**
3. **Multiple video clips on the SAME `data-track-index` (or in one wrapper) → only the FIRST renders;
   the rest are BLACK.** Each independent clip needs its OWN `data-track-index` AND its OWN wrapper div.
4. **Stacked same-z wrappers with a `background` → an inactive wrapper on top covers the active one
   (black).** Drive each wrapper's `opacity` in the timeline so only the active segment's wrapper shows.
5. **Full-frame `mix-blend-mode` (grain feTurbulence overlay) over a transparent/alpha output = ~4×
   per-frame slowdown.** Do grain in ffmpeg, NOT HF. (Fine in HF when the comp has video, not alpha.)
6. **Animated `box-shadow` blur = per-frame raster cost.** Animate `opacity` for glows (GPU-cheap).
7. **Source videos MUST have dense keyframes** or HF freezes frames ("sparse keyframes 8.33s"). Re-encode:
   `ffmpeg -i in -r 30 -g 30 -keyint_min 30 -sc_threshold 0 -c:v libx264 -crf 18 ... out`. Also: identical
   `src`+`data-start`+`data-duration` videos get deduped/frozen → use distinct source files.
8. **ffmpeg `noise=...:allf=t` (temporal grain) is INCOMPRESSIBLE** — it can make the final file 30× bigger
   (a 535s 1080p file went 140MB → 7.3GB). Use a STATIC grain overlay, very light noise, or skip grain.
9. Sub-comp hosts need BOTH `data-composition-src` AND `data-composition-id`. Nested sub-comp timelines are
   LOCAL-clock (run from 0 at their `data-start`). Lint takes a DIRECTORY; non-entry roots aren't auto-linted.
   Render a specific composition with `-c <file>`; multiple root files → non-fatal `multiple_root_compositions`.

## The pattern (3 stages)
1. **ffmpeg base** — continuous read (never sliced) + blurred-fill gutters + b-roll on cue windows
   (`trim`/`setpts`/`tpad` + `overlay enable='between(t,S,E)'`) + face-PiP masking any baked webcam,
   read audio only, NO captions. See `scripts/build_base_clean.py`. (Geometry from the ffmpeg pipeline
   skill / `reference_ffmpeg_video_composite_pipeline` memory.)
2. **HyperFrames transparent overlay, SEGMENTED** — captions + chyrons + progress(opacity-pulse glow) +
   intro/outro cards, NO video/audio, transparent bg, split into <240s chunks with all times offset to
   local. Render each `--format mov` (alpha), `--quality draft` is crisp enough for text. See
   `scripts/overlay_seg_gen.py` (generates the chunk HTMLs from captions.ass + a chyron list + an
   amplitude envelope). Each renders ~6-7 fps via the streaming path.
3. **ffmpeg composite** — concat the alpha chunks (`concat=n=N:v=1`), overlay on the base
   (`overlay=format=auto`), add grain (static/light), map padded read audio, encode crf 20.
   See `scripts/combine_hybrid.py`.

Short verticals (<240s, few short clips) render fine in PURE HyperFrames — see `scripts/index-vertical-template.html`
for the face-forward 9:16 pattern (each segment its own track + wrapper, wrapper-opacity driven).

## Verification (do this — frame-by-frame)
Extract frames with `ffmpeg -ss <t> -i out.mp4 -frames:v 1 f.png` at: intro card; a b-roll window
(PiP fully masks the webcam; caption clears/overlaps acceptably); the hero beat (chyron fires, sync exact);
full-face (no leftover b-roll, logo present); outro card. Confirm total duration and a sane file size
(a 9-min 1080p master should be ~100-300MB, NOT multi-GB — if multi-GB, you left temporal grain on).

## References
- Memory: `~/.claude/projects/C--Users-ariel/memory/feedback_hyperframes_longform_render_limits.md`
- Worked example: `~/.claude/projects/provn-challenges/provn-challenge-100-hf/` (PROVN Challenge 100 v7)
- GBrain: `projects/provn-challenge-100-video-pipeline`
- HyperFrames docs: `npx hyperframes docs <compositions|rendering|data-attributes>`
