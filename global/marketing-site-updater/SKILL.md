---
name: marketing-site-updater
description: Use when a product ships, hits a milestone, or changes version — updates the static marketing site (gifloop-site, aphor.me, agor.me, modelstack.digital) with new copy, App Store URL, version, and release date, opens a PR, and auto-merges. Wraps `scripts/update_marketing_site.py` pattern.
---

> Folded from the `marketing-site-updater` subagent on 2026-11-18 (single-loop plan). Run these steps in the main loop; spawn a subagent only for parallel fresh-context work, black-box verification, or permission isolation. The original agent file is in `~/.claude/unused-agents/marketing-site-updater.md`.

# marketing-site-updater

Pushes marketing-site content changes (new version, App Store link, "Now live" banner, screenshots, pricing) to the product's Netlify-deployed static site. Pattern lives in gifloop/scripts/update_marketing_site.py and can be adapted for each site.

## Sites + their repos

| Product | Site repo | Hosting | Tech |
|---|---|---|---|
| GifLoop | `arielagor/gifloop-site` | Netlify | static HTML + CSS |
| aphor.me | `C:\Users\ariel\.claude\projects\aphor.me\` | Netlify | static |
| agor.me | `C:\Users\ariel\.claude\projects\agor.me\` | Netlify | Next.js |
| modelstack.digital | `C:\Users\ariel\.claude\projects\modelstack.digital\` | Netlify | static + build scripts |
| MVAT Focus | `mvat-focus/site/` | Netlify | static |
| co-kee | `co-kee.com` | Netlify | static |

## Canonical script shape (see gifloop `scripts/update_marketing_site.py`)

Env:
- `<PROJECT>_SITE_PAT` — GitHub PAT with push rights on the site repo
- `APP_STORE_URL` — e.g. `https://apps.apple.com/app/id6761496920`
- `RELEASED_AT` — ISO date, e.g. `2026-04-16`
- `VERSION` — e.g. `1.0`

Behavior:
1. Clone the site repo to a temp dir with the PAT in the remote URL.
2. Edit the relevant files (hero CTA, banner, release date, version string).
3. **Idempotent**: if content already matches, exit 0 with "already up to date". If a PR with head `release/v{VERSION}` already exists, reuse it.
4. Create branch `release/v{VERSION}`, commit, push, open PR.
5. Try to auto-merge (`gh pr merge --auto --rebase --delete-branch`; rebase-merge is the only style agents use, see memory reference_claudemd_git_hygiene.md). If auto-merge is off, leave the PR open and log it.
6. Exit 0 on success (including no-op), 1 on failure.

## Deploy verification

After merge, Netlify auto-deploys from main. Do NOT declare success until:
1. Netlify deploy status = `ready`
2. `curl -s <site-url>` returns 200 and contains the new version/link

Per `feedback_verify_before_success.md` — never trust a merge, always verify the live URL.

## Env var management

Ariel's hard rule: **Netlify env vars cannot be set via local Claude commands**. If the update requires a new env var (e.g. a new Stripe key), tell Ariel to set it via the Netlify dashboard or `netlify env:set` — do NOT hallucinate a `claude config set` command.

## Content rules

- Ariel writes copy directly, no corporate tone, no emoji unless the site already uses them.
- Link to App Store via the numeric app id, not the slug (stable): `https://apps.apple.com/app/id6761496920`.
- Never touch blog content or pricing via this agent — those have their own agents / manual flows.
- For agor.me specifically: the blog feed is at `src/app/feed/blog/route.ts` (dynamic Next.js) and any copy change near there may affect Substack import. See `substack-syncer`.

## Sources
- Pattern: `C:\Users\ariel\.claude\projects\gifloop\scripts\update_marketing_site.py`
- `feedback_verify_before_success.md`
- CLAUDE.md: "Netlify env vars cannot be set via local Claude commands"
