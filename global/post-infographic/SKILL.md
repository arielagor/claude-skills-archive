---
name: post-infographic
description: Turn one blog post into a hub-and-branches infographic in the property's own brand - a static PNG, a looping GIF sized for LinkedIn and an MP4 - using the structure and motion grammar reverse engineered from Charlie Hills's LinkedIn infographics (never his skin). Use when Ariel types /post-infographic, or asks to "make an infographic for this post", "make the LinkedIn graphic for the blog post", "infographic like Charlie's for <post>", or wants a shareable one-page picture of a post from agor.me or another property. Takes a post path or URL. NOT for charts of data (use dataviz), covers or hero art (image-generator), or videos that tell a story (hyperframes).
---

# post-infographic

One post in, three files out: `<slug>-<layout>.png`, `.gif`, `.mp4`, all 1080x1350 (4:5).

What was copied from Charlie Hills is the arrangement and the motion, measured off his files. What was not: his mascot, avatar, starburst, clock face, wording, colours, light ground. The measurements and the corpus are in `REVERSE-ENGINEERING.md`; read it before changing a layout or the timing.

## Run it

```
node ~/.claude/skills/post-infographic/scripts/run.mjs <post.mdx | url> --link agor.me/blog/<slug>
```

Options: `--layout hub|lanes|rail` (default hub), `--slug`, `--property agor`, `--drop N` (cut branch N), `--from layout|render|export` (resume), `--gif-width`, `--gif-fps`.
Work lands in `~/.claude/state/post-infographic/<slug>/`, finished files in its `out/`.

## The pipeline: four stages, each runnable alone

| Stage | Script | In, out | Gate |
| --- | --- | --- | --- |
| extract | `scripts/extract.mjs <post> --out <dir>` | post, `spec.json` | shape and word budgets; every number, name and quote must be in the post; one repair round, then `spec.rejected.json` and exit 1. Exit 2: the post does not decompose, nothing is forced |
| layout | `scripts/layout.mjs <spec.json> --out <proj> --layout hub` | spec, HyperFrames project + `layout.json` | deterministic; anything that does not fit is cut and named in `layout.json`, type is never shrunk |
| render | `scripts/render.mjs <proj>` | project, `master.mp4` | `hyperframes check` has no errors; duration matches |
| export | `scripts/export.mjs <proj> --name <n> --out <dir>` | master, PNG + GIF + MP4 | first and last frame match (the loop closes); GIF within LinkedIn's 500 frames (LinkedIn help a564109) and under 8 MB (our own budget for feed load time, not a LinkedIn limit) |

| trace | `scripts/trace.mjs <proj>` | master + `layout.json`, timing report | each branch's half-brightness return, measured on the crop `layout.json` gives for it; the hold after the last branch; first-to-last frame difference (under 1 of 255 closes the loop) |

Tests: `node --test ~/.claude/skills/post-infographic/tests/pipeline.test.mjs`. `scripts/show-spec.mjs <spec.json>` prints the words as an outline; `scripts/check-summary.mjs <proj>` reads the last check report.

The extract stage makes one model call through `lean-claude.mjs` on the `deep` tier. Nothing else calls a model. Rendering is the `hyperframes` skill's CLI; this skill has no renderer of its own.

## What you do each time

1. Run extract, then `show-spec.mjs`. Read every line against the post. The grounding check catches invented numbers and names, not a wrong emphasis or a flat headline; fix those by editing `spec.json` by hand (it is content, in a file) and re-run from `--from layout`.
2. Build all three layouts as stills, side by side, before animating anything. Same words, three arrangements:
   `layout.mjs` for `hub`, `lanes`, `rail`, then `npx hyperframes snapshot --at 10 --no-end -o snap` in each, then tile them. Pick with reasons. Read each `layout.json`: a layout that had to cut half the steps is the wrong layout for this post.
3. Render and export the pick. Extract frames across the loop and look: frame 0 complete, ghost by 1.0 s, branches back in order (cards cross half brightness about 3.0, 3.8, 4.9, 6.0, 7.5 s on the five-branch hub), heartbeat comets in the hold (about 9.0 to 9.6 s on hub and lanes, 8.2 to 9.3 s on rail), none at 10 s.
4. Check the still against the property's `REFERENCE.md` and every tell in `~/.claude/DESIGN-TELLS.md`. Say which were checked and which were fixed.
5. Send the files with `SendUserFile`, with the variant sheet, so Ariel can overrule the pick.

## Choosing a layout

- `hub`: the reference arrangement. A hub ring at left made of one coloured segment per branch, numbered nodes on an orbit beside it, first and last branch full width above and below (their connectors sweep out to the left edge and round into the row), middle connectors turn on large radii, a result panel closing every row. Holds 3 to 5 branches; first and last rows up to 4 steps, middle rows 2. Reads as "one idea, several ways in".
- `rail`: a vertical rail from the hub, one band per branch, steps in a two-column grid, result at the right. Holds 6 branches at 2 steps each, fewer branches at 4. The most legible at feed size.
- `lanes`: hub on top, a bus, one column per branch, result tile closing each lane. Best at 3 to 5 branches with 3 to 4 steps each; at 6 the lanes are narrow.

## Rules that are not negotiable

- Facts only from the post. A failed grounding check is fixed in the spec, never waved through.
- Colours, type, radii, logo and any motion overrides come from the property's profile, `properties/<name>.json` (loaded by `scripts/lib/tokens.mjs`; pick it with `--property <name>`). Every value is copied from the property's `REFERENCE.md`, and `_notes` names the section. A new property means reading its `REFERENCE.md` in full, copying `properties/agor.json` and replacing every value. Never type a hex from memory. A test fails the build if any profile lets a colour that is not in it reach the page.
- Agor: dark ground only, the gradient once, on the glyphs of the headline's accent phrase.
- Branches are colour-coded by default (`--palette series`; Ariel asked for "More colors" on 2026-11-15 and this is our within-token reading of it, not his ruling): each branch takes one of the five gradient stops from REFERENCE.md §1.1 as a flat colour on its badge, step dots, connector, card borders and figure, ordered so neighbouring branches never take neighbouring stops. `--palette single` puts every branch on violet. No hue outside the five stops without Ariel's ruling and a REFERENCE.md entry.
- Motion (in `layout.mjs`, shared by all layouts): complete picture, ghost, then per branch in reading order: its hub segment fills and pulses, its node pops, its connector draws with a comet on the tip, each step lights as the comet passes its dot, the result lands when the comet arrives (figures of two to four digits count up; single digits just land). One heartbeat comet pass in the hold, finished before the still at t = 10 s. Every entrance starts from the identity pose (scale 1), so nothing jumps where the ghost sat.
- Every connector is one continuous subpath; a branch with two runs uses two paths.
- Result panels show real material: a sourced figure, a verbatim quote, or a plain line from the post. No drawn fake screenshots, no stock imagery, no emoji, no icons that were not drawn for it.
- No type under 12 px; nothing shrunk to fit. Cut a step or a branch and say which.
- The loop must close and the PNG is taken from the hold (t = 10 s).

## Known limits

- `hyperframes check` warns `text_below_floor` (28 px, a video heuristic) and `connector_orphan` (connectors stay faintly drawn while a branch is ghosted, which is the design). Both are expected. Step text is 14 to 16 px on a 1080 canvas, the same proportion as the reference; at feed size people read the shape and the headline, then tap to read.
- Text height is estimated from character counts (calibrated on rendered Geist), not measured in a browser. Look at the still: an overflow is possible with unusually wide words.
- Only the `agor` profile exists so far.
- Essays that are one argument, not a set of parallel parts, should exit 2 at extract. That is the right answer, not a failure.
