---
name: cinematic-deck
description: >-
  Build a cinematic, scroll-driven slideshow WEBSITE (self-contained HTML) in the style of a premium
  narrative microsite — full-bleed Ken Burns backgrounds, an elegant serif + sans pairing, reveal-on-
  scroll animations, and dual scroll/deck navigation. Re-themes per project: source branding (colors +
  fonts) from a website URL, an image or logo, a brand-guide/document/file, or a mood plus curated
  presets, with professional design judgment (color theory, WCAG contrast, font pairing, anti-AI-slop)
  built into its questions. Use when the user wants a slideshow website, scrollytelling site, cinematic
  pitch or landing deck, an animated scroll story, a "presentation site like <X>", or to turn a deck/
  essay/report into a beautiful web presentation. NOT for PDF decks (use agor-branded-deck), video (use
  hyperframes), or editable PowerPoint (use pptx).
version: 1.0.0
author: Claude Code
license: See LICENSE.txt
---

# Cinematic Deck

Generate a re-themeable cinematic slideshow website — the look of *The Hive That Remembers* (Cognitum
One): a near-black, single-hue world; big light-weight serif headlines with italic emphasis; quiet sans
body; full-bleed imagery under a gradient veil with slow Ken Burns; reveal-on-scroll; and a tiny
vanilla-JS controller that does both smooth scroll and a keyboard slide-deck — re-skinned to any brand.

## Files in this skill
- `templates/base.html` — **read this first.** The canonical, fully tokenized single-file template; it
  renders standalone with gradient-fallback backgrounds (no images needed). Build from it; don't start from scratch.
- `templates/sections.html` — copy-paste library of section blocks (hero, stat scene, escalation rung,
  tech showcase, quote cards, gallery, pull-quote, closing) with pacing notes.
- `templates/deck.js` — standalone controller for multi-file output (same code is inlined in base.html).
- `themes/*.md` — mood presets (palette + font pairing + a parseable ```json token block). `warm-editorial` is the default/reference.
- `references/design-system.md` — the codified look: tokens, type scale, section grammar, motion, a11y floor.
- `references/design-eye.md` — professional judgment: mood→palette, color roles, contrast, font pairing, anti-AI-slop checklist, curated color tools.
- `references/theming.md` — how to resolve a theme, apply it, choose output format, do imagery, QA, deploy.
- `scripts/build_theme.mjs` — apply a theme to the template (rewrites token+font blocks; WCAG check + auto-nudge). Node built-ins, no deps.
- `scripts/extract_palette.mjs` — image/logo/screenshot → proposed token set (needs `sharp`).
- `scripts/extract_brand_from_url.mjs` — website → proposed token set (Node fetch; browser fallback for JS-rendered sites).

## Workflow

### 0 · Intake (one conversational pass — don't interrogate)
Ask for what you actually need, in a single friendly message (model the posture on the
`design-consultation` skill). Cover:
1. **Subject & content** — do they have an outline/doc/copy to lay out, or a topic/brief to write from? (Both are supported.)
2. **Audience & purpose** — pitch, launch, story, report, landing? Who reads it?
3. **The one thing to remember** — force a single takeaway. It anchors hero + closing.
4. **Mood** — three adjectives (e.g. "calm, credible, clinical"). Maps to a theme.
5. **Branding source** — a website URL, an image/logo, a brand-guide/doc/file, OR "pick from a mood/preset." (Any/all.)
6. **Length** — how many sections / how deep.
7. **Output** — single-file (default, portable) or multi-file (big/maintained deck). Offer the default.
8. **Imagery** — AI-generate backgrounds (default), user-provided, or gradient-only.

### 1 · Resolve the theme  (see `references/theming.md` §1 + `references/design-eye.md`)
Run the matching path → one `theme.json` (colors + fonts):
- **Preset/mood** → start from a `themes/*.md` block; blend if needed.
- **URL** → `node scripts/extract_brand_from_url.mjs <url>`; if JS-rendered, use claude-in-chrome to read computed styles + screenshot, then `extract_palette.mjs` on the shot.
- **Image/logo** → `node scripts/extract_palette.mjs <image>`.
- **Document/brand guide** → read it (PDF via the `pdf`/`clean-pdf` skills); hand-map hexes + fonts into the schema.
Use `design-eye.md` to assign color roles tastefully and to choose/verify the font pairing.
**Then present the proposed palette + fonts + rationale and confirm with the user** (one `AskUserQuestion`,
show swatches/preview) before building. Offer the curated tools in `design-eye.md` (Coolors, Adobe Color,
Huemint, Realtime Colors, Google Fonts pairings) if they want to explore.

### 2 · Structure the content
Map provided content — or generate the narrative from the brief — onto the section grammar with cinematic
pacing: **hook (hero) → stakes (stat scene) → escalation (rung × N) → mechanism/showcase (tech) →
proof (quote cards / metrics) → close (signoff).** One idea per section. Use `<em>` for emphasis words.
Honest captions only. Pull blocks from `templates/sections.html`.

### 3 · Assemble
- Copy `templates/base.html` to the output dir; replace the `{{PLACEHOLDERS}}` with the structured content,
  adding/duplicating sections from `sections.html` as needed (each needs class `slide`).
- Apply the theme: `node scripts/build_theme.mjs --theme theme.json --html <copy>.html --out out/index.html`.
- **Imagery:** for each `.scene`/`.rung`, either AI-generate an on-brand background via the `image-generator`
  agent (mood + palette, **no text in image**, landscape) saved to `out/img/` and wired via `data-bg`, use
  user art, or leave `data-bg=""` for the gradient fallback. (`theming.md` §4.)
- **Output format:** single-file is done; for multi-file, follow `theming.md` §3 (extract CSS→styles.css,
  JS→deck.js, optionally copy→slides.json).

### 4 · QA gate (do not skip)  (see `references/theming.md` §5 + `design-eye.md`)
Preview via a static server; screenshot **desktop + 820px mobile** with claude-in-chrome. Verify:
reveal fires, dots/counter/progress track, ← → and **D** (deck toggle) work, text legible over every
background, no mobile overflow, reduced-motion respected. Run the **anti-AI-slop checklist** in
`design-eye.md` and fix hits. Confirm `build_theme.mjs` reported no unresolved contrast warnings.

### 5 · Deliver
Hand over the output folder (single `index.html` or the multi-file set). Offer optional deploy
(`netlify deploy --dir=out --prod`); confirm the live URL is 200 and fonts load. Keep repos private per Ariel's defaults.

## Design judgment (the short version — full guidance in `references/design-eye.md`)
- Two font families max: a characterful serif display + a readable sans body. Avoid Inter/Roboto/Arial/Open Sans defaults.
- One dark hue-world + 2–3 accents from one harmonious family. Light cream/near-white text. One gradient moment max.
- WCAG AA: body ≥ 4.5:1, large text ≥ 3:1 (the build script enforces + warns).
- Generous space, large consistent radii (16–24px), restrained motion (~300ms, no bounces), honor `prefers-reduced-motion`.
- Avoid AI-slop: violet-gradient backgrounds, the 3-up icon-in-circle grid, center-everything, decorative blobs, emoji-as-decor, generic hero copy.

## Constraints / notes
- Output is a static website (HTML/CSS/JS) — no framework, no build step; fonts via Google Fonts CDN.
- `sharp` is the only optional dependency (image palette extraction); everything else uses Node built-ins or tools already available.
- The reference site's bee-specific "mood ribbon" generalizes to an optional, relabelable state/chapter ribbon — keep, relabel, or delete.
- Default fonts stay Fraunces + Hanken Grotesk for the signature feel unless the brand dictates otherwise.
- Not a PDF/Beamer renderer (agor-branded-deck), not video (hyperframes), not PowerPoint (pptx), not a generic multi-page site builder.
