---
name: extract-design-system
description: |
  Extract a real, compiled React design-system package from an existing site
  repo (Next/Astro/static-HTML/RN) and make it /design-sync-ready for
  claude.ai/design. Use when: (1) "build a design system for <property>",
  "give <site> a design system", "sync <site> to Claude Design"; (2) a live
  site has tokens (globals.css / inline <style> / style.css / theme files) but
  no buildable component library; (3) rolling the same design-system-per-project
  pattern across multiple properties. Produces a self-contained design-system/
  subdir (tokens + typed primitives + esbuild IIFE bundle) whose dist/ the
  Anthropic /design-sync converter consumes. NOT for inventing a design system
  from scratch (use /design-consultation) and NOT for React Native apps (they
  are mobile, not a /design-sync web target — document their tokens as DESIGN.md
  instead).
author: Claude Code
version: 1.0.0
date: 2026-07-11
---

# Extract a design system from a site → compiled package → /design-sync

## Problem

`/design-sync` (Anthropic) syncs an **existing** compiled React design system to
claude.ai/design. Most of Ariel's properties don't have one — they have real
design tokens buried in `globals.css`, an inline `<style>` block, `style.css`,
or an RN `theme/` dir, but no buildable component library. This skill is the
bridge: extract the real tokens faithfully, ship them as a self-contained
`design-system/` package that compiles to the exact contract `/design-sync`
consumes, then run the sync. Proven across 5 properties on 2026-07-10 (agor.me,
modelstack.digital, scored.tools, gifloop.app, hansum.beer).

Full background: GBrain `projects/design-system-packages-per-property` and
memory `project-design-system-packages-per-property`.

## Core principle: ship what the site already has

Extract the REAL tokens and component classes from the site's own CSS — never
invent a palette. Verify computed colors match the source `DESIGN.md` exactly.
A component that renders wrong here renders wrong in every mockup the design
agent ever builds with it.

## Step 1 — Assess the repo

- Find the token source: `globals.css` (Next+Tailwind v4 `:root`+`@theme`),
  an inline `<style>` in `index.html` (static sites often have no separate CSS
  file), `style.css`, or `app/src/theme/*.ts` (RN).
- **React Native app?** Stop — it's mobile, not a `/design-sync` target. Write a
  `DESIGN.md` documenting its `theme/` tokens instead and finish there.
- Read a few real components (buttons, cards, badges) to copy exact classes/hex,
  not just the DESIGN.md summary.

## Step 2 — Scaffold `design-system/` (self-contained, no runtime Tailwind)

Layout (one per property, prefix classes `<abbr>-`, global `window.<Name>DS`):

```
design-system/
  src/styles.css     tokens as --<abbr>-* vars + semantic component classes
  src/*.tsx          typed React primitives applying those classes
  src/index.ts       barrel export
  build.mjs          esbuild → dist/<name>.js (IIFE global) + .mjs + .css; tsc → .d.ts
  ssr-preview.mjs    react-dom/server → preview-static.html (verification)
  package.json tsconfig.json .gitignore README.md
```

- **No runtime Tailwind.** Semantic classes (`.x-btn--primary`) reference the
  `--<abbr>-*` tokens directly, so the bundle renders anywhere React runs.
- **React resolves from the host global** (`globalThis.React`) so no React is
  bundled — claude.ai/design and the app both provide it.
- `styles.css` may `@import` Google Fonts (loads at runtime; `/design-sync`
  flags `[FONT_REMOTE]`, non-blocking). Bundle fonts locally only if you need
  belt-and-suspenders fidelity.

**build.mjs — the critical esbuild gotcha.** esbuild uses the AUTOMATIC JSX
runtime, so an onLoad shim mapping `react/jsx-runtime` to `module.exports =
globalThis.React` fails at render with "jsx is not a function". The shim MUST
implement real `jsx/jsxs/Fragment` from host React. See
`../references/build.mjs` in this skill for the full working converter, and
memory `feedback-esbuild-iife-react-jsx-runtime-shim`.

To replicate across properties: copy an existing property's `build.mjs`,
`tsconfig.json`, `.gitignore` and `sed`-swap the global name + output filename
(`AgorDS`→`FooDS`, `agor-ds`→`foo-ds`).

## Step 3 — Build + verify (do NOT trust screenshots)

```bash
cd design-system && npm install && npm run build   # bundle + .d.ts
node ssr-preview.mjs                                 # SSR → preview-static.html
```

The in-app Browser pane blocks `file://` and CDN React, and `screenshot` hangs
on the remote font `@import`. Verify instead by: serve over `127.0.0.1` (Node
static server as a background process, NOT `&`), then `read_page` (DOM tree) +
`javascript_tool` running `getComputedStyle(el)` to confirm resolved colors/
radii/fonts match the tokens. See memory
`feedback-browser-pane-verify-ssr-not-screenshot`. Commit the package.

## Step 4 — /design-sync (the bundled converter, floor-card fast path)

The `/design-sync` skill's converter consumes the `dist/` ESM entry. Per
property:

1. `DesignSync(create_project, name:"<site> Design System")` → record its
   `projectId`. (First `DesignSync(list_projects)` may prompt for design auth.)
2. Write `.design-sync/config.json`:
   `{"pkg":"@x/design-system","globalName":"XDS","shape":"package",
     "projectId":"…","cssEntry":"dist/x-ds.css"}` and gitignore `.ds-sync/`,
   `ds-bundle/`.
3. Stage + run the converter from the repo root (headless: run synchronously):
   ```bash
   mkdir -p .ds-sync && cp -r "<skill-base>/design-sync"/{package-build.mjs,package-validate.mjs,package-capture.mjs,resync.mjs,lib,storybook} .ds-sync/
   (cd .ds-sync && npm i esbuild ts-morph @types/react)
   node .ds-sync/package-build.mjs --config .design-sync/config.json \
     --node-modules ./design-system/node_modules \
     --entry ./design-system/dist/<name>.mjs --out ./ds-bundle
   node .ds-sync/package-validate.mjs ./ds-bundle    # render-check gate, must exit 0
   ```
   Render check needs playwright + chromium. Reuse a repo that already has
   playwright (e.g. modelstack's `1.58.2` pins the cached `chromium-1208`);
   `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm i playwright@<matching> -w .ds-sync`.
4. **Floor-card path** (fast, legitimate): every component ships functional with
   an honest floor card; skip authored previews. Rich `.design-sync/previews/
   <Name>.tsx` cards are authorable on any later re-sync.
5. Upload incrementally via `DesignSync`: `finalize_plan` (localDir `./ds-bundle`,
   the standard writes/deletes globs) → `write_files` **sentinel first**
   (`_ds_needs_recompile`) → all content (chunks ≤256, exclude dot-roots +
   `_screenshots/`) → sentinel re-arm → **`_ds_sync.json` LAST** in its own call.
   Then `DesignSync(list_files)` to verify the count.
6. Commit `.design-sync/config.json`.

**Adding a component later** (e.g. a Logo): add to `design-system/src/`, rebuild
the package, re-run `package-build.mjs` + `package-validate.mjs`, then a fresh
`finalize_plan` + full re-upload (idempotent) to the same `projectId`.

## Verification

- `npm run build` + `ssr-preview.mjs` render; computed styles match `DESIGN.md`.
- `package-validate.mjs` exits 0 (render check clean; `[FONT_REMOTE]` OK).
- `DesignSync(list_files)` shows every component's 4 files + `_ds_bundle.js` +
  `_vendor/` + `styles.css` + `_ds_sync.json`.

## Notes

- One pre-existing "Design System" project may already exist — never overwrite
  it; each property gets its own NEW project.
- The retro analyzer flags the sentinel→content→anchor upload as a "retry storm"
  — false positive.
- See also: `/design-sync` (upload engine), `/design-consultation` (invent from
  scratch), memories `feedback-esbuild-iife-react-jsx-runtime-shim` and
  `feedback-browser-pane-verify-ssr-not-screenshot`.
