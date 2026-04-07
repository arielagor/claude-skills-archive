---
name: mvat-retro
description: "Engineering retrospective with metrics, team analysis, streak tracking, and trend comparison. Analyzes commit history, work patterns, and code quality signals."
user_invocable: true
---

# /mvat-retro — Engineering Retrospective

Generates a comprehensive engineering retrospective analyzing commit history, work patterns,
and code quality metrics. Team-aware: identifies contributors, gives per-person praise and
growth opportunities. Adapted from gstack's `/retro` with MVAT pipeline integration.

## Arguments
- `/mvat-retro` — default: last 7 days
- `/mvat-retro 24h` — last 24 hours
- `/mvat-retro 14d` — last 14 days
- `/mvat-retro 30d` — last 30 days
- `/mvat-retro compare` — compare current vs prior same-length window

## Steps

### Step 1: Gather Raw Data
Fetch origin and identify current user, then run ALL in parallel:
```bash
git fetch origin main --quiet
git config user.name

# All commits with stats
git log origin/main --since="<window>" --format="%H|%aN|%ae|%ai|%s" --shortstat

# Per-commit test vs production LOC
git log origin/main --since="<window>" --format="COMMIT:%H|%aN" --numstat

# Commit timestamps for session detection
git log origin/main --since="<window>" --format="%at|%aN|%ai|%s" | sort -n

# File hotspots
git log origin/main --since="<window>" --format="" --name-only | grep -v '^$' | sort | uniq -c | sort -rn

# PR numbers from commit messages
git log origin/main --since="<window>" --format="%s" | grep -oE '#[0-9]+' | sort -n | uniq

# Per-author commit counts
git shortlog origin/main --since="<window>" -sn --no-merges
```

### Step 2: Compute Metrics

| Metric | Value |
|--------|-------|
| Commits to main | N |
| Contributors | N |
| PRs merged | N |
| Total insertions / deletions | +N / -N |
| Net LOC | N |
| Test LOC ratio | N% |
| Active days | N |
| Detected sessions | N |
| Avg LOC/session-hour | N |

Per-author leaderboard:
```
Contributor      Commits   +/-          Top area
You (name)            32   +2400/-300   src/
alice                 12   +800/-150    app/services/
```

### Step 3: Commit Time Distribution
Hourly histogram (local timezone). Call out:
- Peak hours and dead zones
- Bimodal (morning/evening) vs continuous patterns
- Late-night coding clusters

### Step 4: Work Session Detection
Detect sessions using 45-minute gap threshold. Classify:
- **Deep sessions** (50+ min)
- **Medium sessions** (20-50 min)
- **Micro sessions** (<20 min)

Calculate total active coding time, average session length, LOC per hour.

### Step 5: Commit Type Breakdown
Categorize by conventional commit prefix (feat/fix/refactor/test/chore/docs).
Flag if fix ratio > 50% — signals "ship fast, fix fast" pattern.

### Step 6: Hotspot Analysis
Top 10 most-changed files. Flag files changed 5+ times (churn hotspots).

### Step 7: PR Size Distribution
Bucket: Small (<100 LOC), Medium (100-500), Large (500-1500), XL (1500+).
Flag XL PRs with file counts.

### Step 8: Focus Score + Ship of the Week
**Focus score:** % of commits touching the single most-changed directory. Higher = deeper work.
**Ship of the week:** Highest-LOC PR with title and impact summary.

### Step 9: Team Member Analysis
For each contributor:
1. Commits, LOC, areas of focus (top 3 directories)
2. Commit type mix (their personal feat/fix breakdown)
3. Session patterns (peak hours, session count)
4. Test discipline (personal test LOC ratio)
5. Biggest ship

**For current user ("You"):** Deepest treatment — full session analysis, focus score.
**For each teammate:**
- **Praise** (1-2 specific things anchored in actual commits — not "great work")
- **Opportunity for growth** (1 specific, constructive suggestion framed as investment)

### Step 10: Streak Tracking
Count consecutive days with commits to origin/main:
- Team streak
- Personal streak

### Step 11: Trend Comparison
Load prior retro from `.context/retros/`. Show deltas:
```
                Last    Now     Delta
Test ratio:     22%  →  41%     ↑19pp
Sessions:       10   →  14      ↑4
Fix ratio:      54%  →  30%     ↓24pp (improving)
```

### Step 12: Save History
Save JSON snapshot to `.context/retros/{date}-{seq}.json` with full metrics, per-author data, streak, and tweetable summary.

### Step 13: MVAT Pipeline Integration
If MVAT governance is active:
- Cross-reference with pipeline stage progress
- Note which pipeline stages got most commits
- Flag if circuit breakers tripped during the window
- Count escalations created vs resolved
- Track agent-generated vs human commits (via Co-Authored-By)
- Note assumption confidence changes during the window
- Create retro artifact at `rollout/retrospectives/` if phase is completing

## Output Structure

**Tweetable summary** (first line):
```
Week of Mar 8: 47 commits (3 contributors), 3.2k LOC, 38% tests, 12 PRs | Streak: 47d
```

Then sections:
1. Summary Table (metrics)
2. Trends vs Last Retro
3. Time & Session Patterns
4. Shipping Velocity
5. Code Quality Signals
6. Focus & Highlights
7. Your Week (personal deep-dive)
8. Team Breakdown (per teammate)
9. Top 3 Team Wins
10. 3 Things to Improve
11. 3 Habits for Next Week

## Tone
- Encouraging but candid, no coddling
- Specific and concrete — anchor in actual commits
- Skip generic praise — say exactly what was good
- Frame improvements as leveling up, not criticism
- Never compare teammates negatively
- ~3000-4500 words total
