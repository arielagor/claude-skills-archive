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

### Step 4: Cross-check gstack learnings

Check gstack's project-scoped learnings for anything that should also exist as a memory file (for non-gstack sessions) or vice versa. Run this exact command from the project directory. It is the same from the Bash tool and the PowerShell tool, and it takes ~45s, so give it a 180s timeout:

```bash
node "$HOME/.claude/skills/session-retro/gstack-learnings.mjs" search --limit 50
```

**Never call the gstack bins through a bare `bash`.** From the PowerShell tool, `bash` is WSL (`C:\Windows\System32\bash.exe`), where the bins don't exist. The old `2>/dev/null || echo "No gstack learnings."` step then reported nothing while 36 learnings existed (2026-09-27). The wrapper runs Git Bash by absolute path, refuses WSL, and prints stderr, so a failure shows up as an error and a genuinely empty result is labelled as empty. The slug comes from the working directory: pass `--cwd DIR` if you're not already in the project.

For each gstack learning:
- If it's a reusable cross-session insight, ensure a corresponding feedback memory file exists
- If a memory file exists for a pattern not in gstack learnings, consider logging it there too via `gstack-learnings-log`

For each new memory file created during the session:
- If it describes an operational pitfall or pattern that gstack skills would benefit from, write the JSON to a file with the Write tool (`{"skill":"session-retro","type":"TYPE","key":"SHORT_KEY","insight":"DESCRIPTION","confidence":N,"source":"observed"}`), then log it. A file avoids quoting and backslash loss in both shells:
```bash
node "$HOME/.claude/skills/session-retro/gstack-learnings.mjs" log --from-file PATH/TO/learning.json
```

### Step 5: Update MEMORY.md index

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

## Three Learning Stores

The system bridges three parallel stores:

| Store | Scope | Written By | Read By |
|-------|-------|-----------|---------|
| **Claude memory** (`~/.claude/projects/.../memory/`) | Global, cross-project | Claude sessions | Every Claude session |
| **GBrain** (`projects/` pages) | Global, durable knowledge | Claude sessions, collectors | Claude sessions via MCP |
| **gstack learnings** (`~/.gstack/projects/<slug>/learnings.jsonl`) | Per-project | gstack skills | gstack skills |

The session retro bridges them: insights that matter across projects go to memory + GBrain. Insights specific to one project's build/deploy/test quirks go to gstack learnings. Operational pitfalls go to both.
