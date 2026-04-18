---
name: scrape
version: 1.0.0
description: |
  Browser automation and web scraping with a single, predictable tool path.
  Defaults to claude-in-chrome MCP. Refuses to thrash through Playwright,
  the browse skill, or hand-rolled scrapers without explicit reason.
  Use when the user says "scrape", "extract", "scroll and collect", "automate
  this page", "grab data from", or asks to interact with a website that has
  no API. Especially for X/Twitter (API is spend-capped).
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - WebFetch
triggers:
  - scrape
  - extract from page
  - scroll and collect
  - automate this page
  - grab from website
---

# Scrape — One Tool Path, No Fallback Parade

Past sessions burned hours iterating: nonexistent scrapers → API spend cap → hung browse server → Playwright Chrome conflict → finally claude-in-chrome. Stop the parade.

## Decision tree (run top to bottom, stop at first match)

1. **Does a structured public API exist?** → use `WebFetch` or `curl`. (Skip browser entirely.)
2. **Does a structured private API exist (you have the token)?** → use `curl` with auth header.
3. **Does the site have an RSS/Atom feed?** → fetch the feed.
4. **Otherwise: claude-in-chrome MCP** (default). Tools: `mcp__claude-in-chrome__navigate`, `read_page`, `find`, `form_input`, `javascript_tool`.
5. **Only if claude-in-chrome demonstrably can't do it** (e.g. it's been tried and the specific failure is documented), then Playwright as last resort.

State the choice and reason **before** starting. Example: *"Choosing claude-in-chrome — X has no public bookmarks API, scrape is the only option."*

## Site-specific overrides

| Site | Tool | Reason |
|------|------|--------|
| X / Twitter | claude-in-chrome | API is spend-capped on Ariel's account |
| LinkedIn | claude-in-chrome | API gates most write actions; OAuth comment delete is blocked |
| ParentsSquare | claude-in-chrome | No public API |
| Substack settings | curl `PUT /api/v1/publication` | Private REST endpoint discovered, faster than UI |
| Netlify DNS | `netlify api` CLI | UI saves can silently fail; verify with `nslookup` |
| GitHub | `mcp__github__*` | Native MCP installed |
| Stripe | `mcp__stripe__*` | Native MCP installed |
| Firebase | `mcp__plugin_firebase_firebase__*` | Native MCP installed |

## Scroll-collect pattern (X/Twitter, LinkedIn feeds)

Don't trust the API or pagination. Use a MutationObserver loop in a JS injection:

```javascript
// Inject via mcp__claude-in-chrome__javascript_tool
const seen = new Set();
const out = [];
const observer = new MutationObserver(() => {
  document.querySelectorAll('[data-testid="tweet"]').forEach(el => {
    const id = el.querySelector('a[href*="/status/"]')?.href;
    if (id && !seen.has(id)) {
      seen.add(id);
      out.push({ id, html: el.outerHTML });
    }
  });
});
observer.observe(document.body, { childList: true, subtree: true });
// Then scroll with window.scrollTo() or PageDown keys, dump `out` to console
```

This is how 2,967 X bookmarks were captured (the API claimed 197).

## Pre-flight before scraping

- Confirm the right tab. Call `mcp__claude-in-chrome__tabs_context_mcp` first — never reuse a tab ID from a previous session.
- Check auth: navigate to the target URL and verify the user is logged in (look for username in DOM).
- Set `gif_creator` if the user might want to review what happened.

## Verification (mandatory)

After collecting, **count the result** and compare to expectation. Don't trust pagination claims. If the user said "all my bookmarks" and you have 197, scroll more — see the X lesson. Use `/verify` skill for the final report.

## Anti-patterns to refuse

- ❌ "Let me try Playwright first" — no, claude-in-chrome is the default.
- ❌ "The browse skill should work" — it has hung in past sessions; don't start there.
- ❌ "I'll write a Node scraper with puppeteer" — you have claude-in-chrome already.
- ❌ "API returned 197 results, done" — verify with the actual UI count.
- ❌ Trying 4 tools serially while reporting partial results — pick one, commit, finish.

## When the user wants something downloaded

Chrome downloads do **not** land in CDP-controlled tabs. Either:
- Intercept the fetch/XHR via `javascript_tool` and write to disk via Bash.
- Hand off to Ariel's regular Chrome (he clicks the download).

Don't pretend the file landed if Chrome's download bar isn't visible to you.
