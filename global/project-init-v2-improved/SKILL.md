---
name: project-init-v2-improved
description: Generate a CLAUDE.md file and task management structure for new coding projects, tailored to the project's stack, scope, and team context. Use this skill whenever the user wants to start a new project, initialize a codebase, create or update a CLAUDE.md, set up project conventions, bootstrap a repo, or mentions "project setup", "init", "new repo", "scaffold", or "get started on a new app." Also trigger when the user says things like "let's build X" or "start a new X project" — even if they don't explicitly mention CLAUDE.md or project initialization.
---

# Project Initialization (v2)

This skill generates a `CLAUDE.md` and supporting task management files customized to the project at hand. The key principle: **interview first, generate second**. A bash CLI and a production SaaS app need fundamentally different guidance — the template should reflect that.

## Step 1: Interview

Before generating anything, understand the project. Ask these questions conversationally (not as a checklist dump). If the conversation already contains answers, extract them and confirm rather than re-asking.

1. **What are you building?** — Get the one-sentence description. A CLI tool? An API? A full-stack app? A library?
2. **What's the stack?** — Language, framework, database, key dependencies. If they don't know yet, help them decide or note it as TBD.
3. **What's the scope?** — Solo weekend project, team production app, or something in between? This determines how much process to include.
4. **How do you want to test?** — Unit tests, integration tests, E2E? What framework? Or "I'll figure it out later" (which is fine — scaffold the section anyway).
5. **Any deployment target?** — Vercel, AWS, Docker, "just local for now"? This shapes the deployment section.
6. **Anything non-standard?** — Monorepo? Specific linting config? Existing CI pipeline? Unusual conventions?

Adapt the depth of questioning to the complexity of the project. For a quick script, questions 1-2 might suffice. For a production app, go deeper.

## Step 2: Generate

Once you have enough context:

1. Create `CLAUDE.md` at project root using the template in [CLAUDE-TEMPLATE.md](CLAUDE-TEMPLATE.md), customized based on the interview
2. Create `tasks/` directory with `backlog.md` and `lessons.md`
3. If a stack was identified, populate the Stack section with real commands and conventions (not placeholders)
4. Remove any sections that don't apply — a solo script doesn't need PR conventions
5. Confirm the generated files with the user before writing any project code

## Step 3: Task Directory

```
tasks/
├── backlog.md    # Active plan with checkable items
└── lessons.md    # Accumulated corrections and patterns
```

**backlog.md** — Write the plan here before implementing. Mark items as you go. Structure:

```md
# Project Backlog

## Current Sprint / Focus
- [ ] Task description
  - [ ] Subtask if needed

## Completed
- [x] What was done — brief outcome note

## Parking Lot
- Ideas or future work not yet prioritized
```

**lessons.md** — Updated after every user correction. Reviewed at the start of each session. The self-correction loop is what makes Claude get better over time on your project — treat it as essential infrastructure, not optional documentation.

```md
## [Date or Session]

### Pattern: [Short name]
- **Trigger**: What went wrong
- **Rule**: What to do instead
- **Why**: Root cause
```
