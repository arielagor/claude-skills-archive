---
name: cross-repo-update
description: Apply the same change across multiple repos/websites in parallel. Use when updating emails, branding, config, or any repeated change across sites.
user_invocable: true
---

# Cross-Repo Update

Apply a consistent change across multiple repositories in parallel.

## Usage
The user will specify:
- **What to change** (e.g., "update contact email to hello@agor.me")
- **Which repos** (or "all" to scan all projects)

## Steps

1. **Parse the change request** — identify the search pattern (old value) and replacement (new value).

2. **Identify target repos.** If "all", scan `C:\Users\ariel\.claude\projects\` for repos. Otherwise use the specified list.

3. **For each repo, spawn a parallel Task agent** that:
   a. Uses Grep to find all files containing the old value
   b. Shows the user what will change (file paths + line counts)
   c. Makes all edits using the Edit tool
   d. Runs any available build/lint checks
   e. Commits with message: `chore: [description of change]`
   f. Pushes to remote
   g. If Netlify-deployed, waits 60s then verifies the live site
   h. Reports: repo name, files changed, deploy status, verification result

4. **Collect results** into a summary table.

5. **If any repo fails verification**, retry the deploy once before flagging.

## Constraints
- Always show a preview of changes before committing (unless --force flag)
- Never modify files in node_modules, .git, or dist directories
- Use Edit tool (not sed) for all file modifications
- Commit each repo independently — don't batch across repos
