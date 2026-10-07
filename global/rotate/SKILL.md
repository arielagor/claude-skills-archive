---
name: rotate
description: Rotate this Claude Code session into a fresh context window, the way the AI CEO session does. It writes and commits a structured HANDOFF.md, opens a new `claude` window that resumes from it (re-creating crons and loops first), and closes this window once the new one checks in. `/rotate auto [N]` arms the session so a hook triggers the rotation automatically at N tokens (default 330K). Use whenever the user types /rotate or /Rotate, or says "rotate", "rotate the session", "fresh context window", "hand off to a new session", "the context is getting bloated/too long", "restart yourself with a handoff", or "auto-rotate this session". Also use when a [session-rotate] hook message says the rotation point has been reached. Prefer this to letting auto-compaction happen whenever the work has to continue: a rotation keeps exact ids and constraints, and compaction drops them.
---

# /rotate

Moves the current session to a fresh context window without losing the thread. It is the AI CEO's
rotation (`~/.claude/scripts/ceo-watchdog/`), generalised so any session can do it on demand,
with no watchdog or registration step.

Why rotate rather than compact: the compaction summary is lossy in exactly the places that matter.
It drops exact ids, verbatim user constraints and in-session crons, and the next window then has
to re-derive them. A handoff written while the full window is still in view keeps all of it.

Modes, taken from the arguments:
- no argument, or `now`: rotate now (steps 1–5 below).
- `auto [tokens]`: arm auto-rotate for this session, then stop. Run
  `node ~/.claude/skills/rotate/scripts/rotate.mjs arm --at <tokens>` (default 330000; the
  autocompact window is 350K). From then on the `session-rotate` hook injects a reminder at that
  size, and when it does, run this skill in "now" mode. Arming carries over to the successor
  session automatically. `off` disarms it (`rotate.mjs disarm`), and `status` shows armed sessions
  and recent rotations.

Every `rotate.mjs` call has to run from this session's own tool shell. It reads `CLAUDE_PID` and
`CLAUDE_CODE_SESSION_ID` from there, so it can't run from a subagent.

## Rotate now

### 1. Finish the current atomic step
Complete the step in progress, or stop it at a clean point. Don't start anything new: whatever
starts now gets split across two windows.

### 2. Write the handoff
Location:
- Inside a project git repo: `<repo root>/HANDOFF.md`. Update the existing file and don't
  clobber it. Keep its useful history and put a fresh "Start here" at the top.
- Otherwise (cwd is `C:\Users\ariel`, `~/.claude`, or not a repo):
  `~/.claude/handoffs/<YYYY-MM-DD>-<first 8 of session id>-rotate.md`.

Follow `references/handoff-template.md` (read it now). Every section is required. Write "none"
rather than dropping a section, because an empty section tells the reader something and a missing
one doesn't. Before writing, collect:
- **CronList**: every session cron, with its exact prompt. Also any /loop that is running.
  Session-scoped jobs die with this window, and these lines are the only way they come back.
- **Background agents/tasks** still running: what each one is doing, and its worktree/branch.
  They can't be handed over, so the successor has to verify their output from outside.
- **The user's constraints, quoted verbatim**, including instructions relayed from peer
  sessions. This is the section compaction mangles most.
- **Verified facts with their evidence** (ids, hashes, URLs, counts), plus **unverified claims**
  labelled as unverified.

Write it for a reader with zero context. Test: could a fresh session take the correct next step
from "Start here" alone?

### 3. Commit it (repo case)
`git add HANDOFF.md && git commit -m "handoff: rotate <topic>"`. The commit gate and auto-push
hooks apply as usual, so report the push line truthfully. Commit only the handoff (plus work that
is already finished). Don't sweep half-done edits into the commit. Name them in the handoff
instead. `rotate.mjs` refuses to run on a handoff that has uncommitted changes, is stale (over
45 minutes old), is under 400 characters, or has no "Start here" section. Fix the cause rather
than working around the check.

### 4. Launch the successor
```
node ~/.claude/skills/rotate/scripts/rotate.mjs launch --handoff "<handoff path>" --name "<this session's name>" --cwd "<working dir>"
```
`--name` is the session's display name (the name peers see in ListAgents), or a short topic if it
has none. The new window gets "<name> (rotated YYYY-MM-DD HHMM)". The script:
- pre-accepts folder trust for the cwd. An unanswered "trust this folder?" prompt hung the CEO's
  unattended rotation on 2026-10-07.
- opens a new Windows PowerShell console running the profile's `claude` function (Opus,
  `--dangerously-skip-permissions`, ANTHROPIC_API_KEY stripped). Its first prompt tells it to run
  `rotate.mjs arrived <token>`, read the handoff, and re-create crons and loops before any other
  work.
- starts a hidden, detached closer. Once the successor runs `arrived`, the closer kills this
  `claude.exe` and its console window. It only kills the window if that window is a plain shell,
  never VS Code, the Desktop app or Windows Terminal. If the successor never arrives within 20
  minutes, this window stays open.

Use `--dry-run` to write the launcher and print the plan without launching anything.

### 5. Tell the user, then stop
One line: rotating, the handoff path (and commit), and the new window's name. After that, start
no new tool work. This window closes itself within seconds of the successor checking in.

## If you are the successor
The resume prompt covers this, but in order:
1. `rotate.mjs arrived <token>` first. Until it runs, the old window stays open.
2. Read the handoff in full, then the files it points to.
3. Re-create every job under "Session crons to recreate" with CronCreate, and restart the /loops.
4. Treat "Unverified claims" as unverified, and check "In flight" items before building on them.
5. Tell the user in one line that the rotation landed, then continue the next step.

## Notes
- The AI CEO session keeps its own watchdog-driven rotation (`ceo-rotate.mjs`, `register.mjs`).
  In the registered CEO session, don't use this skill. Run its own
  `node ~/.claude/scripts/ceo-watchdog/request-rotate.mjs` instead. The watchdog relaunches a CEO
  whenever the registered pid dies, so a /rotate there would leave two CEOs running.
- Keeping HANDOFF.md current at milestones, not only at rotation time, is what makes any rotation
  or compaction cheap.
- Log: `~/.claude/logs/rotate-YYYY-MM.log`. State: `~/.claude/state/rotate/`.
