---
name: video-broll-composite
description: |
  Composite a narrated talking-head video with screen-capture B-roll into a finished 1080p
  file using ffmpeg (no NLE). Use when: (1) "make a video of me with my screen recording as
  b-roll", (2) overlay screen-cap clips on top of a talking-head read at specific spoken
  moments, (3) add a picture-in-picture face over b-roll, (4) replace black pillarbox bars
  with a blurred background, (5) burn in captions that match a written SCRIPT (not raw
  auto-transcription), (6) keep only the read's audio and silence the b-roll. Covers ffmpeg
  overlay enable-windows, tpad time-shift, blurred-fill, faster-whisper cue timing, and
  difflib script-to-ASR caption alignment. NOT for AI-avatar videos (use /heygen) or
  AI tool routing (use ai-orchestrator).
author: Claude Code
version: 1.0.0
date: 2026-05-31
---

# Video B-roll Composite (talking-head + screen-cap, ffmpeg)

## Problem
You have (a) a talking-head "read" video where someone narrates a script, and (b) a long
screen-capture you want to show as B-roll on top, at the moments the narration mentions them.
You want a finished 1080p video — B-roll punctuating the read, the face tucked into a corner
over the B-roll, full-screen face (with a clean background, not black bars) in the gaps, the
read's audio only, and burned-in captions whose text matches the script verbatim. Doing this
in a GUI editor is slow and imprecise; ffmpeg does it deterministically once you know the
filtergraph.

## Context / Trigger Conditions
- "Edit my screen-cap to match the script I read," "put my face in the corner over the b-roll,"
  "captions that match my script," "blur the background where it's just me," "mute the b-roll."
- Source read is often low-res / 4:3 / pillarboxed (webcam, or an Eddie/CapCut export).
- The screen-cap may already contain a webcam self-view (a face baked into the b-roll) that the
  corner PiP must cover so there aren't two faces.

## Solution

Working reference implementation (adapt paths): `build_video_v2.py` (compositor) and
`caption_gen.py` (captions) in `~/.claude/projects/provn-challenges/100-program-at-risk/`,
copied into this skill's `scripts/`. Full prose reference:
`~/.claude/projects/C--Users-ariel/memory/reference_ffmpeg_video_composite_pipeline.md`.

Prereqs: `ffmpeg`/`ffprobe` (WinGet), `faster_whisper` python pkg (CPU, base.en, int8).

### 1. Find cue timestamps (when to drop each B-roll clip)
Transcribe the READ with faster-whisper, locate the spoken phrase that each clip illustrates.
```python
segs,_ = WhisperModel("base.en",device="cpu",compute_type="int8").transcribe(read_wav, word_timestamps=True)
```

### 2. Compositor filtergraph (one ffmpeg `-filter_complex`)
- Split the read 3 ways: `[0:v]<crop?>,fps=30,split=3[bg][fg][pip]`
- **Blurred-fill full-face** (kills black bars; auto-limited to non-B-roll because B-roll covers the frame):
  `[bg]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,gblur=sigma=20[bgblur]`
  `[fg]scale=1920:1080:force_original_aspect_ratio=decrease[fgfit]`
  `[bgblur][fgfit]overlay=(W-w)/2:(H-h)/2[base]`
- **Each B-roll clip**, shifted to its cue and length-bounded:
  `[k:v]fps=30,scale=...:force_original_aspect_ratio=decrease,pad=1920:1080:...,trim=0:W,setpts=PTS-STARTPTS,tpad=start_duration=S[bk]`
  (tpad prepends black so the overlay never stalls waiting for the first frame)
  then `[prev][bk]overlay=enable='between(t,S,E)':eof_action=pass[next]`. Windows contiguous:
  `E_i = min(cue_{i+1}, cue_i + clip_len)`.
- **Face-PiP over B-roll only:** `[pip]scale=W:H:force_original_aspect_ratio=increase,crop=W:H,drawbox=...white...t=3[pipf]`
  then `[last][pipf]overlay=x=PX:y=PY:enable='between(t,S0,E0)+between(t,S1,E1)+...'[vcomp]`
  (the `+`-summed `between()` is truthy in ANY window; the PiP vanishes in full-face gaps).
  **Size/position the PiP to exactly cover any webcam baked into the b-roll** — measure it:
  `ffmpeg -ss T -i broll.mp4 -vf "drawgrid=w=60:h=60" grid.png` then a `drawbox` test frame.
- **Audio = read only:** `-map "[vout]" -map 0:a`. Never `-map` the b-roll audio -> b-roll silent.

### 3. Captions that match the SCRIPT (not the ASR)
ASR mis-hears names ("Arrivia"->"Arivia"). So: take TEXT from the script, TIMING from ASR.
- faster-whisper with `word_timestamps=True` -> list of (word, start, end).
- `difflib.SequenceMatcher(a=script_norm, b=asr_norm, autojunk=False)`; for `equal` blocks, give
  each script word its matched ASR word's time; interpolate the gaps.
- Chunk into short lines (break on `.!?`, comma if >=4 words, 7-word cap) -> ASS (PlayResX/Y
  1920x1080, `Alignment 2` bottom-center). Burn last: `[vcomp]subtitles=captions.ass[vout]`.
  **Run ffmpeg with cwd = the folder holding captions.ass and reference it by bare filename**
  to dodge Windows subtitles-path escaping (`C\:/...` pain).

## Verification
- `ffprobe -show_entries format=duration:stream=codec_type` -> one video + one audio stream, right duration.
- Extract frames at a gap, inside two B-roll windows, and at the boundaries:
  `ffmpeg -ss T -i out.mp4 -frames:v 1 f.png` and eyeball: gap = full face + blur + NO pip;
  window = b-roll + corner face fully masking any baked-in webcam; caption text == script.

## Example
PROVN Challenge 100 methodology video (2026-05-31): 9-min read + 6 screen-cap clips ->
`FINAL-provn-challenge-100-v6.mp4`, 1920x1080, read-only audio, bottom-left PiP masking the
build-webcam, blurred-fill gaps, script-matched captions. Delivered via Google Drive.

## Notes
- **Eddie AI** exports a low-res 352x288 `.3gp` by default; request the HQ `.mp4` (it's 1080p but
  pillarboxed — `cropdetect` it: `crop=1440:1080:240:0` to strip the 240px bars before compositing).
- **Large-file delivery to Google Drive:** `Copy-Item` into `G:\My Drive` (Drive for Desktop) —
  it auto-syncs. The claude.ai Drive MCP `create_file` can't carry a 100MB+ payload and can't set
  sharing (and changing sharing is a restricted action — the user does it). See
  [[feedback_claude_ai_drive_mcp_no_permission_write]].
- Low-res sources upscale soft; the blur-fill hides bars but can't add real resolution. Record
  the read at 1080p for crisp output.
- Iterate by versioning the OUT filename (v1..vN) and re-rendering; keep the build script
  parameterized (cues, PiP box, paths at top).

## References
- ffmpeg overlay `enable` + `tpad`: https://ffmpeg.org/ffmpeg-filters.html
- faster-whisper: https://github.com/SYSTRAN/faster-whisper
- Memory: `reference_ffmpeg_video_composite_pipeline.md`; sibling: `feedback_claude_in_chrome_file_upload_broken.md`
