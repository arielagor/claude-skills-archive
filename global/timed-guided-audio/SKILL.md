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
  that proves cues land on the beat in the rendered audio. Also the contemplative variant (hypnosis,
  meditation, self-inquiry in a cloned voice): named gap tiers as the only pacing lever, a runtime
  scaler over the contemplative tiers, bed ranking by hypnotic score before generating anything,
  a local STT omission check with homophone folding, and publishing the master as an agor.me
  podcast episode. NOT for a script-driven piece whose timing follows the performance (use
  `audio-drama`), NOT for video (`hyperframes`, `seedance-narrated-short`), NOT for authoring
  ElevenLabs markup (`elevenlabs-tts-scripting`).
author: Claude Code
version: 1.1.0
date: 2026-09-01
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

## Variant: contemplative pieces (hypnosis, meditation, self-inquiry)

Added 2026-09-01 from the satori-session build ("Could You Stop It Completely?", 45:00, Ariel's
xAI clone `gpp66sriwbgy`, every gate passing). Same inversion as the workout case, with one
difference: there is no grid and no slot. The silence IS the protocol, so the timeline is measured
clip + prescribed gap, and the gaps are the whole design surface.

### V1. Named gap tiers, and the clone at native pace

Every line in `script/script.json` carries a tier name, not a number:

```json
"gaps": { "beat": 1.2, "pause": 2.5, "long": 5, "settle": 10, "abide": 25, "open": 150 }
```

`beat` and `pause` are conversational rhythm, `long`/`settle`/`abide` are contemplative, `open`
is the single final drop (bed only). Retuning how the whole session breathes is a six-number edit
followed by `timeline && build-voice && mixdown && verify`; nothing else moves. **The voice is
never slowed.** Ariel's standing correction (2026-08-22): "use the normal way the xAI outputs the
script, don't slow it down, it just sounds weird." So no `speed`, no `atempo`, no sentence
splitting of a paragraph to manufacture gaps. Hypnotic pace comes from short utterances (8 to 32
words, one idea each, one TTS call each) and digital silence between them. Gap rules that keep a
hypnotic subject held instead of asleep: any gap of 25 s or more is entered on a question or a
stay-awake line; any gap over 90 s except the final drop gets a two-word touch ("just this").

### V2. The runtime scaler touches only the contemplative tiers

`timeline.mjs` sums the fixed part (measured voice, `beat`/`pause`/`open` gaps, lead-in, tail-out)
and the scalable part (`long`/`settle`/`abide` at base values), solves
`factor = (target - fixed) / scalable` exactly, clamps it to 0.7 to 2.5 and logs if the clamp
binds, then fails the build if the total lands outside the runtime band (43 to 47 min for a 45
target). Extra runtime therefore lands after instructions and questions, never mid-induction and
never as a slower voice. Reference: 144 cues, factor 1.481, voice 16:09, silence 28:51,
total 44:59.8, `long 5 -> 7.4`, `settle 10 -> 14.81`, `abide 25 -> 37.02`.

### V3. Rank the beds on disk before generating one

`music/rank.py` scores every candidate on four ratios (40 to 500 Hz energy share, 6 to 12 kHz
energy share inverted, crest inverted, 2 s window envelope spread inverted; the original
analyser's duration weight is dropped because every candidate is looped), normalises within the
candidate set and writes `beds/rank.json` plus the winner to `beds/bed.mp3`. The committed
recomp bed `clean/rest.mp3` won at **0.851** against the best of three fresh Lyria 3 Pro takes at
**0.629** (high band -57.6 dB vs -40 to -50, envelope std 2.1 dB). So: score the beds already on
disk first and generate only if none clears the bar. Lyria output is not reproducible from its
prompt, so commit whichever take ships. Lyria rejects any prompt that names an artist ("in the
style of X", Prohibited Use on every attempt); describe the sound instead. An iCloud placeholder
(`RECALL_ON_DATA_ACCESS`) makes ffprobe say "Invalid argument" and a copy hang until the cloud
times out; skip it or hydrate from the Mac. No binaural or isochronic layer: the absorption stage
asks the listener to rest on their own pleasant sensation, and an entrainment tone competes with
it (decision 001 in the reference repo).

### V4. Truncation gate on the RAW tail, then an STT omission check

xAI returns HTTP 200 with a cut-off body often enough that status is not evidence. `voice/gate.mjs`
reads `parts/manifest.json`, whose tail figure `render.mjs` measured on the RAW response before
trimming (last 80 ms peak vs clip peak, abrupt if above -12 dB; also under 800 bytes, under 0.10 s
per word, or over 300 wpm on 12+ words). The trimmed copy cannot be tested: trimming removes
exactly the decay a tail test looks for.

A clip that drops a clause mid-sentence has a clean tail, so the truncation gate cannot see it.
`tools/stt.py` transcribes every levelled clip with faster-whisper `small` (CPU int8, local, free,
`condition_on_previous_text=False`, keeps existing entries so a re-render transcribes only the
changed clips) and `voice/verify-clips.mjs` fails any clip over **15% WER** after normalising both
sides (lowercase, digits spelled out, punctuation stripped, clips under 1 s exempt because Whisper
hallucinates on them). **Fold homophones** before comparing (`four/for`, `two/too/to`,
`onto/on to`): Whisper picks the spelling by context, and a countdown "four" heard as "for" is a
false failure. Read the diff, not only the number: "a tension too" transcribed as "attention to"
is what a listener in a deep state will hear, and it is a script fix, not an STT fix. Reference:
143 clips, mean WER 0.8%, none over 15%. First pass about 16 min CPU, seconds after.

### V5. Ship gate for a contemplative master

Same shape as the workout gate with the content-specific numbers: integrated -23 to -19 LUFS
(bed at a measured -30 LUFS pre-duck, speech target -17 dBFS on `vo.wav`), true peak at or below
-1.0 dBTP, bed continuity on the isolated `duckout` stem (no 12 s block below -55 dBFS outside
the fade windows, so a listener never thinks the file ended), longest silent run in `vo.wav` no
more than the longest named gap plus 1 s (proves nothing fell out of the timeline), chapter count,
embedded cover. Reference master: 45:00.0, -21.4 LUFS, -2.60 dBTP, speech -17.0 dBFS, duck
-8.3 dB, 8 chapters.

### V6. Publishing the master as an agor.me podcast episode

Three artefacts on `main` plus one blob; no NotebookLM, no post. Upload with
`uploadEpisodeAudioToBlob(fs.readFileSync(mp3), "YYYY-MM-DD")` from the agor.me repo (cwd there so
`dotenv` finds `.env.local`; the 62 MB set 403'd once and the helper's retry landed). Verify by
HEAD 200 and a tail `Range` 206 whose bytes equal the local tail; the route is `force-dynamic`, so
audio is live before any deploy. Episode mdx in `src/app/resources/episodes/<date>-<slug>.mdx`
(`publishedAt` long form, `audioUrl: "/episode-audio/<key>"`, `duration: "MM:SS"`, `papers: []`,
`keyInsights: []`, HTML body); cover 1400 to 3000 px square RGB with no alpha (check magic bytes,
the reference `art/cover.png` was a JPEG). The feed is `force-static`, so the item appears on the
next build; Spotify has no publish API and crawls on its own schedule. **If the checkout is on
another session's branch, publish through a detached worktree** at `origin/main` with a junction
to the main tree's `node_modules` so husky and tsc run, push `HEAD:main`, and delete the junction
with `(Get-Item).Delete()` BEFORE removing the worktree or the removal recurses into the real
`node_modules`. Never run `scripts/notify-episode-published.ts` unless subscribers are meant to be
emailed. Details: memories `feedback_detached_worktree_publish_junction_node_modules` and
`reference_agor_blog_publish_and_podcast_from_post`.

### Contemplative gotchas

- The 22 MB mobile copy and an 11 MB lite copy both timed out on `SendUserFile` (30 s window,
  three attempts). The cap is 30 MiB; the practical ceiling that day was under 11 MB. Send the
  script and a short excerpt, put the masters on iCloud and the mounted Drive.
- `build-voice` about 2 min, `mixdown` about 3 min at 45 min of audio, and `placeCues` writes
  ~2 GB of full-length mono wavs to `build/tmp`. Run both detached (`Start-Process node
  -RedirectStandardOutput`) and poll with `Get-Process`; the shell tool kills foreground commands
  at 10 minutes. `Tee-Object` inside a background PowerShell task never creates its log file.
- Commit `parts/raw/` and `beds/`: xAI TTS is not deterministic (a re-render changes every
  duration and therefore the timeline) and Lyria is not reproducible from its prompt.
- Keep Pali, Sanskrit, and Japanese terms out of the spoken text (TTS mispronunciation, and the
  listener does not need them); say "joy", "absorption", "stillness". Denylist grep in the docs
  build. Stages that pose inquiry questions never assert the answer; grep fails on "there is no",
  "you are awareness", "no one is".

## Reference implementations

`~/.claude/projects/recomp-audio-guides`: 40 masters (4 music styles x 5 sessions x 2 rest
variants), every gate passing. `plan/timeline.mjs` is the timeline, `music/pulse.py` the grid,
`voice/gate.mjs` the slot-fit gate, `verify-master.mjs` the ship gate.

`~/.claude/projects/satori-session` (private `arielagor/satori-session`): the contemplative
variant, one 45:00 master, every gate passing. `script/script.json` holds the gap tiers,
`timeline.mjs` the scaler, `music/rank.py` the bed ranking, `voice/gate.mjs` the raw-tail
truncation gate, `tools/stt.py` + `voice/verify-clips.mjs` the omission check, `verify-master.mjs`
the ship gate, `HANDOFF.md` the change recipes, `docs/decisions/001-runtime-pace-bed-no-binaural.md`
the decisions.

## Notes

See also: `audio-drama` for the emergent-timing case (script in, performance sets the pace); it
owns casting by measured F0, foley, and the multi-voice mix, all of which apply here too.
`heuristic-detector-hygiene` for the discipline behind the gates. `media-use` for asset sourcing.

Related memories: `feedback-ffmpeg-alimiter-auto-level-defeats-gain-staging`,
`feedback-measure-the-right-artifact-not-the-threshold`,
`feedback-never-author-code-through-a-shell-command`,
`feedback-spawnsync-pool-gives-zero-parallelism`, `feedback-xai-tts-runs-fast-pacing-levers`,
`reference-lyria-3`, `project_satori_session`, `feedback_lyria_blocks_artist_names_in_prompts`,
`feedback_detached_worktree_publish_junction_node_modules`,
`reference_agor_blog_publish_and_podcast_from_post`, `feedback_senduserfile_delivery_surface_gap`.

## References

Findings here are empirical, verified against rendered artifacts in the reference build rather
than taken from documentation. The one API fact was confirmed against ffmpeg's own filter help
(`ffmpeg -h filter=alimiter`), which is the primary source for its defaults.
