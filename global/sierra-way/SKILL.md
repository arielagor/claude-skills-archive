---
name: sierra-way
description: End-to-end engagement playbook for delivering a Sierra-style customer-experience AI agent to a client. Walks through the 11-item minimum-viable-Sierra-clone blueprint (job-to-be-done, outcome pricing, context engineering, multi-model routing, simulation harness, supervisor + monitor layers, observability, closed feedback loop, release discipline, vertical benchmark, forward-deployed engagement) as a phased delivery framework with checklists, artifacts, client-interview questions, and "done" criteria. Use when scoping or running an agent build for a client, replicating Sierra's approach, planning an FDE-style engagement, or asked "how do I run a Sierra-way build", "agent engagement playbook", "minimum viable Sierra clone", "FDE agent build".
---

# Sierra-Way: Minimum-Viable Sierra-Clone Client Engagement

> A 9-phase playbook for delivering a Sierra-style customer-experience AI agent to a client. Derived from cross-corpus analysis of 84 Sierra blog posts (see `C:\Users\ariel\sierra-corpus.md` §4). The 11 items from the replication blueprint map onto the 9 phases below.

## How to use this skill

When invoked, do one of three things based on what the user asks:

1. **"Start a new engagement"** — walk through all 9 phases in order. At each phase, read the corresponding `phases/<n>-*.md` file, ask the listed client-interview questions, produce the listed artifact(s) into a per-client engagement folder, and stop for confirmation before advancing.
2. **"I'm on phase N"** — load only `phases/<n>-*.md`, run that phase's playbook against existing engagement artifacts.
3. **"Audit this engagement"** — load `phases/audit-checklist.md` and grade an in-flight engagement against the 9-phase rubric. Report which phases are complete, partial, or missing.

Default engagement folder: `~/.claude/projects/sierra-way-engagements/<client-slug>/`. The skill creates and writes there unless the user specifies otherwise.

## The 9 phases

Each phase has one goal, a small set of client questions, an artifact, and a single "done" gate. Don't advance until the gate clears — partial phases compound into unshippable agents later.

| # | Phase | Output | Done-gate |
|---|---|---|---|
| 0 | **Discovery** — find the one job-to-be-done | `00-jtbd.md` | Single sentence: "When [trigger], [persona] wants to [job] so they can [outcome]." Quantified baseline rate exists. |
| 1 | **Commercial structure** — outcome-based pricing | `01-pricing.md` | Outcome unit defined, measurement clock specified, true-up mechanic agreed, escalation cases priced (usually $0). |
| 2 | **Context architecture** — 8 components scaffolded | `02-context-arch.md` + repo | Journeys, Tools, Rules/Policies, Workflows, Knowledge, Memory, Glossary, Response phrasing all exist as code primitives, even if stub. |
| 3 | **Reliability infra** — multi-model router + supervisors | `03-reliability.md` + code | MMR routes between ≥2 providers; supervisor catches one named policy violation in a test; behavior preserved on failover. |
| 4 | **Simulation harness** — personas + LLM judge | `04-sims.md` + sim suite | ≥100 auto-generated test cases from SOPs; LLM judge scores against goal completion; pass^1 and pass^4 both computed. |
| 5 | **Observability** — traces + monitors | `05-observability.md` | Every conversation produces a step trace; ≥3 monitors (looping, frustration, false-transfer) running with reasoning surfaced. |
| 6 | **Feedback loop** — human resolutions → KB | `06-feedback.md` | When a human resolves an escalation, the resolution auto-drafts a KB article for human approval. Loop is closed, not just instrumented. |
| 7 | **Release discipline** — workspaces + immutable snapshots | `07-release.md` + CI | Branch → QA → staging → production gates exist; rollback is one command; every release pinned to model/prompt/KB versions. |
| 8 | **Vertical benchmark** — your-domain-bench | `08-benchmark.md` + repo | ≥10 stateful tasks for the client's vertical, pass^k scoring, leaderboard scaffold, MIT-licensed on GitHub. |
| 9 | **Forward-deployed engagement** — FDE cadence | `09-fde.md` | Weekly cadence locked, escalation matrix written, one named engineer assigned, success-criterion reporting automated. |

## The 11 items mapped onto the 9 phases

The 11-item blueprint from `sierra-corpus.md` §4.10 maps cleanly:

- Item 1 (one vertical, one JTBD) → Phase 0
- Item 2 (outcome-based commercial) → Phase 1
- Item 3 (eight context components) → Phase 2
- Item 4 (multi-model router + hedging + behavior preservation) → Phase 3 (first half)
- Item 6 (supervisor + monitor layers) → Phase 3 (second half) + Phase 5
- Item 5 (simulation harness) → Phase 4
- Item 7 (observability — traces, timing, "why") → Phase 5
- Item 8 (closed feedback loop) → Phase 6
- Item 9 (release discipline) → Phase 7
- Item 10 (open-source vertical benchmark) → Phase 8
- Item 11 (forward-deployed engineer per major customer) → Phase 9

## Hard rules (apply across every phase)

1. **No fabrication of client facts.** When in doubt, ask the client. Do not invent a JTBD, a baseline rate, an SOP, or a metric. If the answer is "we don't know," that *is* the answer — phase 0 stays open until you do.
2. **No skipping phases.** Phase 5 monitors are useless without phase 4 sims to validate them against. Phase 8 benchmarks are useless without phase 0's JTBD to derive tasks from. The order matters.
3. **Verify before declaring done.** Each phase has a "done-gate." Run the gate check — execute the test, count the rows, time the failover — don't trust the artifact alone. Mirror the global rule from `~/.claude/CLAUDE.md` ("Verification Before Claiming Success").
4. **One artifact per phase, versioned.** Every phase produces exactly one numbered markdown file in the engagement folder. Treat these as the immutable record. Subsequent revisions go in `00-jtbd.v2.md`, never overwrite.
5. **Receipts get cited inline.** When the artifact references Sierra's published methodology, cite the slug (e.g., `/context-engineering-the-key-to-great-agents`). When it cites a number, cite the source conversation, run ID, or document.
6. **Pricing alignment is structural.** If phase 1 lands on seat-based or token-based pricing, the rest of the playbook will fight itself. Push back on the commercial structure before building the technical stack.

## Reference artifacts in this skill

- `phases/0-discovery.md` — client interview script for finding the one JTBD
- `phases/1-pricing.md` — outcome-pricing structuring playbook with a sample term sheet
- `phases/2-context-arch.md` — scaffolding the eight context components in code
- `phases/3-reliability.md` — multi-model router design + supervisor pattern
- `phases/4-sims.md` — simulation harness construction with personas + judge
- `phases/5-observability.md` — trace + monitor design
- `phases/6-feedback.md` — closed-loop knowledge ingestion
- `phases/7-release.md` — workspace + snapshot release flow
- `phases/8-benchmark.md` — building the vertical benchmark in the τ-bench mold
- `phases/9-fde.md` — forward-deployed engagement model
- `phases/audit-checklist.md` — grade an in-flight engagement against all 9 gates
- `templates/term-sheet.md` — fillable outcome-pricing term sheet
- `templates/supervisor-prompt.md` — supervisor agent prompt skeleton
- `templates/monitor-spec.md` — monitor definition template
- `templates/sim-task.json` — single simulation task schema (τ-bench-style)
- `templates/release-checklist.md` — pre-release gate

## Done-state of the whole engagement

When all 9 phases are green, the client has:

- A named agent serving one JTBD with a stated success rate against baseline
- A contract that pays Sierra-clone only when the agent succeeds
- A code repo with eight named context components, multi-model routing, supervisors, sim harness, monitors, traces, KB feedback loop, and a release pipeline
- An open-source benchmark for their vertical, on GitHub
- A named FDE on a weekly cadence with a written escalation matrix
- Quarterly evidence that the agent is improving against its own benchmark and the client's success criterion

That is the deliverable. Nothing less is the Sierra way; nothing more is required for the minimum-viable version.
