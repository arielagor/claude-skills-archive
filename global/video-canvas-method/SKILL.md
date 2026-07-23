---
name: video-canvas-method
description: >-
  The production-management layer under every video build: a canvas-as-repo structure (asset cards,
  scene cards, non-destructive versions) and six approval gates, the important one being a KEYFRAME
  gate that puts an approved still in front of every shot BEFORE any motion is generated. Use at the
  start of any video project, when a build is about to generate clips, when a piece is drifting
  (faces changing, style wandering, scenes being regenerated repeatedly), or when someone asks for a
  storyboard. Sits under `ai-commercial` (dialogue ads), `seedance-narrated-short` (narrated film),
  and `hyperframes-*` (motion graphics) and does not replace any of them: they own CRAFT, this owns
  WHEN WORK GETS APPROVED and WHAT GETS WRITTEN DOWN. Ported from TopView AI Canvas methodology
  (2026-07-22), verified against our own HeyGen + Seedance + xAI-TTS + ffmpeg stack.
---

# The Canvas Method

> Craft doctrine lives in `ai-commercial/SKILL.md` and `seedance-narrated-short/SKILL.md` (plus its
> `references/FILM-CRAFT.md`). **Those files outrank this one on every question of craft.** This file
> only decides the order of operations and the artifacts that survive.

## The one change that matters

> **Every shot gets an approved STILL before it gets MOTION.**
> No clip is generated until its keyframe exists and has been looked at.

Our old order was: prompt, then a 15s clip, then discover the problem, then instrument it (Pass 0),
then repair or regenerate. Every defect got discovered after we had already paid to animate it. The
felt-time build stumbled onto the fix and wrote it down for exactly one scene type ("verify cheaply
before the full render", a 3 to 4 fps contact-sheet pass, `ai-commercial/references/lyria-threejs-captions-playbook.md`).
Generalize it. A wrong face, a wrong wardrobe, a broken 180 line, a wandering palette, a text
artifact: all of them are visible in a still, and a still is far cheaper to redo than a clip.

The corollary matters just as much: when something is wrong, **edit the one failing still and
re-animate that one shot.** Do not regenerate the sequence.

## The six gates

| Gate | Name | Artifact | Passes when |
|---|---|---|---|
| G0 | Brief | `canvas/BRIEF.md`: SMP, big idea, channel, aspects, runtime | Ariel signs off |
| G1 | Story and style | `canvas/STORY.md` + `canvas/assets/style.card.md` (the one global style block) | Ariel signs off |
| G2 | Asset cards locked | `canvas/assets/*.card.md`, one per character, environment, prop | every card carries a resolved ID and a reference still |
| **G3** | **Keyframe** | `canvas/scenes/NN.card.md`, `NN.key.png`, `canvas/SHEET-keys.png` | **every shot has an approved still. No motion spend before this.** |
| G4 | Motion | `canvas/scenes/NN.mp4`, `canvas/SHEET-motion.png` | each clip approved against its own keyframe |
| G5 | Assemble and QC | masters in both aspects | the owning skill's QC checklist and ship gate both pass |

Gates are sequential per shot, not per project. Shot 07 may be at G4 while shot 09 is still at G3.
The only rule that never bends is that a given shot cannot reach G4 before it has passed G3.

## Canvas as repo

```
canvas/
  CANVAS.md              # board index: gate status per shot, every card, every version, one screen
  BRIEF.md   STORY.md
  assets/
    style.card.md        # the ONE global style block, pasted verbatim into every prompt
    char-ray.card.md     char-maya.card.md
    env-diner.card.md    prop-phone.card.md
  scenes/
    03-diner.card.md     # engine tag, 180 side, camera move, prompt, refs, keyframe, versions
    03-diner.key.png     03-diner.v2.key.png     03-diner.mp4
  SHEET-keys.png   SHEET-motion.png
```

**Asset cards replace scattered constants.** `assets/avatars.json` from the-safety-of-strangers and
the inline `STYLE_SUFFIX` from `beats.mjs` both become cards: a stable ID, a reference still, a
one-line description. GOTCHA-1 (ten characters all rendering as the same bearded man in a tan blazer,
some wearing a visible lavalier mic) becomes structurally impossible, because G2 cannot close until
every named role owns its own card with its own resolved look ID.

**Scene cards are the source of the EDL.** Generate `edl.json` / `beats.mjs` from the cards rather
than maintaining both. If the storyboard and the cut are two hand-written files, they will drift.

### Scene card shape

```markdown
# 03-diner
engine:   CINEMATIC          # DIALOGUE routes to Avatar IV/V, CINEMATIC routes to Seedance
side:     A frame-left       # the 180 assignment, from STORY.md
camera:   slow push-in       # exactly ONE move
dur:      6s
refs:     char-ray, env-diner, prop-phone
keyframe: 03-diner.key.png   # approved 2026-07-22
versions: v1 (rejected: wrong wardrobe), v2 (approved)
prompt:   |
  <verbatim style.card.md block>
  <shot description>
  preserve composition and colors
```

## Running G3 on our stack

Nothing new gets bought. Everything below already exists here.

1. **Generate the keyframe.** `scripts/keyframe.mjs`, one still per shot, style card pasted in
   verbatim via `--style` and the character/environment cards attached via `--ref`.
   ```bash
   node scripts/keyframe.mjs "wide, the empty booth, rain on the glass" \
     --style canvas/assets/style.card.md --ref canvas/assets/env-diner.png \
     --out canvas/scenes/03-diner.key.png
   ```
   Defaults to `gemini-3.1-flash-image` (about $0.067). Pass `--model gpt-image-2` when the frame
   carries text you need to read in order to approve it. Building shot N+1's keyframe with shot N's
   as a `--ref` is how the palette and set stay put; it is also how you get a matched pair for step 4.
2. **Contact sheet before spend.** Tile the stills with labels into `SHEET-keys.png` and Read it.
   Judging twelve stills in one image is the cheapest QC in the whole pipeline. `scripts/sheet.py`
   does this (it generalizes the felt-time 2x2 verification pass).
3. **Approve or locally edit.** A failing still gets re-prompted on its own. The others are untouched
   and their approval still stands.
4. **Carry the approved still into motion, by the route the shot deserves** (table below).
5. **Only now generate.** Then `SHEET-motion.png` (first, middle, last frame of each clip) for G4.

### Engine routing at G4

The engine choice is a cost decision, and the two costs are not the same kind of thing. Read the
warning at the top of `ai-commercial/SKILL.md` before this table: HeyGen is 1 plan credit per
generation and its wallet dollar figure gates nothing, so **HeyGen is never the thing to economize
on.** Veo is metered in real dollars against `GEMINI_API_KEY`, so it is a deliberate purchase.

| The shot needs | Engine | Cost | How the keyframe is used |
|---|---|---|---|
| A character to SPEAK exact words | Avatar IV / V | 1 credit | keyframe informs the look; VO drives the mouth |
| Ordinary cinematic motion, identity from an avatar | HeyGen Seedance `cinematic_avatar` | 1 credit | keyframe passed in `references` (<=9) + "preserve composition and colors" |
| **To start AND end on exact approved frames** | **Veo 3.1** | **$0.10/s at fast 720p** | **`--first` and `--last`, literal** |
| A hard continuity seam between two shots | Veo 3.1 | as above | shot N's last still is shot N+1's `--first` |

**Default to HeyGen.** Reach for Veo when a specific seam or a specific composition is worth paying
for: the shot that has to land on the end-card framing, the one join where a cut would expose drift,
the hero shot. A whole film routed through Veo at 8s a clip is a real invoice, and it does not
inherit our avatar identity system.

```bash
node scripts/animate.mjs "slow push-in, the lamp flickers once, nothing else moves" \
  --first canvas/scenes/03-diner.key.png --last canvas/scenes/04-cup.key.png \
  --out canvas/scenes/03-diner.mp4 --model fast --duration 8
```
`--duration 8` is not a preference. `--last` is rejected at 4s and 6s.

**Continuity chaining still applies.** Compose each keyframe so that it ends where the next shot's
keyframe begins. That instruction is now checkable at G3 by looking at two stills side by side,
instead of being hoped for at generation time.

## Non-destructive versions

Variants are additive. `03-diner.v2.key.png` sits next to `03-diner.key.png`, and the rejected one
stays on disk with its rejection reason recorded on the card. Two reasons this earns its keep: the
"worse" variant is frequently the right answer for a neighbouring shot, and a rejection reason
written down once stops the same prompt from being retried three sessions later.

Selection happens off the contact sheet, never by opening files one at a time.

## Recipes

TopView's Canvas lets you save a finished workflow as a reusable "Skill" and re-run it against a new
product or campaign. Our equivalent is a recipe file per format, checked into the project:
`canvas/RECIPE.md` records the gate settings that worked (aspect set, shot count, engine mix, style
card, voice assignments, music approach) so the next piece in the same series starts from a known
configuration instead of from a blank brief. The Two Owners and the felt-time explainer are both
recipes waiting to be written down.

## Process metrics (report these, they are the evidence the method works)

- **Waste ratio**: clips generated divided by clips used in the final cut.
- **Post-motion regenerations**: how many clips had to be re-rendered after G4. Under the old flow
  this was routine (GOTCHA-7 tells you to regenerate freely). Under this method it should approach
  zero, because the defect that caused it should have been caught as a still.
- **Defects caught at G3**: each one is a clip that was never paid for.

## What this does NOT change

The craft rules are untouched and still outrank this file. Do not let a process change quietly trade
away any of these:

- **Shot routing** DIALOGUE / CINEMATIC to engine (`ai-commercial/SKILL.md`). Unchanged.
- **180 line, one camera move per shot, global style block verbatim.** Unchanged.
- **Pass 0 time-pressure judged BY EYE.** GOTCHA-2 proved that scene-score ranks backwards on exactly
  the variable that matters. A keyframe gate does not replace Pass 0 and cannot: a still cannot show
  whether something in the world is changing. G3 catches identity, wardrobe, palette, framing and
  text defects. P4 still catches rhythm.
- **CV >= 0.50**, the eight legal narration jobs, the noun-collision gate, the three mix guards, the
  ship gate.
- **On-screen text is always a post overlay.**
- **The HeyGen wallet dollar balance is not a budget.** Each generation is 1 plan credit and a low
  `remaining_balance` gates nothing. This matters here specifically: TopView is credit-metered and
  its methodology carries a cost-estimation habit. Do not import that habit. Never cut scope,
  resolution, shot count or fidelity because of a wallet number.

  The Veo and OpenAI routes are the one real exception, and keeping the two straight is the whole
  point: **HeyGen credits are not money and Veo seconds are.** Never ration HeyGen. Do choose Veo
  shot by shot. If a piece is being quietly shrunk, the cause is almost always someone misreading the
  HeyGen wallet, which has happened repeatedly.

## What we deliberately reject from TopView's method

- **Agent-proposed scene sequence.** Their agent drafts the shot order and you approve it. That is
  the same surrender of editorial control that `ai-commercial` already bans for HeyGen Video Agent.
  Keep the gates, write the sequence yourself.
- **Their consistency claim as a substitute for engineering it.** Reviewers report faces drifting
  between the first and last scene of longer productions. Per-character look IDs stay mandatory.
- **No pacing doctrine.** Canvas has no equivalent of the time-pressure rule or a CV target. It will
  approve a beautiful, uniform, unwatchable slideshow. Our rhythm rules outrank their workflow.

## What we already had and were not using (verified 2026-07-22)

An earlier draft of this file listed first-frame/last-frame control as a capability our stack lacks.
That was wrong, and the error mattered: it is a **HeyGen** limitation, not a stack limitation. The
keys in `~/.claude/settings.json` already reach every engine below. Nothing new was bought.

| TopView Canvas uses | We already have | On which key | Verified |
|---|---|---|---|
| GPT-Image-2 for storyboard frames | `gpt-image-2` (also `gpt-image-1.5`, `chatgpt-image-latest`) | `OPENAI_API_KEY` | models list |
| Seedance for motion | HeyGen `cinematic_avatar` | `HEYGEN_API_KEY` | in production |
| first frame + last frame i2v | **`veo-3.1-*-generate-preview`** | `GEMINI_API_KEY` | **generated a clip, confirmed below** |
| (none) | `sora-2`, `sora-2-pro` | `OPENAI_API_KEY` | models list, untried |
| music | `lyria-3-clip-preview`, `lyria-3-pro-preview` | `GEMINI_API_KEY` | models list + docs |

### The Veo 3.1 result, in full

A push-in on a diner booth: two keyframes generated with `keyframe.mjs` (the second built from the
first as a reference, so the palette and set match), then `animate.mjs` with both attached. The
output's **first frame is keyframe 1 and its last frame is keyframe 2**, 8s, 1280x720, 24fps, with a
native audio stream. The approved still is no longer a hint the model may ignore. It is the frame.

**Verified constraints, learned by probing (failed submits cost nothing):**
- `lastFrame` **requires `durationSeconds: 8`**. At 4s or 6s the API returns
  `400 INVALID_ARGUMENT "Your use case is currently not supported"` on both `fast` and `full`. The
  message names nothing, so this is worth remembering rather than rediscovering.
- Durations are 4, 6, or 8 only. 8 is also required for 1080p, 4k, reference images, and extension.
- Veo 3.1 has **no seed**. Aspect is 16:9 or 9:16 only.
- Cost is per second of output: `full` $0.40 (720p/1080p) / $0.60 (4k) · `fast` $0.10 / $0.12 / $0.30
  · `lite` $0.05 / $0.08. The verification clip above cost about $0.80.

### Still genuinely missing

- **Omni Reference tag syntax** (`<<<Image1>>>`, `<<<Video1>>>` inside one prompt) for explicit
  style-from-here, motion-from-there control. No engine we hold exposes this. Approximate it by
  passing separate reference stills and saying which controls what in prose.
- **Seedance 2.5 at its marketed tier** (30s single pass, 4K, 50 multimodal references, identity
  consistent first frame to last). Not reachable from TopView's public API either: as of 2026-07-22
  their docs top out at Seedance 1.5 pro / 12s with reference caps of 3 to 9. Our 15s ceiling and the
  dissolve-chain workaround both stand. Veo 3.1's extension (+7s, up to 20 times, 720p only) is the
  nearest thing we hold, and it is not the same thing.
- **GPT Image 2's crisp-text claim** is now testable rather than theoretical, since the model is on
  the OpenAI key. Still untested. **The text-is-always-a-post-overlay rule stands** until someone
  tests it, and it will keep standing for final deliverables regardless: the reason to render text
  into a keyframe is to make the approval artifact legible, not to ship it.

Reference-only vendored copy of the official client, with its local guard:
`~/.claude/skills/topview-skill/` (see its `LOCAL-POLICY.md`; do not authenticate it, do not run it).

## Companions

`ai-commercial` (dialogue ads, the P0 to P6 pipeline) · `seedance-narrated-short` (narrated film,
P0 to P10, FILM-CRAFT doctrine) · `hyperframes-longform-video` (HTML motion graphics) ·
`heygen` (single talking head) · `media-use` (assets and licensing) · `image-generator` (keyframes) ·
`crossfamily-council` (judge the output, jury excludes the producing family).
