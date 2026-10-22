---
name: constructed-drawing
description: Make any video look geometrically constructed before your eyes by a draughtsman's hand - an engraved 19th-c. hand ruling lines with a fountain pen against an ivory rule, colouring fills with a marker in the ink, and swinging a compass from a pinpricked centre, with pinpricks where arcs and lines cross. Reuses the Byrne engine's automatic tool layer and Ariel's approved hand assets from animation-vs. Use when Ariel asks for a video (any genre - math, physics, diagrams, explainers, logos, maps, architecture, infographics) "drawn as it would be constructed", "with the drawing hand", "in the Byrne/Euclid style", "with the compass hand", or to add the hand to an existing canvas animation.
---

# Constructed drawing: the draughtsman's hand

Built and approved on Animation vs. Euclid (repo `C:\Users\ariel\.claude\projects\animation-vs`, 2026-10-21;
Ariel: "Close enough to perfect"). Everything below is the reusable process plus the lessons that took
five rounds of his notes to learn. Read the code before changing it; this file says what and why.
For the whole production run (score, record, cut into parts, publish to YouTube), use the **hand-drawn-video** skill;
this file is the look.

## What it is
A tool layer that watches a deterministic canvas animation and puts the right real-world drawing tool
on whatever is being drawn, frame by frame, with no per-scene authoring:

| What appears                          | Tool                                                                 |
|---------------------------------------|----------------------------------------------------------------------|
| a line growing (`rule` prog rises)    | fountain pen in that ink, nib on the growing end, ivory rule laid along the line on the far side from the hand |
| an arc / circle growing (`circ` sweep)| compass: needle on the centre, pencil leg (lead in the ink) on the arc, hand pinching the head |
| a fill fading in (`plate`, `wedge`)   | marker in that ink zigzagging along a wipe front; the fill is revealed behind the front at full ink |
| anything that would pop in whole      | drawn in instead (`ov` scales prog / sweep / wipe in the real pass)  |
| needle stood / arc×arc / arc×line     | pinprick (ring + dot), shown ~3 s                                    |

## Files (copy or import from animation-vs)
- `engine-byrne/core.js`: `HAND` registry + `treg()` hooks inside `rule`, `circ`, `plate`, `wedge`; `wipeClip`.
- `engine-byrne/tools.js`: probe/track/classify (`handTrack`), `handBegin`, sprites, `compassHand`, `ruler`, `pinprick`, `drawHand`.
- `engine-byrne/player.js`: `handBegin(t)` before the world draw, `HAND.cur=null` after, `drawHand(t)` last.
- `engine-byrne/hands/`: `pen.png`+`pen-mask.png`, `marker.png`+`marker-mask.png`, `compass.png` (handle cut out), `hands.json` (anchors, compass `stem`, `hingeR`), `src/` Gemini originals.
- `tools/gen-hand.mjs` (Gemini `gemini-nano-banana-2.1`, Ariel's reference engravings inline as style input), `tools/prep-hands.py` (sprite prep), `tools/build.mjs` (inlines sprites as `HAND_SPR`), `tools/record.mjs` (awaits `window.HAND_READY`).
- Ariel's reference images: `C:\Users\ariel\.claude\uploads\3a1b8a51-0885-4018-a599-a6f806eab901\` (engraved hands, compass pinched by its head, starched cuff; yellow school ruler he liked).

## Using it for a new video (any genre)
1. Draw everything through the four primitives (`rule`, `circ`, `plate`, `wedge`) or add a `treg(kind,color,pts,v)`
   call plus an `ov` hook to any new primitive (pattern: `const it=treg(...);if(it&&it.ov!=null){prog*=it.ov;...}`).
   Points must be in the space the primitive draws in; treg converts with the current transform.
2. Scenes must be pure functions of time (`draw(τ)`), so the probe can replay them. No randomness without a seed.
3. Animate construction honestly: grow lines from where a real pen would start, sweep arcs from a real radius
   point, fade fills in. The layer only follows what the animation does; it cannot invent a construction order.
4. Build, render a contact sheet of frames at ~45% and ~82% of each scene, check the tool is on the stroke, then record.

## Lessons (Ariel's notes, in order; each one is a rule now)
1. **Style comes from his references, not from me.** A drawn-in-code hand was rejected ("I don't like the hand").
   Generate with Gemini using his reference images inline, 3 variants, pick, then prep: flood-fill the white
   background from the border (enclosed whites stay: the hand is opaque vellum), map ink to the page's black,
   key a magenta barrel into a separate **RGBA alpha** tint mask (an L-mode mask tinted the whole hand).
2. **Ruler:** his pick was a flat wooden school rule (bevel, mm/half/cm ticks, numbered cm, hang hole), **ivory**
   not yellow so it never reads as the yellow ink. Laid on the far side of the line from the hand.
3. **Compass legs are equal and fixed-length.** Unequal legs and a hinge floating straight above the midpoint were wrong.
4. **The handle is always centred on the hinge,** on the legs' centre line, never at an angle to where the legs join.
5. **The hand stays still; the fingertips roll the handle.** The whole hand orbiting the circle was the biggest miss.
   Fix: the pinch point is fixed above the needle; the handle and hinge are drawn live (cut out of the sprite:
   `STEM_CUT`, anchor `PINCH`); the hinge swings on the handle's length below the fingers; the compass leans at most
   **45°** off upright toward the pencil's side; the wrist turns "ever so slightly" (0.15× the lean, ~7° max);
   knurl grooves phase with the compass angle so the roll reads.
6. **Drawing pressure:** the compass leans ~12° into the direction of travel, head ahead, so the lead is dragged and the
   mark trails it; eased in by the pencil's speed so it settles when the sweep stops.
7. Sprite scale: compass hand 1.5× the pen hand (`HSC*1.5`), or it reads as a toy.
8. Known open item: on big circles the still hand can reach the caption band; offer to move it to one side.

## Engineering traps
- A circle born with a small sweep was classified "born whole" and skipped: born-whole must exclude tracks the scene
  itself animates over the next ~20 frames.
- Probe pass cost is one replay per scene, cached on the timeline entry (`e.H`); fine for 10-minute books.
- Recording: read long foley back in 16 MB chunks (`REC.chunk`); one 175 MB CDP string killed Chrome.
- SendUserFile caps at 30 MiB: send 720p previews of long parts.
- Revision cap (2 rounds) applies to my self-review loops, never to Ariel's notes on the look.
