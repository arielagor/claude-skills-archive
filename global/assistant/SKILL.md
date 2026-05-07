---
name: assistant
description: |
  Analyzes the current conversation and recommends an ordered chain of skills,
  subagents, and slash-commands to invoke next, then auto-executes the chain
  after one bulk approval. Use when the user says "/assistant", "what's next",
  "what should I run", "chain the skills", "auto-pilot this", or "what skills
  apply here". Also fire when the user finishes a chunk of work (build done,
  feature shipped, bug fixed, research wrapped) and wants the obvious follow-up
  workflows run for them. Proactively suggest at natural workflow boundaries
  when 2+ obvious follow-on skills exist and the user hasn't explicitly said
  they're stopping.
voice-triggers:
  - "assistant"
  - "what should I run"
  - "what skills should I run"
  - "chain the skills"
  - "auto-pilot this"
  - "what next"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
  - Skill
  - Agent
  - Write
---

# /assistant — Skill Decision & Auto-Execution

Look at what just happened in this conversation. Decide which skills, subagents, and slash-commands would obviously move the work forward. Show that chain to the user with rationale. Get one approval. Run the chain.

This skill exists because the user has hundreds of skills available and remembering the right follow-up chain after every chunk of work (ship → notes → marketing site → social → docs) is friction. Let the model do the routing.

## When to invoke

**Explicit triggers** — user says any of: `/assistant`, "what should I run", "what's next", "chain the skills", "auto-pilot this", "what skills apply here".

**Proactive triggers** — at the end of any of these natural boundaries, suggest running `/assistant` if 2+ follow-up skills are obvious:
- A build, deploy, or release just finished.
- A feature was just merged.
- A bug investigation just wrapped.
- A research/exploration phase produced a finding the user might act on.
- A long session is winding down (user said "ok done", "thanks", "wrapping up").

If a follow-up chain is not obvious, do not push `/assistant` for its own sake. Sometimes the right move is silence.

## Hard rules (read before doing anything)

- **Read-only until approved.** During synthesis and chain-building, do not Edit/Write/Bash anything that mutates state. The only allowed write before approval is to scan skill frontmatter via Read.
- **Never re-recommend a skill the user just ran in this session.** Track via session synth; if `/foo` ran 5 messages ago and succeeded, don't propose it again unless the user explicitly asks.
- **No em-dashes.** Use period, comma, semicolon, parens, or conjunction. Hard rule across all of Ariel's outputs.
- **Default model = Opus.** Any subagent the chain spawns must be passed `model: "opus"` explicitly. Never default to Sonnet/Haiku.
- **Cap chain length at 7.** If more than 7 obvious steps exist, append `(then run /assistant again)` to the tail.
- **No parallel chain execution.** Skills run sequentially; one finishes before the next starts. State changes from step N often affect step N+1.

## Step 1 — Synthesize session context

Write 3-5 bullets in user-facing text capturing:

- **Completed:** what the user actually finished this session (commits, builds, files written, decisions made).
- **Attempted but failed/abandoned:** what was tried and dropped.
- **Touched:** which repos, projects, files, or services were the focus.
- **Stated/implied next intent:** the user's last direction, or what they're clearly about to want.
- **Skills already run this session:** so we don't propose them again.

Pull this from the conversation only. Do not pull from MEMORY.md, GBrain, or git log unless the conversation already brought them in.

Keep this section to 5 bullets max. If the session is genuinely empty (e.g. the user just opened a new session and immediately typed `/assistant`), say so and exit cleanly: "Nothing to chain off yet. Do something, then ask me again."

## Step 2 — Inventory available execution surfaces

Three sources, in priority order:

1. **The user-invocable skills list** is already in the system prompt of every conversation. Use it directly. No need to scan disk.
2. **Subagent types** are listed in the Agent tool description in the system prompt. Use it directly.
3. **Deeper skill frontmatter** (only if a recommendation is borderline and the system-prompt one-liner isn't enough): scan `C:\Users\ariel\.claude\skills\<name>\SKILL.md` and `C:\Users\ariel\.claude\plugins\cache\**\skills\<name>\SKILL.md` via Glob+Read on the specific candidates. Don't bulk-scan; read the 2-3 you're unsure about.

## Step 3 — Build the chain

For each candidate step, capture:

```json
{
  "tool": "Skill" | "Agent" | "none",
  "name": "skill-name or subagent_type",
  "args_or_prompt": "args string for Skill, prompt for Agent",
  "rationale": "one sentence why this comes next",
  "risk": "low" | "medium" | "high"
}
```

**Heuristics:**

- **Specialist beats generalist.** If a wrapped skill exists (`/ios-ship`, `/asc-promoter`, `/marketing-site-updater`), use it instead of asking a subagent to redo what the skill already encodes.
- **Match the canonical chain.** Read `references/chain-heuristics.md` for 12+ pre-baked chain patterns. If the session synth matches one, use that chain as the spine and tweak.
- **Order by dependency.** If skill B reads state that skill A produces, A goes first. Most chains follow: verify → test → ship → marketing → social → document.
- **Mark risk=high** for any skill in `references/risky-skills.md` (anything that ships code, deploys, sends external messages, or costs real money). The risk badge changes execution behavior in Step 6.
- **Preflight if needed.** If the chain would fire a skill that requires being inside a git repo and the current `pwd` is `C:\Users\ariel` (not a repo) or unclear, prepend `/preflight` to fail fast. Detect via `Bash: git rev-parse --is-inside-work-tree 2>/dev/null || echo no`.
- **Cap at 7 steps.** Beyond 7, the chain gets stale before it finishes. Tail with "(then run /assistant again)".

## Step 4 — Render the plan

Show the user a numbered markdown list. One step per line, with rationale and risk badge. Plain Strange voice. No em-dashes.

Format:

```
Here is what I'd run next:

1. /orient — get oriented in the current project (low)
2. /preflight — confirm we're in the right repo (low)
3. /ideate — pressure-test the new feature direction (low)
4. /spec — write the PRD and four-lens review (low)
5. /scaffold — create the private repo and base config (medium)

(approve once, I run them in order; high-risk steps still ask before firing)
```

## Step 5 — Single approval gate

Use `AskUserQuestion` with three options. The recommended option must come first and be labeled `(Recommended)`.

```
Question: "Approve this chain?"
Options:
  1. Approve all (Recommended)
     Description: Execute in order. Pause only before high-risk steps.
  2. Edit
     Description: Free-text redirect. I'll reflow the chain based on your input.
  3. Cancel
     Description: Log abandoned and exit. Nothing runs.
```

If the user picks `Edit`, take their free-text response, re-do Step 3 with that as steering, render again, ask again. Cap at 3 edit cycles before forcing a yes/no.

## Step 6 — Execute

Loop through approved steps in order. For each:

- **`tool=Skill`** → call `Skill(skill="<name>", args="<args>")`.
- **`tool=Agent`** → call `Agent(subagent_type="<name>", description="<3-5 word desc>", prompt="<self-contained brief>", model="opus")`. Always pass `model: "opus"`.

**Before each step:** print one short user-facing line: "Step N: running /<name>".

**Before risk=high steps:** even though the user gave bulk approval, ask one inline confirmation: "Step N is high-risk (`/<name>` ships/deploys/sends). Proceed?" Use AskUserQuestion with `Yes / Skip this step / Cancel rest of chain`. This protects the user from chain runaway on a destructive step.

**After each step:** one-sentence outcome. "Done. /foo wrote X." or "Failed: <reason>."

**On step failure:** stop the chain. Do not auto-continue. Summarize what failed, what's left unrun, and ask the user how to proceed (retry, skip, cancel rest).

## Step 7 — Log

Build a JSON object with these exact fields:

```json
{
  "ts": "<ISO 8601 UTC>",
  "session_synth": "<one-line collapsed version of Step 1>",
  "plan": [{"tool": "Skill", "name": "orient", "rationale": "..."}],
  "approved": true,
  "executed": ["orient", "ideate"],
  "outcomes": ["ok", "ok"],
  "abandoned_at": null
}
```

Append it as one JSONL line via `scripts\log-recommendation.ps1`:

```bash
echo '<json-string-here>' | powershell -ExecutionPolicy Bypass -File C:/Users/ariel/.claude/skills/assistant/scripts/log-recommendation.ps1
```

Log on every run, including cancelled and abandoned. The log file is `C:\Users\ariel\.claude\projects\C--Users-ariel\memory\assistant-log.jsonl`. The log is append-only; never read from it during a run, only write.

## Edge cases

- **Empty session** (Step 1 produced nothing): say so, exit, do not log.
- **User runs /assistant twice in a row with no work between**: detect via session synth being identical to last run. Respond "No new chain to suggest, last chain still in flight" and exit. Do not log.
- **Skill not found in available-skills list**: do not invent skills. If the chain calls for something that doesn't exist, drop that step and note "<skill-name> not installed" in the rationale of the next step.
- **Subagent not found**: same rule. Drop and note.
- **User says "Edit" but the redirect is incoherent**: ask one clarifying question via AskUserQuestion. Do not loop forever.

## Reference files

- `references/chain-heuristics.md` — common context-to-chain mappings. Read this on every run during Step 3.
- `references/risky-skills.md` — names + patterns for risk=high classification. Read on every run during Step 3.
