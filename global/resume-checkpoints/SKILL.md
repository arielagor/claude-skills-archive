---
name: resume-checkpoints
description: Spawn a dedicated Claude Code session per open (in-progress) checkpoint across all gstack projects — each window auto-trusts the repo via --dangerously-skip-permissions and enters /checkpoint resume on launch. Use when picking work back up after a context compaction or a fresh morning and you want every in-flight thread restored to its own parallel window. Also useful after /checkpoint list shows multiple open threads.
---

# /resume-checkpoints — Fan out every open checkpoint into parallel sessions

Aggregates every `status: in-progress` checkpoint in `~/.gstack/projects/*/checkpoints/`,
deduplicates to the most recent per project, then spawns an elevated PowerShell
per checkpoint running `claude.exe --dangerously-skip-permissions "/checkpoint resume <name>"`
from that project's folder. Every session is remote-controllable per the
`Remote Control on Windows` memory (elevation = required for registration).

## Detect command

Parse the user's input for flags:

- `/resume-checkpoints` → scan + spawn all open checkpoints (one window per project, most recent only)
- `/resume-checkpoints --dry-run` → scan + print the table, **do not spawn anything**
- `/resume-checkpoints --project <slug>` → only the matching project (partial match OK)
- `/resume-checkpoints --limit N` → spawn at most N (highest-priority = most recent)
- `/resume-checkpoints --include-old` → skip dedup, spawn every in-progress file even if a newer one exists

Default: spawn all open, deduplicated to the most recent per project.

## Step 1 — Scan open checkpoints

```bash
bash ~/.claude/skills/resume-checkpoints/scripts/scan.sh
```

The scanner emits one JSON line per open checkpoint:
```
{"slug":"arielagor-scored-tools","project_path":"C:\\Users\\...","checkpoint":"...","checkpoint_name":"...","title":"...","branch":"...","timestamp":"..."}
```

Notes:
- `project_path` is a best-guess resolve from slug to `~/.claude/projects/<folder>`. If empty, the project folder couldn't be found — skip + flag it.
- `checkpoint_name` is the basename without `.md` — this is what gets passed to `/checkpoint resume`.

## Step 2 — Deduplicate (default) or keep all (--include-old)

Default: group by `slug`, keep only the row with the highest `timestamp`.
With `--include-old`: keep every row.

## Step 3 — Apply filters

- `--project <slug>`: keep rows where slug contains the argument (case-insensitive)
- `--limit N`: sort by timestamp desc, take top N

## Step 4 — Present the summary

Print a one-line banner then the table. Example:

```
Found 4 open checkpoint(s). Spawning 4 new sessions.
#  Slug                       Branch     Title                              Age
─  ─────────────────────────  ─────────  ─────────────────────────────────  ──────
1  arielagor-scored-tools     master     social-distribution-complete       12m
2  arielagor-keepclose        main       dashboard-action-plumbing          3h
3  arielagor-gifloop          main       ios-initial-build                  9h
4  arielagor-co-kee           main       iap-multispecies-integration       2d
```

If `--dry-run`: stop here. Do not spawn. Print "Dry run — nothing spawned."

## Step 5 — Confirm on large batches

If the spawn count > 5 (and not `--dry-run`), ask once via AskUserQuestion:

> About to open N new Claude Code windows, one per checkpoint. Each will resume
> independently in parallel. Want to proceed?
>
> A) Proceed (spawn all N)
> B) Only the top 3 most recent
> C) Cancel

If the count is ≤ 5, skip the prompt and proceed directly — the user asked for this, honor it.

## Step 6 — Launch

For each kept row, run:

```bash
bash ~/.claude/skills/resume-checkpoints/scripts/launch.sh "<project_path>" "<checkpoint_name>" "<title>"
```

`launch.sh` wraps a PowerShell `Start-Process -Verb RunAs` that spawns an
elevated terminal, `cd`s into the project, and runs Claude with the resume
command. Each spawn is independent — they run truly simultaneously.

Rate-limit: insert a ~300ms sleep between launches so Windows UAC doesn't
drop prompts.

## Step 7 — Report

After the loop:

```
✓ Spawned N session(s).
  Each window is elevated (remote-controllable) and should auto-resume its
  checkpoint within ~10s of Claude launching.
  Watch the new windows to confirm each session's /checkpoint resume fires.
```

If any launch command exited non-zero, list the failed ones + suggest manually
running the printed PowerShell snippet.

## Important rules

- **Never run without gathering state first.** Always run the scanner and show
  the user what's about to fan out.
- **Elevation is required.** Per the Windows Remote Control memory, only
  elevated PowerShell spawns register as remote-controllable. The launcher
  uses `Start-Process -Verb RunAs`.
- **No permission prompts.** `--dangerously-skip-permissions` is always passed
  — this is the user's explicit opt-in via this command.
- **Do not modify checkpoint files.** This skill reads checkpoints only; resume
  lives inside each spawned session.
- **Deduplicate by default.** Multiple in-progress checkpoints in one project
  usually mean older ones were superseded without being marked completed.
  `--include-old` overrides.
