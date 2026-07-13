---
name: seedance-narrated-short
description: |
  Produce a long-form NARRATED cinematic short (art film, video essay, or novel/story/script
  adaptation) from a text, using HeyGen Seedance for the picture and xAI/ElevenLabs for a
  continuous NARRATOR spoken OVER the footage (no lip-synced dialogue). Use when the ask is
  "adapt this novel/story/essay into a film", "make a narrated short film / video essay",
  "turn this script into a cinematic Seedance short", or any beat-driven narrated piece longer
  than a couple minutes. NOT for lip-synced SPEAKING characters or ads (use `ai-commercial`),
  NOT for a single talking-head (use `heygen`), NOT for HTML/motion-graphic explainers (use
  `hyperframes`). Covers the whole pipeline (beats to Seedance clips, dense continuous narration,
  silent-face regen, dissolves, ducked score, narration-over-music mixdown) and the gotchas that
  bite: silent talking mouths, dead air, incoherent montage, reaped background pollers, ElevenLabs
  Music ToS + credit limits.
author: Claude Code
version: 1.0.0
date: 2026-07-13
---

# Seedance Narrated Short

Adapt a text into a long-form narrated cinematic short. The picture is a sequence of short
Seedance clips; a continuous narrator carries the story over them. This is the opposite of a
lip-synced ad: characters should NOT appear to speak, because the narrator is the voice.

Reference implementation (verified end to end, ~26 min film): the repo
`C:\Users\ariel\.claude\projects\the-safety-of-strangers` (generate.mjs, narrate-v3.mjs,
dissolve.mjs, score.mjs, finale-score.mjs, mixdown.mjs, script/silent-overrides.mjs).

## Problem

A text-to-film montage of Seedance clips with a sparse art-film narrator fails three ways:
(1) characters' mouths move as if talking but say nothing (uncanny), (2) long dead-air gaps,
(3) the scenes do not cohere as a story. All three trace to the same causes and have the same fixes.

## Context / Trigger Conditions

Use when adapting a novel, short story, essay, or script into a narrated film or video essay,
where a narrator (not on-camera dialogue) tells the story. Length is typically minutes to tens of
minutes, built from many short clips.

## Solution (pipeline)

1. **Read the source; write a BEAT SCRIPT.** One Seedance clip per beat (~15s, the model's max).
   Decide a directorial style and lock a **STYLE_SUFFIX** appended verbatim to every prompt so N
   clips read as one film (palette, lens, grain, framing, "no on-screen text, no distorted faces,
   no fast motion"). Prompt formula per beat: subject, action, camera, environment, lighting, mood;
   ONE action per clip. Keep beats in a data module (`beats.mjs`).
2. **Generate the clips (HeyGen Seedance).** `cinematic_avatar` requires an avatar LOOK as anchor
   even for scene shots (use one consistent look for continuity). ~1 credit per 15s clip. Driver:
   submit async -> poll `heygen video get` -> download `video_url`. Resumable via on-disk state.
   All clips come out uniform (h264/1920x1080/24fps) so the base concat can be stream-copy.
3. **Write DENSE, CONTINUOUS narration** (the single biggest lever). A near-continuous narrator
   makes the story legible AND masks the silent mouths (a voice over a person in frame reads as
   normal narrated-over footage). Place cues SEQUENTIALLY-ANCHORED: each starts at
   `max(prevEnd + gap, beatOffset)` so dense cues never overlap while staying roughly synced.
   Voices: xAI Grok TTS (voice `leo` + cast) or ElevenLabs. See [[ai-music-tts-apis]].
4. **Regenerate the worst talking close-ups as silent** via a prompt-override file merged into the
   generator (`buildPrompt` uses `OVERRIDES[id]` if present): rewrite to "silent, mouth closed,
   not speaking, contemplative," favor faces-away / profile / hands / objects.
5. **Dissolves** at act seams + key emotional/water beats (hard cuts elsewhere). Split into
   segments at dissolve points, stream-copy-concat each, then xfade-chain (one re-encode). Compute
   offsets from ACTUAL clip durations (clips are ~97% of nominal), and re-time the audio to the
   dissolved timeline (each dissolve removes `duration` seconds).
6. **Score**: ElevenLabs Music for original cues, or CC-BY tracks via yt-dlp when credits run out
   (Scott Buckley etc., attribution required). Place cues on the dissolved timeline.
7. **Mixdown that guarantees narration OVER music at all times**: even the VO (acompressor to lift
   quiet lines), lower the music base (~0.45) and hard-duck it under the VO
   (`sidechaincompress` ratio ~18 keyed to the voice), then loudnorm. Mux over the picture.

## Verification

- ffprobe every clip: uniform 1080p/24fps, ~15s.
- Final duration matches the picture; scrub for black frames / artifacted faces.
- **Narration over music: MEASURE, do not judge by ear.** In each loud music cue, compare VO peak
  vs ducked-music peak (`volumedetect` on the isolated tracks); target VO +6 to +8 dB.
- Watch end-to-end: story legible, no dead air, no silent lip-flap.

## Example

Novel -> 120 beats -> 120 Seedance clips (Kubrick x Tarkovsky STYLE_SUFFIX) -> ~65-segment
continuous xAI/Leo narration (sequential-anchored) -> 21 talking close-ups regenerated silent ->
dissolves at 3 act seams + 5 water beats -> ElevenLabs cues + a CC-BY orchestral finale ->
ducked mixdown (Leo +6-8 dB over music) -> 26-min 1080p master. Repo: `the-safety-of-strangers`.

## Notes

- **Background pollers get reaped at turn boundaries** on this host. For the long clip-download
  poll, use bounded FOREGROUND drains (`--once` or `--maxPollMin=8`), not a long background job.
  See [[background-jobs-reaped-use-foreground-drains]].
- **ElevenLabs Music**: prompts naming a musician (Steve Reich, Ligeti, Penderecki, Arvo Part)
  are rejected as ToS violations; describe the style instead. Credits run out fast (~16 min of
  music). See [[ai-music-tts-apis]].
- **Spotify cannot source audio** (metadata + 30s previews only). For downloadable CC music use
  yt-dlp `ytsearch1:...` and keep attribution in CREDITS.md.
- Cost is trivial (~1 credit per clip). The HeyGen wallet `remaining_balance` is a FRACTION of the
  plan credit pool, not USD. See [[heygen-seedance-credit-cost]] and [[heygen-seedance-cli-wsl]].
- Memory: [[narrated-seedance-film-dense-vo-silent-faces]]; project [[project-the-safety-of-strangers-seedance]].

## See also

- `ai-commercial` — the OTHER hybrid pipeline: lip-synced SPEAKING characters for ads/commercials
  (Avatar IV/V for dialogue). Use that when mouths must say the exact words. This skill is its
  narrated, no-lip-sync, long-form counterpart.
- `heygen` — single talking-head / avatar message.
- `hyperframes` — HTML-authored motion graphics / explainers (not photoreal generative video).

## References
- HeyGen Seedance CLI mechanics: memory `reference_heygen_seedance_cli_wsl.md`.
- ElevenLabs Music: https://elevenlabs.io/docs/api-reference/music/compose
- xAI TTS: https://docs.x.ai/developers/model-capabilities/audio/text-to-speech
