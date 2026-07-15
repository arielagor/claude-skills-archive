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
| Deploy (Netlify) | `netlify status` + `curl -s -o /dev/null -w "%{http_code}" <prod-url>` |
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
