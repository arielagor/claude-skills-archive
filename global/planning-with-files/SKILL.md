---
name: planning-with-files
description: Manus-style persistent markdown planning for complex tasks. Use when starting multi-step projects (3+ phases), research tasks, building/creating projects, or any task requiring 5+ tool calls. Creates task_plan.md, findings.md, and progress.md as persistent "working memory on disk" to prevent goal drift, track errors, and maintain context across long sessions. Trigger phrases include "complex task", "multi-step", "research project", "build me", "create a", or when the task clearly has multiple phases.
---

# Planning with Files

Work like Manus: Use persistent markdown files as "working memory on disk."

## Core Principle

```
Context Window = RAM (volatile, limited)
Filesystem = Disk (persistent, unlimited)
→ Anything important gets written to disk.
```

## The 3-File Pattern

For every complex task, create THREE files in the project directory:

| File | Purpose | Update When |
|------|---------|-------------|
| `task_plan.md` | Phases, status, decisions | After each phase completes |
| `findings.md` | Research, discoveries, resources | Every 2 view/search operations |
| `progress.md` | Session log, test results, errors | During execution |

## Quick Start

Before ANY complex task:

1. **Create `task_plan.md`** — Use [assets/task_plan_template.md](assets/task_plan_template.md)
2. **Create `findings.md`** — Use [assets/findings_template.md](assets/findings_template.md)
3. **Create `progress.md`** — Use [assets/progress_template.md](assets/progress_template.md)
4. **Re-read plan before major decisions** — Refreshes goals in attention window
5. **Update after each phase** — Mark complete, log errors

## Key Rules

### Rule 1: Plan First (Non-Negotiable)
Never start complex work without `task_plan.md`. Create it immediately.

### Rule 2: The 2-Action Rule
After every 2 research/browser/view operations, MUST save findings to `findings.md`. This prevents losing discovered information.

### Rule 3: Re-read Before Decisions
Before making major decisions, re-read `task_plan.md`. This solves the "lost in the middle" problem—after ~50 tool calls, original goals drift out of attention.

### Rule 4: Log ALL Errors
Every error goes in the plan file. This builds knowledge for future attempts.

### Rule 5: Never Repeat Failures
```
if action_failed:
    next_action != same_action
```
Track what you tried. Mutate the approach.

## Workflow

```
┌─────────────────────────────────────┐
│ 1. CREATE task_plan.md              │
│    (NEVER skip this step!)          │
├─────────────────────────────────────┤
│ 2. CREATE findings.md, progress.md  │
├─────────────────────────────────────┤
│ 3. WORK LOOP:                       │
│    • Before decisions → read plan   │
│    • Every 2 searches → save finds  │
│    • After file writes → update log │
│    • Phase complete → mark done     │
├─────────────────────────────────────┤
│ 4. VERIFY all phases complete       │
│    before declaring task done       │
└─────────────────────────────────────┘
```

## When to Use

**Use this pattern for:**
- Multi-step tasks (3+ steps)
- Research tasks
- Building/creating projects
- Tasks spanning many tool calls (>5)
- Anything where you might lose track of goals

**Skip for:**
- Simple questions
- Single-file edits
- Quick lookups

## Anti-Patterns to Avoid

| Don't | Do Instead |
|-------|------------|
| Start without a plan | Always create task_plan.md first |
| Keep findings in context only | Write to findings.md every 2 operations |
| Repeat failed approaches | Log errors, try different approach |
| Forget original goals mid-task | Re-read task_plan.md before decisions |
| Declare done without verification | Check all phases marked complete |

## Why This Works

After ~50 tool calls, models suffer "goal drift"—original objectives get pushed out of the attention window. By periodically re-reading the plan file, goals are pulled back into recent context where they receive attention.

This is the pattern that made Manus worth $2B: treating the filesystem as persistent memory while the context window acts as volatile working memory.
