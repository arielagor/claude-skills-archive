---
name: crm-integration
description: "GBrain-as-CRM patterns for this vault: contact and company records, hybrid search, interaction history, relationship mapping, and pipeline-stage tagging via GBrain MCP tools, plus the file-based revenue scorecard for deal-stage tracking. Use when: CRM, contact record, lead sync, deal tracking, pipeline stage, activity logging, account mapping, relationship history, GBrain."
---

<objective>
There is no SaaS CRM in this stack. GBrain (Postgres + pgvector, exposed via the `mcp__gbrain__*`
MCP tools) is the CRM of record for every property in `PORTFOLIO_PROPERTIES.md`. Deal-stage
tracking for the active consulting pipeline lives in a separate file-based revenue scorecard,
because GBrain has no native pipeline-stage field. This skill covers four deliverables:

1. **Contact and company records** - `put_page` / `get_page` against the `people/` and
   `companies/` directories (see `~/.claude/projects/brain/RESOLVER.md`)
2. **Interaction history** - `get_backlinks` to pull every page that references a contact,
   `add_timeline_entry` to log a touchpoint
3. **Relationship and account mapping** - `traverse_graph` to walk the link graph outward from a
   person or company
4. **Pipeline-stage tracking** - `add_tag` mirroring the revenue scorecard's stage vocabulary,
   `add_link` for role/relationship links, plus the file-based scorecard itself for the actual
   deal-value and next-step columns GBrain has no field for

Never generate a HubSpot, Salesforce, Close, or Pipedrive API client, OAuth setup, or webhook
handler. None of these exist in this stack (`data/connections.md` lists all three as ABSENT). If
a request specifically names one of them, say so plainly and redirect to the GBrain patterns
below, per `data/REMAP.md` Row 1.
</objective>

## Workspace Context

Read `data/REMAP.md` (Row 1) and `data/connections.md` (the GBrain row) before any CRM-flavored
task; both are the source of truth for what actually exists. Most CRM work in this vault touches
the consulting pipeline, so also read `briefs/agor-consulting.md` for the current offer ladder and
`briefs/_portfolio.md`'s "LIVE - consulting" table for the two active named engagements. State in
an early "Workspace context" line that this was done. Save any generated drafts to
`content/<platform>/drafts/YYYY-MM-DD_short-topic-slug.md`; route durable learnings about a
contact, company, or deal into GBrain itself via `put_page`, not into a vault content file.

## Operating Contract

This skill is self-contained for its frontmatter scope: use its local instructions and reference
file as the playbook; ask only for missing task-specific inputs; hand off to adjacent skills
instead of expanding scope; and return an actionable artifact, decision, plan, or diagnostic.

<success_criteria>
A CRM task in this vault is successful when:
- A person or company has exactly one page at a stable slug (`people/<first-last>` or
  `companies/<company-name>`), never a duplicate created because the slug wasn't checked first
- Every touchpoint (call, email sent, proposal sent, reply received) is logged as a timeline entry
  the same day it happens, matching the update discipline already in force for the file-based
  scorecard
- `get_backlinks` on a contact returns the full interaction history: mentions, linked meetings,
  linked deals
- The stage tag on a GBrain page and the stage column in the revenue scorecard file agree; nobody
  should ever have to guess which one is stale
- No CRM SaaS API client, key, or OAuth flow appears anywhere in generated code
</success_criteria>

<quick_start>
**Look up a contact or company (always do this before creating a new page):**
```
mcp__gbrain__get_page({ slug: "people/jon-cooper", fuzzy: true })
mcp__gbrain__get_page({ slug: "companies/veruna-minerals", fuzzy: true })
```
`fuzzy: true` catches near-miss slugs (a stray middle initial, a company suffix) so a lookup
doesn't silently create a duplicate person page later.

**Create or update a person record:**
```
mcp__gbrain__put_page({
  slug: "people/jon-cooper",
  content: `---
name: "Jon Cooper"
type: "person"
description: "Contact at Veruna Minerals; operational intelligence layer engagement, Phase 0 in conversation"
company: "Veruna Minerals"
role: "primary contact"
---

## Context
Discussing an operational intelligence layer above Zengate/Palmra for Veruna Minerals.
Phase 0 is a two-week diagnostic, target $35-60K, phased build to follow.
`
})
```

**Create or update a company record:**
```
mcp__gbrain__put_page({
  slug: "companies/veruna-minerals",
  content: `---
name: "Veruna Minerals"
type: "company"
description: "Mining operator; target for an operational intelligence layer engagement"
---
`
})
```

**Log a touchpoint (the GBrain equivalent of an activity):**
```
mcp__gbrain__add_timeline_entry({
  slug: "people/jon-cooper",
  date: "2026-07-09",
  summary: "Follow-up sent: financial memo + call slots",
  detail: "SMTP-verified send; watching for reply by mid-week before an SMS fallback",
  source: "email"
})
```

**Pull interaction history for a contact:**
```
mcp__gbrain__get_backlinks({ slug: "people/jon-cooper" })
```
Returns every page (meeting notes, project pages, other people pages) that links to this contact,
which is the closest equivalent to a CRM's activity feed.

**Map an account's relationships:**
```
mcp__gbrain__traverse_graph({ slug: "companies/veruna-minerals", depth: 2 })
```
Walks outward from the company page across `works_at`, `mention`, and other link types to surface
everyone and everything connected to the account, not just the one contact you already know.

**Tag a pipeline stage:**
```
mcp__gbrain__add_tag({ slug: "people/jon-cooper", tag: "stage:in-conversation" })
```
See the stage vocabulary below; when a deal advances, remove the stale stage tag and add the new
one so `list_pages({ tag: "stage:proposal-sent" })` stays an accurate live view.

**Link a person to a company or a deal:**
```
mcp__gbrain__add_link({
  from: "people/jon-cooper",
  to: "companies/veruna-minerals",
  link_type: "works_at",
  context: "Primary contact for the Phase 0 engagement"
})
```

**Hybrid semantic search across the whole brain:**
```
mcp__gbrain__query({ query: "Veruna Minerals operational ontology engagement", limit: 10 })
```
Use `query` for fuzzy, meaning-based recall ("who have I talked to about agentic yield
management") and `search` for exact keyword lookups (a specific deal name or company).
</quick_start>

<entity_mapping>
## Concept mapping (GBrain has no fixed CRM schema, so map by convention, not by field)

| CRM concept | GBrain construct | Notes |
|---|---|---|
| Company / Account | `companies/<company-name>` page | One page per company, per `RESOLVER.md` |
| Person / Contact | `people/<first-last>` page | One page per human, per `RESOLVER.md` |
| Deal / Opportunity | A row in the **file-based revenue scorecard** (see below), optionally cross-linked to a `deals/<deal-slug>` or `projects/<engagement-slug>` GBrain page for narrative context | GBrain's `RESOLVER.md` routes financial transactions with terms to `deals/`; ongoing engagement work with a repo/spec to `projects/` |
| Activity / Touchpoint | `add_timeline_entry` on the relevant person or company page | Log the same day it happens |
| Custom field (tier, source, industry) | Frontmatter key on the page, or an `add_tag` value for anything enumerable | e.g. `tag: "source:prospect-cron"` |
| Pipeline stage | `add_tag` mirroring the revenue scorecard vocabulary | See stage vocabulary below; keep both in sync manually, there is no automatic two-way sync |
| Relationship (works at, invested in, referred by) | `add_link` with a `link_type` | Active types in use: `mention`, `emailed_with`, `texted_with`, `works_at`, `semantic` |

## Deal-stage tracking: the revenue scorecard

GBrain has no native pipeline-stage or deal-value field, so deal tracking for the active
consulting pipeline lives in a separate file-based CRM-of-record:
`~/.claude/projects/job-applications/potential consulting projects clients/README.md`, parsed
weekly by `~/.claude/revenue-scorecard/revenue-scorecard.mjs` (Monday 7:30 AM Windows Task
Scheduler run) into an emailed scorecard. Its markdown tables are the actual pipeline of record;
treat any GBrain stage tag as a mirror of that file, not a replacement for it.

**Exact stage vocabulary (one per row):**
```
lead -> outreach-staged -> outreach-sent -> in-conversation -> call-booked -> proposal-sent -> won
terminal: lost / parked
```

**Real, current pipeline (as of the last update to that file), used here as the worked examples
for this skill rather than invented deals:**

| Contact / Company | Opportunity | Stage | Value |
|---|---|---|---|
| Paul Schneider, Oncore Digital | "The Yield Desk" (agentic CTV/DOOH yield management) | `proposal-sent` | $6K discovery -> $18K pilot -> $4-6K/mo |
| Jon Cooper, Veruna Minerals | Operational intelligence layer, Phase 0 diagnostic | `in-conversation` | $35-60K Phase 0 target, phased build to follow |
| (rotating prospect list) | $299 AI Visibility audit -> consulting ladder wedge | `outreach-sent` | $299 entry, ladders to Pilot/Managed per `briefs/agor-consulting.md`'s Agor AI Ads offer ladder |

When a CRM task touches one of these (or a new prospect), update the scorecard file's Stage and
Last touch columns the same day, and mirror the stage as a GBrain tag if the contact already has
a page. Never fabricate a stage change, a sent status, or a reply that didn't happen; the scorecard
file's own update discipline says the same thing.

For query syntax, tagging taxonomy, and more `traverse_graph` patterns, see
`reference/gbrain-deep-dive.md`.
</entity_mapping>

<routing>
## Request Routing

**User wants "CRM integration" without naming a platform:**
-> Explain GBrain is the CRM of record here. Walk through `get_page`/`put_page` for the record,
`add_timeline_entry` for the activity, `add_tag`/`add_link` for stage and relationship.

**User names HubSpot, Salesforce, Close, or Pipedrive specifically:**
-> State plainly that none of these exist in this stack (`data/connections.md`: ABSENT). Do not
write an API client "just in case." Redirect to the GBrain patterns above. If there's a genuine
new requirement a SaaS CRM would solve that GBrain and the scorecard cannot, flag that gap to Ariel
rather than silently building the SaaS integration.

**User wants deal-stage or pipeline tracking:**
-> Point to the revenue scorecard file as the source of truth, and to `add_tag` for the GBrain
mirror. Reference `sales-and-revenue-operations` for forecast/velocity questions, which is the
skill that owns pipeline-wide analysis rather than single-record CRUD.

**User wants a contact's interaction history:**
-> `get_backlinks` first; if that's thin, `query` for a broader semantic sweep across emails,
notes, and meeting pages that might mention the person without a formal link.

**User wants account or relationship mapping:**
-> `traverse_graph` from the company page, depth 2 as a default, deeper only if the account looks
sparse and a wider net seems warranted.

**User wants to log an activity/touchpoint:**
-> `add_timeline_entry`, same day, with a `source` field (email, call, meeting) so later queries
can filter by channel.
</routing>

<file_locations>
## Reference Files

- `reference/gbrain-deep-dive.md` - query and search patterns, the pipeline-stage tagging
  taxonomy in full, `traverse_graph` depth guidance, and the 15-directory `RESOLVER.md` filing
  schema recap
</file_locations>

<env_setup>
## What's actually running, for context (no keys needed at the skill-invocation level)

- GBrain MCP server: `bunx gbrain serve`, already registered; tools appear as `mcp__gbrain__*`
- Backing store: Postgres 16 + pgvector, Docker container `gbrain-pg`, port 5433, config at
  `~/.gbrain/config.json`
- Revenue scorecard: `~/.claude/revenue-scorecard/revenue-scorecard.mjs`, reads the CRM-of-record
  markdown at `~/.claude/projects/job-applications/potential consulting projects clients/README.md`,
  sends via Gmail SMTP (credentials already provisioned in `~/.claude/cron-health/.env`, not this
  skill's concern to manage)

Nothing in this skill's own scope needs an API key. If a task seems to need one (a CRM webhook
secret, an OAuth client ID), that is a strong signal the task is describing a SaaS CRM that
doesn't exist here, not a missing setup step.
</env_setup>

<example_session>
## Example Session

**User:** "Log that I had a discovery call with Jon Cooper at Veruna Minerals today, and it looks
like the engagement is progressing."

**Claude:**
1. Check for an existing page first: `mcp__gbrain__get_page({ slug: "people/jon-cooper", fuzzy: true })`.
2. If found, log the touchpoint:
```
mcp__gbrain__add_timeline_entry({
  slug: "people/jon-cooper",
  date: "2026-07-09",
  summary: "Discovery call held",
  detail: "Engagement appears to be progressing toward the Phase 0 scope",
  source: "call"
})
```
3. If the stage genuinely advanced (e.g. from `in-conversation` toward `call-booked` or
   `proposal-sent`), remove the stale tag and add the new one:
```
mcp__gbrain__add_tag({ slug: "people/jon-cooper", tag: "stage:call-booked" })
```
4. Flag, don't silently do: the file-based scorecard at
   `~/.claude/projects/job-applications/potential consulting projects clients/README.md` also
   needs its Stage and Last touch columns updated for this same row, the same day, since that
   file (not GBrain) is what the Monday scorecard cron actually parses.
5. No outward send (a follow-up email, a proposal) happens from this skill; that's a draft for
   Ariel to send, per the vault-wide dry-run policy.
</example_session>
