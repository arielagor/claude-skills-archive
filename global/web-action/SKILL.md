---
name: web-action
description: Execute a high-level web goal (e.g. "add Gmail alias foo@bar.com", "delete LinkedIn comment X", "publish GTM container Y", "fill out and submit this application form") by trying API → claude-in-chrome MCP → Playwright in order with 60s timeouts and automatic fallback. Logs successful paths to memory so future runs prefer the proven route. Also the canonical reference for filling any React form in the browser: read the "React control traps" section before using form_input, which silently fails on comboboxes, radios and checkboxes (renders correct, validates empty) and has caused a blocked submit and an application submitted with no resume attached.
---

# web-action

A router skill for high-level web operations. The user gives a goal in plain English; you find the cheapest path that actually works, cache that result, and prefer it next time.

## When to use

Invoke this skill any time the user asks for a web action where the right tool is unclear or has historically been flaky:
- Gmail alias / send-as / filter / label management
- LinkedIn comment / post / connection actions
- Google Tag Manager publishing, GA4 config, Search Console actions
- Facebook / Instagram / X posting, deletion, edits
- Netlify / Vercel / Firebase console actions that aren't covered by their CLIs
- Any "I tried 3 tools and one of them works" task

Do NOT use for:
- Read-only browsing or scraping (use `/browse` or `mcp__claude-in-chrome__read_page` directly)
- Operations with a clean, well-known API path (just call the API)

## Inputs

The user provides a goal as natural language. Parse it into:
- **goal_class** — short slug like `gmail_alias_add`, `linkedin_comment_delete`, `gtm_container_publish`
- **target** — the specific entity (alias address, comment URL, container ID, etc.)
- **payload** — any data needed (alias display name, replacement text, container version notes)

If `target` or `payload` is missing, ask the user for them ONCE before proceeding.

## Step 1 — Consult the path log

Before trying anything, read:
```
C:\Users\ariel\.claude\projects\C--Users-ariel\memory\web_action_path_log.json
```

Look up `goals[goal_class].preferred_path`. If a preferred_path exists with success_rate >= 0.7 (computed from the last 5 attempts), **try that path first**. Otherwise, use the default chain in Step 2.

If the log file doesn't exist, create it with `{"goals": {}}`.

## Step 2 — Tool priority chain

Default order (when there's no learned preference):

1. **API/MCP** — direct API call or first-party MCP server
   - Gmail → Gmail REST API or `mcp__claude_ai_Gmail__*` tools (note: alias add is NOT in the API; expect this to fail for that goal_class and fall through)
   - LinkedIn → LinkedIn REST API (most write actions require Marketing Developer Platform approval — expect failure for personal-account actions)
   - GTM → Tag Manager API v2 (`tagmanager.accounts.containers.versions.publish`)
   - Facebook/Instagram → Graph API
   - X → X API v2 (note: spend-capped per memory)
   - Netlify → `netlify api` CLI or REST API
   - Vercel → `mcp__claude_ai_Vercel__*` tools

2. **claude-in-chrome MCP** — `mcp__claude-in-chrome__*` tools
   - Per CLAUDE.md and memory, this is the **preferred browser automation path**
   - Use `tabs_context_mcp` first to see existing tabs, `tabs_create_mcp` for new
   - Use `find` + `form_input` + click sequences
   - **Read "React control traps" below before filling any form.** `form_input` reports success on
     controls it did not actually set.

### React control traps (verified 2026-09-01, Greenhouse; same pattern on Ashby)

`form_input` works on **text inputs and textareas** and silently fails on **every other React
control**. It returns `ok`, the field renders the right value on screen, and the form still
validates it as **empty**. This has caused a blocked submit and, on a prior run, a submitted
application with no resume attached.

| Control | `form_input` | What to do |
|---|---|---|
| text input, textarea | works | `form_input` |
| combobox / select | **silently fails** (still shows "Select...") | click by ref, `type` the option text, `key Enter` |
| radio | **silently fails** (stays unselected) | real click on the option |
| checkbox | **worst case: renders CHECKED but validates empty** | real click, then verify |

**The checkbox double-click trap.** After a `form_input` on a checkbox, one real click **UNCHECKS**
it: React's state still believes it is unchecked, so your click toggles React on while the DOM
property flips off. Two real clicks total. Screenshot between them.

**Click by `ref`, never by coordinate.** These pages reflow between the screenshot and the click, so
coordinates go stale inside a single tool call. Ref-clicks survive the reflow.

**Prefer keyboard over option-clicking on comboboxes.** `find` repeatedly reports an open menu as
closed ("no dropdown option currently visible in an open menu") while a screenshot shows it open.
Click the control by ref, `type` the option text, press Enter. Use `Down Enter` for a single option.

**Verify with `get_page_text`, not screenshots.** On heavy forms `Page.captureScreenshot` timed out
(30s, "renderer may be frozen") on roughly half of attempts and several successes returned a blank
viewport. `get_page_text` was reliable every time and renders selected combobox values and
validation errors inline. Screenshots remain the only way to read checkbox state.

**Locating a blocked submit.** A failed validation sends nothing (no duplicate risk). The error text
renders **directly beneath the failing field group**, so `get_page_text` shows it in position. Trust
that over `find`, which misattributed the failing field on this run.

**Submit last, with a freshly captured ref.** Never batch clicks on a re-rendering form. Detail:
`~/.claude/projects/C--Users-ariel/memory/feedback_browser_cannot_submit_embedded_ats_forms.md`.

3. **Playwright** — `mcp__plugin_playwright_playwright__*` tools
   - Last resort. Often conflicts with the user's running Chrome session.
   - Only use when claude-in-chrome is unavailable or has failed twice in a row for this goal_class.

**60-second timeout per attempt.** If a path hasn't completed (success or definitive failure) in 60s, abort it and move to the next path. Track elapsed time with a wall-clock check before each significant tool call.

## Step 3 — Verification

**Never declare success based on a tool exit code alone** (per `feedback_verify_before_success.md`). After the action, verify the actual end state:
- Gmail alias add → re-fetch the send-as list and confirm the new alias is listed AND verified
- LinkedIn comment delete → re-fetch the post's comments and confirm the target comment is gone
- GTM publish → re-fetch the container and confirm the published version number incremented

If verification fails, treat the path as failed and fall through to the next one.

## Step 4 — Log the result

Append to `web_action_path_log.json`:

```json
{
  "goals": {
    "<goal_class>": {
      "preferred_path": "<path that just succeeded, or unchanged>",
      "history": [
        {
          "path": "api" | "claude-in-chrome" | "playwright",
          "success": true | false,
          "duration_ms": 12345,
          "error": "<short error string if failed>",
          "verified": true | false,
          "ts": "2026-04-07T18:30:00Z"
        }
      ]
    }
  }
}
```

Recompute `preferred_path` after every run: it's the path with the highest success rate over the last 5 attempts; ties broken by lowest mean duration.

Trim `history` to the last 20 entries per goal_class to keep the file small.

## Step 5 — Report to user

Format:
```
goal: <goal_class>
target: <target>
result: SUCCESS via <path> (verified ✓) in 12.3s
attempts: api ✗ (404) → claude-in-chrome ✓
preferred_path now: claude-in-chrome (4/5 success)
```

On total failure (all three paths failed or timed out), report each attempt's failure mode and stop. Do not retry blindly. Suggest the user manually check the affected service.

## Retry budget

- Max 1 attempt per path per invocation (3 paths = 3 attempts max).
- Max 3 minutes total wall-clock per invocation.
- Never call destructive paths (deletes, publishes) more than once even on ambiguous failure — verify state and report rather than retry.

## Known goal classes (seed knowledge)

These are documented failure modes. Apply them as priors:

- `gmail_alias_add` — Gmail API does not support adding aliases programmatically. API path will always fail. Skip straight to claude-in-chrome on first invocation.
- `linkedin_comment_delete` — LinkedIn write API requires Marketing Developer Platform approval for personal accounts. Skip to claude-in-chrome.
- `gtm_container_publish` — Tag Manager API v2 supports this directly via OAuth2; API path is the right answer if credentials are configured.
- `x_post_create` — X API is spend-capped (per memory). Skip to claude-in-chrome.
- `facebook_page_post` — Graph API works for owned pages with valid page token. API is the right answer.
