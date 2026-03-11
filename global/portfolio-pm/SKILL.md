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
| `/pm` | Dashboard | Full scan of all 6 projects |
| `/pm sprint` | Sprint | Generate or review weekly sprint plan |
| `/pm <project>` | Deep-dive | Focus on one project (e.g., `/pm modelstack`) |
| `/pm market <project>` | Marketing | Execute marketing actions for one project |
| `/pm blockers` | Blockers | Cross-project blocker report |
| `/pm revenue` | Revenue | Revenue analysis with action items |
| `/pm sync` | Synergies | Cross-project synergy opportunities |

## Project Registry (Quick Reference)

| # | Project | Path | Deploy | Revenue Model |
|---|---------|------|--------|---------------|
| 1 | modelstack.digital | `C:\Users\ariel\.claude\projects\modelstack.digital` | Netlify `fd2416ab` | Stripe Payment Links, 36 products |
| 2 | aphor.me | `C:\Users\ariel\.claude\projects\aphor.me\subconscious-studio` | Netlify `endearing-clafoutis-f18631` | Stripe Checkout, sessions $9.99-$29.99 |
| 3 | mvat-focus | `C:\Users\ariel\.claude\projects\mvat-focus` | EAS Build (App Store + Google Play) | IAP $0.99 lifetime |
| 4 | agor.me | `C:\Users\ariel\.claude\projects\C--Users-ariel--claude-projects-agor.me` | Netlify `c589be58` | Consulting bookings |
| 5 | mvat-mirror | `C:\Users\ariel\.claude\projects\mvat-mirror` | EAS Build | IAP $9.99/mo, $49.99 lifetime |
| 6 | mvat.ai | `C:\Users\ariel\.claude\projects\Mvat` | Netlify (site/) | Brand support |

## Mode: Dashboard (`/pm`)

Spawn **6 parallel sub-agents** (one per project). Each agent runs in the project directory and reports:

### Per-project scan checklist
1. Read `HANDOFF.md` in project root (if exists)
2. Run `git status --short` (never `-uall`)
3. Run `git log --oneline -5`
4. Read project `CLAUDE.md` for current status
5. Count content: blog posts, products, sessions (project-specific)
6. Check deploy: Netlify status or EAS build status
7. Identify top blocker

### Sub-agent prompt template
```
Scan project: {name}
Directory: {path}

1. Read HANDOFF.md if it exists
2. Run: git status --short
3. Run: git log --oneline -5
4. Read CLAUDE.md (first 100 lines)
5. Count content items:
   - modelstack: count files in products/ and blog/posts/
   - aphor.me: count sessions in src/lib/sessions.ts
   - agor.me: count .mdx files in src/app/blog/posts/
   - mvat-focus/mirror: check app.json version, read recent build status
   - mvat.ai: check governance/kill-switch.json
6. Report: last_commit_date, uncommitted_count, content_counts, top_blocker, deploy_status
```

### After collecting results

1. Build dashboard table:
```
| Project | Last Commit | Uncommitted | Content | Deploy | Top Blocker |
```

2. Calculate revenue priority score per project:
   - product_readiness (0-1) × 0.4
   - payment_integration (0-1) × 0.3
   - marketing_maturity (0-1) × 0.2
   - content_volume (0-1) × 0.1

3. Generate **Top 5 Actions** ranked by revenue impact, each linking to specific project + files to modify.

4. Save results to `C:\Users\ariel\.claude\agent-memory\portfolio-pm\portfolio-state.json` (overwrite).

## Mode: Sprint (`/pm sprint`)

1. Read `C:\Users\ariel\.claude\agent-memory\portfolio-pm\sprint-log.json`
2. If previous sprint exists, score completion (done / total)
3. Run dashboard scan if state is stale (>24h or missing)
4. Generate exactly **10 sprint items**:

**Allocation by revenue rank:**
- 4 items → highest revenue-priority project
- 3 items → #2 project
- 2 items → #3 project
- 1 item → spread across remaining

**Each item:**
```json
{
  "id": 1,
  "project": "modelstack.digital",
  "action": "Fix social posting to hit Facebook/Instagram/LinkedIn",
  "revenue_impact": "high|medium|low",
  "effort": "1h|2h|4h|8h",
  "status": "pending|in_progress|done|blocked",
  "files": ["scripts/post-to-social.mjs"],
  "depends_on": []
}
```

5. Save to `sprint-log.json` with `week_of` timestamp.
6. Present as a numbered checklist to the user.

## Mode: Marketing (`/pm market <project>`)

1. Read `REFERENCE-playbooks.md` for the target project's playbook.
2. For each action in the playbook, assess current state (read relevant files).
3. Present actions as a ranked checklist with current status (done / not done / partially done).
4. Ask user which actions to execute now.
5. For executable actions, spawn sub-agents to do the work:
   - SEO audit → read HTML files, check for meta tags, structured data, sitemap
   - Social expansion → check social posting scripts and manifests
   - Email setup → check email infrastructure code
   - Content → check blog post counts and cadence

## Mode: Deep-dive (`/pm <project>`)

1. Run the single-project scan from the dashboard protocol
2. Read the project's CLAUDE.md fully
3. Read HANDOFF.md if exists
4. Read the playbook for this project from REFERENCE-playbooks.md
5. Present: current state, blockers, marketing status, and recommended next actions

## Mode: Blockers (`/pm blockers`)

Scan all 6 projects (parallel) and for each, identify:
- Uncommitted changes blocking deploys
- Failed builds or store rejections
- Missing infrastructure (domain, webhook, credentials)
- Stale content pipelines (blog not posting on schedule)

Present as a priority-sorted blocker list with resolution steps.

## Mode: Revenue (`/pm revenue`)

1. Read `C:\Users\ariel\.claude\agent-memory\portfolio-pm\revenue-tracker.json`
2. For each project, assess:
   - Is payment infrastructure live and tested?
   - Is there traffic (blog posts, social, email)?
   - What's the conversion path (visitor → customer)?
   - What's blocking first revenue?
3. Present revenue readiness scorecard and top 3 actions to unlock revenue.

## Mode: Synergies (`/pm sync`)

Read `REFERENCE-cross-promo.md` and for each high-value synergy:
1. Check if it's already implemented (grep for cross-links in code)
2. If not, propose specific implementation
3. Prioritize by: effort (low first) × audience overlap (high first)

## State Management

All state lives in `C:\Users\ariel\.claude\agent-memory\portfolio-pm\`:

- `MEMORY.md` — Agent memory, updated after each significant interaction
- `sprint-log.json` — Sprint history and current sprint
- `revenue-tracker.json` — Revenue milestones and projections
- `portfolio-state.json` — Last dashboard scan results (generated on scan)

## Constraints

- Never force-push or commit `.env` files
- Never deploy without user confirmation
- Marketing actions that involve creating social media posts should be previewed before posting
- Sprint items should be actionable within a single Claude Code session
- Maximum 6 parallel sub-agents (one per project) during dashboard scan
- Maximum 3 parallel sub-agents during marketing execution
- Always read REFERENCE files for project-specific details — don't rely on cached knowledge
