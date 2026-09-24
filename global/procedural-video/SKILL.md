---
name: procedural-video
description: >-
  Turn a song, a podcast or interview recording, or a script into a finished video where every frame is
  drawn by code Claude writes, in a look chosen from a gallery of 17 presets (moving oil painting, clean
  illustration, ink wash, woodcut, halftone comic, watercolor, and variants), cut to the audio's own
  words and beats, delivered in 16:9, 9:16 and 1:1 from one project. Use when the ask is "make a music
  video for this song", "turn this podcast / episode / interview into a video", "animate this script",
  "narrate and animate this", "make a song from these lyrics and a video for it", "painted video",
  "visual podcast", "video for this audio", or any piece that needs original animation (not stock, not AI
  footage) landing on the audio. Covers intake, audio prep (xAI TTS narration in Ariel's cloned voice,
  Lyria 3 songs, clipping long recordings), local timing analysis (faster-whisper word timestamps,
  Needleman-Wunsch alignment to known text, numpy beat tracking), storyboard, the director + parallel
  chapter-subagent build, contact-sheet QA at every aspect, and a resumable parallel render. The picture
  costs nothing in media APIs. NOT for HTML motion graphics, kinetic typography or lyric-card videos (use
  `hyperframes`), NOT for AI-generated footage films (use `seedance-narrated-short`), NOT for lip-synced
  dialogue ads (use `ai-commercial`), NOT for audio-only pieces (use `audio-drama` or `timed-guided-audio`,
  whose masters make good inputs here). Reference implementation: `~/.claude/projects/procedural-video`,
  an engine port of ledbetterljoshua/functional-emotions-video proven bit-exact against the original.
author: Claude Code
version: 1.0.0
date: 2026-09-23
---

# procedural-video

Every frame is a **pure function of time** that Claude writes as Canvas2D code: a scene draws a flat
underpainting `s` and an additive light layer `f`; a **look** (painted brushstrokes, or clean) turns them into
the frame; Chrome renders frames in parallel out of order; ffmpeg muxes the audio. The timing comes from the
audio itself: word-level timestamps aligned to the known text, a beat grid for music, audio features for
modulation. The process that made the original 6-minute painted music video (168 shots) is encoded here:
storyboard → director writes the reference chapter → parallel subagents each paint one chapter → contact-sheet
review → render.

**Reference implementation: `~/.claude/projects/procedural-video`** (repo; engine, tools, analysis, templates,
the original video as a port fixture, smoke-test examples). New videos are scaffolded from it into their own
folder under `~/.claude/projects/<slug>/` with the engine vendored in.

## The pipeline

```
0 intake        mode · files · aspects · look · captions · clip-or-episode · direction
1 scaffold      node ~/.claude/projects/procedural-video/tools/new_project.mjs  -> ~/.claude/projects/<slug>/
2 audio         song: as given | lyrics->song: scripts/gen_song.mjs | script->narration: scripts/narrate.py
                long recording: scripts/clip.py (clip jobs)
3 analysis      python analysis/run.py --project .   -> data.js (META/TEXT/FEAT) + data.summary.txt
4 prove         placeholder scene: check --auto 6 --aspect all, render 10 s     (pipeline works before art)
5 storyboard    STORYBOARD.md from data.summary.txt (every Time from the printout)
6 reference     theme.js + cast.js + scenes/c1.js by the director; sheets at every aspect  [creative gate]
7 chapters      ANIMATION_GUIDE.md filled; one opus subagent per chapter, in parallel, own file only
8 review        director reads every chapter's sheets, sends notes back, fixes shared bugs
9 render        bench once per machine; render --aspect all; ffprobe gate; SendUserFile
```

All commands below run **from the project folder** unless they start with the repo path.

## 0 · Intake (one AskUserQuestion, grouped)

Ask only what isn't already clear from the request:

| Decision | Options | Default |
|---|---|---|
| Mode | **song** (audio + lyrics) · **lyrics → song** (Lyria makes the track) · **podcast** (a recording; optional speaker-labelled transcript `NAME: text`) · **script → narration** (xAI TTS) | from the files given |
| Aspects | any of 16:9, 9:16, 1:1 (one project renders all) | all three |
| Stage | the aspect you compose for; others are crops of it | 16:9, or 9:16 if vertical-first |
| **Look (preset)** | one of the 17 presets below, **chosen from the gallery** (see "Choosing the look") | `paint` |
| Captions | off · lines · words (highlighted spoken word) | off for music, words for speech |
| **Long audio (> ~5 min)** | **clip** (1–5 min segments at full density) or **full episode** (sets, lower density). **Always ask; never assume.** | — |
| Direction | one or two lines in the user's words; "your call" is fine | — |

### Choosing the look (always, before any creative work)

Unless the request already names a look, **show the options before scaffolding**:
1. `SendUserFile` the gallery **`~/.claude/skills/procedural-video/references/look-gallery.jpg`** (all 17 presets on
   the same frame, labelled), with the list below.
2. Ask with AskUserQuestion: first the **family** (Painted · Clean · Ink & print · Watercolor), then the **variant**
   inside it (≤ 4 options each; "Other" takes any preset name). Recommend what suits the material: music → Painted;
   speech with captions → Clean or Halftone; literary / sombre → Ink or Woodcut; gentle / warm → Watercolor.
3. The paint variants differ mostly in **motion** (boil rate, stroke size), which a still can't show. If the choice is
   between paint variants, render a 5 s preview of each on the project once chapter I exists
   (`node tools/render.mjs --from 20 --to 25 --preset paint-loose`) instead of arguing from stills.
4. Scaffold with `--preset <name>`. It can change later: the look is chosen at render time and every preset renders the
   same scenes. Once chapter I exists, re-check on the project's own frames:
   `node tools/looks.mjs out/check/looks.jpg --times <3 good times> --presets <2-4 candidates>`.

| Family | Presets (`--preset`) |
|---|---|
| Painted | `paint` (default: moving oil painting) · `paint-loose` (impressionist) · `paint-gouache` (tight, calm) · `paint-still` (meditative) · `paint-agitated` (chaotic) · `paint-dreamy` (heavy warm bloom) |
| Clean | `clean` (as drawn, light grain) · `clean-flat` (bold flat graphic) · `clean-film` (grain + vignette) |
| Ink & print | `ink` (ink wash on cream paper) · `ink-sumi` (tinted sumi-e) · `woodcut` (carved linework, hatching) · `woodcut-spot` (woodcut on tinted paper) · `halftone` (comic dot screen, bold outlines) · `halftone-pop` (bigger dots, fewer colours) |
| Watercolor | `watercolor` (transparent washes, bleeding colour, wet rims) · `watercolor-wet` (more bleed, heavier granulation) |

Presets live in `engine/looks/presets.json` (look + base settings + multipliers). Scene code still wins over a
preset's base settings; the preset's multipliers apply last. Details and every setting: [references/looks.md](references/looks.md).

Narration voice is Ariel's clone **`gpp66sriwbgy`** ("Ariel Agor - Smooth") unless told otherwise. Music via
Lyria: no artist names, no numeric BPM (both are refused or ignored).

## 1 · Scaffold

```
node ~/.claude/projects/procedural-video/tools/new_project.mjs --name "Title" --mode song|podcast|narration \
  [--audio file] [--text lyrics.txt|script.txt|transcript.txt] [--text-format lyrics|script|speakers] \
  [--stage 16:9] [--aspects 16:9,9:16,1:1] [--preset <name>] [--captions off|words|lines] [--density clip|episode] \
  [--slug name] [--dest dir] --git          # --git for projects under ~/.claude/projects, not inside another repo
```
Copies engine/tools/analysis/scripts + templates, writes `project.json`, runs `npm install`, prints next steps.

## 2 · Audio

- **Song given:** nothing to do. Lyrics as plain lines; `[Chorus]` tags and `(x2)` are handled.
- **Lyrics → song:** `node scripts/gen_song.mjs --lyrics assets/lyrics.txt --prompt "<genre, mood, instruments, vocal>" --out assets/song.mp3`
  (`lyria-3-pro-preview`, GEMINI_API_KEY, ~$0.08; `--dry-run` shows the prompt). Lyria returns the lyrics **as sung**
  (its own sections, repeats and ad-libs) next to the audio: gen_song saves them as `assets/lyrics_sung.txt`. **Set
  project.json `"text"` to `lyrics_sung.txt`, not the lyrics you sent**, and `"audio"` to the mp3. `--duration` is a hint
  Lyria may ignore (asked 1:20, got 2:42): render the range you need with `--from/--to`.
- **Script → narration:** `python scripts/narrate.py --script assets/script.txt --out-dir assets [--voice gpp66sriwbgy]`
  → `narration.mp3` + `narration_lines.json` (exact line offsets, used as a prior by alignment), and it sets the
  project's `"audio"` itself. One line per sentence or beat; a blank line = paragraph gap.
- **Clip jobs:** `python scripts/clip.py --in long.mp3 --out assets/clip.mp3 --from 612.4 --to 790`. Pick ranges from a
  first-pass transcript (`run.py` on the full file, then read `data.summary.txt`). The clip can keep the FULL transcript
  as its `"text"`: alignment detects the length mismatch and trims the known text to what the clip contains
  (measured: 50 s of a 15-min drama against its 2,133-word transcript → exactly the 6 lines in the window, 100%).

## 3 · Analysis

```
python analysis/run.py --project .          # stages: features, beats (music), transcribe, align | segment, build
```
Writes `data.js` (`META` · `TEXT.lines[{text,s,e,speaker,words[{t,s,e,i}]}]` · `FEAT` 30 fps features + beats) and
`data.summary.txt`: header (tempo, phase, beat0/period, downbeat, sections), then every line `start-end * [speaker] text`
(`*` = has interpolated words), then a 5 s energy table. **Read the whole summary before storyboarding.**
Checks: song alignment coverage ≥ 70% (else fix lyrics or add a Demucs vocal stem via `"analysis": {"stem": …}`);
tempo plausible (a slow groove may track at double time: judge by feel, override `beatPeriod`); speech modes report
`phase: none` (no beat grid: `BT()` throws by design). `phase: beats` means the tempo drifts (the original song's grid
drifted up to 0.87 s): cut with `BT(n)` / `snap(t,'downbeat')`, never with `B0 + n*BEAT` arithmetic. The **downbeat**
is a best guess from bass energy; if big cuts feel a beat early/late, set `meta.downbeat`.
Override anything in `project.json` `"meta"`. Runtimes on this laptop's CPU: Whisper ~0.9–1.2x realtime (a 60-min
episode ≈ 1 h of transcription, once; it's cached), features seconds, alignment < 1 s.

## 4 · Prove the pipeline before any art

```
node tools/check.mjs out/check/draft.jpg --auto 6 --aspect all        # placeholder scene at every aspect
node tools/render.mjs --from 0 --to 10 --aspect 9:16                  # 10 s with audio: plays, syncs, right size
```
Fix environment problems now (GPU, fonts, audio path), not after 3,000 lines of scene code.

## 5 · Storyboard

Copy nothing from memory: build `STORYBOARD.md` (template in the project) from `data.summary.txt`.
- **The idea** (two paragraphs of pictures), **tone**, **rules for every shot** at this mode's density
  ([references/density.md](references/density.md)), **cast** table, **palette arc** (one palette per chapter).
- Chapters of 20–60 s on section boundaries. One table per chapter: `Time | Text | Shot | Camera / out`.
- Music: a real music video, not a lyric video. Story, scenes, timing. Cuts on beats, big changes on downbeats.
- Speech: the words are the soundtrack; the pictures are a second telling. Literal claim, then metaphor. Never
  paint the words; captions carry them.

## 6 · Reference chapter (director) + the creative gate

1. `theme.js`: palette `P` + `THEME {bg, ink, accent, …}`. `cast.js`: every recurring character/prop as a pure
   drawing function (people on `figure()`/`groove()`, speakers on the `talk` kit's `talker()`).
2. Replace `scenes/c1.js` with chapter I, fully finished: it is the style reference every subagent imitates.
3. Review it the way the agents will: `node tools/check.mjs out/check/c1.jpg <a> <b> --shots` and
   `--aspect all` sheets; `--bench` (scene p95 < 150 ms). Add `focus` to any shot that loses its subject in 9:16.
4. **Creative gate:** send one `--aspect all` sheet + a 10–15 s render of chapter I with `SendUserFile`. Continue
   when approved. Skip the gate only when told to go all out without check-ins.

## 7 · Chapters in parallel

Fill every `{{…}}` in `ANIMATION_GUIDE.md` (direction, stage, aspects, look paragraph, timing line, kits, cast API,
style, text rule). Add each chapter's file to `project.json` `"scripts"` in order. Then spawn **one Agent per
remaining chapter in a single message**, each with `model: "opus"`:

> You are painting chapter {{N}} ({{NAME}}, {{start}}–{{end}} s) of "{{TITLE}}", a procedural video in
> `{{PROJECT_DIR}}`. Read `ANIMATION_GUIDE.md` fully, then `STORYBOARD.md` (idea, rules, cast, and your chapter's
> table), `data.summary.txt` for your time range, `theme.js`, `cast.js`, and `scenes/c1.js` (the reference chapter:
> match its craft level). Write `scenes/c{{N}}.js` only; it must start at {{start}} and end exactly at {{end}}.
> Check your work with `node tools/check.mjs` sheets (≤ 9 frames each, `--shots` and `--aspect all`) and open
> every sheet with Read. Iterate until every shot is beautiful, readable and alive at every aspect and scene time
> stays under 150 ms. Do not edit any other file; report shared-file bugs in your final message. Final message:
> the shot list with times, the sheet paths you reviewed last, bench numbers, and any bugs found.

## 8 · Review

Open each chapter's final sheets yourself (and make new ones: first/last frame of every shot, the transitions
into and out of the chapter, every aspect). Send concrete notes back with `SendMessage` to that agent (it keeps
its context). Fix shared-file bugs yourself, re-run `npm test` in the repo if the engine changed. A chapter is
accepted when you would ship its sheets.

## 9 · Render and deliver

```
node tools/bench.mjs --look paint                        # once per machine: writes the best worker count
node tools/render.mjs --aspect all [--look paint] [--captions words] [--resume]
```
Outputs `out/<slug>_<aspect>_<look>.mp4` and `out/last-render.json`. Segments are resumable (`--resume` after an
interruption). Then the ship gate, then `SendUserFile` the masters (and one sheet).

## Episode density (long recordings, when chosen at intake)

Build 4–8 sets (`defineSet(id, (t, lt, dur, params) => …)`: a home set per speaker, a two-shot, topic sets), plan
with `autoPlan({ by: 'speaker', minHold: 6, maxHold: 18, minCut: 2.5, choose: (span, i) => ({ set, params }) })`
(`span` = `{a, b, lines, speaker, text}`; choose topic sets with word-boundary regexes: `/hum/` matched "human"),
register with `episode(plan)`, hand-override key spans. Print the plan's holds and set counts once
(`window.__plan = plan` + a page evaluate, or read `__shots()`) before rendering. Every set must stay alive for 18 s
without a cut: arc the camera across the hold with `lt/dur`. Worked example: `examples/podcast-unfurling-episode`.
Details: [references/density.md](references/density.md).

## Looks

Six renderers: `paint` (GPU brushstrokes; `whip()` smears strokes), `clean` (Canvas2D, no GPU needed), and four
shader looks: `ink`, `woodcut`, `halftone`, `watercolor` (auto-exposed, so night scenes still read on paper), plus
17 named presets over them. Same scenes, any look, chosen at render time (`--preset`, `--look`). Scenes built for
paint read well in every look: strong silhouettes and value contrast are what all six key on. Adding a look is one
file (`makeShaderLook` in `engine/looks/_shader.js` does the plumbing). See [references/looks.md](references/looks.md).

## Gotchas (each one measured)

- **GPU Canvas2D is history-dependent in Chrome**: the original rendered 26 of 766 frames differently depending
  on render order. The tools rasterize Canvas2D on the CPU (`--disable-accelerated-2d-canvas`, default
  `--raster cpu`); WebGL strokes stay on the GPU. Noise floor with CPU raster: 0. Don't switch it back for renders.
- **SwiftShader**: if Chrome falls back to software WebGL, paint is ~20x slower; render/check abort and say so
  (`node tools/gpuprobe.mjs` to diagnose; `--headed` or `--look clean` as fallbacks). On Windows the flags are
  `--use-gl=angle --use-angle=d3d11` (the original's `--use-angle=metal` is macOS-only).
- **No beat grid in speech.** `BT()` throws; use `when`, `whenPhrase`, `lineAt`, `accentAfter`. `check.mjs` lints
  scenes that reach for beats in a speech project. `sway`/`groove` still breathe on `META.pulse`.
- **Pure function of t.** No `Math.random`, no clocks, no state between frames (linted). Frames render out of order.
- **Light has no depth**: repaint silhouettes in black on `f` after the light with `occlude()`.
- `ease.back(0)` returns about -2e-16: guard radii (`if (!(r > .5)) return;`) before drawing.
- **9:16 of a 16:9 stage shows the centre 608 px.** Two-shots and off-centre subjects need `focus` (stage x, [x, y],
  a function of t, or per aspect). Check `--aspect all` on every chapter, not just the stage aspect.
- **The beat tracker can stop before the song ends** (the original's did at 367.7 of 372.7 s): extrapolate the
  grid for the tail (`BT(last) + k * BEAT`).
- **Frame budget**: scene p95 < 150 ms (`check --bench`). Hundreds of shapes are fine, tens of thousands aren't.
- **Frame time is `from + i/fps` with a global i** in every render path; boil and grain are floors of `t`, so any
  other formula moves them.
- **Captions over the subject**: captions sit at a fixed band per aspect (9:16 at 70% height). Keep faces out of it,
  or move the band: project.json `"captionStyle": { "y": .9, "size": 70, "maxChars": 20 }`.
- **Silhouettes need a lit backdrop.** Dark figures on dark ground vanish (both looks): put heads against a window, a
  lit wall, a fire, the sky. The smoke tests lost a crowd and a dog this way until they were moved against light.
- **Projects vendor the engine.** After changing the repo's engine/tools/analysis, refresh a project with
  `node ~/.claude/projects/procedural-video/tools/new_project.mjs --update <project dir>`.
- The commit gate runs `npm test`; the repo's port test (~80 s) is not in it. After touching `engine/looks/paint.js`
  or `engine/core/*`, run `node tools/porttest.mjs` in the repo: it must PASS bit-exact.

## Ship gate

- [ ] `data.summary.txt` read; song coverage ≥ 70% or explained; tempo/phase sane
- [ ] STORYBOARD.md rows come from the printout; density matches mode
- [ ] every chapter reviewed on sheets at **every aspect**: first/last frame of every shot, transitions, hits
- [ ] no page errors or lint in `check.mjs`; scene p95 < 150 ms
- [ ] each master: `ffprobe` size matches aspect (1920×1080 / 1080×1920 / 1080×1080), duration within one frame of
      the audio range, an audio stream present (`out/last-render.json` records all three)
- [ ] watched start, middle and end of each master; sync on a hard hit checked by eye
- [ ] captions (speech): readable at 9:16, not covering the subject's face
- [ ] delivered with `SendUserFile`; decisions logged in the project's `docs/decisions/`

## Files

| Path (repo) | What |
|---|---|
| `engine/index.html`, `engine/core/*` | loader + player; config (stage/aspect/view), math, timing (beats/accents/words), draw, rig, shots (chapters/sets/autoPlan), layers, captions, main |
| `engine/looks/paint.js`, `clean.js` | the looks |
| `engine/kit/scenery.js`, `talk.js` | sky/clouds/stars/moon/room; `speaking()`, `talker()` |
| `tools/new_project.mjs` | scaffolder |
| `tools/check.mjs`, `render.mjs`, `bench.mjs`, `serve.mjs`, `gpuprobe.mjs` | sheets/bench/lint; render; worker sweep; live preview; GPU check |
| `tools/porttest.mjs`, `fixtures/fev/` | the original video on this engine; bit-exact proof |
| `analysis/*.py` | audio_io, features, beats, transcribe, textnorm, align, segment, build_data, run |
| `scripts/narrate.py`, `gen_song.mjs`, `clip.py` | audio prep |
| `templates/` | STORYBOARD.md, ANIMATION_GUIDE.md, theme.js, cast.js, placeholder c1.js |
| `examples/` | smoke-test projects: `song-the-painter` (Lyria song, paint, beats + sung words, focus), `narration-every-frame` / `narration-dogfood` (TTS, 9:16 stage, clean, word captions), `podcast-unfurling-clip` (clip vs full transcript, talker, captions), `podcast-unfurling-episode` (5.5 min, sets + autoPlan, clean) |
| `docs/decisions/` | why things are the way they are |

## See also

`video-canvas-method` (approval gates; this skill's gate 6 is its keyframe gate in code form) · `hyperframes`
(HTML motion graphics, kinetic type) · `seedance-narrated-short` (AI-footage narrated film) · `audio-drama`,
`timed-guided-audio` (audio masters that can feed this) · `media-use` (BGM/SFX sourcing).
