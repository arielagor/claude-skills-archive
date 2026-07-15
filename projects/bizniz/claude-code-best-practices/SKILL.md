---
name: claude-code-best-practices
description: >
  Authoritative best practices for Claude Code agentic coding sessions. Use this skill whenever
  starting a Claude Code project, setting up a new repository, writing or refining CLAUDE.md files,
  configuring permissions, creating slash commands, structuring MCP servers, optimizing context
  management, or seeking guidance on effective prompting patterns for agentic coding. Also trigger
  when the user mentions "best practices", "CLAUDE.md", "slash commands", "hooks", "worktrees",
  "headless mode", "subagents", or asks how to get the best results from Claude Code.
---

# Claude Code Best Practices

Distilled from Anthropic's official engineering blog, official documentation, and battle-tested
patterns from production teams. These are starting points — experiment and adapt to your workflow.

---

## 1. Environment Setup

### CLAUDE.md — Your Project's Persistent Memory

CLAUDE.md is the single most impactful lever you have. Claude reads it automatically at session
start. Treat it like a well-maintained onboarding doc for a senior engineer joining your team.

**What to include:**

- Common bash/build/test/lint commands with exact invocations
- Key files, directories, and utility functions
- Code style rules (imports, naming, patterns to use and avoid)
- Testing instructions and how to run individual tests
- Repository etiquette (branch naming, merge vs. rebase, PR conventions)
- Developer environment setup (runtime versions, compilers, env vars)
- Surprising behaviors, gotchas, or project-specific warnings
- Architecture decisions and why they were made

**What NOT to include:**

- Obvious things Claude can infer from the codebase
- Exhaustive command references (link to docs instead)
- Style rules your linter already enforces — use hooks and linters for that
- Information only relevant in rare edge cases (use `@path/to/detail.md` references)

**CLAUDE.md placement hierarchy (all are auto-loaded):**

1. `~/.claude/CLAUDE.md` — global, applies to every session
2. Project root `CLAUDE.md` — check into git, share with team (recommended)
3. Project root `CLAUDE.local.md` — personal overrides, gitignored
4. Parent directories — useful for monorepos
5. Child directories — loaded on-demand when working in subdirectories

**Keep it concise.** Every line competes for attention with your actual task. Aim for the minimum
set of universally applicable instructions. Use progressive disclosure via `@path/to/file.md`
imports to keep the root file lean while making detail available when Claude needs it.

**Iterate on it like a prompt.** Run it through the prompt improver occasionally. Add emphasis
("IMPORTANT", "YOU MUST", "NEVER") where adherence matters most. Use the `#` key during sessions
to add instructions that Claude will auto-incorporate into CLAUDE.md.

**Use `/init` as a starting point.** It generates a reasonable first draft by analyzing your
project. Then delete what's obvious and add what's missing. Deleting is faster than creating
from scratch.

### Permissions and Tool Allowlists

Claude Code is deliberately conservative — it asks permission for system-modifying actions. Tune
this to reduce friction on safe operations:

- Select "Always allow" during sessions for tools you trust
- Use `/permissions` to manage the allowlist (e.g., `Edit`, `Bash(git commit:*)`)
- Edit `.claude/settings.json` (check into git for team sharing) or `~/.claude.json`
- Use `--allowedTools` CLI flag for session-specific overrides

### Essential Integrations

- **GitHub CLI (`gh`)**: Install it. Claude uses it for issues, PRs, comments, and more
- **MCP Servers**: Configure in project `.mcp.json` (shared), global config, or project config.
  Use `--mcp-debug` flag when troubleshooting
- **Custom Slash Commands**: Store prompt templates in `.claude/commands/` as markdown files.
  Use `$ARGUMENTS` for parameterized commands. Check into git for team access

---

## 2. Prompting Patterns

### Be Explicit and Specific

Vague prompts produce vague results. Specificity on the first attempt prevents costly corrections.

| Weak | Strong |
|------|--------|
| "add tests for foo.py" | "Write tests for foo.py covering the logged-out edge case. Avoid mocks." |
| "why does this API look weird?" | "Look through ExecutionFactory's git history and summarize how its API evolved." |
| "add a calendar widget" | "Study HotDogWidget.php to understand the existing widget pattern and interface separation. Then implement a calendar widget with month selection and year pagination. Build from scratch, no new libraries." |

### Use Thinking Levels

The word "think" triggers extended thinking. Escalate for harder problems:

- `"think"` — standard extended thinking
- `"think hard"` — more computation time
- `"think harder"` — significantly more
- `"ultrathink"` — maximum thinking budget

### Give Claude Rich Context

- **Images**: Paste screenshots (Cmd+Ctrl+Shift+4 on macOS → Ctrl+V), drag-drop, or give paths
- **Files**: Use tab-completion and `@` mentions to reference files/directories
- **URLs**: Paste URLs directly. Use `/permissions` to allowlist domains you reference often
- **Data**: Pipe via stdin (`cat logs.txt | claude`), copy-paste, or tell Claude to pull data

---

## 3. Core Workflows

### Explore → Plan → Code → Commit

The general-purpose workflow for most problems:

1. **Explore**: Tell Claude to read relevant files/images/URLs. Say "don't write code yet."
   Use subagents for complex investigations early — this preserves context
2. **Plan**: Ask Claude to plan using "think" (or harder). Save the plan to a file or GitHub
   issue so you can reset if implementation goes sideways
3. **Code**: Have Claude implement, asking it to verify reasonableness as it goes
4. **Commit**: Ask Claude to commit, create a PR, and update READMEs/changelogs

Steps 1–2 are crucial. Without them, Claude jumps straight to coding, which works for simple
tasks but fails on anything requiring deeper thought.

### Test-Driven Development (TDD)

Especially powerful with agentic coding:

1. Ask Claude to write tests based on expected I/O pairs. Say "we're doing TDD" to prevent mocks
2. Tell Claude to run tests and confirm they fail. Say "don't write implementation code yet"
3. Commit the tests when you're satisfied
4. Ask Claude to write code that passes the tests without modifying them. Say "keep going until
   all tests pass." Use subagents to verify the implementation isn't overfitting
5. Commit the passing code

### Visual Iteration

1. Give Claude screenshot capability (Puppeteer MCP, iOS simulator MCP, or manual screenshots)
2. Provide a visual mock (paste, drag-drop, or file path)
3. Ask Claude to implement, screenshot, and iterate until it matches
4. Commit when satisfied. 2–3 iterations typically produce dramatically better results

### Git and GitHub

Claude handles 90%+ of git interactions for many Anthropic engineers:

- **History search**: "What changed in v1.2.3?", "Who owns this feature?", "Why was this designed this way?"
- **Commit messages**: Claude examines changes and recent history to compose contextual messages
- **Complex operations**: Reverts, rebase conflict resolution, patch comparison
- **PRs**: "Create a PR" (understands "pr" shorthand). Generates messages from diff and context
- **Code review fixes**: "Fix the comments on my PR and push"
- **CI fixes**: "Fix the failing build" or "Fix the linter warnings"
- **Issue triage**: "Loop over open GitHub issues and categorize them"

---

## 4. Session Optimization

### Use `/clear` Aggressively

Context fills with irrelevant history during long sessions, degrading performance. Clear between
tasks. For complex restarts, have Claude dump its plan and progress to a `.md` file, `/clear`,
then start fresh by reading the file.

### Checklists for Complex Tasks

For migrations, bulk fixes, or multi-step operations:

1. Have Claude run the command and write all issues to a markdown checklist
2. Instruct Claude to fix each item one by one, verifying and checking off as it goes

### Course Correct Early

- **Plan first**: Tell Claude not to code until you approve its plan
- **Escape to interrupt**: Preserves context, lets you redirect
- **Double-Escape**: Jump back in history, edit a previous prompt, explore a different direction
- **"Undo changes"**: Combined with Escape to take a different approach

### Headless Mode (`claude -p`)

For non-interactive automation — CI, pre-commit hooks, build scripts:

```bash
# Issue triage
claude -p "Label this GitHub issue based on content" --json

# Linting
claude -p "Review this code for typos, stale comments, misleading names"

# Bulk operations
claude -p "Migrate this file from React to Vue. Return OK or FAIL." --allowedTools Edit Bash(git commit:*)
```

Use `--verbose` for debugging, disable in production. Use `--output-format stream-json` for
streaming JSON.

**Safety**: Use `--dangerously-skip-permissions` only in containers without internet access.

---

## 5. Multi-Agent Patterns

### Write + Review (Separate Context)

1. Claude #1 writes code
2. `/clear` or start Claude #2 in another terminal
3. Claude #2 reviews the work
4. Claude #3 edits based on review feedback

Separation of context often produces better results than single-agent.

### Parallel Checkouts

1. Create 3–4 git checkouts in separate folders
2. Open each in separate terminal tabs
3. Start Claude in each with different tasks
4. Cycle through to check progress and approve permissions

### Git Worktrees (Lightweight Alternative)

```bash
git worktree add ../project-feature-a -b feature-a
cd ../project-feature-a && claude
```

Tips: consistent naming, one terminal tab per worktree, separate IDE windows. Clean up with
`git worktree remove`.

### Headless Fan-Out

For large migrations or bulk analysis:

1. Have Claude write a script generating a task list
2. Loop through tasks, calling `claude -p` programmatically for each
3. Run multiple times and refine the prompt

---

## 6. Hooks

Hooks run shell commands before or after Claude Code actions. Use them for deterministic rules
that complement CLAUDE.md's suggestions:

- **PreToolUse hooks**: Block commits unless tests pass, enforce branch protections
- **PostToolUse hooks**: Auto-format after file edits, run lint after changes
- **Hint hooks**: Non-blocking feedback for suboptimal patterns

Avoid blocking on `Edit` or `Write` — interrupting mid-plan confuses the agent. Block at
commit/submit boundaries instead.

---

## 7. Context Management

Context is your most precious resource. Manage it deliberately:

- Scope each chat to one project or feature
- Use `/clear` between tasks rather than letting history accumulate
- Prefer `/clear` + custom `/catchup` command over automatic compaction
- For complex tasks: document progress to a `.md` file, `/clear`, resume by reading the file
- Use `@file` references in CLAUDE.md for progressive disclosure rather than inlining everything
- Front-load the most important instructions — LLMs bias toward prompt peripheries

---

## 8. Jupyter Notebooks

Claude reads and writes `.ipynb` files, including interpreting image outputs. Open Claude Code
and a notebook side-by-side in VS Code. Tell Claude to make visualizations "aesthetically
pleasing" — it responds well to explicit visual quality instructions.
