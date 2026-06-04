---
name: ai-ads
description: Agor AI Ads — the answer-visibility (and ads) agency for AI assistants (ChatGPT, Google AI Mode/Overviews, Copilot, and more). Visibility-first: get the brand recommended/cited in the AI answer (organic GEO/AEO), buy the high-intent ad slot where the surface is live. Use when Ariel types "/ai-ads", asks to "run an AI visibility audit / AI ads audit", "refresh the AI ads landscape / KB", "draft an AI ads / AI visibility guide", "map AI ad surfaces for <brand>", "plan an AI ads campaign", or asks anything about getting recommended in or advertising on AI assistants. Two engines: AUTHORITY (a living citation-verified knowledge base + content/SEO/GEO flywheel) and DELIVERY (an 8-stage campaign pipeline with a human-in-the-loop gate on every action that spends money). Public-information only; no NDA exposure. Never spends, publishes, or sends without Ariel's explicit go.
---

# /ai-ads — Agor AI Ads

The first-to-market authority and productized agency for advertising on AI assistants. This
skill is a thin launcher: it loads the playbook and runs the right pipeline. Same pattern as
`/provn`, `/job-application`, `/meeting-to-proposal`.

## Step 0 — Load the playbook (ALWAYS, before anything else)

Read the full playbook now and follow it exactly:

```
C:\Users\ariel\.claude\AI_ADS_PLAYBOOK.md
```

The three Iron Laws (public-info-only / NDA firewall; human-in-the-loop on every
spend-affecting action; honesty / no overclaim), the thesis, the two engines, the 8-stage
campaign pipeline, the Audit spec, the honesty rules, the deliverable templates, and the
outcome log all live there. Read the current version each run.

The venture repo is `~/.claude/projects/ventures/ai-ads-agency/` (GitHub
`arielagor/ai-ads-agency`, private). The KB is `kb/`, the workflows are in `workflow/`.

## Step 1 — Resolve the argument → route

Invoked as `/ai-ads <subcommand> [args]`. Route:

- **`audit <brand or URL>`** → run the **AI Visibility Audit (organic + paid)** (playbook §5).
  The first paid rung, zero spend at risk. Lead with answer-visibility (is the brand cited /
  recommended in the AI answer?), then the paid slots where the surface is live. Read the KB for
  live surfaces, research the brand's public footprint + category queries, produce the audit on
  Agor AI letterhead (`templates/audit-report.md`). STOP before sending anything to a client.

- **`campaign <client>`** → run the **delivery pipeline** (playbook §4) via
  `workflow/client-delivery.workflow.js`. Eight named stages. **Hard STOP for human approval
  before `launch` and before any budget-moving optimize action.** Never spends autonomously.

- **`kb-refresh` / `landscape refresh`** → run the **authority-refresh workflow**
  (`workflow/authority-refresh.workflow.js`). Opus fan-out, one agent per ad surface,
  citation-verified, re-label LIVE/ANNOUNCED/RUMORED, diff vs. the prior KB, surface content
  opportunities. Updates `kb/`. (This is the monitor/alert engine, run on a schedule or on
  demand.)

- **`landscape` / `kb`** (no "refresh") → read and summarize the current KB (`kb/_index.md`,
  `kb/landscape.json`) — what's live, what changed, where the opportunities are. Read-only.

- **`content <topic>`** → draft an authority piece (guide / per-platform deep dive / format
  explainer / policy summary) from the KB, tuned to rank AND to be cited by the assistants
  (GEO/AEO). Reuse the agor.me blog generator + SEO flywheel + IndexNow patterns (playbook
  §3.2). Produce a draft. **Do not publish / IndexNow-ping / cross-post without Ariel's go.**

- **`map-surfaces <brand>`** → just stage 2 of the pipeline: which live surfaces fit this
  brand and the formats/targeting available today. Quick, read-the-KB answer.

- **`proposal <client>`** → do NOT rebuild proposal machinery. Run `/meeting-to-proposal`
  with the Audit findings + the client's asks as the spec; it produces the branded,
  spec-diff-gated package and stages a Gmail draft.

- **Empty / unclear** → state the menu above in one line and ask which. Don't invent a brand,
  a client, or a platform fact.

State the resolved route in one line, then proceed.

## Step 2 — Run it per the playbook

Follow the relevant playbook section for the chosen route. For workflow routes, the
orchestration scripts in `workflow/` are the implementation (opus on every agent). For the
Audit, follow §5 + render via `templates/audit-report.md`.

## Hard rules carried from the playbook (do not violate)

- **Public information only.** Never use anything confidential to Paul Schneider, Oncore
  Digital, NRS, or IDT. Ground every platform claim/number/format/policy in a real public URL
  + date. No citation, no ship. (Law 1.)
- **Human-in-the-loop on every dollar.** Recommend → human approves → log. Hard STOP before
  `launch` and before any budget move. Never change a bid/budget/spend autonomously. (Law 2.)
- **Honesty.** AI-native builder, not an adtech veteran. Lead with what ships; name the gap
  as a fast-ramp area. Never invent a capability, metric, client, or prior action. Never
  promise a numeric lift without the client's baseline. (Law 3.)
- **Label LIVE / ANNOUNCED / RUMORED** anywhere a client sees a platform claim.
- **No outward action without an explicit, in-the-moment go** — no publish, no IndexNow ping,
  no social post, no email/proposal send, no ad spend.

## Don't

- Don't present a marketing-blog number as fact — verify against primaries, label uncertainty.
- Don't plan a client's budget around an ANNOUNCED-but-not-shipped format.
- Don't autonomously spend, bid, publish, ping IndexNow, post, or send.
- Don't overclaim adtech expertise to fill a slot — flag the ramp honestly instead.
- Don't touch or reference any Oncore / NRS / IDT confidential material. Public only.
