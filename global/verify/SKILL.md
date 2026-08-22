---
name: verify
version: 1.0.0
description: |
  Independently verify a claimed task completion before reporting success.
  Demands concrete evidence (row count, CI status, file diff, HTTP response)
  rather than trusting prior tool output, exit codes, or agent self-reports.
  Use when the user says "verify", "double-check", "is that actually done",
  "show me proof", or before declaring any deploy/scrape/import/fix complete.
  Proactively run after any workflow rerun, mass scrape, deploy, or store submit.
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - WebFetch
triggers:
  - verify
  - double-check
  - is that done
  - show me proof
  - prove it landed
---

# Verify

The single biggest leverage point in Ariel's workflow. Premature success claims have caused real rework: 197 vs 2,967 bookmarks, workflow reruns reported green that had failed, QA fixes that introduced audio/layout regressions.

## Charter

For the most recent task claimed complete (or the one named in arguments):

1. **Identify the concrete artifact.** What should exist if the task succeeded? A file, commit, CI run, DB row count, HTTP 200, ASC build entry, store listing field, etc. State it explicitly.
2. **Run a fresh check.** Don't reuse prior tool output. Re-query the source of truth.
3. **Compare actual vs expected.** Numbers, not vibes.
4. **Report PASS/FAIL with evidence.** If the task can't be verified, say `UNVERIFIED` — never re-state "complete."
5. **On FAIL: don't fix. Report.** The user decides whether to re-run, debug, or accept.

## Verification recipes by task type

| Task type | Verification command |
|-----------|---------------------|
| Git push | `git log origin/$(git branch --show-current) -1 --oneline` matches HEAD |
| GitHub Actions | `gh run list --limit 5 --workflow <name>` — check `status` AND `conclusion` |
| Deploy (Netlify) | Compare `published_deploy.commit_ref` to the branch HEAD you pushed (see "A ready deploy is not YOUR deploy" below). `netlify status` + a 200 is NOT sufficient. |
| Running service / daemon | Inspect the ARTIFACT the process is executing, not git. If it bundles at spawn (esbuild/tsx/webpack-dev), grep the built bundle for your change and check process start time against your edit. |
| Client-side constant | Fetch the live page, extract the served JS chunk URLs, grep those for the value. A build-time-inlined constant is not what the repo says it is. |
| Deploy (Vercel) | `vercel ls <project> --prod` + curl health endpoint |
| iOS submit | Poll `https://api.appstoreconnect.apple.com/v1/builds` until processed; do NOT trust `eas submit` exit code |
| Android submit | Poll Play Console internal track for the new versionCode |
| DB import | `SELECT COUNT(*) FROM <table> WHERE created_at > '<start>'` — compare to expected |
| Scrape | Re-run scraper with fresh cursor, count results; compare to claim |
| Browser action | Navigate back to the page, assert the change is visible (DOM check or screenshot) |
| Sent email/text | Check sent folder / message log, not just SMTP 250 |
| Memory/CLAUDE.md edit | `grep` for the new string in the actual file — no linter ate it |
| MCP install | `claude mcp list` shows it `✓ Connected`, plus invoke one tool successfully |
| File edit | `grep` for new content; `git diff --stat` for line counts |
| Cron / scheduled task | Trigger one manual run, confirm it produced output, then check next-run-time |

## Anti-patterns to refuse

- "The build completed" → demand: `Output written on X` line + file size + page count if PDF.
- "Imported 197 records" → re-query the table, don't trust the API's pagination.
- "Workflow reran" → `gh run list` and check `conclusion`, not just `status`.
- "Fix is live" → curl the prod URL, don't trust the deploy webhook.
- "App store update pushed" → query ASC API, don't trust `eas submit` exit 0.
- "The source says X" → that is never evidence that PROD serves X. Verify the artifact users hit.
- "The guard/test passes" → ask what it would FAIL on. If you cannot make it fail, it is not a guard.
- "The script exited 0" → for a wrapper script, confirm it actually WROTE something (count rows/lines before and after). `set -euo pipefail` plus command substitution can swallow an inner error into a silent no-op.

## A "ready" deploy is not YOUR deploy

Learned the hard way 2026-08-19: `app.agor.me` served a **four-week-old commit** while the
deploys list was full of `state: ready` entries. Netlify builds BRANCH deploys too, so a `ready`
row can be a build that was never published, and the live site returns a healthy 200 the whole
time. A completed migration sat on an unmerged branch and everyone read the dashboard as fine.

```bash
# the ONLY question that matters: is the PUBLISHED commit the one I pushed?
curl -s -H "Authorization: Bearer $TOK" https://api.netlify.com/api/v1/sites/<site-id> \n  | node -e "let d='';process.stdin.on('data',c=>d+=c).on('end',()=>{const s=JSON.parse(d);
      const p=s.published_deploy||{};
      console.log('published:', p.commit_ref, p.state, '| publishes from:', s.build_settings.repo_branch)})"
```

Also check `build_settings.repo_branch`: the publish branch is not always `main`, and pushing to
the wrong one builds nothing while every command still exits 0.

**Generalize past Netlify.** Ask what artifact the user actually touches, and verify THAT:
a long-running daemon executes the bundle it built at spawn (a process started days ago serves
the old code no matter what any branch says), a browser executes the served JS chunk, a phone
call reaches whichever checkout the supervisor launched. Source, branch, and exit code are all
proxies; the artifact is the fact.

**Timestamps lie too.** Before dating a row from a timestamp column, confirm that column actually
advances on write. An upsert commonly preserves `created_at`, so a row rewritten seconds ago can
read as months old and send you chasing a bug that does not exist.

**Proving a guard.** To show a new test/detector/threshold actually protects anything, make it
fail on purpose, then restore. See `heuristic-detector-hygiene` for the full discipline.

## Output format

```
VERIFICATION: <task name>
EXPECTED:     <what should be true>
ACTUAL:       <what is true (with command output)>
RESULT:       PASS | FAIL | UNVERIFIED
EVIDENCE:     <command, response, file path, or "could not check because X">
```

## When to skip

Trivial reads, exploratory questions, or tasks where the verification cost exceeds the task cost. Use judgment — but lean toward verifying when stakes are real (deploys, store submissions, mass data operations, infrastructure changes).
