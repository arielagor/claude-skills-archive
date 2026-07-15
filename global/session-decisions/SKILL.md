---
name: session-decisions
description: Capture substantive product decisions made during coding sessions as versioned documentation in the repo. Triggers on EVERY coding session, Claude Code session, Cowork session, or chat involving code changes. Creates and maintains a decisions log (docs/decisions/) that records the WHY behind code changes — architectural choices, trade-offs evaluated, constraints discovered, scope decisions, and design rationale. These docs are versioned with the code and serve as context for future sessions. Use when writing code, debugging, refactoring, building features, or making any implementation choice that reflects a product or architectural decision.
---

# Session Decisions

## Core Principle

Code commits record WHAT changed. Decision logs record WHY. Both live in the repo, both get versioned, both serve as context for future sessions.

```
Code without decision docs = amnesia between sessions.
Decision docs without code = strategy without execution.
Together = cumulative intelligence across sessions.
```

## Quick Start

At the START of every coding session:

1. **Check for existing log**: `ls docs/decisions/` — read the most recent entry to orient
2. **Create session entry**: `docs/decisions/YYYY-MM-DD-{slug}.md` using the template below
3. **Log decisions as they happen** — don't batch at end, capture in real-time as choices emerge
4. **Close the entry** at session end with a status line and next-session context

At the END of every coding session:

1. **Review what was built** — scan git diff or changed files
2. **Ensure every non-trivial choice is logged** — if you chose X over Y, that's a decision
3. **Write the "Next Session Context" section** — this is the handoff to your future self
4. **Commit the decision doc with the code** — same commit or same PR, never separate

## Directory Structure

```
docs/
└── decisions/
    ├── INDEX.md                        # Running index of all decisions
    ├── 2025-02-26-auth-architecture.md # Session decision log
    ├── 2025-02-27-api-pagination.md    # Session decision log
    └── ...
```

Create `docs/decisions/` if it doesn't exist. Create `INDEX.md` if it doesn't exist.

## Decision Entry Template

```markdown
# [Session Title — descriptive, not date-based]

**Date**: YYYY-MM-DD
**Session type**: Claude Code | Chat | Cowork
**Scope**: What area of the codebase was touched

---

## Context

What state was the project in? What triggered this session?
(1-3 sentences. Link to previous decision entries if this continues prior work.)

## Decisions Made

### 1. [Decision title]

- **Choice**: What was decided
- **Over**: What alternatives were considered (even briefly)
- **Because**: The actual reasoning — constraints, trade-offs, priorities
- **Consequence**: What this commits us to or forecloses

### 2. [Next decision...]

(Repeat for each substantive decision. A session typically has 2-7.)

## Discoveries

Things learned during the session that aren't decisions but matter:
- Constraints found (API limits, library bugs, performance ceilings)
- Assumptions validated or invalidated
- Technical debt identified but deferred

## What Was Built

Brief inventory of artifacts produced:
- Files created/modified (grouped by purpose, not listed exhaustively)
- Tests added
- Config changes

## Open Questions

Unresolved items that need future attention. Be specific.

## Next Session Context

> Write this as a briefing for yourself in the next session.
> What should you read first? What's the most fragile thing?
> Where did you leave off and what's the natural next move?
```

## What Counts as a "Decision"

Log these — they're the choices that won't be obvious from code alone:

| Category | Examples |
|----------|----------|
| **Architecture** | "Used event-driven over request-response because..." |
| **Scope** | "Deferred multi-tenant support to keep MVP tight" |
| **Trade-offs** | "Chose Prisma over raw SQL — slower queries but faster development" |
| **Design** | "Single endpoint for CRUD vs. RESTful split — went REST for client clarity" |
| **Constraints** | "API rate limit forced batch processing pattern" |
| **Reversals** | "Abandoned Redis caching — complexity exceeded benefit at current scale" |
| **Standards** | "Error responses follow RFC 7807 Problem Details" |

Do NOT log these — they're implementation details, not decisions:

- Variable naming choices
- Import ordering
- Formatting decisions
- Which test assertion library

## The Real-Time Rule

**Log decisions AS they emerge, not at session end.**

When you're mid-session and choose approach A over B — that's the moment to write 2-3 lines in the decision doc. Batching at the end produces sanitized retrospectives, not authentic decision records. The reasoning is freshest at the moment of choice.

## INDEX.md Template

```markdown
# Decision Log Index

| Date | Title | Key Decisions | Status |
|------|-------|---------------|--------|
| 2025-02-26 | [Auth Architecture](2025-02-26-auth-architecture.md) | JWT over sessions; RBAC model | Active |
| 2025-02-27 | [API Pagination](2025-02-27-api-pagination.md) | Cursor-based; 50 default limit | Active |
```

Update the index every time a new entry is created. Statuses: `Active`, `Superseded by [link]`, `Reversed — see [link]`.

## Integration with Existing Project Files

- **CLAUDE.md**: Add a line pointing to `docs/decisions/` so future sessions know to check it
- **tasks/backlog.md**: Decision logs may surface new backlog items — cross-reference
- **tasks/lessons.md**: Lessons are about process corrections; decisions are about product choices. Different registers, both valuable.
- **Git commits**: Reference decision entries in commit messages when relevant: `feat: add pagination (see docs/decisions/2025-02-27-api-pagination.md)`

## Session Start Checklist

- [ ] Read the most recent 1-2 decision entries for orientation
- [ ] Create today's entry file with the template
- [ ] Fill in Context section before writing code
- [ ] Begin logging decisions as work proceeds
- [ ] Close entry at session end with Next Session Context
