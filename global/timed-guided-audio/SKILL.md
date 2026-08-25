---
name: timed-guided-audio
description: |
  Produce audio where the TIMING IS THE PRODUCT: a guided workout with counted reps, an interval
  or HIIT timer, a meditation or breathwork track with held phases, a hypnosis session with timed
  suggestion and pause, a physio or rehab protocol, a language drill with response gaps. Use when
  the ask is "turn this program/routine into guided audio", "count my reps", "a coach that paces
  me", "timed audio guide", or any piece where a rest interval must be exactly N seconds because
  the PROTOCOL says so, not because that is how long the narration ran. Covers the prescriptive
  timeline, exact-BPM tempo locking (Lyria 3 refuses numeric BPM, so the grid is synthesized), the
  slot-fit gate that forces copy to fit its window, per-clip levelling, and a rep-lock assertion
  that proves cues land on the beat in the rendered audio. NOT for a script-driven piece whose
  timing follows the performance (use `audio-drama`), NOT for video (`hyperframes`,
  `seedance-narrated-short`), NOT for authoring ElevenLabs markup (`elevenlabs-tts-scripting`).
author: Claude Code
version: 1.0.0
date: 2026-08-24
---

# Timed guided audio

## Problem

`audio-drama` builds a piece FROM a script: narration is rendered, its durations are measured, and
the timeline is derived from them. Timing is emergent.

Guided audio inverts that. Rest is 120 seconds because physiology says so. A hold is 30 seconds
because the protocol says so. The schedule is fixed first and **the narration has to fit inside
it.** Every part of the architecture follows from that inversion, and reusing the emergent-timing
pipeline for this produces audio that drifts, rushes, or silently talks over itself.

The second problem is that the obvious way to fill time is forbidden. You cannot stretch a clip to
reach the next cue: time-stretching smears speech audibly and is a worse artefact than whatever it
was correcting.

## Trigger conditions

- A routine, protocol, or program with explicit intervals needs to become audio
- The user says "count", "pace me", "timed", "intervals", "coach me through"
- A rest, hold, or gap has a number attached that came from the domain, not from the audio
- Any request where the listener will be MOVING and cannot look at a screen

## Solution

### 1. One source of truth, and it is data

Put the whole protocol in a single JSON file: sets, reps, tempo, interval lengths by variant, and
every line of spoken copy. The timeline builder reads it and emits absolute cue offsets, music
sections, and chapters. Retuning any interval then re-renders everything with no code change.

### 2. Never stretch. Remove the lever entirely

Fill time with exactly two things: a clip at its natural rendered length, and true digital silence
of a computed duration. **Delete the `speed` parameter from the TTS wrapper** so the rule is
structurally enforced rather than remembered, and keep `rubberband` / `atempo` out of the repo.
`grep -rE "rubberband|atempo|speed" .` should return nothing outside comments.

### 3. Counts must be individual clips

Rendering "one… two… three" as one utterance lets the MODEL decide the gaps, and the gaps are the
tempo. Render each number once, place each at an exact offset with `adelay`. Deduplicating by
hashed text is what makes this cheap: in the reference build 215 unique clips covered 4,382
placements for about five cents.

### 4. Lock the tempo by synthesizing the grid

**Lyria 3 cannot be given a numeric BPM** (no BPM values, no key signatures, descriptive tempo
only) and Lyria RealTime, which could, is no longer on the key. So split the bed:

- **Lyria writes harmony and character.** Prompts must forbid drums outright, or its beat fights
  yours and neither can be stretched to agree. State what must NOT happen ("no build, no climax,
  no resolution") or it writes a song with an arc.
- **A numpy layer writes the grid**, placing each hit at `round(beat_index * 60/bpm * SR)`. Exact
  by construction: no drift across a twelve-rep set, no measure-and-reroll loop.

Choose tempos so one rep is a whole number of 4/4 bars: 3.0 s = 1 bar at 80 BPM, 4.0 s = 2 bars at
120, 5.0 s = 2 bars at 96.

Render the grid for a whole session in ONE pass with each section starting at its own offset.
Slicing a single global click track does not work: a set beginning at 1234.5 s finds the grid
mid-beat.

### 5. The slot-fit gate

Every cue carries `{text, slotStart, slotEnd}`. After rendering, measure. If the clip is longer
than its slot, **fail the build** and print the cue, its measured duration, and a word budget.
The only remedy is to rewrite the line shorter. Also gate on pairwise collision using measured
durations. Size any narration window to its copy (`max(floor, predictSec(text) + margin)`) so
editing a line cannot silently overflow.

### 6. Level every clip, then the bus

TTS returns each utterance at its own level. Across 215 clips the perceptual spread was 6.4 dB,
which is inaudible once and a fault when the count word repeats 241 times in one session.

- Metric: **p90 of 50 ms window RMS.** Full-clip RMS is dragged down by the tail of a vowel so a
  one-word clip measures far quieter than it sounds; peak tracks plosives the ear discounts.
- **Gain FIRST, limit second.** Compressing before the gain (tried at three strengths) moved crest
  only 22.5 → 19.2 dB and left the peak ceiling binding, so most clips never reached target.
  Gain-then-limit took the spread to 0.0 dB.
- Same for the bus: level it to a **measured speech level**, never to its integrated loudness. The
  voice stem is ~85% digital silence, so EBU R128 reads 4-9 dB below the actual speech and asks the
  mix for gain the limiter then eats, audibly crushing the cues.

### 7. Verify the claim, not the arithmetic

Assert **rep lock** on the rendered audio: detect real onsets in the pulse track and measure how
far each count sits from the nearest one. Reference build: 100% of 241 counts within 40 ms, median
4.45 ms. Verifying the timeline maths would only prove the maths.

## Verification

Ship gate per file: duration vs timeline ±0.6 s · integrated loudness in a band chosen for THIS
content · true peak · speech level asserted separately · zero dead blocks · ducking measured on the
isolated ducked-music branch · chapter count · embedded cover · **rep lock**.

## Gotchas that cost real time

- **`alimiter` auto-levels by default.** `level` defaults to `true`, normalising output UP to the
  limit instead of only attenuating. It overrides measured gain staging and pins every file's peak
  at the ceiling, so lossy encode overshoot pushes true peak over. Always `level=disabled`.
- **The ceiling is the lever for peaks, not the trim.** With `level=disabled` the limiter clamps at
  the ceiling regardless of input, so backing off an upstream gain lowers loudness without lowering
  the peak at all.
- **Encode overshoot is material-dependent** (0.5-1.2 dB; short bright transients worst). Do not
  hand-tune one ceiling for every style: encode, measure the encoded file's true peak, lower the
  ceiling by the measured excess, re-encode.
- **Loudness targets are content-specific.** A guided session is ~15% speech over a deliberately
  quiet bed; forcing the -16 LUFS podcast figure means crushing the voice to make a bed that is
  meant to sit back sound loud. -20 LUFS with speech at about -15 dBFS is the honest shape.
- **Ducking cannot be measured from the master** (voice and bed are summed there). Emit the
  isolated ducked-music branch and measure that.
- **An in-process worker pool around `spawnSync` gives zero concurrency.** Spawn child processes.
- **Measure the right artifact.** Read truncation off the RAW API response, not a file you have
  since trimmed; trimming removes exactly the decay a tail test looks for.

## Reference implementation

`~/.claude/projects/recomp-audio-guides` — 40 masters (4 music styles x 5 sessions x 2 rest
variants), every gate passing. `plan/timeline.mjs` is the timeline, `music/pulse.py` the grid,
`voice/gate.mjs` the slot-fit gate, `verify-master.mjs` the ship gate.

## Notes

See also: `audio-drama` for the emergent-timing case (script in, performance sets the pace) — it
owns casting by measured F0, foley, and the multi-voice mix, all of which apply here too.
`heuristic-detector-hygiene` for the discipline behind the gates. `media-use` for asset sourcing.

Related memories: `feedback-ffmpeg-alimiter-auto-level-defeats-gain-staging`,
`feedback-measure-the-right-artifact-not-the-threshold`,
`feedback-never-author-code-through-a-shell-command`,
`feedback-spawnsync-pool-gives-zero-parallelism`, `feedback-xai-tts-runs-fast-pacing-levers`,
`reference-lyria-3`.

## References

Findings here are empirical, verified against rendered artifacts in the reference build rather
than taken from documentation. The one API fact was confirmed against ffmpeg's own filter help
(`ffmpeg -h filter=alimiter`), which is the primary source for its defaults.
