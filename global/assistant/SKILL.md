---
name: assistant
description: |
  Analyzes the current conversation and recommends an ordered chain of skills,
  subagents, and slash-commands to invoke next, then auto-executes the chain
  immediately with no approval gate. Use when the user says "/assistant", "what's next",
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

Look at what just happened in this conversation. Decide which skills, subagents, and slash-commands would obviously move the work forward. Show that chain to the user with rationale, then run it immediately. No approval gate.

This skill exists because the user has hundreds of skills available and remembering the right follow-up chain after every chunk of work (ship → notes → marketing site → social → docs) is friction. Let the model do the routing.

> **Standing authorization (Ariel, 2026-07-24): always run the recommended chain without gating.**
> No bulk-approval prompt, no per-step high-risk confirmation. Render the plan, then execute it in
> order. Transparency replaces gating: announce each step before it fires, report each outcome after,
> and log the whole run. The user can still interrupt mid-chain, and any single step that itself
> stops for its own confirmation (a wrapped skill's internal gate) is still honored. The one thing
> that never changes: **a step failure stops the chain** (Step 6). This authorization lives in the
> skill on purpose so it is durable across sessions; to reinstate gating, revert this block and
> Steps 5 to 6.

## When to invoke

**Explicit triggers** — user says any of: `/assistant`, "what should I run", "what's next", "chain the skills", "auto-pilot this", "what skills apply here".

**Proactive triggers** — at the end of any of these natural boundaries, suggest running `/assistant` if 2+ follow-up skills are obvious.
(**Log them honestly:** see the `trigger` values in Step 7. A boundary suggestion the user then accepts is `"suggested"`, NOT `"proactive"`.)
- A build, deploy, or release just finished.
- A feature was just merged.
- A bug investigation just wrapped.
- A research/exploration phase produced a finding the user might act on.
- A long session is winding down (user said "ok done", "thanks", "wrapping up").

If a follow-up chain is not obvious, do not push `/assistant` for its own sake. Sometimes the right move is silence.

## Hard rules (read before doing anything)

- **Read-only during synthesis.** While doing Step 1 to Step 4 (deciding the chain), do not Edit/Write/Bash anything that mutates state; synthesis is investigation only. Execution begins at Step 6. The mutation happens there, run by the chained skills themselves, not by /assistant's own hands during planning.
- **Never re-recommend a skill the user just ran in this session.** Track via session synth; if `/foo` ran 5 messages ago and succeeded, don't propose it again unless the user explicitly asks.
- **No em-dashes.** Use period, comma, semicolon, parens, or conjunction. Hard rule across all of Ariel's outputs.
- **Default model = Opus.** Any subagent the chain spawns must be passed `model: "opus"` explicitly. Never default to Sonnet/Haiku.
- **Cap chain length at 7.** If more than 7 obvious steps exist, append `(then run /assistant again)` to the tail.
- **No parallel chain execution.** Skills run sequentially; one finishes before the next starts. State changes from step N often affect step N+1.
- **Deferred steps don't silently resurface.** If a step was previously deferred on an external condition (App Store approval pending, waiting on a reply), do not re-recommend it without first checking whether the condition cleared, and say which condition you checked.

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
3. **Deeper skill frontmatter** (only if a recommendation is borderline and the system-prompt one-liner isn't enough): read `C:\Users\ariel\.claude\skills\<name>\SKILL.md` first; it is the canonical copy. Fall back to `C:\Users\ariel\.claude\plugins\cache\**\skills\<name>\SKILL.md` only for plugin-only skills with no local copy (the cache can hold stale duplicates of local skills). Don't bulk-scan; read the 2-3 you're unsure about.

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

(running these now, in order; I announce each step and report each outcome)
```

The risk badge is still shown, for transparency, not for gating. It tells the user what class each
step is (a `high` badge means the step ships/deploys/sends/spends) so they can interrupt if a step is
not what they wanted. It no longer triggers a confirmation prompt.

## Step 5 — No approval gate (standing authorization)

**Do not ask for approval. Render the plan (Step 4), then go straight to Step 6 and execute it.**
Per the standing authorization at the top of this file (Ariel, 2026-07-24), the chain always runs
without gating. There is no `AskUserQuestion` here, no "Approve this chain?", no bulk-approval prompt.

The user retains three levers without a prompt:
- **Interrupt.** They can stop the chain mid-run at any time; honor it immediately.
- **Redirect after the fact.** If they say the chain was wrong, do not re-run the bad steps; reflow
  from where they redirected.
- **A wrapped skill's own internal gate still fires.** If a step is a skill that itself stops for a
  confirmation (its own design), that is honored. `/assistant` does not add a gate; it also does not
  suppress one a downstream skill owns.

Only skip execution when Step 1 found genuinely nothing to chain (empty or no-new-work session). In
that case, say so plainly and exit. Silence is a valid result; a manufactured chain is not.

## Step 6 — Execute

Loop through approved steps in order. For each:

- **`tool=Skill`** → call `Skill(skill="<name>", args="<args>")`.
- **`tool=Agent`** → call `Agent(subagent_type="<name>", description="<3-5 word desc>", prompt="<self-contained brief>", model="opus")`. Always pass `model: "opus"`.

**Before each step:** print one short user-facing line, and for a `high` step name the class so it is
never a surprise: "Step N: running /<name>" or "Step N: running /<name> (high: ships/deploys/sends/spends)".

**No inline confirmation, including on high-risk steps.** Per the standing authorization, fire the
step. The pre-step announcement above is the transparency mechanism; the user can interrupt on seeing
it. Do not call `AskUserQuestion` anywhere in the execution loop.

**After each step:** one-sentence outcome. "Done. /foo wrote X." or "Failed: <reason>."

**On step failure:** stop the chain. Do not auto-continue. Summarize what failed, what's left unrun, and ask the user how to proceed (retry, skip, cancel rest).

**Deferrals:** when a step is dropped because an external condition isn't met yet ("App Store approval pending", "after Ariel sends the drafts"), record it as a deferral instead of silently dropping it: capture the step name and the blocking condition. After the chain finishes, if any deferral has a concrete date or checkable condition, offer ONE `/schedule` one-shot that runs the deferred sub-chain when the condition should have cleared. Never auto-create the scheduled task; offer it and let the user decide.

## Step 7 — Log

Build a JSON object with these exact fields:

```json
{
  "ts": "<ISO 8601 UTC>",
  "trigger": "explicit" | "proactive",
  "session_synth": "<one-line collapsed version of Step 1>",
  "plan": [{"tool": "Skill", "name": "orient", "rationale": "..."}],
  "gated": false,
  "executed": ["orient", "ideate"],
  "outcomes": ["ok", "ok"],
  "deferred": [{"name": "social-announcer", "condition": "GifLoop 1.2.0 App Store approval"}],
  "abandoned_at": null
}
```

`trigger` records WHO started the run. Three values, and the distinction matters because the
previous two-value scheme was unobservable:

- `"explicit"` — the user typed `/assistant` or a trigger phrase themselves.
- `"suggested"` — Claude proposed running it at a workflow boundary and the user then invoked it.
- `"proactive"` — Claude invoked the Skill tool ITSELF, with no user turn in between.

**Why this changed (2026-08-20 tune):** across 188 logged runs the split was `explicit: 134,
proactive: 0`. Not a single proactive run, ever. The reason is structural, not behavioral: this
skill only executes when invoked, so if Claude suggests it and the user accepts, the user typed it
and the run correctly logged `"explicit"`. Under the old two-value scheme `"proactive"` could only
be reached by Claude self-invoking, which nothing instructed it to do. The `"suggested"` value makes
the boundary-suggestion path observable, so a future tune can actually measure whether proactive
suggestion is working instead of reading a permanent zero. `deferred` is `[]` when nothing was deferred.

Append it as one JSONL line via `scripts\log-recommendation.ps1`. Write the JSON to a temp file first; do not pipe it through shell quoting (embedded quotes in session_synth break `echo '<json>'`):

```powershell
Set-Content -Path $env:TEMP\assistant-log-entry.json -Value '<json here via Write tool, not inline>' 
powershell -ExecutionPolicy Bypass -File C:/Users/ariel/.claude/skills/assistant/scripts/log-recommendation.ps1 -JsonFile $env:TEMP\assistant-log-entry.json
Remove-Item $env:TEMP\assistant-log-entry.json
```

In practice: use the Write tool to create the temp JSON file (avoids all quoting), then run the script with `-JsonFile`, then delete the temp file.

Log on every run, including cancelled and abandoned. The log file is `C:\Users\ariel\.claude\projects\C--Users-ariel\memory\assistant-log.jsonl`. The log is append-only; never read from it during a normal run, only write. The single exception is tune mode (below).

## Tune mode — `/assistant tune`

The log exists so the heuristics can learn from reality. When invoked as `/assistant tune` (or "tune the assistant", "mine the assistant log"), skip Steps 1-7 entirely and instead:

1. Read `C:\Users\ariel\.claude\projects\C--Users-ariel\memory\assistant-log.jsonl` (this is the one sanctioned read of the log).
2. Surface, with counts:
   - Chains observed 3+ times that are not in `references/chain-heuristics.md`.
   - Steps repeatedly skipped or deferred by the user (candidates for demotion or removal from a canonical chain).
   - Steps recommended 3+ times but never approved. **Dead metric since gating was removed
     (2026-07-24): every recommendation now executes, so this is structurally always zero.** Read
     chain SHAPE and the `outcomes` strings instead; that is where real failures surface.
   - Recommended skills that no longer exist in the available-skills list (heuristics referencing deleted skills).
   - Trigger split across `explicit` / `suggested` / `proactive`. Baseline at the 2026-08-20 tune:
     134 explicit, 0 proactive, `suggested` did not yet exist. If `suggested` is still 0 several
     tunes from now, Claude is not actually offering `/assistant` at workflow boundaries and that
     section of this file should be cut rather than left as decoration.
3. Propose concrete edits to `chain-heuristics.md` and `risky-skills.md` as a diff-style summary.
4. After ONE approval, apply the edits and update the "Last tuned" line in chain-heuristics.md with the date and run count.

Run this roughly monthly, or whenever the log has grown by 30+ entries since "Last tuned". Tune mode never executes any skill chain and never writes to the log.

## Edge cases

- **Empty session** (Step 1 produced nothing): say so, exit, do not log.
- **User runs /assistant twice in a row with no work between**: detect via session synth being identical to last run. Respond "No new chain to suggest, last chain still in flight" and exit. Do not log.
- **Skill not found in available-skills list**: do not invent skills. If the chain calls for something that doesn't exist, drop that step and note "<skill-name> not installed" in the rationale of the next step.
- **Subagent not found**: same rule. Drop and note.
- **The obvious chain would touch work that is not the user's or not this session's** (uncommitted files from another session, a WIP thread blocked on the user's own pending decision, a repo with no remote that would need creating): do not sweep it in autonomously just because the gate is gone. Name it as out of scope in the synthesis and leave it. "Run without gating" removed the approval prompt; it did not widen scope to other people's or other threads' work.
- **User interrupts mid-chain or redirects incoherently after the fact**: stop, and if the redirect is unclear ask one clarifying question via AskUserQuestion (disambiguation, not a gate). Do not loop forever; do not re-run steps that already ran.

## Reference files

- `references/chain-heuristics.md` — common context-to-chain mappings. Read this on every run during Step 3.
- `references/risky-skills.md` — names + patterns for risk=high classification. Read on every run during Step 3.
