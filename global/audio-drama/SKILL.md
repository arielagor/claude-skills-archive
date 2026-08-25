---
name: audio-drama
description: >-
  Produce a finished AUDIO-ONLY multi-voice piece from a script: a radio drama, an audio play,
  a narrated essay, a multi-character audiobook, or a scripted podcast episode. Use when the ask
  is "turn this script into a radio drama", "make this into an audio piece / audio play",
  "narrate this with different voices for each character", "produce this as an mp3", or any
  script that needs casting, a score, ambience, a mix, and a delivered audio master. Covers the
  whole pipeline: structured script model, casting by MEASURED pitch, xAI Grok TTS, a Google
  Lyria 3 score, synthesized foley, stem assembly, ducked mixdown, and a ship gate. NOT for video
  (use `seedance-narrated-short` for narrated film, `hyperframes` for motion graphics,
  `ai-commercial` for dialogue ads), NOT for writing the script text itself, and NOT for
  ElevenLabs markup authoring (use `elevenlabs-tts-scripting`), and NOT for audio whose timing is
  PRESCRIBED rather than emergent, such as a counted workout, an interval timer, a meditation or a
  hypnosis track (use `timed-guided-audio`, which inverts this pipeline). Reference
  implementation: `~/.claude/projects/the-unfurling`.
author: Claude Code
version: 1.1.0
date: 2026-08-22
---

# Audio drama, the proven pipeline

Reference implementation: **`~/.claude/projects/the-unfurling`** ("The Unfurling", a ten-section
Joe Frank style radio drama, 2,133 words, five voices, 14:40). Every script named below exists
there, working. Copy the repo and localize rather than starting from scratch.

## Problem

Turning a script into a finished audio piece has five failure modes that all look like success:
a TTS response that returns HTTP 200 with truncated audio, a music bed mixed louder than the
narrator, a mix that silently amputates its own ending, over-processed speech that sounds
subtly wrong, and a cast whose voices blur into each other. None of these throw an error.

## Pipeline

```
script/script.mjs     the script, VERBATIM, as segments with speakers and pauses
script/cast.mjs       speaker -> voice + treatment chain
script/timeline.mjs   SINGLE SOURCE OF TRUTH for every offset
narrate.mjs           TTS + truncation gate
gen-lyria.mjs         Lyria 3 score cues (cached by output path)
sfx.py                synthesized foley
build-voice.mjs       -> build/vo.wav
build-score.mjs       -> build/score.wav
build-amb.mjs         -> build/amb.wav
mixdown.mjs           duck, master, embed art -> the mp3
verify-master.mjs     ship gate
```

Never re-declare timeline constants in a build script. Four copies is how stems drift apart.

## The rules that matter

### 1. Ship the TTS at its native pace

Do NOT slow narration with a `speed` reduction, a `rubberband` time-stretch, or sentence-level
splitting. This was tried and rejected on listening: time-stretching smears speech (the artefact
is worse than the fast pace it corrects), and splitting a paragraph at every period discards the
intonation the model carries across sentence boundaries.

**One TTS call per PARAGRAPH.** If the piece must breathe more, widen the silence BETWEEN
paragraphs, which costs no audio quality. See `feedback-xai-tts-runs-fast-pacing-levers`.

### 2. Cast by measured F0, not by the voice descriptions

Provider tone blurbs ("warm", "authoritative") are marketing copy, not data. Render each
candidate on a real line from the script and autocorrelate for fundamental frequency. Aim for at
least 25 Hz between any two speakers, and never let two characters who share a scene sit close.

The Unfurling's cast, for calibration: narrator (Ariel's clone `gpp66sriwbgy`) 90 Hz,
`altair` 118, `helix` 165, `luna` 176, `celeste` 208.

Counter-intuitively, a warm reassuring voice reading institutional copy ("your grief is important
to us") is colder than a robotic one. Cast against the obvious.

### 3. Clean lead, degraded diegetic

Process only what IS a recording inside the fiction: a cassette, a phone line, an intercom. Keep
the narrator dry and close. The contrast does the work, and it keeps a long piece intelligible.
Telephone band is 300 to 3400 Hz; cassette is roughly 180 to 6200 Hz plus a slow `vibrato` wow.

### 4. Score levels are MEASURED, never guessed

The single most damaging bug in this pipeline: a first mix had the score at -12.4 LUFS against a
voice at -25.4 LUFS, so the bed was 13 dB LOUDER than the narrator. Ducking modulates a
relationship, it cannot invert one.

Run `ebur128` per stem and compute the gain to a target:

```js
const m = stderr.match(/Integrated loudness:[\s\S]*?I:\s*(-?\d+\.?\d*)\s*LUFS/);
const gainFor = (measured, target) => Math.pow(10, (target - measured) / 20);
```

Targets that worked: **voice -18, music bed -31, ambience -34 LUFS**, then a gentle
`sidechaincompress` ratio 6, then master `loudnorm=I=-16:TP=-1.5:LRA=11`. `spawnSync` needs
`maxBuffer: 1 << 26` or ebur128's per-frame progress truncates stderr and every match returns
`NaN`. See `feedback-set-bed-levels-from-measurement`.

### 5. If the piece has more than one speaker, give the other voices their own bed

The lead's music belongs to the LEAD. When the piece cuts to someone else's testimony, drop the
main bed (0.10 to 0.22) and bring up a cue that belongs to that character. The main bed returning
afterwards then reads as an event. Verify by measurement, not by intent: monologue sections
should sit clearly above testimony sections in level, and ideally differ in spectral centroid.

Slice bed regions from ONE full-length render at their own absolute times with about 1.4 s of
overlap. Because neighbouring slices are literally the same samples over the overlap,
complementary linear fades sum back to unity: no dip where the gain is equal, a smooth ramp where
it changes.

### 6. The truncation gate is not optional

TTS providers return HTTP 200 with a truncated body. The log says ok, the file is short, and the
stitch, the export and the file listing all accept it.

**Primary signal: tail abruptness.** A truncated response stops mid-waveform at full amplitude; a
complete render decays into silence. Measure the last 80 ms peak relative to the file peak.
Complete renders land at -26 to -34 dB; a mid-word cut lands near -10 dB. Threshold -12 dB.

Words-per-minute is a SECONDARY check only, and only at 12 or more words. It false-positives on
short utterances where the render's own lead-in dominates. Do not respond to a false positive by
widening the threshold; that trains you to ignore the gate. See
`feedback-prefer-direct-signal-over-proxy-in-detectors`.

**Prove both layers against a deliberately truncated file.** One such test revealed the tail
check would have been dead code if the cut had landed in silence.

### 7. Three ffmpeg traps that silently amputate the ending

```
[vo]  acompressor=...
      asplit=2 -> [vokey][vomix]      # a filter output can only be consumed ONCE
[vokey] apad                          # sidechaincompress ends with its SHORTEST input
[bed][vokey] sidechaincompress=...
      amix=inputs=2:duration=longest:normalize=0
```

- **`asplit`**: reusing a bare `[vo]` label leaves the second reference unresolved and ffmpeg
  reads it as a stream specifier ("Stream specifier 'vo' matches no streams").
- **`apad` the KEY**: without it the ducked bed dies the instant the last word does, taking the
  whole tail with it.
- **`normalize=0` on EVERY amix**: the default rescales by active-input count and pumps the bed.
- **Never `-shortest`**, and **assert the OUTPUT's audio stream duration after encoding**.
  Checking the inputs is not enough; the filtergraph itself can truncate.
- `-t` truncates but never EXTENDS. Pad the voice stem with `apad` so all stems match the
  timeline, or the sidechain key dies early.

### 7b. A fourth trap: `alimiter` auto-levels by default

**Always `alimiter=limit=X:level=disabled`.** Its `level` option defaults to `true`, which is auto
level: it applies gain so the output peak REACHES the limit. It is a normaliser with a ceiling,
not a ceiling.

That silently undoes the measurement discipline in section 6 above. In a 2026-08-24 build the
final trim came out at **-0.20 dB where it should have been +3.00 dB** — the limiter was doing the
levelling and every carefully measured stem gain upstream was decorative. It also pins each
master's peak exactly at the ceiling, so lossy-encode overshoot (0.5-1.2 dB, worst on short bright
transients) pushes true peak over a -1.0 dBTP gate. 19 of 40 files failed for that reason alone.

Consequences worth internalising:

- **The ceiling is the lever for peaks, not the trim.** With `level=disabled` the limiter clamps at
  the ceiling regardless of what is fed in, so backing off an upstream gain lowers loudness without
  lowering the peak at all.
- Set the sample ceiling BELOW the true-peak target, or better: encode, measure the encoded file's
  true peak, lower the ceiling by the measured excess, re-encode.
- ⚠ `~/.claude/projects/the-unfurling/mixdown.mjs:91` and `script/cast.mjs:25,32` still omit the
  flag. That master measured fine (-16.3 LUFS / TP -1.4), so the effect there was evidently small
  and I did not chase why; set the flag anyway rather than rely on it.

## Score and foley

**Score: Google Lyria 3** (`lyria-3-pro-preview`) via the Gemini Interactions API. Query
`v1beta/models` first rather than assuming which model is current. Prompt for underscore by
stating what must NOT happen ("no build, no climax, no resolution, no percussion"), or it writes
a song with an arc. See `reference-lyria3-google-music-generation`.

**Derive everything from one cue where the script allows it.** Autocorrelate the render's energy
envelope to find its true loop period (The Unfurling's came back at exactly 16.000 s, four bars at
60 BPM), then build the bed, any diegetic variant (slowed, band-limited) and the tail from that
single cell. It is why a piece hangs together.

**Foley: synthesize it.** `sfx.py` in the reference repo generates room tone, tape hiss, cassette
transport, dial tone (350+440 Hz), DTMF, ringback (440+480 Hz), busy, line noise, carrier hum and
a tape-out, all from numpy/scipy primitives with a fixed seed. It is deterministic, regenerable,
and carries no licence question. Verify telephony spectrally; the real signalling frequencies are
free and correct.

## Ship gate

`verify-master.mjs` prints the number it measured for every check:

- output audio-stream duration matches the built timeline
- integrated loudness in range, true peak below clipping
- no unintended dead air across the timeline
- speech windows measurably louder than bed-only windows (voice should sit 5 dB or more above)
- speech-band (200 to 4000 Hz) energy higher during speech
- the ending behaves as the script says it does
- every part passed the truncation gate

**Adapt the ending assertion to the script.** The generic "last 1.5 s below -45 dB" is wrong for a
piece that ends on a hard cut. The Unfurling ends with a tape running out, so the assertion became
"the bed is still audible immediately before the stop, the drop is abrupt, and the file ends in
true silence".

## Rights

Everything in a delivered piece should be generated on the user's own keys or synthesized. Before
reaching for anything found on disk, check its licence: AI music services often reserve
film/TV/streaming use for higher tiers, and a voice clone of a real identifiable person is a
publicity-rights problem independent of copyright. Record what was deliberately NOT used, and why,
in a `CREDITS.md`.

## Delivery

A finished master is often too large for a chat upload channel. On Ariel's machine, Google Drive
is MOUNTED (`G:\My Drive` for ariel.agor@gmail.com, `H:\My Drive` for ariel@agor.me), so copying
there is plain filesystem I/O with no size limit. Check the mount before reaching for an upload,
a token, or the browser. **Version delivered files rather than overwriting them**; a replaced
master is only recoverable if it was tracked in git.

## Notes

- Track the master in the repo. It is the deliverable, and it is what made a v1 recoverable
  byte-identically after an overwrite.
- Foley is deterministic and belongs in `.gitignore`; Lyria renders are NOT reproducible from the
  prompt and must be committed.
- Embed cover art as an ID3 APIC frame mapped as a video stream with `-c:v copy
  -disposition:v:0 attached_pic`. Without the disposition flag mp3 tries to encode it as a rolling
  video track and some players choke.
- Chapters via an ffmetadata file and `-map_chapters`.

## See also

`seedance-narrated-short` (narrated film, video), `ai-commercial` (lip-synced dialogue ads),
`elevenlabs-tts-scripting` (authoring script text for ElevenLabs markup), `media-use` (media
resolution and the audio engine), `hyperframes-audio` (mixing inside HyperFrames compositions).
