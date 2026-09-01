---
name: external-system-watchdog
description: |
  Author a standing watchdog over an EXTERNAL system you do not control (Merchant Center,
  App Store Connect, a payment processor, an ad platform, any third-party API) so it neither
  cries wolf nor misses a silent failure. Use when: (1) building a cron/scheduled monitor that
  polls someone else's API and alerts, (2) a monitor reported a problem that turned out to be
  normal propagation delay or a legitimate difference between their data and yours, (3) a
  monitor stayed green while the thing it watched was broken, (4) deciding what a monitor
  should email about versus merely log, (5) picking exit codes for a scheduled task so
  fleet-health reads them honestly. Covers the snapshot-and-diff shape, the four false-positive
  traps (wrong comparison, absence-during-latency, ignoring their own status endpoint,
  inferring config from data), throttle-never-suppress alert policy, and proving the monitor by
  making it fire on a real defect. NOT for scanning your own repo (see heuristic-detector-hygiene),
  one-off verification of a claimed completion (see verify), or post-deploy canaries (see canary).
author: Claude Code
version: 1.0.0
date: 2026-09-01
---

# External-System Watchdog

## Problem

A monitor over a third-party system has two failure modes, and they pull in opposite directions:

- **Cries wolf.** It reports problems that are not problems. Every false alarm teaches the reader to ignore the channel, so the monitor's own noise destroys the thing it exists to provide.
- **Stays green while broken.** It watches a metric that cannot express the failure, so a real outage produces no signal at all.

The tempting fixes trade one for the other. The way out is not a sensitivity dial; it is asking *better questions of the remote system*.

Real cost: a store had 35 products drop to "Limited" visibility with zero clicks for weeks, because nothing watched. When a watchdog was finally written it then produced **three separate confident false positives** before it was right.

## Context / Trigger Conditions

- You are writing a scheduled job that polls an API you do not own and emails when something is wrong.
- A monitor alerted and the answer was "that is normal, it just hadn't synced yet."
- A monitor was green throughout an outage.
- You are choosing between "alert every time" and "alert never" for a known-pending condition.
- The remote system has **asynchronous state**: you write, and it reflects the write minutes or hours later.

## Solution

### 1. The shape: snapshot, diff, and an honest exit code

Persist a normalized snapshot each run and diff against the previous one. A monitor with no memory can only see *state*; most real failures are *transitions*.

```js
const snapshot = { checkedAt, accountIssues, productCount, byDestination, issueCounts };
// ...diff against the previous snapshot BEFORE writing the new one
if (prev) for (const [k, v] of Object.entries(byDestination))
  if (prev.byDestination?.[k] && v.approved < prev.byDestination[k].approved)
    problems.push(`${k}: approved fell ${prev.byDestination[k].approved} -> ${v.approved}`);
```

A **fall in a healthy count** is a defect even when nothing is formally flagged as an error. That is exactly what "Limited visibility" looked like: no error, no rejection, just quietly fewer.

**Exit codes must distinguish three states, not two:**

```
0  checked, healthy
1  COULD NOT CHECK (auth, network, permission)
3  checked, found problems worth a human
```

"Could not check" and "checked and fine" are opposite facts. A boolean collapses them, and the collapse always resolves toward green.

### 2. Trap: comparing the wrong two quantities

The remote system legitimately holds things you did not send it, and vice versa. Comparing *counts* manufactures a defect out of a normal difference.

Compare **by identity**, and recognise the two directions mean opposite things:

| Direction | Meaning |
|---|---|
| in **yours**, missing from **theirs** | a real defect: you published it, they do not have it |
| in **theirs**, not in **yours** | usually expected (they discovered it another way) — informational |

Reporting "35 rows vs 38 products" as a problem was wrong: the extra three were crawl-discovered, and everything sent had arrived.

### 3. Trap: declaring absence during normal latency

Remote systems ingest on **their** schedule. A thing you published minutes ago is legitimately absent.

**Debounce absence across two consecutive checks.** Missing once is propagation; missing twice, a full cycle apart, is a defect.

```js
const persistent = missing.filter((id) => previouslyMissing.has(id));
if (persistent.length) problems.push(...);
else log('  first sighting — awaiting the next remote fetch, not flagged');
```

Without this, every routine addition pages a human.

### 4. Trap: not asking the system's own status endpoint

Most platforms expose a resource that states *their* view of your last write. It outranks any inference you draw from a list endpoint.

`datafeedstatuses` reported `processingStatus: success, itemsValid: 42/42` while `productstatuses` still listed 38. Those are not in conflict — one is ingestion, the other is indexing, and indexing lags. Ask the authoritative one before declaring loss:

```js
if (feedProcessedCleanly) log('accepted every row — statuses still catching up. Not flagged.');
else if (persistent.length) problems.push(...);
```

Generalises: `published_deploy.commit_ref` beats a deploys list; a build's own processing state beats a submit's exit code; `/debug/mp/collect` beats a 204 from `/mp/collect`.

### 5. Trap: inferring configuration from data

A count of zero means *this did not happen*. It never means *this is not configured*.

A funnel report announced "no event is marked as a key event" because the count was 0. The event was marked correctly and simply never fires, because the store has no sales. **Read the config resource** when making a claim about config.

### 6. Trap: reporting success on empty output

If the monitor (or any generator it drives) writes artifacts, assert the artifacts are *plausible*, not that the write returned.

```js
const hashes = new Set(files.map(f => md5(readFileSync(f))));
if (files.length > 1 && hashes.size === 1) fail('all outputs identical — they are blank');
if (sizes.some(s => s < MIN_PLAUSIBLE_BYTES)) fail('output below plausible size floor');
```

Seven image files once wrote successfully and were seven byte-identical blank canvases. "Wrote 7 files" was true and meaningless.

### 7. Alert policy: by severity, throttled, never silent

| Condition | Policy |
|---|---|
| Real defect found (exit 3) | Alert **every time**. It costs money every day it persists. |
| Cannot check (exit 1) | Alert **at most weekly**. Usually a known setup gap; a daily email about the same gap trains you to ignore the channel. |
| Healthy | No alert. Clear the throttle stamp so the next real outage alerts immediately. |

**Throttling is not suppression.** The task still exits non-zero every run, so a fleet-health dashboard keeps showing it red. You are rate-limiting the *push*, never hiding the *state*.

### 8. Prove it by making it fire

A monitor verified only against a healthy system is not known to detect anything.

Inject the real defect, confirm the alert, revert, confirm silence. Prefer the *actual* historical failure over a synthetic one — synthetic fixtures pass while real events slip through.

## Verification

- [ ] Run against live data; confirm exit 0 and no alert when healthy.
- [ ] Inject a real defect (delete an item, break a field); confirm exit 3, the specific message, and the email.
- [ ] Revoke credentials; confirm exit **1**, not 0 and not 3.
- [ ] Add a new item and run immediately; confirm it is **not** flagged (debounce), then confirm it clears once the remote catches up.
- [ ] Run twice with no change; confirm the second run reports "no change" rather than repeating the whole state as if new.
- [ ] Confirm the scheduled task's `LastTaskResult` matches the script's exit code (no wrapper swallowing it).

## Example

Reference implementation, all three traps handled:

- `modelstack.digital/scripts/loop/merchant-watch.mjs` — snapshot/diff, by-ID comparison, debounce, datafeed cross-check, honest exit codes
- `modelstack.digital/scripts/run-merchant-watch.ps1` — severity-based alerting with the weekly throttle stamp
- `modelstack.digital/scripts/loop/setup-cron.ps1` — S4U registration, `pwsh -File` directly so `LastTaskResult` is the real exit code

Proven in production: it caught a genuine 45 → 44 approved-product regression unattended, alerted, and confirmed recovery the next morning.

## Notes

- On Windows, register **S4U** and invoke `pwsh -File` directly. A VBS/wrapper indirection makes `LastTaskResult` report the wrapper's success and hid a 7-day outage behind a false green.
- Prefer a service-account JWT over shelling out to a CLI: a scheduled task in session 0 cannot rely on an external binary being on PATH.
- A monitor that has never alerted is not proof of health; it is an untested monitor. Check that it *can* fail.
- See also: `heuristic-detector-hygiene` (scanning your own repo), `verify` (one-off verification of a claim), `canary` (post-deploy window on your own deploy), and the memory `feedback_verify_state_before_declaring_it`.

## References

- Google SRE Book, "Monitoring Distributed Systems" — symptom-based alerting and the argument that every page should be actionable: https://sre.google/sre-book/monitoring-distributed-systems/
- Content API for Shopping, datafeed statuses (the "ask their own status" case): https://developers.google.com/shopping-content/reference/rest/v2.1/datafeedstatuses
