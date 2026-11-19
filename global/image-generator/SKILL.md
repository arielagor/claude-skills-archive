---
name: image-generator
description: Use for any image generation — blog covers, social posts, episode art, marketing graphics. Always uses the latest Gemini Flash image model (currently `gemini-nano-banana-2.1`), never Imagen 4. For AI/Agor content, applies the cognexus connectionism style direction.
---

> Folded from the `image-generator` subagent on 2026-11-18 (single-loop plan). Run these steps in the main loop; spawn a subagent only for parallel fresh-context work, black-box verification, or permission isolation. The original agent file is in `~/.claude/unused-agents/image-generator.md`.

# image-generator

Generates all images for Ariel's projects. Two hard rules up front.

## Rule 0: Grok override (opt-in only)

If — and only if — Ariel **explicitly** asks for Grok (e.g. "please use grok to create the following image...", "use grok imagine", "make this with grok"), skip Gemini entirely and use the xAI Imagine helper:

```
node ~/.claude/scripts/grok-imagine.mjs "the prompt" --out <path> [--aspect 16:9] [--resolution 2k] [--n N]
```

- Key comes from `XAI_API_KEY` in `~/.claude/settings.json` (auto-resolved by the script). No setup needed.
- Model defaults to `grok-imagine-image-quality`; pass `--model grok-imagine-image` for the cheaper standard model.
- Output is **JPEG** (~$0.05/img at 1k, $0.07 at 2k). The script auto-corrects the file extension.
- The last stdout line(s) are the saved absolute path(s) — read that back to Ariel.

This is a manual override. Without an explicit "grok" from Ariel, default to Gemini Flash below.

## Rule 1: Model choice

**Always use the latest Gemini Flash image model. Never Imagen 4.**

Current model (Nano Banana 2.1, GA 2026-10-06; live-verified 2026-10-09): `gemini-nano-banana-2.1`

Before generating, confirm the current latest with a models list call — there may be a newer variant. Google switched naming at 2.1: look for `gemini-nano-banana-*` (newer scheme) as well as `gemini-*-flash-image*` (old scheme). Always prefer the newest flash-tier (non-Pro) image model.

API pattern:
```
Model: gemini-nano-banana-2.1
Config: { "responseModalities": ["image", "text"] }
Endpoint: generateContent
```

Do NOT use `imagen-4.0-generate-001` or any other Imagen variant unless Ariel explicitly asks. This is a global preference across all projects.

## Rule 2: Art direction for AI / Agor content

Any image for Agor AI Consulting, agor.me, AI-related blog posts, episode covers, podcast art, or similar uses the **cognexus connectionism** style:
- Brains, neurons, nodes, networks, circuits
- The mixing of man and machine
- Neural / connectionist visual language

Ariel's original description: "connectionism oriented with brains and nodes and networks and neurons etc. and circuits the mixing of man and machine, cognexus"

See `feedback_art_style.md`.

## Style by project

| Project | Style direction |
|---|---|
| Agor AI / agor.me | Cognexus connectionism (brains, nodes, circuits) |
| ModelStack | Financial models, clean business graphics — NOT cognexus |
| MVAT Focus / Mirror | Minimalist, productivity, Apple-native feel |
| aphor.me | Calm, dreamlike, Ericksonian — NOT neural/tech imagery |
| GifLoop | Playful, colorful, GIF/animation culture |
| Coqui Chorus / co-kee | Natural, biological, frogs, wetland, scientific |

If the project isn't listed, ask Ariel or infer from existing assets in the project repo.

## Workflow

1. Read the use case (blog cover? social post? product shot?).
2. Pick the project's style from the table above.
3. Compose the prompt. Be specific about composition, aspect ratio, color palette, subject. Reference real-world art only when needed.
4. Generate. Inspect the output. Re-prompt if it's off — don't ship subpar.
5. Save to the right path:
   - Blog covers: `<project>/public/images/blog/<slug>.png` or `<project>/blog/images/<slug>.png`
   - Social: `<project>/marketing/social/<date>.png`
   - Episode art: follow the existing pattern in the project

## Aspect ratios

- Blog cover: 16:9 or 1200×630 (OG image)
- Social (X/Twitter): 16:9 or 1:1
- Instagram: 1:1 or 4:5
- Instagram story: 9:16
- Podcast episode cover: 1:1, 3000×3000 min for Apple Podcasts

## Don't

- Don't use Imagen 4. Never. Unless Ariel explicitly says so.
- Don't bolt cognexus onto projects where it doesn't fit (aphor.me, modelstack, coqui).
- Don't ship the first attempt if it's off — iterate.

## Sources
- `feedback_image_gen.md` — Gemini Flash, not Imagen 4
- `feedback_art_style.md` — cognexus connectionism for AI/Agor content
