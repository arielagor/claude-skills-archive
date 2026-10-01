---
name: tty-cli-unattended
description: |
  Drive an interactive, TTY-only CLI unattended on Windows (Claude Code's `claude setup-token`,
  or any Ink/React-rendered prompt), including an OAuth browser approval, without a human at the
  keyboard. Use when: (1) a CLI prints NOTHING when its output is redirected or it runs from a
  tool call or scheduled task (Ink renders only to a real TTY), (2) you need a long-lived
  `claude setup-token` token (CLAUDE_CODE_OAUTH_TOKEN) minted from a Claude session, (3) a CLI
  shows "Paste code here if prompted" and needs a code from a browser callback page, (4) a
  regex over captured terminal output swallows neighbouring words ("...state=abcHoldShift...").
  Covers pywinpty with a threaded reader, turning ESC[nC cursor-forward codes back into spaces,
  approving via claude-in-chrome, and saving a secret to a file without ever printing it.
author: Claude Code
version: 1.0.0
date: 2026-09-30
---

# Drive a TTY-only CLI unattended (Windows)

## Problem

Some CLIs only work in a real terminal. `claude setup-token` draws its UI with Ink: run with
stdout redirected (a tool call, `*> file`, a scheduled task) it prints nothing at all, not even
the sign-in link, and just waits. There is no non-interactive flag. It also ends at a
"Paste code here if prompted" prompt that needs a code from the browser.

## Context / Trigger Conditions

- The output file stays at 0 bytes while the process runs (seen: `claude setup-token *> out.txt`).
- The CLI needs a browser approval and prints a one-time code page (Claude's redirect is
  `https://platform.claude.com/oauth/code/callback`, which shows `code#state` to paste back).
- Captured output shows words run together (`HoldShiftwhileselecting...`) after stripping ANSI.
- No `node-pty` or `pywinpty` installed yet (`python -c "import winpty"` fails).

## Solution

1. **Give it a real pseudo-terminal.** `python -m pip install pywinpty`, then spawn with
   `winpty.PtyProcess.spawn([exe, args...], dimensions=(60, 2000))`. The very wide terminal
   keeps long URLs and tokens on one line.
2. **Read on a background thread.** `PtyProcess.read()` BLOCKS while the CLI sits idle at a
   prompt. A read in the main loop therefore never returns to check whether the code has
   arrived. The first attempt on 2026-09-30 hung exactly there, and the approval it had waited
   for was wasted: a new run means a new PKCE state and a second approval. Push chunks onto a
   `queue.Queue` from a daemon thread and poll it with a timeout.
3. **Convert cursor-forward to spaces BEFORE stripping ANSI.** Ink draws spaces as `ESC[nC`.
   Stripping every escape sequence deletes the spaces, so a URL or token regex runs straight
   into the next words. Replace `\x1b\[(\d*)C` with n spaces first, then strip the rest.
   Belt and braces: the OAuth `state` is 43 base64url chars, so trim anything glued after it.
4. **Hand-off through files.** The driver writes the authorize URL to `url.txt`. The session
   approves it and writes the callback's `code#state` to `code.txt`. The driver types it,
   waits 0.5 s, and sends `\r`.
5. **Approve in the logged-in Chrome** via claude-in-chrome: navigate to the URL, `find` the
   Authorize button and click it by ref. It can render disabled for a few seconds; if a click
   does nothing, `scroll_to` the ref and click again. Screenshots of that page sometimes time
   out or come back tiled; the button still works by ref. Read the code from the callback tab.
   The callback URL itself carries `code=` and `state=`; the paste format is `code#state`.
6. **Never print the secret.** Match the token (`sk-ant-oat\d{2}-...`) in the driver, write it
   straight to its destination file, print only `TOKEN_SAVED len=N`, and redact it in any
   transcript. Lock the file down: `icacls <file> /inheritance:r /grant:r "<user>:(R,W)" /grant:r "SYSTEM:(R)"`.
   Keep it outside every git repo (`~/.claude` is itself a repo; use `%APPDATA%\...`).

The verified driver for `claude setup-token` is `scripts/setup_token_pty.py`:

```powershell
python -u "$HOME\.claude\skills\tty-cli-unattended\scripts\setup_token_pty.py" $work   # run in background
# poll $work\url.txt -> approve in Chrome -> write "code#state" to $work\code.txt
# driver prints URL_WRITTEN, CODE_SENT, TOKEN_SAVED len=108, DONE token_saved=True
```

## Verification

- The driver prints `TOKEN_SAVED` and exits 0. The token file is 108 chars and matches
  `^sk-ant-oat\d{2}-[A-Za-z0-9_-]+$`.
- Prove the token is what is actually used: one real call with it answers, and the same call
  with a deliberately bogus token returns `401 OAuth access token is invalid`. Without the bogus
  check, a silent fallback to another login looks identical to success.
- For a setup-token, also confirm `~/.claude/.credentials.json` is byte-identical before and
  after (hash it). The whole point is not touching the shared login.

## Example

2026-09-30, minting a one-year token for scheduled jobs (the `lean-claude.mjs` seam): the
first run with output redirected produced 0 bytes. The first pywinpty run found the URL but
hung, because of the blocking read. The second, with the threaded reader, wrote the URL; the
approval in Chrome gave `code#state`; the driver pasted it and saved a 108-char token. A real
Haiku call worked, a WebSearch call worked, a bogus token got 401, and `.credentials.json`
was unchanged.

## Notes

- A `setup-token` token is inference-only (`user:inference`). It cannot run Remote Control or
  fetch claude.ai connectors, and `/api/oauth/usage` returned 429 for it. Give it only to
  processes that make model calls; never set `CLAUDE_CODE_OAUTH_TOKEN` system-wide.
- `--bare` mode ignores `CLAUDE_CODE_OAUTH_TOKEN`.
- Granting OAuth consent is an explicit-permission action: do it only when the user asked for
  this login in chat, and say which account the consent page showed.
- The same driver pattern fits other Ink/Inquirer CLIs that refuse to run without a TTY; swap
  the spawn args and the URL/secret regexes.
- **If Chrome's claude.ai session has lapsed, stop.** The authorize link redirects to
  `claude.ai/login?reauth=1`, and "Continue with Google" opens a popup window the extension cannot
  see or drive (2026-09-29). Ask Ariel to sign in to claude.ai in Chrome, then rerun; never enter a
  password.
- **If clicking Authorize by ref does nothing twice, click by coordinates.** On 2026-10-01 two
  ref clicks (one after `scroll_to`) left the page unchanged; a `screenshot` at scale 0.5 and a
  left_click at the button's full-frame coordinates went straight to the callback page.
- **Minting for WSL:** pass a `\\wsl.localhost\<distro>\home\<user>\.claude-oauth-token` path as
  the token file, so the secret is written straight into the distro and never exists on the
  Windows side; then `chown`/`chmod 600` it from inside WSL. Have the user's `claude` wrapper
  export `CLAUDE_CODE_OAUTH_TOKEN` from that file when unset, so non-interactive callers
  authenticate. `claude auth status` then reports `loggedIn: true, authMethod: oauth_token`.
  Worked example: memory `project_wsl_claude_watchdog`.
- **Plan for expiry.** The token lives one year. Record where it is used and warn ahead of the
  anniversary (`\CronHealth\WslClaude` fails 30 days early, from the token file's mtime).
- See also: memory `feedback_claude_code_oauth_logout_refresh_race` (why jobs got their own
  token), `~/.claude/scripts/lib/lean-claude.mjs` (how the token is consumed).

## References

- Claude Code docs, Authentication, "Generate a long-lived token": https://code.claude.com/docs/en/authentication
- pywinpty (Windows pseudo-terminal bindings for Python): https://github.com/andfoy/pywinpty
