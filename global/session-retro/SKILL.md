# /session-retro — Session Learning Capture

Run this at the end of any significant session (or mid-session after a complex debugging episode) to extract and persist learnings.

## What This Does

1. **Analyzes audit logs** for the current session — detects retry storms, file churn, exploration spirals, debugging loops, reverts, and infrastructure creation
2. **Reviews the conversation** for approaches that worked, approaches that failed, corrections received, and non-obvious successes
3. **Files learnings** to GBrain (project pages for infra, feedback memories for behavioral patterns) and MEMORY.md

## When to Use

- End of any session longer than 30 minutes
- After a complex debugging episode
- After building infrastructure (pipelines, cron jobs, hooks, integrations)
- After receiving corrections or discovering non-obvious approaches
- Before writing a HANDOFF.md

## Steps

### Step 1: Run the audit analyzer

```bash
node ~/.claude/scripts/session-retro.mjs --days 1
```

Review the output. Note any high-severity patterns.

### Step 2: Self-reflect on the session

Answer these questions (don't skip any):

1. **What was tried that didn't work?** Document the failed approach and why it failed. If the failure mode could recur, save as a feedback memory.
2. **What non-obvious approach succeeded?** If you chose an unusual path and it worked (especially without correction from Ariel), save as a feedback memory with the reasoning.
3. **What corrections were received?** Check if they're already saved as feedback memories. If not, save them.
4. **What infrastructure was built?** Verify every pipeline, scheduled task, hook, or integration has a GBrain project page and a MEMORY.md entry.
5. **What codebase knowledge was hard-won?** If you spent significant time finding how something works, consider whether the answer should be in a CLAUDE.md or memory file for next time.

### Step 3: File the learnings

For each learning identified:

- **Failed approach** → feedback memory: what was tried, why it failed, what to do instead
- **Successful approach** → feedback memory: what was done, why it worked, when to reuse
- **Correction received** → feedback memory: the rule, the reason, how to apply
- **Infrastructure built** → GBrain project page + memory file + MEMORY.md entry + CLAUDE.md if cross-session
- **Codebase knowledge** → appropriate CLAUDE.md or memory file

### Step 4: Update MEMORY.md index

Add entries for any new memory files created.

## Example Output

```
## Session Retro: 7355822...
**Duration:** 45m | **Actions:** 127 | **Error rate:** 3%

### Patterns Found (2)

[!] retry_storm (1x)
   1 retry storm detected — Bash called 4x rapidly with similar npm commands
   
[~] file_churn (1x)
   1 file edited 7 times — settings.json was modified incrementally
   
### Action Items
- [ ] retry_storm: npm install was failing due to network; consider offline cache
```

## Integration

This skill is the human-invocable counterpart to three automated mechanisms:
- `gbrain-filing-reminder.sh` — PostToolUse hook, fires on infra-related git commits
- `revert-detector.sh` — PostToolUse hook, fires on git revert/reset commands
- CLAUDE.md behavioral rule requiring infrastructure filing

Together they form the **learning loop**: hooks catch signals in real-time, the retro synthesizes them into durable knowledge, and the memories inform future sessions.
