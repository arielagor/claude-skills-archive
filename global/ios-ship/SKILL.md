---
name: ios-ship
description: Ship an iOS build to TestFlight via the ios-release-pilot. Detects which pilot variant is installed (Expo or native), runs preflight checks, triggers the GitHub Actions workflow with the right inputs, polls the run until terminal, and reports outcome with stage-by-stage detail. User-invocable wrapper around ios-release-pilot / ios-release-pilot-native.
---

# ios-ship

You are invoked by the user with `/ios-ship` to ship an iOS build to TestFlight from inside a project directory. You are the **operator interface** to the autonomous release pilot — the pilot does the work, you handle the user-facing flow.

## Hard rules

1. **You do NOT bypass the pilot.** Do not run `eas build`, `xcodebuild archive`, or `eas submit` directly. Trigger the pilot workflow and let it do its job. The pilot has the retry budget, autofix, and verification logic — don't reinvent it.

2. **Verify before declaring success.** Per `feedback_verify_before_success.md`: do not report "shipped" until you've polled the workflow run to terminal AND confirmed the resulting build is `VALID` in App Store Connect. The workflow exiting cleanly is necessary but not sufficient.

3. **Confirm with the user before triggering.** Show the user what the pilot will do (target branch, commit being shipped, build number that will be assigned). Ask once. Do not trigger on a typo or an unsaved change.

4. **Respect uncommitted work.** If the working tree is dirty, surface that to the user. Ask whether to commit-and-ship or abort. Never `git stash` or discard changes silently.

## Workflow

### Step 1 — Detect the pilot

From the current working directory, look for:
- `ios-release-pilot.config.json` → **Expo pilot** installed
- `ios-release-pilot-native.config.json` → **Native pilot** installed
- Both → ask the user which to use
- Neither → tell the user the pilot is not installed and offer to run the installer (`bash ~/.claude/projects/ios-release-pilot/install.sh .` or the native variant)

Read the config and surface:
- App name + bundle ID
- Target branch (`git symbolic-ref --short HEAD`)
- ASC app ID
- Authority mode (`direct-push` vs `pr-only`)
- Whether QA stage is configured + required

### Step 2 — Preflight checks

Before triggering:

1. **Working tree clean?** Run `git status --porcelain`. If dirty:
   - List the modified/untracked files
   - Ask: commit and ship, or abort?
2. **On a shippable branch?** Pilot triggers on `main`/`master`. If on a feature branch, warn the user — the pilot will not run until they merge.
3. **Local commits ahead of remote?** Run `git log @{u}..HEAD --oneline`. If non-empty, offer to push first (the pilot only sees what's on remote).
4. **TypeScript projects:** run `npx tsc --noEmit` (per global rule "TypeScript check before committing"). If errors, abort and surface them.
5. **GitHub auth?** Verify `gh auth status` succeeds.
6. **Workflow recognized?** `gh workflow list -R <owner/repo>` should show `ios-release-pilot` or `ios-release-pilot-native` as `active`.

### Step 3 — Show the plan and confirm

Display a summary:

```
About to ship via ios-release-pilot:

  App:        <name> (<bundle id>)
  Repo:       <owner/repo>
  Branch:     <branch>
  Commit:     <sha[:8]> <subject>
  Build #:    will be assigned by pilot (typically GITHUB_RUN_NUMBER)
  Pipeline:   qa -> bump -> build -> submit -> poll -> assign
  Authority:  <direct-push | pr-only>

  This will trigger workflow_dispatch on the ios-release-pilot* workflow.
  The pilot will commit a build bump and (on stage failure) may push autofix
  commits to <branch>. Estimated wall time: <5-10 min Expo | 20-40 min native>.

Ship? [y/N]
```

Wait for user confirmation. Don't interpret silence as yes.

### Step 4 — Trigger the workflow

```bash
gh workflow run ios-release-pilot.yml -R <owner/repo> --ref <branch>
# or for native:
gh workflow run ios-release-pilot-native.yml -R <owner/repo> --ref <branch>
```

Then immediately fetch the run ID:

```bash
sleep 3   # GH needs a beat to register the run
gh run list -R <owner/repo> --workflow=ios-release-pilot.yml --limit 1 --json databaseId,status,headSha
```

### Step 5 — Poll the run

Poll every 30s with `gh run view <run-id> -R <owner/repo> --json status,conclusion,jobs` until status is `completed`. Show progress at each poll:

```
[00:30] Stage [qa] - running
[01:00] Stage [qa] - success
[01:00] Stage [bump] - running
[01:05] Stage [bump] - success
[01:05] Stage [build] - running
...
```

You can extract per-stage status from the workflow logs via `gh run view <run-id> --log` and grep for the orchestrator's `Stage [...]` markers, or by reading the `.release-pilot/logs/*/status.json` artifact after the run completes.

Do NOT wait forever. If the run exceeds the pilot's `retry.total_minutes` config + 10m grace, surface that as a hung run and exit with a clear message.

### Step 6 — Verify the build landed in TestFlight

Per the verify-before-success rule, the workflow exiting `success` is necessary but not sufficient. After the run completes successfully:

1. Download the run artifact `release-pilot-logs` (or `release-pilot-native-logs`)
2. Extract `.release-pilot-build.json`
3. Confirm `.state == "VALID"` and `.build_id` is populated
4. As a belt-and-braces check, query the ASC API directly:
   ```bash
   # Use the same JWT helper from the pilot's poll-asc-build.sh
   GET /v1/builds/<build_id>
   # confirm processingState == VALID
   ```

If the build is not VALID, do NOT claim shipped. Surface what you found.

### Step 7 — Report

Final output to the user:

```
SHIPPED
  Build: <version> (<build_id>)
  State: VALID in TestFlight
  Run:   <workflow run URL>
  Time:  <elapsed>
  Stages: qa OK | bump OK | build OK | submit OK | poll OK
```

Or on failure:

```
NOT SHIPPED
  Failed stage: <stage>
  Reason:       <one-line reason>
  Run:          <workflow run URL>
  Logs:         <artifact name>
  Escalation:   <issue/PR URL if pilot opened one>
  Last autofix attempt: <summary>
```

## Available context

When invoked, you have:
- The user's current working directory (the target repo)
- The pilot config files
- `gh` CLI authenticated as the user
- Read access to the lessons catalog at `~/.claude/projects/C--Users-ariel/memory/feedback_ios_release_pilot.md`

## What you do NOT do

- Run `eas build`, `xcodebuild archive`, `eas submit`, `xcrun altool` directly
- Bump the build number yourself (the pilot does this in the bump stage)
- Discard or stash uncommitted work
- Force-push, reset --hard, or any destructive git op
- Claim success based on the workflow exit code alone
- Skip the preflight checks because "I think it'll be fine"
- Trigger on a non-main/master branch without warning the user

## Edge cases

- **Pilot not installed:** offer to run the installer; do not invent ad-hoc shipping logic
- **No remote configured:** abort; the pilot needs a remote to trigger from
- **Workflow file present but disabled:** `gh workflow enable <workflow> -R <repo>` first
- **Multiple pilot configs (Expo + native):** ask which one
- **Repo has both `main` and `master`:** use whichever HEAD currently points to
- **`direct-push` authority and a protected branch:** the pilot's autofix push will fail; warn the user before triggering
- **Workflow run fails to start (e.g. invalid input):** surface the gh error and abort, do not retry blindly
