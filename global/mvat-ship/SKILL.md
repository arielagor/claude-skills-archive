---
name: mvat-ship
description: "Automated ship workflow: merge main, run tests, pre-landing review, version bump, changelog, bisectable commits, push, create PR. Non-interactive by default."
user_invocable: true
---

# /mvat-ship — Ship Workflow

Fully automated shipping pipeline. User says `/mvat-ship`, next thing they see is the PR URL.
Adapted from gstack's battle-tested `/ship` with MVAT governance integration.

## Philosophy

This is a **non-interactive, fully automated** workflow. Do NOT ask for confirmation at any step.

**Only stop for:**
- On `main` branch (abort)
- Merge conflicts that can't be auto-resolved
- Test failures
- Pre-landing review finds CRITICAL issues
- MINOR or MAJOR version bump needed

**Never stop for:**
- Uncommitted changes (always include them)
- Version bump choice (auto-pick PATCH)
- Changelog content (auto-generate from diff)
- Commit message approval (auto-commit)

## Steps

### Step 1: Pre-flight
1. Check branch — abort if on `main`
2. Run `git status` (never `-uall`)
3. Run `git diff main...HEAD --stat` and `git log main..HEAD --oneline` to understand scope
4. **MVAT governance check**: If governance files exist, verify no circuit breakers tripped, no critical escalations pending

### Step 2: Merge origin/main
```bash
git fetch origin main && git merge origin/main --no-edit
```
If merge conflicts: try auto-resolve simple ones. Complex conflicts → STOP and show them.

### Step 3: Run tests
Run test suite for the project. Auto-detect test runner:
- `package.json` with test script → `npm test`
- `pytest` → `pytest`
- `cargo` → `cargo test`
- `go.mod` → `go test ./...`
- `Gemfile` → `bundle exec rspec` or `bin/test-lane`

**If any test fails:** Show failures and STOP. Do not proceed.

### Step 4: Pre-Landing Review
Run `/mvat-review code` on the diff:

1. Fetch diff: `git diff origin/main`
2. Apply two-pass review:
   - **Pass 1 (CRITICAL):** SQL safety, race conditions, LLM trust boundary, XSS
   - **Pass 2 (INFORMATIONAL):** Conditional side effects, magic numbers, dead code, test gaps

3. **If CRITICAL issues found:** For EACH critical issue, AskUserQuestion:
   - A) Fix it now (recommended)
   - B) Acknowledge and ship anyway
   - C) False positive — skip

   If any fixes applied: commit fixes, tell user to run `/mvat-ship` again.

4. **If only informational:** Include in PR body, continue.

### Step 5: Version bump (auto-decide)
If `VERSION` file exists:
- < 50 lines changed → PATCH bump
- 50+ lines → MINOR (ask user)
- Major features → MAJOR (ask user)

If no `VERSION` file: skip this step.

### Step 6: Changelog (auto-generate)
If `CHANGELOG.md` exists:
1. Auto-generate entry from `git log main..HEAD --oneline` and `git diff main...HEAD`
2. Categorize: Added / Changed / Fixed / Removed
3. Insert dated entry after header

### Step 7: TODOS cross-reference
If `TODOS.md` exists:
- Mark completed TODOs based on diff evidence (be conservative)
- Move completed items to `## Completed` section with version annotation
- Flag new work that should become a TODO

### Step 8: Commit (bisectable chunks)
Split into logical commits for `git bisect`:

**Ordering:**
1. Infrastructure (migrations, config, routes)
2. Models & services (with their tests)
3. Controllers & views (with their tests)
4. VERSION + CHANGELOG + TODOS.md (final commit)

**Rules:**
- Each commit = one logical change
- A model and its test go in the same commit
- Each commit must be independently valid
- If diff is small (< 50 lines, < 4 files), single commit is fine
- Final commit message:
  ```
  chore: bump version and changelog (vX.Y.Z)
  ```

### Step 9: Push
```bash
git push -u origin <branch-name>
```

### Step 10: Create PR
```bash
gh pr create --title "<type>: <summary>" --body "$(cat <<'EOF'
## Summary
<bullet points from changelog>

## Pre-Landing Review
<findings from Step 4, or "No issues found.">

## Test plan
- [x] All tests pass

## MVAT Governance
<governance state if applicable: escalations, assumptions>
EOF
)"
```

**Output the PR URL** — this is the final output.

### Step 11: MVAT Artifact (optional)
If MVAT governance is active:
- Create a ship artifact at `artifacts/engineering/` documenting what was shipped
- Update any pending escalations this PR resolves

## Important Rules
- Never skip tests. If tests fail, stop.
- Never skip the pre-landing review.
- Never force push.
- Split commits for bisectability.
- The goal: user says `/mvat-ship`, next thing they see is the PR URL.
