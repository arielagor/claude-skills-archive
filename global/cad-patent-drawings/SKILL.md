---
name: cad-patent-drawings
description: |
  Generate draftsman-grade patent (37 CFR 1.84) or technical line drawings from
  real 3D CAD geometry using build123d/OCP, instead of flat 2D schematics. Use when:
  (1) making formal patent figures (exploded, orthographic, cross-section, isometric)
  for a nonprovisional or examined application, (2) "upgrade the figures / draftsman
  quality / proper patent drawings", (3) any time hidden-line line art + a manufacturable
  STEP/STL from parametric dimensions is wanted, (4) the matplotlib schematic figures
  aren't good enough. Covers the hard-won gotchas: build123d won't install on Python 3.14
  (use a 3.12 venv), boolean results are multi-solid ShapeLists (wrap Compound), sections
  must use a thin-slab intersect (not subtract-half) or they render dashed, numeral
  placement uses the projection's mass-centroid, cairosvg needs libcairo (absent on
  Windows) so project edges with matplotlib, and the build parallelizes cleanly via a
  per-embodiment agent fan-out on a shared parts+render foundation.
author: Claude Code
version: 1.0.0
date: 2026-06-11
---

# CAD patent drawings (build123d -> hidden-line line art)

Proven on the deflate-valve nonprovisional: a parametric CAD model -> 9 draftsman-grade
patent figures (`figures-cad.pdf`) + a manufacturable STEP. Worked example lives in
`~/.claude/projects/deflate-valve/figures/cad/` (model.py, parts.py, render.py, *_figs.py).

## Problem
Matplotlib 2D schematics are flat, arbitrarily proportioned, and lack hidden/section-line
conventions. Examined patent applications read far better with drawings made FROM real 3D
geometry (correct proportions, hidden-line removal, true sections), which also yields a
manufacturable STEP/STL as a byproduct.

## Context / trigger conditions
- "Upgrade the figures", "draftsman-grade / proper patent drawings", "formal drawings".
- Need exploded, orthographic, cross-section, or isometric views with reference numerals.
- A parametric model that regenerates every figure when a dimension changes.

## Solution (the pipeline)

**1. Environment — DO NOT skip; build123d will not install on Python 3.14.**
OCP/scipy lack 3.14 wheels and try to compile (no MSVC -> meson "Unknown compiler" error).
Create a Python 3.12 venv:
```
winget install --id Python.Python.3.12 --scope user --silent
"%LOCALAPPDATA%\Programs\Python\Python312\python.exe" -m venv .venv312
.venv312\Scripts\python.exe -m pip install build123d numpy-stl matplotlib
```
Run ALL CAD scripts with `.venv312\Scripts\python.exe`.

**2. Model parametrically (build123d algebra mode).** Define each part from real dimensions;
`Pos(x,y,z)*Cylinder(...)`, boolean `+`/`-`. Export `export_step(part, "x.step")` +
`export_stl`. Keep parts as separate functions with a `dz` offset so the same parts compose
both assembled and exploded views.

**3. Hidden-line line art (the patent format).** `visible, hidden = part.project_to_viewport(direction)`,
then plot each edge with matplotlib: visible = solid black (lw~1.4), hidden = dashed gray.
Sample each edge `[e @ (i/n) for i in range(n+1)]` -> `(p.X, p.Y)`. One figure per US-letter
PDF page, "FIG. N" title, bare reference numerals + leader lines (NO descriptive sentences).

**4. Cross-sections — use a thin SLAB, not subtract-half.** `project_to_viewport` does
hidden-line removal against the opaque solid, so a subtract-half "section" renders the cut
interior DASHED from every angle. Instead intersect a thin slab straddling the cut plane and
view it edge-on, so every edge is on the silhouette -> SOLID lines (correct 37 CFR 1.84):
```
slab = Box(BIG, t, BIG)            # t~1mm; axis: Box(BIG,t,BIG)=y-plane, Box(t,BIG,BIG)=x-plane
out=[]
for part in shapes:
    sols=[s & slab for s in part.solids() if (s & slab) and len((s&slab).solids())]
    ...                             # per-solid: Compound & Box only catches one child!
```
View along the slab normal (e.g. y-slab -> direction (0,+/-100,z); pick the sign that faces
the cut toward the viewer — render both and Read the PNG to choose).

**5. Numerals.** `project_to_viewport`'s look_at defaults to the shape's MASS CENTROID, not
bbox center (they can differ by >10mm), which scrambles label anchors. Probe each feature's
projected (x,y) with the centroid look_at, place numerals OUTSIDE the outline with short
non-crossing leaders, using the render's returned bbox.

**6. Parallelize via agent fan-out (optional, for multi-part sets).** Build a STABLE shared
foundation first (a `parts.py` primitives library + a `render.py` with `render()` and
`slab_section()`), verify it yourself, THEN fan out one agent per embodiment/assembly. Each
agent writes its OWN module + figure files (non-overlapping), imports the shared foundation
read-only, and SELF-VERIFIES by Reading its own rendered PNGs and iterating numeral/section
choices. Default agents to the SOTA model.

## Verification
After each render, **Read the PNG yourself** and check: geometry reads correctly, sections
show solid (not dashed) interior lines, numeral leaders point at the right features without
crossing. For quick geometry validation, render the STL shaded via numpy-stl + matplotlib 3D.

## Gotchas (each cost real time)
- **Python 3.14 -> no build123d.** Use a 3.12 venv (above).
- **Boolean results are multi-solid ShapeLists.** `Location * ShapeList` raises "other must be
  a list of Locations", and `export_step` needs `.wrapped`. Normalize: `Compound(children=list(part.solids()))`,
  then `.translate((0,0,dz))`. A `_place(part, dz)` helper handles both.
- **`Compound & Box` only intersects ONE child** of a multi-solid compound -> section/slice must
  loop `for s in part.solids()` and recombine.
- **cairosvg fails on Windows** (`cannot load library libcairo`); don't rely on SVG->PNG.
  Project edges directly with matplotlib (above), and use numpy-stl for shaded previews.
- **`scale(Cylinder(...), (1, ratio, 1))`** makes elliptical towers (mouthpiece/cap).

## Notes
- Informal drawings are filable and correctable later (Notice to File Corrected Drawings);
  this skill makes them clean enough to avoid the objection. Surface shading (oblique lines)
  is the one thing this doesn't do and 1.84 doesn't require it; hand the STEP to a patent
  illustrator only if gallery-grade shading is wanted.
- Pairs with `[[file-provisional-patent]]` (the filing flow); these are its drawings.

## References
- Worked example: `~/.claude/projects/deflate-valve/figures/cad/` — `model.py`, `parts.py`,
  `render.py` (`render()` + `slab_section()`), `cart_figs.py`/`slider_figs.py`/`corner_figs.py`,
  `figures-cad.pdf`.
- build123d docs: build123d.readthedocs.io (project_to_viewport, ExportSVG, algebra mode).
- 37 CFR 1.84 (USPTO drawing standards).
- GBrain: `projects/deflate-valve-cad-figure-pipeline`.
