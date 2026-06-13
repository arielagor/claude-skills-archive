---
name: agor-branded-doc
description: |
  Render an Agor AI branded DOCUMENT as a polished PDF (report, memo, retrospective,
  analysis, addendum, brief, whitepaper) on the Agor letterhead, with optional
  matplotlib charts in the Agor gradient and an optional dark-mode variant. Use when:
  (1) the user asks for "an Agor branded PDF / document / report / memo / writeup", a
  "branded retro/analysis/addendum as a PDF", or "put this on the Agor letterhead";
  (2) a body of prose or data needs to become a publication-quality branded document
  (NOT slides); (3) the user asks for charts/graphs inside that PDF, or a "dark mode"
  version. Forks the Veruna letterhead DOCUMENT template (Georgia+Arial, magenta->
  violet->blue gradient, AGOR AI wordmark). NOT for 16:9 slide decks (use
  agor-branded-deck), NOT for generic unbranded typesetting (use clean-pdf), NOT for
  editable .docx/.pptx (use docx/pptx).
author: Claude Code
version: 1.0.0
date: 2026-06-13
---

# Agor AI Branded Document PDF

## Problem
There was a skill for branded SLIDES (`agor-branded-deck`, 16:9 Beamer) and one for
generic typesetting (`clean-pdf`, not Agor-branded), but nothing for a branded
DOCUMENT: a report/memo/retro/analysis on the Agor letterhead with charts. Building
one ad hoc each time means re-deriving the letterhead preamble, the matplotlib brand
palette, and (for dark mode) the white-logo inversion every time. This skill makes it
one command.

## Context / Trigger Conditions
- "Make this an Agor branded PDF / document / report", "put it on the Agor letterhead",
  "branded retro/analysis/addendum as a PDF", "a memo on our letterhead".
- The deliverable is a flowing document (prose + tables + charts), not slides.
- A dark-mode PDF is requested, or charts/graphs are wanted inside the PDF.

## Solution

**One-command scaffold + build.** From the Bash tool:

```bash
# light
bash ~/.claude/skills/agor-branded-doc/scripts/scaffold.sh my-report
# dark
bash ~/.claude/skills/agor-branded-doc/scripts/scaffold.sh my-report --dark
```

This creates `~/.claude/projects/C--Users-ariel/branded-docs/my-report/` containing:
`brand-gradient.png`, `brand-gradient-thin.png`, the logo (dark `agor-logo.png` or
auto-inverted `agor-logo-white.png`), `preamble.tex` (the chosen light/dark preamble),
`main.tex` (starter body), `agor_charts.py` (the brand chart helper), `make_charts.py`
(a stub), and `build.sh`.

Then:
1. **Edit `main.tex`** — set the title block and write the sections. The body is the
   same for light and dark (the preamble defines the colors). Callout boxes:
   `thesisbg/thesisborder` (violet, the headline), `casebg/caseborder` (blue),
   `warnbg/warnborder` (amber). In dark mode add `coltext=textlight` and a `*title`
   color (e.g. `fonttitle=\color{thesistitle}`) to each `tcolorbox`.
2. **Edit `make_charts.py`** (only if you want charts) — import from `agor_charts`:
   ```python
   from agor_charts import brand, new_axes, gradient_vbar, gradient_hbar, donut, clean, save
   brand("light")   # or "dark"  — sets palette + rcParams; MUST match the doc mode
   fig, ax = new_axes(7.4, 3.0)
   gradient_vbar(ax, 0, 948); gradient_vbar(ax, 1, 651)   # vertical gradient bars
   clean(ax); save(fig, "chart-velocity.png")
   ```
   Reference each PNG in `main.tex` with `\includegraphics[width=\textwidth]{chart-velocity.png}`.
3. **`./build.sh`** — runs `python make_charts.py`, then `xelatex` twice, then verifies
   with `pdfinfo` (page count) + `pdftoppm` (writes `preview-1.png`). Eyeball the preview.

**Charts: matplotlib, never three.js.** three.js is WebGL/browser and cannot embed in a
print PDF. `agor_charts.py` provides the brand colormap (blue->violet->magenta),
`gradient_vbar`/`gradient_hbar` (true gradient fills via clipped `imshow`), `donut`, and
`save` (300-DPI transparent PNG so it works on white or dark). Call `brand(mode)` with
the SAME mode as the document.

## Verification
- `./build.sh` prints `BUILT main.pdf — N pages, 0 overfull` and writes `preview-1.png`.
  Always Read the preview image to confirm the letterhead, logo, gradient rules, and
  charts rendered (dark-mode failure modes: vanished logo = not inverted; invisible
  chart labels = `brand("dark")` not called; black text on black = body color not set,
  but the dark preamble auto-applies it via `\AtBeginDocument`).
- Verified 2026-06-13: light and dark scaffolds both build to a clean 1-page PDF out of
  the box, and the dark preview shows the white logo + deep-black page + violet box.

## Example
Five documents in this exact pattern shipped 2026-06-13, all under
`~/.claude/projects/C--Users-ariel/branded-docs/`: `retro-all-time` (velocity gradient
bars + authorship donut + project bars), `retro-last-week` (per-project bars + daily
spike + hourly histogram), `retro-addendum-mvat` (light) and `retro-addendum-mvat-dark`
(same analysis, dark variant with brightened chart), and `new-sota-pin`.

## Notes
- **Brand source of truth:** `~/.claude/projects/veruna-engagement/source/` (logo +
  gradient PNGs) and `.../deliverables/v3/02-architecture-proposal-v3.tex` (the original
  document preamble these are forked from). GBrain page:
  `projects/agor-branded-document-pdf-pipeline`.
- **xelatex** is required (fontspec + Georgia/Arial): MiKTeX at
  `C:\Users\ariel\AppData\Local\Programs\MiKTeX\miktex\bin\x64\xelatex`. Run twice so
  `lastpage` settles the "Page N of M".
- **matplotlib/Pillow:** `python -m pip install matplotlib pillow` if missing.
- **Footer text:** override per-doc by setting `\providecommand{\docfooterleft}{...}`
  near the top of `main.tex` before `\input{preamble.tex}`.
- **No em-dashes in body prose** per Ariel's standing rule for written deliverables.
- Keep each doc's `.tex` + `make_charts.py` + brand PNGs alongside the PDF so it
  rebuilds with one `./build.sh` and re-sends instantly (see
  `feedback_senduserfile_delivery_surface_gap`).

## See also
- `agor-branded-deck` — 16:9 Beamer SLIDES on the same letterhead (this skill is its
  document counterpart).
- `clean-pdf` — generic typeset PDF, not Agor-branded.
- `docx` / `pptx` — when an editable Office file is needed instead of a PDF.
