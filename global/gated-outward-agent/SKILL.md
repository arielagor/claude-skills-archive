---
name: gated-outward-agent
description: |
  Build an autonomous agent that ACTS on the outside world on Ariel's behalf
  (sends email, places calls, fills web forms, posts) safely. Use when the task
  is "build an agent that emails/replies/acts on my behalf", "autonomous reply
  agent", "always-on triage agent", "outward-facing agent", or anytime an agent
  will take a real outward action on a schedule or webhook. Encodes the gated
  build+arm recipe (OFF -> DRAFT -> LIVE), the escalate-not-block safety gate,
  the structural never-act class, idempotency under a scheduler, the claude -p
  LLM seam, and the send-path proof. Reference implementation: the Chief of Staff
  inbox agent (arielagor/chief-of-staff).
author: Claude Code
version: 1.0.0
date: 2026-06-16
---

# Build a gated outward-acting agent

## Problem

An agent that sends email / calls / fills forms / posts on Ariel's behalf can
create real incidents the moment it goes live: a wrong reply to a client, a
double-send, a commitment made in his name, a reply to a spoofed sender. The job
is not "be careful." It is to build **structural seams** so the unsafe action is
impossible until an explicit human go, and even then is bounded and reversible.

## When to use

- Building any agent that takes an outward action (email, voice, web, social) on
  a schedule or webhook.
- Wiring a new auto-action path into an existing live agent.
- A client demo of "an intelligence layer that triages decisions and acts on the
  safe ones" (the Veruna / FDE pitch).

## The recipe (build inert, arm in stages)

This sequence is the deliverable. Each step PROVES the next is safe before taking
it. Do not skip ahead. (Full lesson: `feedback_gated_outward_agent_build_arm_recipe`.)

1. **Build the whole pipeline in OFF.** A 3-rung `.env` mode flag read from the
   cron's `.env`, default OFF: `OFF` (inert, the entry point exits immediately on a
   normal run) -> `DRAFT` (reads + decides + produces the artifact for review,
   acts on NOTHING) -> `LIVE` (acts, whitelist + safe-class only). Flipping the
   mode is a one-line edit the human owns; the cron picks it up with zero code
   change. (`feedback_autonomous_outward_agent_gated_activation_and_escalation`.)
2. **Mock tests green first.** Inject the LLM and the transport/inbox as seams so
   the decision stages are testable with a scripted LLM + a mock adapter. Put the
   safety-critical behaviors under explicit tests: the never-act class never acts,
   idempotency (no double-action on re-run), the rate-limit breaker, escalation
   firing, the kill switch, read-only no-side-effects.
3. **One read-only run against REALITY.** A `--read-only` flag that does NO side
   effects, exercising the real classify/decide on live data. Mocks never catch
   classification drift; reality does.
4. **Flip to DRAFT on the real target.** Real artifacts for review (e.g. Gmail
   drafts) + a real digest, zero outward actions. Verify one write path concretely.
5. **Arm LIVE only on an explicit human "arm it".** The FIRST live action is a
   single action directed AT THE PRINCIPAL HIMSELF, routed through the EXACT
   production path the real actions use (not a bypass), then immediately repeat to
   prove idempotency (the re-run does nothing). Verify the action actually
   happened (e.g. the email landed), not just a success code.

## The safety gate (escalate, do not just block)

Build a single deterministic gate that every action passes through. On ANY doubt
it escalates to the human or downgrades to draft, never acts. Checks, in order:

- **Kill switch** (`<PREFIX>_KILL=1` or a `data/KILL` file) -> halt all actions.
- **Mode** -> only LIVE acts; otherwise downgrade to DRAFT.
- **Whitelist + scope** -> acting is impossible for any recipient/target not on an
  explicit allowlist file, and only for narrow safe scopes.
- **Never-act class (STRUCTURAL)** -> a deterministic scan (NOT the LLM alone) for
  the classes that must never auto-act: pricing, contract, scope, legal,
  signature, commitment, conflict, press, investor relations, unknown
  first-contact. Union it with the model's output. False positives are safe
  because they only downgrade. The model can make you more cautious, never less.
- **Sender/source verification** -> a spoofed or auth-failed source is never acted
  on (check SPF/DKIM for email).
- **Output safety sweep** -> voice/vocab/fabrication checks; any ungrounded factual
  claim (a number/date/amount not traceable to the source or a context card) is a
  possible fabrication and escalates.
- **Rate limit + circuit breaker** -> caps per hour/day; on breach, halt + switch
  to DRAFT + escalate.
- **Quiet hours** -> no action outside the recipient's local business hours.
- **Veto window** -> queue the action with a short delay + push a preview; the
  human can kill it before it fires. A later run flushes matured, non-vetoed items.

Every item gets an append-only audit record: what it saw, the decision, the route,
the confidence, what it did or drafted, and why.

## Stack seams (reuse the proven ones)

- **LLM = `claude -p` on the Max plan.** Strip `ANTHROPIC_API_KEY` + cloud flags
  from the spawn env; `stdio: ["ignore","pipe","pipe"]`; pin `--model` (Fable 5 ->
  Opus 4.8); parse the first balanced `{...}` (never line-1-only); `taskkill /T /F`
  on win32; `--disallowedTools Write,Edit,Bash,...` for text-only calls.
  (`feedback_claude_p_subprocess_ignore_stdin_pin_model`, `feedback_model_fallback_fable_then_opus`.)
- **Idempotency under a scheduler.** Guard the WORKER process with a node pid+ts
  lockfile (fail-open), NOT the Task Scheduler `IgnoreNew` setting (a detached
  launcher exits instantly and defeats it). Non-destructive seen-state + merge-on-
  save. (`feedback_detached_launcher_defeats_ignorenew_use_node_lock`.) Register
  the task to run the worker SYNCHRONOUSLY (`cmd /c run.cmd`), not via a detached
  `.vbs`/`start`.
- **Email send = SMTP/Nodemailer only**, from `ariel@agor.me`, always CC
  `ariel.agor@gmail.com`, App Password from `~/.claude/developer-accounts.md` (the
  `.env` can go stale; re-read the `.md` on a 535). No em-dashes ever; "I" not
  "we". (`send-email-on-behalf-of-ariel`, `feedback_no_em_dashes_in_emails`.)
- **Gmail read/label/draft** without the googleapis SDK: raw Gmail REST + `fetch`
  using the gbrain OAuth tokens (`gmail.modify`).
  (`reference_gmail_rest_adapter_via_gbrain_tokens`.) The Gmail MCP can read/label/
  draft but CANNOT send.
- **Personal-date guard** for any scheduling reply: never propose a blocked date;
  June 16 (Kai's birthday) is a hard rule and is NOT on the calendar.
  (`kai-birthday-june-16`, `feedback_calendar_clear_not_sufficient_for_slots`.)

## Verification

The agent is "done" only when: tests are green, a read-only run produced correct
decisions on real data, a DRAFT run produced reviewable artifacts, and (if armed)
the first LIVE action was a verified self-directed action through the production
path with a proven no-double-action re-run. Verify the action landed, not the
exit code.

## Example

The Chief of Staff inbox agent (`arielagor/chief-of-staff`,
`~/.claude/projects/chief-of-staff`): named-stage pipeline POLL -> CLASSIFY ->
ENRICH -> ROUTE -> COMPOSE -> GATE -> SEND/QUEUE -> EXTRACT -> DIGEST -> LEARN, 37
tests, armed to LIVE 2026-06-16 with a verified self-send + idempotency proof. Its
`docs/decision-graph.md` is the client-demo artifact.

## Notes

- Keep the architecture legible + portable: swap the inbox/transport adapter and
  the context source and the same decision graph runs over any decision stream
  (support tickets, invoices, lead routing). That portability is what makes it a
  client demo, not just personal infra.
- A context card per VIP (relationship, deal state, timezone, comms prefs, open
  commitments, do/don't rules) is the differentiator: ground every output only in
  the source + the card.

## See also

- `sierra-way` skill — delivering a customer-experience agent to a CLIENT (broader
  engagement playbook; this skill is the build+arm mechanics for a self-acting one).
- `claude-code-binding-governance-hook` skill — when the gate must be a hook that
  actually blocks, not in-process logic.
- Memories: `feedback_gated_outward_agent_build_arm_recipe`,
  `project_chief_of_staff_agent`,
  `feedback_autonomous_outward_agent_gated_activation_and_escalation`.
