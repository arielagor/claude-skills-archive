---
name: agor-branded-deck
description: |
  Render a branded 16:9 slide deck (investor pitch, sales deck, board deck) as a polished PDF
  on the Agor AI letterhead, using xelatex + Beamer. Use when: (1) the user asks to "render the
  deck", "make a branded deck/pitch deck/slides", "turn this outline into slides", or "build an
  investor deck"; (2) a deck outline (Markdown) exists and needs to become an actual PDF; (3) any
  Agor AI / Agor AI Advisory branded presentation is needed. Forks the Veruna LaTeX letterhead
  (magenta->violet->blue gradient, AGOR AI wordmark, Georgia+Arial). NOT for branded DOCUMENTS or
  proposals (use meeting-to-proposal or clean-pdf) and NOT for editable .pptx (use pptx).
author: Claude Code
version: 1.0.0
date: 2026-06-09
---

# Agor Branded Deck (xelatex + Beamer)

## Problem
Ariel needs polished, on-brand slide decks (investor pitch, sales, board) as PDFs, on the Agor AI
letterhead. There was no skill for SLIDE decks: `clean-pdf` / `make-pdf` produce documents,
`meeting-to-proposal` produces a branded proposal document, `pptx` produces editable PowerPoint.
This covers the gap: a presentable, brand-consistent PDF deck rendered with LaTeX Beamer.

## Context / Trigger Conditions
- "render the deck", "make a pitch/investor/sales deck", "turn this outline into slides", "branded slides".
- A `PITCH_DECK_OUTLINE.md` (or similar) exists and should become a real, presentable PDF.
- The deck must carry the Agor AI brand (gradient, wordmark, fonts).

## Solution

### 1. Brand assets and palette (fork the Veruna letterhead)
Assets live at `~/.claude/projects/veruna-engagement/source/`:
- `agor-logo.png` (the mark), `brand-gradient.png` (thick rule), `brand-gradient-thin.png` (thin rule).
Copy all three into the deck build dir and reference them relatively (absolute Windows paths are flaky in xelatex graphics).

Palette (HTML hex, from `02-architecture-proposal-v3.tex`):
`agorblack #050508`, `agormagenta #D946EF`, `agorviolet #8B5CF6`, `agorblue #3B82F6`, `agorink #1F2937`, `agormeta #6B7280`. Fonts: `\setmainfont{Georgia}` (body), `\setsansfont{Arial}` (titles).

### 2. Beamer skeleton (16:9, brand chrome)
```latex
\documentclass[aspectratio=169,10pt]{beamer}
\usepackage{fontspec}\usepackage{tikz}\usepackage{graphicx}\usepackage{xcolor}
\usepackage{ragged2e}\usepackage{tcolorbox}\usetikzlibrary{calc}
% colors (define before templates) ...
\usefonttheme{professionalfonts}\setmainfont{Georgia}\setsansfont{Arial}
\renewcommand{\familydefault}{\rmdefault}
\setbeamertemplate{navigation symbols}{}
\setbeamersize{text margin left=16pt, text margin right=16pt}
% frametitle: sans bold + a full-width gradient underline
\setbeamertemplate{frametitle}{\nointerlineskip\vskip10pt%
  {\sffamily\bfseries\color{agorblack}\fontsize{16pt}{19pt}\selectfont\insertframetitle\par}%
  \vskip4pt\hbox{\includegraphics[width=\textwidth,height=2.2pt]{brand-gradient.png}}\vskip2pt}
% footline: thin gradient + AGOR wordmark + page number
\setbeamertemplate{footline}{\hbox{\includegraphics[width=\paperwidth,height=1.0pt]{brand-gradient-thin.png}}%
  \vskip2pt\makebox[\paperwidth]{\hspace{12pt}{\sffamily\fontsize{7pt}{8pt}\selectfont\color{agormeta}<BRAND LOCKUP>}%
  \hfill{\sffamily\fontsize{7pt}{8pt}\selectfont\color{agormeta}\insertframenumber}\hspace{12pt}}\vskip5pt}
```
Title slide: a `[plain]` frame with `\begin{tikzpicture}[remember picture,overlay]`, fill the page `agorblack`, then place the logo+wordmark (top), the big white title, a centered `brand-gradient.png` accent rule, the subtitle, and the founder line as `\node`s positioned by `yshift` off `current page.center`/`.north`/`.south`. A full working file is at `~/.claude/projects/ventures/ai-ads-agency/docs/business/deck/agor-ai-ads-deck.tex` — copy and adapt it.

**Closing slide signature (standard as of 2026-06-10):** every deck's final/closing slide
carries Ariel's handwritten signature as a subtle mark. Asset:
`~/.claude/brand/ariel-signature-transparent.png` (copy into the build dir like the other
assets). On the closing `[plain]` frame (dark `agorblack` fill), place it bottom-right,
small and quiet, via the overlay tikzpicture:
```latex
\node[anchor=south east, xshift=-26pt, yshift=22pt, opacity=0.9] at (current page.south east)
  {\includegraphics[width=2.6cm]{ariel-signature-transparent.png}};
```
On dark fills the blue stroke (#1560F0-ish) reads well; do not recolor it. Keep it OFF
content slides (closing slide only) so it stays a signature, not a watermark pattern.

### 3. Render (twice)
```bash
cd <deck-dir>
xelatex -interaction=nonstopmode -halt-on-error deck.tex   # pass 1
xelatex -interaction=nonstopmode -halt-on-error deck.tex   # pass 2 (settles tikz remember-picture)
```
xelatex is MiKTeX on this box (`...\AppData\Local\Programs\MiKTeX\miktex\bin\x64\xelatex.exe`). The "you have not checked for MiKTeX updates" line is cosmetic.

### 4. Verify visually (do not trust exit code)
The Read tool's PDF rendering needs poppler (`pdftoppm`), which is NOT on its PATH. Use poppler's `pdftocairo` (shipped with MiKTeX) to rasterize specific slides, then Read the PNGs:
```bash
for p in 1 7 12; do pdftocairo -png -r 110 -f $p -l $p -singlefile deck.pdf "v-p$p"; done
```
Then `Read v-p1.png` etc. Check: 0 overfull boxes (`grep -ci overfull pass2.log`), the page count matches, the title slide and any tables/panels render cleanly.

## Verification
- `Output written on deck.pdf (N pages).` with N = expected slide count.
- `grep -ci overfull pass2.log` returns 0.
- Rasterized slides visually correct (brand chrome present, no clipped content).

## Notes / Gotchas
- **Escape for LaTeX:** `$` -> `\$` (prices like `\$299`), `%` -> `\%`, `&` is a table column separator. Tildes: write "about"/"roughly", not `~` (it is a non-breaking space, not a literal `~`).
- **No em-dashes.** Agor honesty/style rule across all client- and investor-facing output. Use commas/colons/parens.
- **"Overfull \vbox ... too high" on a dense slide:** drop the box body to `\footnotesize` and `\setlength\itemsep{2pt}`, shorten a multi-line bullet, or cut the lead line to one line. Re-render and re-check.
- **Title-slide overlap:** adding a line to the title block pushes text into a fixed-position gradient rule. Nudge the `yshift` of the title block up and the gradient/subtitle nodes down until the rule clears the tagline.
- **Two-column "X vs Y" slide:** `\begin{columns}[T]` + a `tcolorbox` per column (`colback=paneltint` violet panel vs `colframe=agorblack` outline panel).
- **Repo hygiene:** the deck repo's `.gitignore` may ignore `*.pdf` (artifacts rebuild from `.tex`). Commit the `.tex` + the 3 brand PNGs; do NOT force-add the PDF. Clean `*.aux/*.nav/*.out/*.snm/*.toc` scratch before committing.
- **Brand lockup** varies by venture (e.g. footer "AI VISIBILITY . built on MVAT, by Agor . app.mvat.ai"); confirm the current product lockup before rendering.

## References
- Brand source: `~/.claude/projects/veruna-engagement/deliverables/v3/02-architecture-proposal-v3.tex` (preamble: colors, fonts, header/footer gradient rules).
- Working deck: `~/.claude/projects/ventures/ai-ads-agency/docs/business/deck/agor-ai-ads-deck.tex`.
- See also: `meeting-to-proposal` (branded proposal documents), `clean-pdf` / `make-pdf` (branded documents), `pptx` (editable PowerPoint).
