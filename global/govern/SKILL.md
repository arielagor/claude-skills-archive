---
name: govern
description: Run a large multi-session project under a short constitution, a few laws, task-type rule pools and case law, with typed sessions (orchestrator, executor, research, working, arbiter), a check-in pack per task type, an audit ladder (scripted checks, then a fresh-context Claude auditor, then Gemini/OpenAI/xAI), filed rulings, and recompilation that re-audits only the work whose rules changed. Use when Ariel types "/govern", asks to "set up a constitution / laws / rule base for this project", "govern this project", "run this as orchestrator", "audit this task against the rules", "arbitrate this conflict", "recompile the rules", or starts a project big enough that many sessions will touch it (a long pipeline, dozens of tasks). NOT for a one-session job, where the framework costs more than it returns.
---

# /govern

This is an improved version of Denis Dovgopoliy's "constitution, laws, rule pools" method. Read `references/framework.md` for the twelve changes and the Polis lessons behind them. Read `references/contracts.md` for every file format.

The CLI is deterministic. Judgment comes from you and from subagents following the role files.

```
G="node $HOME/.claude/skills/govern/scripts/govern.mjs"     # every command takes --root <repo>, default cwd
```

## When to use, and which size

- **Lite:** one constitution, at most 2 laws, 6 files, audit levels 0 and 1. For a project of a few weeks.
- **Standard:** the default. Up to 10 laws, 20 files, and level 2 on tasks briefed `--risk high`.
- **Full:** level 2 on every task. For work where a defect is expensive (money, customers, published claims).

Do not use it for a single session. When the governance load passes the work, `status` says so; then stop adding rules.

## Setting up a project (`/govern init`)

1. Read the project's `CLAUDE.md`, `README`, `docs/decisions/` and any existing gates or checklists. Most of the constitution already exists in those files, scattered.
2. Ask Ariel only what those files do not answer. That is at most seven questions, and usually fewer.
3. Run `$G init --size <lite|standard|full> --project <name>`. It writes `governance/` and adds the orchestrator pack import to `CLAUDE.md`.
4. Draft `CONSTITUTION.md` in invariants only, under the byte budget. Draft at most three laws from `references/templates/law.md`. Convert every rule a script can decide into `enforce: check` with a script in `governance/checks/`. Write no pools yet.
5. Add the routes to `govern.json`. Run `$G lint` and `$G compile` until both are clean.
6. Commit on a branch and land by PR.

## The task loop (orchestrator)

The orchestrator session does no artifact work itself.

1. `$G status` shows the outcomes and whether a recompile is due.
2. To brief a task, run `$G brief --type <task type> --goal "..." --done "..." [--done ...] [--input ...] [--out-of-scope ...] [--risk high] --out brief.md`. Then launch the executor with `Agent` (`model: sonnet`, `subagent_type: general-purpose`) and the brief file's content as the prompt, unchanged.
3. Save the reply to a file and run `$G record T-NNNN --result reply.md`. Act on any `NEEDS ARBITRATION` line before accepting.
4. `$G audit T-NNNN` runs the policy levels in order and stops at the first failure.
   - **Level 0** runs the check scripts.
   - **Level 1** is a fresh-context Opus auditor through lean-claude.
   - **Level 2** goes to other providers through crossfamily-council. Read `families used` in the output. Fewer than two parsed families gives verdict `error`, never `pass`.
5. **On a failure**, re-brief or send the findings back to the executor, then record and audit again. **On a false alarm**, run `$G overturn T-NNNN --rule <id> --reason "..."`, which feeds the false-alarm rate.
6. `$G accept T-NNNN` refuses while any audit the policy requires is missing or failing, or while a law-level question has no ruling. Use `--override "reason"` only with a reason you would put in front of Ariel.

Research and working sessions take `$G pack --type research` or `--type working` as their check-in. They produce findings, never artifacts, so they skip audit.

## Questions: triage, never stall

- **Subject level:** assume, record it, continue.
- **Instruction level:** continue, record it, raise it.
- **Law or constitution level, or anything irreversible:** stop that part and arbitrate.

## Arbitration

Follow `references/roles/arbiter.md`.

- **Pool or law question:** decide it by precedence, then run `$G arbitrate --question ... --level pool|law --decision ... --route <r> --rules <ids> --task T-NNNN`.
- **Constitution question:** run `--level constitution`. The `/council` decides it, the ruling lands by PR in the project, and Ariel gets a two-line summary afterwards. This was his choice on 2026-11-13.
- **Money, customers or irreversible steps:** never arbitrated. They go to Ariel.

When a route collects its second open ruling, the CLI says to create its pool.

## Recompile

Run it when `status` says it is due, or after any batch of rulings.

1. `$G recompile [--deep] --reaudit` lints (with `--deep`, one LLM contradiction pass), compiles, and diffs rule ids. It re-audits, at levels 0 and 1, only the tasks whose pack held a changed rule, and writes `governance/build/recompile-report.md`.
2. Apply the proposals by hand: fold rulings into rules and set them to `folded`, create the proposed pools, and delete rules nobody cites. Then recompile again.
3. Land it by PR.

## Don't

- Don't edit `governance/build/` or `ledger.jsonl` by hand. Both are generated or append-only. Do commit them, because `CLAUDE.md` imports the orchestrator pack.
- Don't write rules for problems that have not happened yet. A rule needs a `why`, and a pool needs two rulings behind it.
- Don't let an executor touch the rule base, or an auditor fix the work it audited.
- Don't run governance as its own scheduled process. It runs when a session working on the project calls it. Polis died of the opposite.
- Don't count a check rule as enforced until `status` lists it as proven by a real failure.

## Files

- `scripts/govern.mjs`: the CLI. Its header lists every command and flag.
- `scripts/lib/*.mjs`: the library, one stage per file.
- `references/roles/`: the role instructions embedded in the packs.
- `references/templates/`: the constitution, law, pool and check-script templates.
- `test/`: run `npm test` here. The LLM, council and provider calls are stubbed, so the tests cost nothing.
