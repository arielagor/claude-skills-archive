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

1. **Generate the keyframe** with the `image-generator` agent (latest Gemini Flash image model), one
   still per shot, with the style card pasted in verbatim and the character reference still attached.
2. **Contact sheet before spend.** Tile the stills with labels into `SHEET-keys.png` and Read it.
   Judging twelve stills in one image is the cheapest QC in the whole pipeline. `scripts/sheet.py`
   does this (it generalizes the felt-time 2x2 verification pass).
3. **Approve or locally edit.** A failing still gets re-prompted on its own. The others are untouched
   and their approval still stands.
4. **Carry the approved still into motion.** HeyGen `cinematic_avatar` accepts no first-frame or
   last-frame parameter (a real limitation, see "What we do not have" below), but it does accept
   `references` at up to 9 images. The approved keyframe goes in as a reference alongside the 3 or
   fewer element refs, with "preserve composition and colors" in the prompt as usual.
5. **Only now generate.** Then `SHEET-motion.png` (first, middle, last frame of each clip) for G4.

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

## What we deliberately reject from TopView's method

- **Agent-proposed scene sequence.** Their agent drafts the shot order and you approve it. That is
  the same surrender of editorial control that `ai-commercial` already bans for HeyGen Video Agent.
  Keep the gates, write the sequence yourself.
- **Their consistency claim as a substitute for engineering it.** Reviewers report faces drifting
  between the first and last scene of longer productions. Per-character look IDs stay mandatory.
- **No pacing doctrine.** Canvas has no equivalent of the time-pressure rule or a CV target. It will
  approve a beautiful, uniform, unwatchable slideshow. Our rhythm rules outrank their workflow.

## What we do not have (recorded honestly)

TopView's API exposes controls our current stack lacks. We are not using it (Ariel's decision,
2026-07-22, no spend), and these are the specific reasons that decision is worth revisiting later:

- **First-frame and last-frame image-to-video.** HeyGen `cinematic_avatar` has neither. A large part
  of our continuity engineering exists to work around that absence.
- **Omni Reference tag syntax** (`<<<Image1>>>`, `<<<Video1>>>` inside the prompt) for explicit
  style-from-here, motion-from-there control.
- **Seedance 2.5** is marketed at 30s single pass, 4K, 50 multimodal references, identity consistent
  from first frame to last. **Unverified and probably not reachable**: as of 2026-07-22 TopView's own
  API docs list Seedance 1.5 pro at 12s with reference caps of 3 to 9 images, and the official skill's
  model table tops out at 15s "Seedance 2.0-level" Standard/Fast. If a real 30s single-pass clip
  becomes reachable, it collapses the 15s ceiling that our dissolve-chain workaround exists to defeat,
  and that is worth re-opening the decision for.
- **GPT Image 2** claims crisp, correctly-spelled on-screen text at 4K. If true it would bear on our
  text-is-always-a-post-overlay rule. Untested by us. **The rule stands.**

Reference-only vendored copy of the official client, with its local guard:
`~/.claude/skills/topview-skill/` (see its `LOCAL-POLICY.md`; do not authenticate it, do not run it).

## Companions

`ai-commercial` (dialogue ads, the P0 to P6 pipeline) · `seedance-narrated-short` (narrated film,
P0 to P10, FILM-CRAFT doctrine) · `hyperframes-longform-video` (HTML motion graphics) ·
`heygen` (single talking head) · `media-use` (assets and licensing) · `image-generator` (keyframes) ·
`crossfamily-council` (judge the output, jury excludes the producing family).
