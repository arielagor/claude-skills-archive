---
name: deploy-all
description: Deploy changes across multiple sites/repos in parallel. Use when the user wants to push updates to multiple websites or repos at once.
user_invocable: true
---

# Deploy All Sites

Deploy changes across multiple repos/sites in parallel using Task sub-agents.

## Steps

1. **Identify target repos.** Check which repos under `C:\Users\ariel\.claude\projects\` have uncommitted changes:
   - Run `git status --short` in each project directory
   - Skip repos with no changes

2. **For each repo with changes, spawn a parallel Task agent** that:
   - Runs any build/lint checks if a `package.json` exists (`npm run build` or `npx tsc --noEmit`)
   - Stages and commits changes with a conventional commit message
   - Pushes to the remote default branch
   - If the repo is deployed on Netlify, checks deploy status with `npx netlify api listSiteDeploys`
   - Reports back: repo name, files changed, commit hash, deploy status

3. **Collect results** into a summary table:
   | Repo | Files Changed | Commit | Deploy Status |
   |------|--------------|--------|---------------|

4. **If any repo fails**, report the error but continue with others. Never let one failure block the rest.

## Known repos and their deploy targets
- `agor.me` → Netlify (site ID: c589be58-d2ca-46ff-8ebf-1fe68097dbb5)
- `mvat` → GitHub only (no deploy)
- `mvat-focus` → EAS Build (Expo)
- `mvat-mirror` → EAS Build (Expo)

## Constraints
- Never force-push
- Never commit `.env` files or credentials
- Always use conventional commit messages (feat:, fix:, chore:, docs:)
- If a repo has merge conflicts, skip it and report the conflict
