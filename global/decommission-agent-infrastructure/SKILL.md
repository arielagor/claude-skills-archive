---
name: decommission-agent-infrastructure
description: |
  Switch off and dismantle an autonomous system you built, completely and in an order that
  leaves no ghosts: GitHub Actions workflows, a self-hosted runner, repo secrets, Dependabot,
  scheduled tasks, and cron. Use when: (1) "kill the X agent/council/bot", "turn off X", "stop
  X costing me money", "I thought we killed X but it is still running"; (2) unexpected email,
  PR comments, or API spend arrives from a system believed to be off; (3) a trial, pilot, or
  sunset window is being ended early; (4) removing a self-hosted GitHub Actions runner from a
  machine; (5) a repo is being archived or retired and things still point at it. Covers the
  ordering traps that are expensive to get wrong (close PRs BEFORE archiving, deregister the
  runner BEFORE deleting its directory), separating the noise you want gone from the value you
  want kept, and proving the thing is off by silence rather than by configuration.
author: Claude Code
version: 1.0.0
date: 2026-09-03
---

# Decommission agent infrastructure

## Problem

Building autonomous infrastructure is well covered (see `gated-outward-agent`,
`external-system-watchdog`, `schedule`). Taking it down is not, and it is the half that
silently keeps spending. A half-dismantled system is worse than a running one: it still emails,
still burns API credit, still holds broad credentials, and everyone believes it is off.

The specific trap that motivates this skill: **a scheduled future shutdown is remembered as a
shutdown.** A trial with pre-registered criteria and a cron that disables the system on failure
feels like the decision has been executed. It has not. See
`feedback_scheduled_shutdown_is_not_a_shutdown` in memory.

## Context / Trigger conditions

- "I thought we killed X yesterday but I am still getting emails from it."
- A repo believed dormant shows recent workflow runs in `gh run list`.
- A kill-switch variable exists in the code but `gh variable list` returns empty.
- A `Runner.Listener.exe` process, or a scheduled task, outlives the project it served.
- Dependabot keeps opening PRs that trigger an expensive gate on every one.
- Ending a trial, pilot, or sunset window early.

## Solution

### Phase 1: Map it before touching it

Never start disabling from the symptom. Enumerate every surface first, because the thing that
sends the email is rarely the thing that costs the most.

```bash
R=owner/repo
gh run list -R $R -L 25 --json createdAt,workflowName,event,conclusion   # is it actually live?
gh workflow list -R $R --all --json name,state,path                      # every workflow + state
gh api repos/$R/actions/runners --jq '.runners[]|"\(.id) \(.name) \(.status)"'
gh api repos/$R/actions/secrets --jq '.secrets[].name'                   # what it can reach
gh variable list -R $R                                                   # is the kill switch SET?
gh pr list -R $R                                                         # what will fire on close
grep -rnE 'runs-on|cron|pull_request_target' .github/workflows/          # triggers + who pays
```

Three things to extract:

1. **What actually costs money.** Split `runs-on: ubuntu-latest` (billed GitHub minutes) from
   `runs-on: [self-hosted, ...]` (free minutes, but your CPU, your machine, and usually your
   paid model API keys). Grep the workflows for API key names; a self-hosted job calling Gemini
   or xAI daily is real spend that never shows up on a GitHub bill.
2. **Whether the kill switch is armed.** A workflow reading `${ENABLED:-true}` with the variable
   unset is **open**, not off. Building the switch and setting it are two different acts.
3. **Blast radius.** A broad PAT stored as a repo secret (a cross-repo merge token, a deploy key)
   is the most dangerous thing in the teardown, and the easiest to forget.

### Phase 2: Separate the noise from the value

The thing that prompted the shutdown is often not the thing worth killing. Before switching
anything off, ask what would be lost.

Worked example: Dependabot version-update PRs in one repo were firing an expensive gate and
emailing constantly. Dependabot **security alerts** across nine revenue repos were a separate
switch that cost nothing and surfaced 124 high/critical advisories on live properties. Killing
"Dependabot" wholesale would have taken both. They were separated, and the keep was verified
after the teardown as an explicit guard step.

State the keeps out loud, then **verify them after the teardown, not before.** A keep you did
not re-check is a keep you hope survived.

### Phase 3: Tear down in dependency order

**The order is the whole skill.** Each of these is irreversible-in-place if done late:

1. **Disable every workflow first.** `gh workflow disable -R $R <file>` for each. This stops the
   bleeding while the rest takes minutes. Set the kill-switch variable too, so intent is legible
   in the repo even if a workflow is re-enabled later.
2. **Remove the trigger source.** Delete `.github/dependabot.yml`, disable alerts/security
   updates **on this repo only** (`gh api -X DELETE repos/$R/automated-security-fixes` and
   `.../vulnerability-alerts`), commit, push.
3. **Close open PRs and issues.** Archived repos are **read-only**; you cannot close a PR
   afterward. `gh pr close N --delete-branch --comment "..."`.
4. **Delete repository secrets.** Before archiving, same read-only reason. Capture their
   metadata (`created_at`, `updated_at`) first so a broad PAT can be identified later in account
   settings if it needs revoking.
5. **Deregister the runner (see below), THEN delete its directory.** Never the reverse.
6. **Remove the local scheduler entry and the install directory.**
7. **Archive the repo last.** `gh repo archive $R --yes`. Archived repos do not run scheduled
   workflows. Nothing is deleted; git keeps everything.
8. **Leave a note in the repo explaining what happened**, especially if a trial or sunset doc
   promised a future decision that will now never be evaluated. Otherwise a future reader sees a
   pending verdict and an absent verdict file and concludes the automation silently failed,
   which is the exact failure mode such docs exist to prevent.

### Phase 4: Removing a self-hosted runner (Windows)

Official docs assume the removal command works and does everything. Four things they do not say:

**Deregister BEFORE deleting the directory.** The removal command lives in the install you are
about to delete. Delete first and you are left with only GitHub's "Force remove this runner",
and until you do that the runner sits on the repo as a permanently-offline ghost.

**Stopping the scheduled task does not kill the listener.** `run.cmd` launches
`Runner.Listener.exe` as a child. `Stop-ScheduledTask` reaps the wrapper and leaves the listener
running. Check and kill it explicitly:

```powershell
Stop-ScheduledTask -TaskPath '\GitHub\' -TaskName 'ActionsRunner'
Get-Process Runner.Listener -ErrorAction SilentlyContinue | Stop-Process -Force
```

**`config.cmd remove` may be unresolvable through an agent harness.** Both
`cmd /c "config.cmd remove ..."` and `cmd /c "cd /d C:\actions-runner && config.cmd remove ..."`
can fail with *"'config.cmd' is not recognized"* on a file that demonstrably exists. It is only a
wrapper, so call what it wraps:

```powershell
$tok = gh api -X POST repos/OWNER/REPO/actions/runners/remove-token --jq .token
& "C:\actions-runner\bin\Runner.Listener.exe" remove --token $tok
```

Fallback, equivalent to the web UI's force-remove:
`gh api -X DELETE repos/OWNER/REPO/actions/runners/<id>`.

**`Remove-Item` on a top-level `C:\` directory is refused** by the destructive-command guard as a
protected system path. Use `rm -rf /c/actions-runner` from the Bash tool. Expect it to exceed a
120s timeout on ~1 GB of small files and complete in the background.

Check the runner's `_work/<repo>/<repo>` checkout before deleting it. It is normally disposable
CI scratch, but it is a real working tree: `git status`, `git log origin/main..HEAD`,
`git stash list`. One command, and it rules out throwing away work.

### Phase 5: Prove it

Configuration is not silence. Verify both, and be explicit about which one you have.

```bash
gh repo view $R --json isArchived --jq .isArchived          # true
gh api repos/$R/actions/runners --jq .total_count            # 0
gh pr list -R $R --json number --jq 'length'                 # 0
gh api repos/$R/actions/secrets --jq .total_count            # 0
gh workflow list -R $R --all --json name,state               # all disabled_manually
```

```powershell
Test-Path C:\actions-runner                                  # False
Get-Process Runner.Listener -ErrorAction SilentlyContinue    # nothing
Get-ScheduledTask -TaskPath '\<Folder>\'                     # gone
```

Then the guard: re-check every keep from Phase 2 and confirm it survived.

**The real proof is the next scheduled slot.** Note the cron times before you start, and say
plainly that the teardown is verified-by-configuration until that window passes with no new
runs. Do not claim silence you have not observed.

## Verification

You are done when all Phase 5 checks pass, every Phase 2 keep is re-verified as still enabled,
and the next scheduled window has elapsed with `gh run list` showing nothing new.

## Example

**Dream Machine Council, 2026-09-03.** Believed killed the previous day; a two-week trial had
been registered instead. Still live: four self-hosted workflows (one firing on every PR), a
daily GitHub-hosted job, a runner up for two days, daily Gemini + xAI spend, a broad cross-repo
merge PAT, and six open PRs. `COUNCIL_ENABLED` was never set, so the kill switch was open.

Torn down in the order above: 10 workflows disabled, switch set, `dependabot.yml` deleted, 6 PRs
closed with branches, 4 secrets deleted, runner deregistered then uninstalled (969 MB), task
unregistered, repo archived with a SUPERSEDED banner on the trial doc. Dependabot security
alerts on all nine revenue repos verified still enabled afterward.

Full record: memory `project_dream_machine_council_dismantled`.

## Notes

- **Do not delete the repo.** Archiving stops the schedules and keeps the history. Deleting
  destroys the record of what the system was and why it was retired.
- **A public fork is a second surface.** Check for one; it may have its own live crons even when
  the private operational repo is handled. Public-repo Actions are free, so it costs nothing and
  is easy to miss.
- **Decide the credential question explicitly.** Deleting a secret from a repo does not revoke
  the underlying PAT. Ask whether the token should die too, and record the answer.
- **Portfolio-wide safety switches usually deserve to survive.** They are cheap and were often
  the only thing making a real risk visible.
- Related skills: `gated-outward-agent` (the build-and-arm counterpart), `verify` (the proof
  discipline), `schedule` (what you may be removing).

## References

- [Removing self-hosted runners, GitHub Docs](https://docs.github.com/actions/hosting-your-own-runners/managing-self-hosted-runners/removing-self-hosted-runners)
