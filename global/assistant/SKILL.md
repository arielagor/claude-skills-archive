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
- **In a beads workspace, the ready queue outranks your guess about what comes next.** If `.beads/` exists in the repo, `bd ready` is a stored, dependency-checked answer to the exact question this skill asks. Read it during Step 2 and reconcile it with the session synth before proposing a chain. **Detect, never assume:** beads is piloted in `chief-of-staff` only as of 2026-09-09, so a `bd` command in a repo with no `.beads/` is a wasted step and a confusing error. See `references/beads-integration.md`.
- **Never recommend `bd remember`, and never let a chained step write knowledge into beads.** Durable knowledge goes to GBrain and memory files via `/session-retro` and `gbrain-curator`. Beads owns work state only. Beads' own shipped instructions say the opposite; they are countermanded on this machine.

## Step 1 — Synthesize session context

Write 3-5 bullets in user-facing text capturing:

- **Completed:** what the user actually finished this session (commits, builds, files written, decisions made).
- **Attempted but failed/abandoned:** what was tried and dropped.
- **Touched:** which repos, projects, files, or services were the focus.
- **Stated/implied next intent:** the user's last direction, or what they're clearly about to want.
- **Skills already run this session:** so we don't propose them again.

Pull this from the conversation only. Do not pull from MEMORY.md, GBrain, or git log unless the conversation already brought them in.

Keep this section to 5 bullets max. If the session is genuinely empty (e.g. the user just opened a new session and immediately typed `/assistant`), say so and exit cleanly: "Nothing to chain off yet. Do something, then ask me again."

**Exception, added 2026-09-09: an empty session in a beads repo is not empty.** Before exiting, run Step 2's `test -f .beads/config.yaml` check. If the repo has a queue, `bd ready` is a stored answer to "what next" that does not depend on this session having done anything, and exiting would throw it away. Build the chain from the queue instead and say where it came from. Only exit early when there is no session context **and** no beads workspace.

## Step 2 — Inventory available execution surfaces

Three sources, in priority order:

1. **The user-invocable skills list** is already in the system prompt of every conversation. Use it directly. No need to scan disk.
2. **Subagent types** are listed in the Agent tool description in the system prompt. Use it directly.
3. **Deeper skill frontmatter** (only if a recommendation is borderline and the system-prompt one-liner isn't enough): read `C:\Users\ariel\.claude\skills\<name>\SKILL.md` first; it is the canonical copy. Fall back to `C:\Users\ariel\.claude\plugins\cache\**\skills\<name>\SKILL.md` only for plugin-only skills with no local copy (the cache can hold stale duplicates of local skills). Don't bulk-scan; read the 2-3 you're unsure about.

4. **The beads work queue, when the repo has one.** One detection, then at most two reads:

```bash
test -f .beads/config.yaml && bd ready --json && bd list --status in_progress --json
```

   **Detect on `config.yaml`, NOT on the directory.** `test -d .beads` is a false positive and
   was one on this machine: `C:\Users\ariel\.beads` exists, holds a single 0-byte
   `eventsData/eventkit.lock`, and belongs to an unrelated tool that collided on the name. Since
   `C:\Users\ariel` is the default cwd for most sessions, a directory-only check would fire
   `bd ready` against a non-workspace on nearly every run. A real workspace has `config.yaml`,
   `metadata.json`, `interactions.jsonl` and `embeddeddolt` (verified against the
   `chief-of-staff` pilot, 2026-09-09).

   If there is no `.beads/config.yaml`, skip this entirely and never mention beads in the plan. If it is
   present, these two lists are load-free facts about what is unblocked and what is already
   claimed, which is strictly better than inferring next steps from conversation alone. This
   is the one sanctioned exception to Step 1's "conversation only" rule, and it lives here in
   Step 2 rather than Step 1 precisely because it is an inventory of surfaces, not a synthesis
   of what happened.

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
- **Reconcile the chain against the beads queue** when Step 2 found one. Three concrete effects, in this order:
  - **Work the session actually finished but did not close.** If a bead is `in_progress` (or the session's commits reference a bead ID) and the work is demonstrably done, the chain closes it: `bd close <id> -r "<what and why>"`. Write a real reason; a reason under 40 characters is bookkeeping and the bridge will correctly ignore it.
  - **Work the session produced but never filed.** If the session surfaced follow-up work, a bug, or a deferral, `bd create` it instead of leaving it in prose. This is what replaces a markdown TODO. A deferral recorded in Step 6 that lives in a beads repo should become a bead, not just a log field.
  - **Anything closed gets bridged.** Append `node ~/.gbrain/beads-decisions-bridge.mjs --apply` after the last close (medium: writes ADRs, commits and pushes the brain repo). Skip it if nothing was closed this run.
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

**In a beads repo, also file the deferral as a bead** (`bd create`, with the blocking condition in the description; `bd defer <id>` if it should stay out of the ready queue until then). A deferral that exists only as a field in the Step 7 log JSON is invisible to the next session, because the log is append-only and never read on a normal run. A deferred bead resurfaces in `bd ready` on its own once its blocker closes, which is the whole reason the queue is worth consulting. This does not replace the `/schedule` offer for time-based conditions; it replaces losing the deferral.

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

**Decision rule set 2026-09-06 (226 runs).** `suggested` has been recorded **0 times across the 38
runs since it was introduced**; the split is still `explicit: 172`, `suggested: 0`, `proactive: 0`
(plus 54 pre-schema entries carrying no trigger at all). One tuning cycle is not enough to conclude,
so it stays for now. **If `suggested` is still 0 at the next tune, cut the proactive-triggers section
of this file outright** rather than leave it as decoration. A documented behavior that has never once
occurred across two full tuning cycles is not a behavior, it is a wish.

Append it as one JSONL line via `scripts\log-recommendation.ps1`. Write the JSON to a temp file first; do not pipe it through shell quoting (embedded quotes in session_synth break `echo '<json>'`):

```powershell
Set-Content -Path $env:TEMP\assistant-log-entry.json -Value '<json here via Write tool, not inline>' 
powershell -ExecutionPolicy Bypass -File C:/Users/ariel/.claude/skills/assistant/scripts/log-recommendation.ps1 -JsonFile $env:TEMP\assistant-log-entry.json
Remove-Item $env:TEMP\assistant-log-entry.json
```

In practice: use the Write tool to create the temp JSON file (avoids all quoting), then run the script with `-JsonFile`, then delete the temp file.

**Logging hygiene, added 2026-09-06 (read this before writing the entry).** `executed` carries **only skill or subagent names**, exactly as they would be invoked. Ad-hoc inline work goes in the `outcomes` text, never in `executed`.

This is not pedantry. Real values found in the log include `git push origin master`, `manual edits`, `phase-1-pdf-fix`, `cleanup-orphaned-helper`, `gbrain-curator-inline`, `promote-harness` and `file-tooling-to-gbrain`. Because chain shapes are mined by joining `executed`, **20 of the 38 shapes since the last tune were unique 1x free-text strings that aggregate into nothing.** Every such entry is a run whose lesson is permanently unavailable to tuning. If a step was done inline rather than by firing the skill, name the skill in `executed` and say "done inline" in `outcomes`.

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

- **Empty session** (Step 1 produced nothing): say so, exit, do not log. **Unless the repo has a `.beads/` queue**, in which case build the chain from `bd ready` and log normally; see the Step 1 exception.
- **User runs /assistant twice in a row with no work between**: detect via session synth being identical to last run. Respond "No new chain to suggest, last chain still in flight" and exit. Do not log.
- **Skill not found in available-skills list**: do not invent skills. If the chain calls for something that doesn't exist, drop that step and note "<skill-name> not installed" in the rationale of the next step.
- **Subagent not found**: same rule. Drop and note.
- **The obvious chain would touch work that is not the user's or not this session's** (uncommitted files from another session, a WIP thread blocked on the user's own pending decision, a repo with no remote that would need creating): do not sweep it in autonomously just because the gate is gone. Name it as out of scope in the synthesis and leave it. "Run without gating" removed the approval prompt; it did not widen scope to other people's or other threads' work.
- **User interrupts mid-chain or redirects incoherently after the fact**: stop, and if the redirect is unclear ask one clarifying question via AskUserQuestion (disambiguation, not a gate). Do not loop forever; do not re-run steps that already ran.

## Reference files

- `references/chain-heuristics.md` — common context-to-chain mappings. Read this on every run during Step 3.
- `references/risky-skills.md` — names + patterns for risk=high classification. Read on every run during Step 3.
- `references/beads-integration.md` — how the beads queue changes chain selection. Read **only when Step 2's `test -f .beads/config.yaml` succeeded**; skip it entirely in a non-beads repo.
