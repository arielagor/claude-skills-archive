---
name: claude-code-workflows
description: >
  Reference guide for common Claude Code workflows and task patterns. Use this skill whenever the
  user is working on a task in Claude Code and needs guidance on the right workflow pattern — 
  including test-driven development, code review, PR creation, documentation generation, debugging,
  refactoring, migration, codebase exploration, image analysis, slash commands, git worktrees,
  plan mode, subagents, hooks, CI/CD automation, or headless mode scripting. Also trigger when
  users ask "how do I...", "what's the best way to...", or describe a multi-step development task
  they want Claude Code to handle.
---

# Claude Code Common Workflows

Practical workflow patterns for Claude Code tasks, from simple one-shot fixes to complex
multi-session projects. Each pattern includes when to use it, the step sequence, and key tips.

---

## Planning and Architecture

### Create a Migration or Refactoring Plan

When you need Claude to analyze a codebase and produce an actionable plan before making changes.

```
> I need to refactor our authentication system to use OAuth2. Create a detailed migration plan.
```

Claude analyzes the current implementation and produces a structured plan. Refine with follow-ups:

```
> Think harder about edge cases in the token refresh flow.
> What could go wrong with backward compatibility?
```

**Plan Mode**: Set `"defaultMode": "plan"` in `.claude/settings.json` to force plan-before-code
behavior. Or press Shift+Tab twice to toggle. Press Ctrl+G to open the plan in your editor for
direct editing before Claude proceeds.

**Persist the plan**: Ask Claude to save its plan to `plan.md` or a GitHub issue. This creates
durable working memory that survives `/clear` and session restarts.

### Codebase Exploration and Q&A

Use Claude as a knowledgeable colleague when onboarding or investigating unfamiliar code.

```
> How does logging work in this project?
> What edge cases does CustomerOnboardingFlowImpl handle?
> Why are we calling foo() instead of bar() on line 333?
> What's the equivalent of line 334 of baz.py in Java?
> How do I make a new API endpoint following our patterns?
```

No special prompting required. Claude agentically searches the codebase. For git-related
questions, explicitly prompt Claude to search git history:

```
> Look through git history and explain how this API design evolved.
```

---

## Writing and Testing Code

### Test-Driven Development (TDD)

The most reliable pattern for changes with verifiable behavior.

1. **Write tests first**:
   ```
   > Write tests for the user authentication flow covering: successful login,
   > invalid credentials, account lockout after 5 failures, and session timeout.
   > We're doing TDD — don't create mock implementations.
   ```

2. **Verify tests fail**:
   ```
   > Run the tests and confirm they all fail. Don't write any implementation code.
   ```

3. **Commit tests**: `> Commit the tests with a descriptive message.`

4. **Implement**:
   ```
   > Write code to make all tests pass. Don't modify the tests.
   > Keep iterating until everything is green.
   ```

5. **Verify and commit**: `> Commit the implementation.`

**Tip**: After implementation, ask Claude to use a subagent to verify the implementation isn't
overfitting to the specific test cases.

### Implement from Visual Mock

When you have a design to implement:

1. Provide the mock (paste screenshot, drag-drop image, or give file path)
2. Ask Claude to implement it
3. If Claude has screenshot capability (Puppeteer MCP, iOS simulator MCP), ask it to screenshot
   its result and compare to the mock
4. Iterate 2–3 times — results improve dramatically with each pass
5. Commit when the output matches

```
> Here's the design mock for the new settings page. Implement it following our
> existing component patterns. Screenshot your result and compare to the mock.
> Iterate until it matches closely.
```

### Fix Lint or Type Errors

For large numbers of issues:

1. Have Claude run the linter/typechecker and write all errors to a markdown checklist
2. Instruct it to fix each one, verify, and check off before moving to the next

```
> Run `npm run typecheck`. Write every error to a checklist in errors.md with
> filenames and line numbers. Then fix each one, verify it compiles, and check it off.
```

### Add Test Coverage

```
> Look at the test coverage for src/utils/auth.ts. Write tests for any uncovered
> code paths. Follow the existing test patterns in __tests__/.
```

Claude examines existing test files to match your style, frameworks, and assertion patterns. Ask
it to identify edge cases you might have missed — it will analyze code paths for error conditions,
boundary values, and unexpected inputs.

---

## Git and GitHub Workflows

### Create a Pull Request

```
> Create a PR for my changes.
```

Claude understands "pr" shorthand. It generates commit messages from the diff and context, pushes,
and opens the PR. For more control:

```
> Create a PR targeting the develop branch. Include a summary of architectural
> decisions in the description. Link to issue #1234.
```

### Fix Code Review Comments

```
> Fix the review comments on my PR and push.
```

For specific comments:

```
> Address the comment about error handling in the auth middleware. Push when done.
```

### Resolve Merge Conflicts

```
> I have merge conflicts after rebasing onto main. Resolve them, keeping our
> feature branch changes where they don't conflict with main's refactoring.
```

### Write Commit Messages

Simply ask Claude to commit — it examines your staged changes and recent history to compose
a contextual message automatically.

```
> Stage and commit these changes.
```

### Issue Triage

```
> Loop over the open GitHub issues and add labels based on their content.
> Use labels: bug, enhancement, documentation, question.
```

---

## Documentation

### Generate or Update Docs

```
> Update the README to reflect the new authentication flow we just implemented.
> Add a section on environment setup for new developers.
```

```
> Generate JSDoc comments for all exported functions in src/utils/.
> Follow the existing documentation style.
```

### Changelog Maintenance

```
> Review the commits since the last tag and update CHANGELOG.md following
> our keep-a-changelog format.
```

---

## Custom Slash Commands

Create reusable workflows as markdown files in `.claude/commands/` (project-level, shared via git)
or `~/.claude/commands/` (personal, all sessions).

### Example: Fix a GitHub Issue

`.claude/commands/fix-issue.md`:
```markdown
Analyze and fix GitHub issue: $ARGUMENTS

1. Use `gh issue view` to get issue details
2. Search the codebase for relevant files
3. Implement the fix
4. Write and run tests
5. Ensure lint and typecheck pass
6. Commit with descriptive message
7. Push and create a PR linking the issue
```

Usage: `/project:fix-issue 1234`

### Example: Security Review

`.claude/commands/security-review.md`:
```markdown
Review the recent changes for security vulnerabilities:

1. Check for injection risks (SQL, XSS, command injection)
2. Verify authentication and authorization on new endpoints
3. Look for sensitive data exposure
4. Check dependency versions for known CVEs
5. Verify input validation and sanitization
6. Report findings with severity levels
```

### Example: Performance Audit

`.claude/commands/perf-audit.md`:
```markdown
Analyze the performance of this code and suggest three specific optimizations:

$ARGUMENTS

Focus on: bundle size impact, render performance, memory leaks, and unnecessary re-renders.
Reference specific line numbers and provide before/after examples.
```

---

## Parallel and Multi-Agent Work

### Git Worktrees for Parallel Tasks

Work on multiple independent tasks simultaneously with full isolation:

```bash
# Create worktrees
git worktree add ../project-feature-a -b feature-a
git worktree add ../project-bugfix -b bugfix-123

# Run Claude in each
cd ../project-feature-a && claude
# (in another terminal)
cd ../project-bugfix && claude

# Clean up
git worktree remove ../project-feature-a
```

Tips: one terminal tab per worktree, separate IDE windows, consistent naming.

### Write + Review Pattern

1. Claude #1 writes code
2. `/clear` or open a new terminal
3. Claude #2 reviews Claude #1's work
4. Claude #3 applies review feedback

The separation of context produces better results than single-agent for complex tasks.

### Subagents

Use subagents for investigation tasks early in a conversation. They run independently and
preserve your main context window:

```
> Use subagents to investigate how error handling works across the three main
> modules before we start refactoring.
```

---

## CI/CD and Automation

### Headless Mode (`claude -p`)

Non-interactive mode for scripts, CI, and automation:

```bash
# Monitor logs
tail -f app.log | claude -p "Alert me if you see anomalies"

# Translate in CI
claude -p "Translate new strings to French and create a PR"

# Bulk review
git diff main --name-only | claude -p "Review these files for security issues"

# Issue triage (GitHub Action)
claude -p "Read this issue and assign appropriate labels" --json
```

Use `--output-format stream-json` for streaming output. Use `--verbose` for debugging,
disable in production.

### GitHub Actions Integration

Run `/install-github-app` to set up automatic PR reviews. Customize the review prompt in
`claude-code-review.yml` — the default is too verbose. Claude finds actual logic errors and
security issues that human reviewers miss.

### Pre-Commit Hooks

Use hooks to enforce quality gates:

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash(git commit:*)",
      "hooks": [{
        "type": "command",
        "command": "npm run test -- --bail || exit 2",
        "timeout": 30
      }]
    }]
  }
}
```

---

## Working with Data

### Pipe Data In

```bash
# Logs
cat server.log | claude -p "Find the root cause of the 500 errors"

# CSV analysis
cat sales.csv | claude -p "Summarize trends and anomalies"

# Diff review
git diff main | claude -p "Review for security issues"
```

### Image Analysis

Provide an image path, paste a screenshot, or drag-drop:

```
> Analyze this image: /path/to/screenshot.png
```

When Claude references images (e.g., [Image #1]), Cmd+Click (Mac) or Ctrl+Click (Windows/Linux)
to open them in your default viewer.

### Use @ Mentions for Quick Context

```
> Explain the logic in @src/utils/auth.js
> What patterns does @src/components/ use?
> Check @mcp-server:resource for the latest data
```

`@file` includes full file content. `@directory` provides a listing. `@server:resource` fetches
from connected MCP servers.

---

## Session Management

### Context Hygiene

- `/clear` between unrelated tasks — don't let stale context accumulate
- For complex task restarts: dump plan/progress to a `.md`, `/clear`, resume from the file
- Scope each session to one feature or project
- Avoid relying on auto-compaction — it's lossy and unpredictable

### Resume and Continue

- `claude --resume` — restart a specific session
- `claude --continue` — pick up the most recent session
- Useful for debugging: resume old sessions to ask how Claude overcame a specific error

### Teleport Between Surfaces

Sessions are portable across Claude Code surfaces:

- Start on web/iOS → pull into terminal with `/teleport`
- Terminal → Desktop app with `/desktop` for visual diff review
- Slack mention @Claude → get a PR back
