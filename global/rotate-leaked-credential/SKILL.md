---
name: rotate-leaked-credential
description: |
  Rotate a leaked or compromised API key / cloud credential with zero downtime, and
  leave a monitor behind that catches the next failure. Use when: (1) a hardcoded
  secret is found in a repo or in git history, (2) a key must be replaced across
  several services or .env files at once, (3) a "fallback" or "backup" credential
  needs verifying, (4) you are about to revoke a credential and are unsure what
  still depends on it, (5) a key authenticates fine but calls fail with 429
  RESOURCE_EXHAUSTED / "prepayment credits are depleted" / 403 on the real
  operation. Covers the inventory-before-you-touch-anything ordering, the
  refuse-to-write-a-dead-key guard, why an auth check is not a health check, and
  the Google AI Studio / Cloud Console specifics (service-account-bound keys, the
  AQ. key format, separate Gemini prepaid credit pools).
author: Claude Code
version: 1.0.0
date: 2026-08-21
---

# Rotating a leaked credential without breaking production

## Problem

A credential is compromised and must be replaced. The obvious move, revoke it and
issue a new one, is the wrong order: it takes production down for however long the
propagation takes, and you discover the full list of consumers by watching things
break. The subtler failure is replacing a live key with one that *authenticates*
but cannot do the work, which looks like success and fails later, in the dark.

## Trigger conditions

- A secret scan, a code review, or a `git log -S` turns up a hardcoded key.
- A key's own source comment justifies hardcoding with an assumption about where it
  lives ("this file is not in a pushed repo"). Verify that claim. `git remote -v`.
- You are about to revoke something and cannot enumerate what uses it.
- A credential returns 200 on a list/metadata endpoint but fails the real call.

## Solution

### The ordering is the whole thing

**Inventory → create → verify new → propagate → verify chain → revoke old → monitor.**

Never revoke first. Both keys stay live through the middle of this, which is what
makes the downtime zero. Revocation is last and is the only irreversible step.

**1. Inventory before touching anything.** Find every location holding the value,
not every location that *should*. Grep the literal secret, not the variable name;
a name search misses copies stored under a different key and finds decoys.

Scope the search or it will hang: a home directory with a large knowledge base or
`node_modules` will time out a recursive grep. Enumerate candidate config files
first, then grep only those.

Separately, grep the *variable name* across source to find consumers, so you know
what to test afterward. Check the deployment platform's env vars too (Netlify,
Vercel, GitHub Actions secrets); a key can live somewhere `grep` on your laptop
will never see.

**2. Create the replacement.** See the provider notes below. Do not skip the
project/tenant question: putting the new key in the wrong project is how you get a
credential that authenticates and cannot work.

**3. Verify the NEW key with the operation you actually depend on**, before it
touches any config. This is the step people skip.

**4. Propagate atomically, with a guard.** Write a small rotation tool rather than
hand-editing N files. Hand-editing is how drift starts, and drift in credentials is
invisible until the one moment it matters. The tool must:
   - probe the proposed value first and **refuse to write a key that fails**
   - update every location in one run
   - validate structured files (parse the JSON back) before overwriting a secrets file
   - never invent or guess a value

**5. Verify the whole chain end to end** through the real consumer code, not just
curl. If there is a failover chain, force each key in isolation; a chain that works
because position 1 works tells you nothing about positions 2 and 3.

**6. Revoke.** Confirm the old value is dereferenced everywhere first, then revoke,
then confirm it is actually dead by calling it.

**7. Leave a monitor.** See below.

### An auth check is not a health check

The generalisable rule: **probe the operation you actually depend on, not the
cheapest endpoint that returns 200.**

A credential can be perfectly valid and still unable to do the work: quota
exhausted, billing lapsed, credits depleted, permission missing on the specific
method, project disabled. Metadata endpoints (`models.list`, `whoami`, `/user`)
succeed in all of those cases.

Observed 2026-08-21: a Gemini key returned **200 on `models.list` and 429
`RESOURCE_EXHAUSTED: prepayment credits are depleted` on `generateContent`.** A
reminder cron had been auth-checking it for a month and reporting it healthy.

### Watch for the rotted safety net

A backup credential is only exercised when the primary is already failing, so a
dead backup is silent until the exact moment you need it. In the incident this
skill came from, a fallback key had been dead **three weeks across four
locations** and nothing noticed.

If you touch a failover chain, test every position. Then monitor every position.

### The monitor

Daily is enough. It should:
- probe the real operation on each distinct value
- self-heal what it safely can: **drift** (one variable holding different values in
  different places) and **rot** (a location holding a dead value while a working
  value for that same variable exists elsewhere), re-verifying after
- only ever copy a value proven working *in the same run*. Never synthesise one.
- treat network/timeout as `unreachable`, never as dead. Do not heal on it.
- notify only on state change, so a standing problem does not become background noise
- **exit 0 whenever the check ran**, including when it finds a problem. Finding a
  problem is the monitor succeeding. A scheduled task parked at a non-zero
  `LastTaskResult` forever is exactly how a genuinely broken monitor hides.

Prove the self-heal by injecting a dead value and watching it repair. An untested
healer is a second failure mode, not a safety net.

### Where automation stops

Some consoles block credential creation under browser automation. Google AI Studio
returns **"Failed to generate API key, The request is suspicious."**

**Do not try to defeat that.** It is the provider's control and no user permission
waives it. Look for the canonical admin path instead, which is usually not blocked:
for Google, `console.cloud.google.com/apis/credentials` creates the same keys and
has no such check. Renames, deletes, and IAM changes in Cloud Console worked fine
in the same session.

If no legitimate path exists, hand that one step to the human and automate the rest.

## Google Cloud / AI Studio specifics (verified 2026-08-21)

- **New API keys cannot call Gemini unless bound to a service account.** In Cloud
  Console the "Gemini API" restriction stays greyed out until you tick
  *Authenticate API calls through a service account* and select one. Order:
  name → tick the box → select the SA → *then* the API becomes selectable → Create.
  The service account needs **no project roles**.
- **Bound keys have a new format, `AQ.…`, not `AIzaSy…`.** Verified working both as
  `?key=` and as an `x-goog-api-key` header, so they are a drop-in for existing code.
- **Gemini billing is a separate prepaid pool from GCP billing.** A project can have
  billing enabled and still return "prepayment credits are depleted" for every key
  in it. Check by *generating*, not by authenticating.
- **The create-key dialog defaults to a project.** If that default is a free-tier
  project, accepting it silently produces a key that authenticates and cannot work.
  Always set the project explicitly.
- **Identify a key's project without console access** by calling an API that is not
  enabled for it; the 403 names the project number:
  `curl "https://pagespeedonline.googleapis.com/pagespeedonline/v5/runPagespeed?url=https%3A%2F%2Fexample.com&key=$KEY"`
- **Deleted credentials are restorable for 30 days** via "Restore deleted
  credentials". That is your undo, and it is worth stating out loud before deleting.
- Before deleting, the console reports **recent usage count**. High usage on a key
  you believe is dereferenced means either a consumer you missed or someone else
  using the leaked key. Both argue for deleting, but investigate the first.

## Verification

- New key passes the real operation *before* being written anywhere.
- Every location updated; old value appears in zero config files.
- Full chain exercised through real consumer code, each position forced alone.
- Old credential returns an error after revocation.
- Monitor runs, logs, and exits 0.

## Notes

- **Do not update the detector.** If a reminder or monitor holds the old value in
  order to detect its death, leave that copy alone. Rotating it blinds the thing
  watching for the all-clear.
- **A secret in git history is not un-leaked by removing it from the working tree.**
  Only revocation ends the exposure. Removing it from `.env` reduces sprawl, nothing
  more, and can make things worse if it removes the only working credential.
- **Verify the assumption in the comment.** The incident that produced this skill
  existed because a file said "this is not a pushed repo" and it was.
- See also: `cso` for finding exposures in the first place (audit and secret
  scanning). This skill covers what to do once you have found one.

## References

First-hand verification rather than published sources: every Google-specific claim
above was observed directly on 2026-08-21 against a live account, including the
service-account binding requirement, the `AQ.` key format, the separate prepaid
credit pool, and the AI Studio automation block. Provider behaviour changes; re-verify
by generating, not by reading.
