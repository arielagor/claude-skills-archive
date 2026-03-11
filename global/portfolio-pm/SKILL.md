---
name: portfolio-pm
description: Portfolio Program Manager for 6 revenue projects (modelstack.digital, aphor.me, mvat-focus, agor.me, mvat-mirror, mvat.ai). Use when user says /pm, /portfolio, asks what to work on next, wants a portfolio overview, revenue priorities, marketing actions, weekly sprint plan, cross-project synergies, SEO audits, content pipeline status, or blocker resolution across projects.
user_invocable: true
---

# Portfolio Program Manager

Unified command center for Ariel's 6-project portfolio. Revenue-first prioritization, marketing execution, sprint planning.

## Invocation Modes

Parse the first argument to determine mode:

| Command | Mode | What it does |
|---------|------|-------------|
| `/pm` | Dashboard | Full scan of all 6 projects (6 parallel agents) |
| `/pm sprint` | Sprint | Generate or review weekly sprint plan (10 items) |
| `/pm <project>` | Deep-dive | Focus on one project (e.g., `/pm modelstack`) |
| `/pm market <project>` | Marketing | Execute marketing actions for one project |
| `/pm blockers` | Blockers | Cross-project blocker report |
| `/pm revenue` | Revenue | Revenue analysis with action items |
| `/pm sync` | Synergies | Cross-project synergy opportunities |

Project name aliases: `modelstack` = modelstack.digital, `aphor` = aphor.me, `focus` = mvat-focus, `agor` = agor.me, `mirror` = mvat-mirror, `mvat` = mvat.ai

## Project Registry (Quick Reference)

| # | Project | Path | Deploy | Revenue Model | Content |
|---|---------|------|--------|---------------|---------|
| 1 | modelstack.digital | `projects/modelstack.digital` | Netlify `fd2416ab` | Stripe Payment Links, 35 products | 19 blog posts |
| 2 | aphor.me | `projects/aphor.me/subconscious-studio` | Netlify (subdomain) | Stripe Checkout $9.99-$29.99 | 22 sessions, 12 blog posts |
| 3 | mvat-focus | `projects/mvat-focus` | EAS Build | IAP $4.99/mo or $39.99/yr | Pomodoro timer app |
| 4 | agor.me | `projects/C--Users-ariel--claude-projects-agor.me` | Netlify `c589be58` | Consulting bookings | 42 blog posts, 6 podcasts |
| 5 | mvat-mirror | `projects/mvat-mirror` | EAS Build | IAP $9.99/mo or $49.99 lifetime | 7 personality frameworks |
| 6 | mvat.ai | `projects/Mvat` | Netlify (site/) | Brand support | 39-agent framework |

All paths relative to `C:\Users\ariel\.claude\`. For full details, read `REFERENCE-projects.md`.

## Mode: Dashboard (`/pm`)

Spawn **6 parallel sub-agents** (subagent_type: "Explore") to scan projects simultaneously. Each runs in the project directory.

### Sub-agent prompt template
```
Scan project: {name}
Directory: {full_path}
Report these items concisely:

1. Read HANDOFF.md if it exists (full content)
2. Run: git status --short (count modified/untracked files)
3. Run: git log --oneline -5 (last 5 commits with dates)
4. Read CLAUDE.md (first 80 lines for current status)
5. Count content:
   {content_check_command}
6. Check deploy status:
   {deploy_check_command}
7. Identify the single biggest blocker preventing revenue

Return a structured summary:
- last_commit: date + message
- uncommitted_files: count
- content_count: {type}: {count}
- deploy_status: live|building|failed|unknown
- top_blocker: one sentence
- handoff_summary: key points or "none"
```

**Content check commands per project:**
- modelstack: `ls products/ | wc -l` and `ls blog/posts/ | wc -l`
- aphor.me: grep "id:" in `src/lib/sessions.ts` and `ls src/app/blog/`
- mvat-focus: read `app/app.json` for version
- agor.me: `ls src/app/blog/posts/*.mdx | wc -l`
- mvat-mirror: read `app.json` for version
- mvat.ai: read `products/active-product.json`

**Deploy check commands:**
- Netlify projects: `netlify status` or check last deploy via `netlify api listSiteDeploys --data '{"site_id":"{id}"}'`
- EAS projects: `eas build:list --limit 1 --non-interactive`

### After collecting all 6 results

1. Build unified dashboard table:
```
| # | Project | Last Commit | Uncommitted | Content | Deploy | Top Blocker |
|---|---------|-------------|-------------|---------|--------|-------------|
```

2. Calculate revenue priority score per project:
   - product_readiness (0-1) x 0.4 — is the product usable and purchasable?
   - payment_integration (0-1) x 0.3 — is Stripe/IAP live and tested?
   - marketing_maturity (0-1) x 0.2 — social, SEO, email active?
   - content_volume (0-1) x 0.1 — enough content to attract traffic?

3. Generate **Top 5 Actions** ranked by revenue impact. Each action must specify: project, what to do, which files to modify, expected outcome.

4. Update agent memory: `C:\Users\ariel\.claude\agent-memory\portfolio-pm\MEMORY.md`

## Mode: Sprint (`/pm sprint`)

1. Read `C:\Users\ariel\.claude\agent-memory\portfolio-pm\sprint-log.json`
2. If active sprint exists, show progress: `done/total` with per-item status
3. If no active sprint or sprint is >7 days old, generate new sprint:

**Generate exactly 10 sprint items, allocated by revenue rank:**
- 4 items for highest revenue-priority project
- 3 items for #2 project
- 2 items for #3 project
- 1 item spread across remaining

**Each sprint item format:**
```json
{
  "id": 1,
  "project": "modelstack.digital",
  "action": "Fix social posting to hit Facebook/Instagram/LinkedIn",
  "revenue_impact": "high",
  "effort": "2h",
  "status": "pending",
  "files": ["scripts/post-to-social.mjs"],
  "depends_on": []
}
```

4. Pull specific actions from `REFERENCE-playbooks.md` — don't invent actions
5. Save sprint to `sprint-log.json` with `week_of` ISO date
6. Present as numbered checklist with effort estimates

**To update sprint item status:** edit sprint-log.json directly when items are completed during a session.

## Mode: Marketing (`/pm market <project>`)

1. Read `REFERENCE-playbooks.md` for the target project's playbook
2. Run project scan (single sub-agent) to get current state
3. For each playbook action, assess: done / partially done / not started
4. Present ranked checklist with current status
5. Ask user which actions to execute now
6. For executable actions, spawn sub-agents (max 3 parallel):
   - SEO audit: read HTML, check meta tags, structured data, sitemap
   - Social check: verify posting scripts, credentials, platform coverage
   - Content audit: count posts, check publication cadence, find gaps
   - Email check: verify Nodemailer config, nurture sequences

## Mode: Deep-dive (`/pm <project>`)

1. Run single-project scan (sub-agent in project directory)
2. Read the project's full CLAUDE.md
3. Read HANDOFF.md if exists
4. Read the project's playbook from REFERENCE-playbooks.md
5. Read cross-promo entries for this project from REFERENCE-cross-promo.md
6. Present: current state, all blockers, marketing status, and top 5 recommended actions

## Mode: Blockers (`/pm blockers`)

Scan all 6 projects (parallel sub-agents) and for each identify:
- Uncommitted changes blocking deploys
- Failed builds or store rejections
- Missing infrastructure (domain, webhook, credentials)
- Stale content pipelines (blog not posting on schedule)
- Dependency issues (crashes, version conflicts)

Present as priority-sorted blocker list:
```
| Priority | Project | Blocker | Resolution | Effort |
```

## Mode: Revenue (`/pm revenue`)

1. Read `C:\Users\ariel\.claude\agent-memory\portfolio-pm\revenue-tracker.json`
2. For each project, assess:
   - Is payment infrastructure live and tested end-to-end?
   - Is there traffic (blog posts, social reach, email list)?
   - What's the conversion path (visitor -> customer)?
   - What's the single thing blocking first revenue?
3. Present revenue readiness scorecard:
```
| Project | Payment | Traffic | Conversion Path | Blocking First $1 |
```
4. Top 3 actions to unlock revenue, with specific steps

## Mode: Synergies (`/pm sync`)

1. Read `REFERENCE-cross-promo.md`
2. For each HIGH-value synergy, spawn a sub-agent to check implementation:
   - Grep for cross-links, UTM parameters, "More from" sections
   - Report: implemented / partially / not started
3. Present synergy status matrix
4. Recommend top 3 synergies to implement now (effort x impact)

## State Management

All persistent state in `C:\Users\ariel\.claude\agent-memory\portfolio-pm\`:

| File | Purpose | Updated when |
|------|---------|-------------|
| `MEMORY.md` | Portfolio snapshot, decisions, blockers | After each dashboard scan |
| `sprint-log.json` | Sprint history + active sprint | Sprint create/update |
| `revenue-tracker.json` | Revenue milestones per project | Revenue mode or milestone reached |

## Constraints

- Never force-push or commit `.env` files
- Never deploy without user confirmation
- Marketing actions that create social media posts: preview before posting
- Sprint items must be actionable within a single Claude Code session
- Maximum 6 parallel sub-agents (dashboard scan), 3 for other operations
- Always read REFERENCE files for project-specific details — don't rely on cached knowledge
- When updating sprint status, preserve existing sprint history
