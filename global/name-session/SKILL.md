---
name: name-session
description: |
  Clever auto-renamer for the current Claude Code session. Reads the conversation,
  applies the naming principles in principles.md (when · where · what · how · tail),
  proposes 3 candidates, and writes the chosen title to the session's .jsonl —
  the same write the native /rename command does, but informed by what was actually
  done. Use when the user says "rename this session", "name session", "name this
  session", "/name-session", "clever rename", "title this", or asks for a better
  session title than the auto-generated one. Distinct from native /rename, which
  echoes the literal argument with no thought.
triggers:
  - name session
  - name this session
  - rename this session
  - clever rename
  - title this session
  - name-session
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

## What this skill does

Sets a meaningful custom title on the current session's `.jsonl` so that `claude --resume` later shows a scannable name instead of `1`, `Remote 4 2026-05-13`, or a verbatim echo of whatever the user typed after `/rename`.

## Run order

1. **Load principles.** Read `~/.claude/skills/name-session/principles.md` to refresh the slot grammar and hard rules.

2. **Identify the session.** Run `node ~/.claude/skills/name-session/rename.mjs --list` to list sessions for the current cwd, newest first. The current session is almost always the top entry (newest mtime). Note its 8-char UUID prefix and current title.

   Optional sanity check: `node ~/.claude/skills/name-session/rename.mjs --read-only --session <uuid>` dumps the resolved path, current title, first user message, and line count.

3. **Synthesize a session summary** from this conversation. Pull together:
   - first user message (intent)
   - last 3–5 user messages (where it ended)
   - cwd → default `where` slot
   - file paths touched, commands run, MCP services called (verb + surface signal)
   - current title — if it's an echo of a slash-command arg (e.g. matches the last user message verbatim), flag it as a target to replace

4. **Propose 3 candidates** that follow `<YYYY-MM-DD> · <where> · <what> · [how] · [tail]`:
   - All ≤ 60 chars, lowercase except proper nouns.
   - Drop slots that don't earn their place — never invent one.
   - Echo-check: if any candidate is a verbatim substring of the user's most recent message, replace it.
   - Sibling-check: if any same-day session in the `--list` output would collide, add a distinguishing tail.

5. **Ask the user to pick** via AskUserQuestion. Always include the 3 candidates plus one free-text "Other" path (AskUserQuestion provides this automatically).

6. **Write and verify** in one shot:

   ```bash
   node ~/.claude/skills/name-session/rename.mjs --title "<chosen title>"
   ```

   The script auto-detects the current session, appends the `custom-title` JSONL line, and reads it back to verify. It prints a JSON result with `previousTitle`, `newTitle`, and `verified: true`. If `verified` is anything else, surface the error — do not retry blindly.

   If the script fails due to wrong cwd (error mentions a different project folder than expected), fall back to directly appending the JSONL line via Node:
   ```js
   const fs = require('fs');
   const path = '<resolved .jsonl path>';
   const line = JSON.stringify({type:'custom-title',customTitle:'<title>',sessionId:'<uuid>'});
   fs.appendFileSync(path, '\n' + line);
   ```
   Then verify by reading back the last line.

7. **Communicate that the rename is already done.** The JSONL write IS the rename for every future `--resume` and `/resume` picker — `verified: true` from step 6 means it's persistent and durable. Nothing else is required for the rename to "work."

   The native `/rename` command's only *additional* effect is updating the in-memory window/tab title of the CURRENT terminal session. That update is purely cosmetic and dies when the session exits. **Skills cannot invoke `/rename` — slash commands are intercepted by the Claude Code harness layer before any tool or model can act on them; there is no `SlashCommand` tool, no IPC into the running REPL, and no documented way around this as of the current CLI.**

   So end the response with one short, factual statement plus the slash command on its own final line, for users who want the cosmetic in-session title sync:

   ```
   Persistent rename done (verified in jsonl). Optional cosmetic sync for this window:
   /rename <chosen title>
   ```

   Put the `/rename <chosen title>` line as the absolute last line of the response with no trailing prose — that way the user can triple-click and paste with one motion. Do NOT promise auto-execution or frame the manual step as a failure — it's a deliberate architectural boundary, and the persistent rename already worked.

## Hard rules (mirrors CLAUDE.md "No fabrication")

- **Never invent project context.** If the session didn't touch a named project, the `where` slot is the cwd basename (e.g. `~/.claude/skills`), not a guess.
- **Verify before claiming success.** The script does its own read-back; report `verified: true` from the script output, not from the exit code alone.
- **Don't shadow native /rename.** This skill is invoked as `/name-session` (or via the natural-language triggers above). Native `/rename <literal>` stays available when the user already knows the title they want.

## Edge cases

- **Brand-new session, one message:** fall back to `<date> · <cwd-basename> · <verb derived from first msg>` — still better than the auto-title.
- **Wrong session detected:** if the top of `--list` isn't this one (rare, but possible if multiple sessions share a cwd), confirm UUID with the user before writing. The user can also pass `--session <uuid-prefix>` to disambiguate.
- **Title collision with a same-day sibling:** the principles file requires a distinguishing tail; pick one before showing candidates, don't propose names that already exist.

## File layout

```
~/.claude/skills/name-session/
  SKILL.md        # this file
  principles.md   # naming grammar + rules + examples (loaded in step 1)
  rename.mjs      # auto-detect + append + verify (called in step 6)
```

## Reference: the write contract

Each session file is `~/.claude/projects/<encoded-cwd>/<uuid>.jsonl` where `<encoded-cwd>` is the cwd with `:`, `/`, and `\` all replaced by `-`. Renaming = appending one line:

```json
{"type":"custom-title","customTitle":"<title>","sessionId":"<uuid>"}
```

The most recent such line in the file wins; older ones are inert history.
