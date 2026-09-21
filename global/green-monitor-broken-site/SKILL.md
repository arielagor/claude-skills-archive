---
name: green-monitor-broken-site
description: |
  Diagnose a site that every monitor calls healthy and every human calls broken.
  Use when: (1) users report a page is down/404/blank but curl, uptime checks or a
  status page all return 200; (2) a status-code sweep of many URLs comes back
  entirely green yet the content is wrong; (3) "it works for me" from the terminal
  and not from a browser; (4) a Cloudflare Workers site 404s the homepage in a
  browser while the Worker looks correct; (5) you need to decide whether a monitor
  that has only ever reported green is actually watching anything. Covers
  header-bisection to find the discriminating request attribute, content-vs-status
  assertion, the Cloudflare `assets_navigation_prefers_asset_serving` /
  `not_found_handling` trap, and the other families of monitor-invisible faults
  (bot protection, geo/IP routing, cache variance, client-side hydration, stale
  resolvers).
author: Claude Code
version: 1.0.0
date: 2026-09-21
---

# When the monitor is green and the site is broken

## Problem

A monitor's job is to disagree with reality loudly. The dangerous failure is when it
cannot: the site returns `200`, the uptime check passes, the deploy succeeded, and every
real visitor sees a broken page. Nothing alerts, because from the checker's position
nothing is wrong.

This is not rare and it is not subtle in effect. A real instance ran **three days**:
`modelstack.digital` served "That page isn't here" to every browser while answering `200`
with the full homepage to `curl`. Every check in place was a curl.

## Trigger conditions

Reach for this when **the observer changes the answer**:

- Users say down; `curl -I` says `200`.
- A sweep of many URLs returns 100% `200` and the site is still visibly wrong.
- It reproduces in a browser and not in a terminal, or vice versa.
- A page loads, then replaces itself with an error (client-side).
- A monitor has never once fired and you cannot say what would make it fire.

## Solution

### 1. Reproduce in the thing that is actually broken

Open a real browser. Screenshot it. Do not accept a terminal's opinion about a browser's
experience. If a browser and `curl` disagree, that disagreement **is** the bug, and it is
also the fastest route to the cause.

### 2. Bisect the request, one attribute at a time

The two clients differ in a handful of ways. Test them individually and find the single
one that flips the result. This is usually a two-minute job and it names the cause outright:

```bash
t() { code=$(curl -s -o /tmp/b -w '%{http_code}' "$@" "$URL"); \
      echo "$code  $(grep -o '<title>[^<]*</title>' /tmp/b | head -1)"; }

t                                        # baseline
t --http2
t -H 'Sec-Fetch-Mode: navigate'          # <- browsers send this on every navigation
t -H 'Sec-Fetch-Dest: document'
t -H 'Accept: text/html,application/xhtml+xml'
t -H 'Accept-Encoding: gzip, deflate, br, zstd'
t -H 'User-Agent: Mozilla/5.0 ... Chrome/140.0.0.0'
t -H 'Cookie: <a real session cookie>'
```

Add `--resolve host:443:<ip>` to pin a specific edge/origin, and repeat per IP if DNS
returns several. A cached local resolver answering with a pre-migration address will
otherwise send you to diagnose infrastructure that is no longer in the path.

### 3. Assert on content, never on status

A status code cannot tell a working page from the wrong page. In the same outage above,
the blog served its **index** in place of all 181 real posts, with `200` on every one, so
a 234-URL status sweep reported a perfectly healthy site while the blog was gone.

Every probe needs a marker string that appears **only** on the correct page:

```bash
curl -s -H 'Sec-Fetch-Mode: navigate' "$URL" | grep -q 'A string only the right page has' \
  || echo "200 but WRONG PAGE"
```

### 4. Prove the monitor can fail

A check that has only ever been green is not evidence. Point it at a deliberately wrong
marker, a dead host and a redirect to the wrong place, and confirm it reports each as a
failure. If you cannot make it fail on demand, it is decoration.

## The families of monitor-invisible faults

| Family | Why the monitor misses it | How to confirm |
|---|---|---|
| **Edge config keyed on request shape** | The platform branches on a header the checker never sends | Header bisection (step 2) |
| **Bot protection / WAF** | Challenges non-browser clients, or the reverse | Compare real UA + cookies vs bare curl |
| **Geo or IP routing** | The checker sits in a favoured region or ASN | Probe from another network; `--resolve` per edge IP |
| **Cache variance** | Checker gets a cached good copy; users miss the cache | Cache-bust; inspect `CF-Cache-Status` / `Age` |
| **Client-side hydration** | HTML is correct; JS then replaces it with an error | Render in a real browser; read the console |
| **Stale resolver** | Checker resolves an address no longer serving | Resolve over DoH, pin with `--resolve` |
| **Soft 404** | Error page returned with `200` | Assert content AND status together |

## Worked example: Cloudflare Workers static assets

**Symptom.** Browser gets `404.html` on `/`; curl gets the real homepage with `200`.

**Mechanism, per Cloudflare's own docs.** With a Worker (`main`), `assets.not_found_handling`
configured, and either the `assets_navigation_prefers_asset_serving` compatibility flag or
a `compatibility_date` of **2025-04-01 or later**, *navigation requests do not invoke the
Worker script at all*. A navigation request is exactly one carrying `Sec-Fetch-Mode: navigate`.

So the asset layer answers browsers from `not_found_handling` before the Worker runs, while
curl — sending no `Sec-Fetch-Mode` — falls through to the Worker and gets the correct page.
Any routing the Worker performs (clean URLs, `/` to `/index.html`, rewrites) is invisible to
real visitors.

**Fixes, in order of preference:**

1. `not_found_handling: "none"` so a miss falls through to the Worker for every request type
   alike. The Worker must then serve its own 404 page **and set the status explicitly** —
   `404.html` is a real asset, so returning the asset fetch unchanged makes every dead URL a
   soft 404.
2. Let the asset layer resolve the path itself (`html_handling`, or a `_redirects` entry), so
   the Worker is never needed for it. Beware the inverse trap: `html_handling` defaults can
   `307` `/faq.html` to `/faq` while a `_redirects` rule rewrites `/faq` to `/faq.html`, an
   infinite loop.
3. Pin an older `compatibility_date`. Works, but freezes unrelated behaviour; treat as a
   stopgap.

**Related trap in the same family:** Cloudflare applies a `_redirects` rewrite *even when a
real file exists*, where Netlify lets the real file win. A `/blog/* -> /blog.html 200` rule
silently shadowed 181 real posts, each with a `200`.

## Verification

```
EXPECTED: browser-shaped request returns the right page
ACTUAL:   curl -H 'Sec-Fetch-Mode: navigate' ... | grep -c '<marker>'
RESULT:   PASS only when status AND marker both hold, on every affected URL
```

Re-check in a real browser with a screenshot, and sweep every URL asserting content rather
than status. Then confirm the monitor you are leaving behind fails on a wrong marker.

## Notes

- **Prefer `--resolve` over trusting DNS** during and after any edge/DNS change. Two probes
  in the source outage read as 404 purely because of a cached local answer.
- **Do not add a second monitor** if one already exists — extend its roster. See
  `feedback_extend_the_existing_monitor_not_a_parallel_one` in memory.
- This is the diagnostic; for the general production-incident loop use the
  `deploy-incident-responder` agent, and for proving a claimed fix use `/verify`.
- For building a standing watch over a system you do not control, see
  `external-system-watchdog`; for scanners that produce confident false positives, see
  `heuristic-detector-hygiene`.

## References

- [Static Assets — Cloudflare Workers docs](https://developers.cloudflare.com/workers/static-assets/)
- [Configuration and Bindings (`not_found_handling`, `html_handling`)](https://developers.cloudflare.com/workers/static-assets/binding/)
- [Single Page Application routing (navigation requests)](https://developers.cloudflare.com/workers/static-assets/routing/single-page-application/)
- [Static Site Generation and custom 404 pages](https://developers.cloudflare.com/workers/static-assets/routing/static-site-generation/)
