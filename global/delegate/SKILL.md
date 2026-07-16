---
name: delegate
description: Route self-contained subtasks to cheaper/faster models via the modelmix router (mix CLI), with live cost/usage attribution in the statusline and mix dash. Use when Ariel says "/delegate", "delegate this", "route this to a cheaper model", "farm this out", or when a task decomposes into independent summarize/extract/classify/bulk-transform/first-draft subtasks that don't need the orchestrator's full context. The orchestrator (you) stays on Claude; subtasks route across Gemini, GPT (Codex plan), Grok, and local Ollama models by quality-per-dollar.
---

# /delegate — route subtasks across the model fleet

You are the orchestrator. modelmix routes self-contained subtasks to the best
quality-per-dollar model and logs every call to a ledger that powers the
statusline mix (e.g. `Fable 12% | gem-flash 55% | qwen 33% | saved $0.83`)
and the `mix dash` TUI.

The router CLI (always invoke with bun.exe by absolute path):

```bash
bun "C:\Users\ariel\.claude\projects\modelmix\src\cli.ts" <command> ...
```

## When to delegate

Delegate a subtask when ALL hold:
- Self-contained: a clear input → output contract, everything the model needs
  fits in the prompt you send it.
- No repo writes: the subtask produces text you will integrate yourself.
- Type maps to cheaper capability: summarize, extract, classify, bulk
  transform, first-draft prose, test-data generation, format conversion.

NEVER delegate:
- Architectural decisions or anything requiring judgment about this codebase.
- File edits (routed models have no tools — they return text only).
- Final review of your own delegated output (you verify; don't outsource the check).
- Anything needing conversation context you can't paste into the prompt.

## Workflow

1. **Create a parent task** (groups subtasks in the dashboard):

```bash
TASK_ID=$(bun "C:\Users\ariel\.claude\projects\modelmix\src\cli.ts" task new "review auth PR")
```

2. **Write each subtask prompt to a temp file** (avoids shell-quoting hell with
   multi-line prompts), then dispatch:

```bash
bun "C:\Users\ariel\.claude\projects\modelmix\src\cli.ts" run \
  --type summarize --latency background \
  --parent "$TASK_ID" --stdin < "$TMPDIR/subtask1.md"
```

- `--type`: summarize | extract | classify | codegen | review | search | bulk | reason | general
- `--latency background` admits slow local (free) models — use it whenever you
  don't need the answer in the next few seconds. `interactive` excludes them.
- `--json` wraps the result in `{task_id, model, tokens, cost_usd, output}`
  when you need the routing metadata.
- `-m <model>` forces a specific model (see `mix models`) — use sparingly;
  the policy is usually right.
- Session attribution is automatic via the cwd pointer written at session
  start; there is no need to pass `--session`.

3. **Fan out in parallel** — dispatch independent subtasks as separate Bash
   calls with `run_in_background: true`, then collect results as they finish.
   The dashboard groups them live under the parent task.

4. **Integrate and verify yourself.** The cheap models have a real quality
   floor. Read every delegated output before using it; redo anything weak
   yourself (that's still a net win — you spent zero context on the drafts).

## Quick reference

```bash
bun "C:\Users\ariel\.claude\projects\modelmix\src\cli.ts" doctor        # provider health
bun "C:\Users\ariel\.claude\projects\modelmix\src\cli.ts" models -t summarize  # roster + scores
bun "C:\Users\ariel\.claude\projects\modelmix\src\cli.ts" run --dry -t classify "..."  # routing preview, no spend
bun "C:\Users\ariel\.claude\projects\modelmix\src\cli.ts" report --today       # spend/saved summary
```

Routing policy: quality-weighted (capability − quotaPenalty − λ·cost). Claude
calls bill the Max plan ($0, ANTHROPIC_API_KEY stripped), GPT via Codex bills
the ChatGPT plan ($0 marginal), Gemini/Grok bill per-token API, Ollama is
local/free and background-only. Every attempt (including failures) lands in
`~/.modelmix/ledger/` — nothing is invisible.
