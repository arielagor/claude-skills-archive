---
name: project-init
description: Generate a CLAUDE.md file for new coding projects with workflow orchestration, task management, and quality standards. Use when user wants to start a new project, initialize a codebase, create a CLAUDE.md, or set up project conventions.
---

# Project Initialization

## Quick Start

When starting any new project:

1. Create `CLAUDE.md` at project root using the template in [CLAUDE-TEMPLATE.md](CLAUDE-TEMPLATE.md)
2. Create `tasks/` directory with `todo.md` and `lessons.md`
3. Customize the template for the project's stack and domain
4. Confirm plan with user before writing code

## Customization Checklist

Before finalizing the CLAUDE.md, adapt these sections:

- [ ] Add project-specific tech stack under a `## Stack` section
- [ ] Add any repo-specific conventions (naming, file structure)
- [ ] Add testing commands and CI expectations
- [ ] Add deployment notes if relevant
- [ ] Remove any sections that don't apply to the project scope

## Task Directory Setup

```
tasks/
├── todo.md       # Active plan with checkable items
└── lessons.md    # Accumulated corrections and patterns
```

**todo.md** — Write the plan here before implementing. Mark items as you go. Add a review section when complete.

**lessons.md** — Updated after every user correction. Reviewed at the start of each session. Format:

```md
## [Date or Session]

### Pattern: [Short name]
- **Trigger**: What went wrong
- **Rule**: What to do instead
- **Why**: Root cause
```
