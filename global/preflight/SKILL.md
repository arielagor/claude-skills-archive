---
name: preflight
version: 1.0.0
description: |
  Front-load environment context checks before any infrastructure, deploy,
  git, SSH, or stateful command. Catches wrong cwd, wrong username, missing
  auth scopes BEFORE they cascade into debugging sessions. 30-second check
  prevents 30-minute dead ends.
  Use at the start of any session involving: git, gh, deploy, SSH, eas submit,
  netlify, vercel, firebase, docker, infrastructure work. Or when the user
  says "preflight", "where am I", "check env", "am I in the right place".
allowed-tools:
  - Bash
  - Read
  - Glob
triggers:
  - preflight
  - check env
  - where am i
  - am i in the right place
  - pre-flight
---

# Preflight — Environment Sanity Check

Sessions burned hours because `/document-release` ran from `C:\Users\ariel` (not a git repo), SSH used `ariel@mac` instead of `agor@mac`, and `gh workflow run` failed silently due to missing `workflow` scope. A 30-second preflight catches all three.

## What it checks

Run these in parallel and report a one-screen summary:

```bash
# Identity & location
pwd
whoami
hostname

# Git context (if in a repo)
git rev-parse --show-toplevel 2>/dev/null && git branch --show-current && git status --short | head -5

# GitHub auth
gh auth status 2>&1 | grep -E "Logged in|scopes|Token"

# Active project hint
ls package.json pyproject.toml Cargo.toml go.mod 2>/dev/null
ls -d .git .claude 2>/dev/null
```

## Project-specific checks (run if relevant)

| Tool | Check |
|------|-------|
| EAS / Expo | `eas whoami` and `eas build:list --limit 1 --platform ios` |
| Netlify | `netlify status` shows current site |
| Vercel | `vercel whoami` and `vercel ls --prod \| head -3` |
| Firebase | `firebase projects:list` and current project |
| Docker | `docker ps --format "table {{.Names}}\t{{.Status}}"` |
| Stripe | `mcp__stripe__get_stripe_account_info` (live vs test mode) |
| AWS | `aws sts get-caller-identity` |
| GCloud | `gcloud config list --format=json \| jq '.core'` |
| SSH targets | Check `~/.ssh/config` for relevant Host blocks |

## Known environment landmines (auto-flag)

If preflight detects any of these, **stop and warn the user** before proceeding:

- ❗ cwd is `C:\Users\ariel` AND user is about to run git/checkpoint/release commands → "This isn't a git repo. Which project did you mean?"
- ❗ User mentions SSH to Mac AND is about to use username `ariel` → "Mac username is `agor`. Did you mean `ssh mac` or `ssh agor@...`?"
- ❗ User mentions `gh workflow run` AND `gh auth status` shows no `workflow` scope → "Run `gh auth refresh -s workflow` first."
- ❗ User mentions Netlify env vars AND attempting from local Claude → "Use Netlify CLI/dashboard — env vars can't be set via local Claude."
- ❗ Stripe is in `test` mode AND user mentions production → flag mode mismatch.
- ❗ Multiple git repos in subdirectories AND ambiguous reference → ask which one.

## Output format

```
PREFLIGHT
─────────
cwd:      C:\Users\ariel\.claude\projects\agor.me  ✓ git repo
branch:   main (clean)
user:     ariel @ AGOR-WIN-DESK
gh:       ✓ logged in as aagor (scopes: repo, gist, workflow)
project:  agor.me (Next.js, package.json present)
notes:    none

Ready.
```

Or, on detected landmine:

```
PREFLIGHT
─────────
cwd:      C:\Users\ariel  ⚠ NOT A GIT REPO
gh:       ✓ logged in as aagor (scopes: repo, gist) ⚠ MISSING workflow scope

⚠ You asked to rerun a workflow, but you're in the home dir and lack
  workflow scope. Run:
    cd C:\Users\ariel\.claude\projects\<the project>
    gh auth refresh -s workflow

Want me to do that now?
```

## When to skip

- Pure question/research sessions (no commands).
- The user has already established context this turn (e.g., they `cd`'d into the project themselves).
- Quick edits to a file the user opened by absolute path.

Lean toward running it whenever the session involves multi-step infrastructure work, especially after `/clear`.
