---
name: seedance-narrated-short
description: >-
  Produce a long-form NARRATED cinematic short or feature-ette (art film, video essay, or a
  novel/story/script adapted to film) using HeyGen Seedance for the picture and a continuous
  NARRATOR spoken OVER the footage — no lip-synced dialogue. Use when the ask is "adapt this
  novel/story/essay into a film", "make a narrated short film / video essay", "turn this script
  into a cinematic Seedance short", "recut / fix / rescue my AI film", or any beat-driven narrated
  piece longer than a couple of minutes. NOT for lip-synced SPEAKING characters or ads (use
  `ai-commercial`), NOT for a single talking-head (use `heygen`), NOT for HTML/motion-graphic
  explainers (use `hyperframes`). Encodes the full craft doctrine (references/FILM-CRAFT.md) and a
  proven, gotcha-hardened pipeline; the fully worked reference implementation is the repo
  `~/.claude/projects/the-safety-of-strangers` ("The Safety of Strangers", a 20-chapter novel cut
  to an ~11-min film).
---

# Seedance narrated short — the proven pipeline

**Read `references/FILM-CRAFT.md` first.** It is the craft doctrine (three cited research streams:
narrated-film precedent, editing/montage theory, screenwriting/adaptation) and it OVERRULES intuition.
This SKILL.md is the operational recipe that executes it. The reference implementation is the repo
`~/.claude/projects/the-safety-of-strangers` — every script below exists there, working, and the
copies in `references/reference-scripts/` are those files to adapt per project.

## What this form is, and the two ways it dies

A montage of Seedance clips + a sparse art-film narrator is *La Jetée*'s exact configuration (28 min
of near-stills + narration, a masterpiece). It fails two ways, and both are **authorship**, not tools:

1. **The picture has no rhythm.** Every shot the same length (a uniform ~13s ASL) reads as a slideshow
   even though *2001* has the same 13s ASL — because *2001* VARIES. The killer is low variance
   (coefficient of variation ~0.1 vs a cinema norm of 0.9–1.2), and it destroys emotion, not just
   pacing: a cut arriving on a fixed metronome can no longer punctuate anything.
2. **The narration describes the picture.** If the beat prompt and the narration cue are written from
   the same source sentence, you get a caption track — two renderings of one thought, each proving the
   other unnecessary. The fix is architectural, not editorial (see P6).

## The one rule that fixes the picture

> **A shot may hold only as long as something in the WORLD is changing. Camera movement is NOT change.**
> If the only thing that changes during a shot is the lens, it is an ACCENT — cut it to its peak.

Test: **run the shot backwards. If nothing is lost, there is no time-pressure** (a push-in reversed is
a pull-back; a shoe hitting a puddle reversed is absurd). Expect ~80% of shots to be N (no
time-pressure); that is the finding, not a failure. Because most shots get short and the few earned
ones get long, the distribution skews, CV rises, and rhythm appears — one rule, applied to every shot.

## The one rule that fixes the narration

> The narrator says what the IMAGE CANNOT: the date, the cause, the doubt, the future, the judgment.
> **There is no ninth job called DESCRIBE.** Eight legal jobs: CLOCK COMPRESS CAUSE PROLEPSIS DOUBT
> JUDGE INTERIOR NAME (references/FILM-CRAFT.md §2).

Two-Way Deletion Test per cue: mute the voice → something specific is lost; black the image → something
DIFFERENT is lost. If either loses nothing, cut it. Target Marker density: **~44 words per minute of
finished film**, voice-free ≥ 55–60%. Silence is scored, never empty.

---

> **Run this build under `video-canvas-method`** (production management: canvas-as-repo, asset cards,
> six approval gates). It changes no craft rule here. Gate mapping: P0/P1 = G0/G1, **P2 = G2** (the
> per-character look cards are exactly what closes G2, which makes GOTCHA-1 structurally impossible),
> **G3 sits between P2 and P3**: a keyframe still per beat, tiled with
> `video-canvas-method/scripts/sheet.py keys`, approved before `generate.mjs` spends a credit. P4
> Pass 0 stays exactly as written and is NOT replaced: stills cannot show time-pressure, and that is
> the variable P4 exists to judge.

## The pipeline (P0 → P10)

**P0 — The source text.** If adapting, you need real prose, not a synopsis. If only a synopsis exists,
WRITE the manuscript first (a bible + fan-out by act; invoke `anti-ai-narrative-tells` and pick ≥4
counter-defaults at outline time). The narration is drawn from this prose in P6 — that is what breaks
the caption-track tautology. *(In the reference impl: `story/NOVEL-BIBLE.md`, `story/MANUSCRIPT.md`.)*

**P1 — The doctrine.** Author/confirm `docs/FILM-CRAFT.md` for this project (copy references/FILM-CRAFT.md
and localize the act targets, motifs, thesis). Decide runtime by rhythm, not by wish — this material is
usually a 12–16 min film, not the 30 the beat-count suggests.

**P2 — Beats + the look.** `script/beats.mjs`: `{id, act, title, avatar, dur(4–15s), hero, prompt}` +
one `STYLE_SUFFIX` appended verbatim to every prompt (the ONLY thing making N clips read as one film —
but strike "slow camera" from it; it pre-empts direction). **Build one dedicated HeyGen photo-avatar
look per character up front** (`assets/avatars.json` maps role→look). Do NOT let every role default to
one look — see GOTCHA-1.

**P3 — Generate.** `generate.mjs` (Seedance `cinematic_avatar` via the WSL heygen CLI). Resumable
on-disk state (`clips/_req|_json|<ID>.mp4`); capture each `video_id` at submit; ~1 credit/clip.

**P4 — Instrument (Pass 0), BY EYE.** For every clip, extract first/mid/last frames and judge:
time-pressure Y/N (name the world-change), register (HOLD 11–15 / BEAT 5–9 / ACCENT 1–4 / CUT),
peak timecode, trim in/out. This is the real work and it is **non-delegable to a metric** (GOTCHA-2).
Fan it out across agents (one act each) viewing frames; write `build/pass0.json`. `instrument.mjs`
extracts frames + distribution stats but its verdicts are advisory.

**P5 — The cut (EDL).** `script/cut-v4.mjs` derives the edit from `pass0.json`: drop CUTs, trim to peak,
be generous on HOLD/BEAT and ruthless on ACCENT, dissolve-chain 6–10 tonally-matched HOLD pairs (the
only way past the 15s clip ceiling into perceived duration). Target **CV ≥ 0.50**. `assemble.mjs` trims
each shot, hard-cuts most, dissolves the seams/chains, fades to black → the picture.

**P6 — Narration from the prose.** `narration/script-v4.mjs`: `{cue, at, sp, job, t}`. Write it against
the MANUSCRIPT and against what P4 says is ACTUALLY in each surviving shot — **never the beat prompts**,
and forbidden from using any content word visible in the frame. `verify-narration.mjs` is the gate:
word cap, legal `job`, anchor exists, and the **noun-collision detector** (≤20% content-word overlap
with the beat prompt; character dialogue exempt) that makes the caption track impossible to reintroduce.
Then `narrate.mjs --all --mix` synthesizes (xAI Grok TTS, one voice per speaker) onto the v4 timeline.

**P7 — Score + SFX.** Place cues on the film timeline (`score-place.mjs`, using the EDL offsets and the
MEASURED picture length). Withhold the resolving theme until the end. Build an SFX spine mirroring the
film's master motif. Compose, don't source, the cue the whole film withholds (GOTCHA-5). Use `media-use`
for generation + a licensing ledger.

**P8 — Mix, with the guards.** `mixdown.mjs`: even the VO → duck the score under it (sidechain) → mix →
loudnorm → mux over the picture. It carries THREE guards you must not remove (GOTCHA-3).

**P9 — QC: WATCH IT END TO END.** Non-delegable. The single uninstrumented check ("watch it") is the
one whose absence ships a film that stops mid-sentence with one face for ten characters. Also verify by
measurement: CV ≥ 0.50; last 1.5s < −45 dB (it resolves); no dead air (sample loudness across the
timeline); a contact sheet for casting/coherence.

**P10 — Publish.** `~/.gbrain/youtube-upload.mjs upload <gmail|agorme> <file> "title" "desc" [privacy]`.
Privacy defaults unlisted; changing privacy AFTER upload needs the `youtube.force-ssl` scope — the
**agorme** token has it, the gmail one is upload-only (GOTCHA-6). Or copy to `G:\My Drive\` for a
watch-link (a 10-min film is far too big for SendUserFile's ~30s upload window).

---

## GOTCHAS — every one of these cost real time. Do not relearn them.

1. **The anchor look is a stock person.** HeyGen's default look `f57aaeab…` is a bearded man in a tan
   blazer. If every role points at it, your 9-year-old girl, your therapist, and your protagonist are
   all that man (some with a visible lavalier mic). Build a dedicated photo-avatar per character FIRST;
   keep the anchor only for anonymous-crowd shots. Gemini **blocks aging a child's face** (IMAGE_SAFETY)
   — generate a teen from a text description, not by image-progressing the child still.
2. **Scene-score does NOT detect time-pressure — verified false.** A dolly-zoom (pure lens) maxes
   ffmpeg's scene score; a puddle-jump (pure world) barely registers. It ranks backwards on the exact
   variable that matters. There is no cheap proxy; P4 is judged by eye.
3. **Three ways the mix silently amputates the ending — all guarded in `mixdown.mjs`:**
   (a) `-shortest` + a mix longer than the picture guillotines the tail → **never use `-shortest`**;
   assert `mix ≤ picture` BEFORE muxing. (b) `sidechaincompress` ends with its SHORTEST input (the VO
   key), so ducked music dies on the last word → **`apad` the key**. (c) container duration reports the
   VIDEO length, hiding a chopped audio stream → **assert the OUTPUT's audio stream length AFTER mux.**
4. **Model vs measured timeline.** xfade quantizes to frame boundaries, so a modeled `filmEnd` runs
   ~0.25s long and the score overruns → **measure `filmEnd` from the encoded picture, never the model.**
   And keep ONE source of truth for the dissolve geometry (`timeline.mjs`) — four hardcoded copies of
   the same constant is how picture and audio drift apart.
5. **The withheld theme must be COMPOSED, not sourced.** A stock cue is why the ending has no argument.
   ElevenLabs *Music* is creator-tier/quota-limited and has film ToS limits — compose note-level
   (FluidSynth + a GM soundfont) so the final cue is the resolution of the earlier one, not a stranger.
6. **YouTube privacy after upload needs `force-ssl`.** Upload-scope tokens can set privacy AT upload
   but cannot change it later, and cannot delete. The agor.me token has force-ssl; the gmail one does
   not. To move a video between channels you must re-upload (new URL) — you cannot transfer.
7. **Regenerate freely — cost is not the constraint.** ~1 credit/clip, ~120 for a whole film. When P4
   finds broken/miscast shots, REGENERATE them (with the right look + a rewritten prompt + a silent
   override if a mouth moves), verify each by eye, and fold them back into `pass0.json`. Do not cut
   artfully around a fixable defect.

## Ship gate (from FILM-CRAFT §5)
- [ ] mix ≤ picture asserted; output audio stream intact; never `-shortest`.
- [ ] last 1.5s < −45 dB (resolves); no dead air across the timeline.
- [ ] CV ≥ 0.50; shot-length plot is a landscape, not a floor.
- [ ] narration ≤ ~44 wpm; every cue job-tagged; noun-collision ≤ 20%; the thesis/formula stated NOWHERE.
- [ ] a CLOCK cue ~every 90s; voice-free ≥ 55%.
- [ ] one consistent face per character across every shot; no lavalier mics, no on-screen gibberish text.
- [ ] **watched end to end.**

## Reference implementation
`~/.claude/projects/the-safety-of-strangers` — the worked example (novel → doctrine → beats → generate →
Pass 0 → EDL → narration-from-prose → score → mix → publish). Scripts here in
`references/reference-scripts/` are copies of that repo's files; adapt, don't reinvent. Companions:
`ai-commercial` (dialogue ads), `heygen` (talking-head), `media-use` (assets + licensing),
`anti-ai-narrative-tells` (write the manuscript).
