---
name: provn
description: Solve a PROVN AI Talent Draft challenge end to end using the hardened playbook. Use when the user types "/provn", "/provn <N>", "/provn <challenge-url>", or asks to start/solve/run a PROVN challenge. Loads the full methodology so a fresh context window picks up without re-onboarding.
---

# /provn — Run a PROVN Challenge From the Playbook

Solve a PROVN AI Talent Draft challenge end to end using the methodology hardened across
the 14-challenge run. This skill exists so a fresh context window can start a challenge
without the user re-pasting the methodology.

## Step 0 — Load the playbook (ALWAYS, before anything else)

Read the full playbook now and follow it exactly:

```
C:\Users\ariel\.claude\PROVN_PLAYBOOK.md
```

Everything that governs how to solve a challenge — the Iron Law, the pipeline stages,
HeyGen rules, upload gotchas, framing rules, secrets hygiene — lives in that file. Do not
work from memory of it; read the current version each invocation (it gets updated as new
lessons land).

## Step 1 — Resolve the argument

The skill is invoked as `/provn <arg>`. Interpret `<arg>`:

- **A number** (e.g. `96`) → challenge **96**. Derive the live URL as
  `https://provn.co/challenges/<N>` and confirm it resolves; if that path 404s, open
  `https://provn.co/challenges` and find the card for challenge `<N>`.
- **A full URL** (e.g. `https://provn.co/challenges/...`) → use it directly.
- **Empty** (`/provn` with no arg) → ask the user only one thing: which challenge number or
  URL. Do not proceed without it.

State the resolved challenge number + URL back to the user in one line, then continue.

## Step 2 — Run the pipeline (per the playbook §2)

Follow `PROVN_PLAYBOOK.md` §1–§9. In order:

1. **Fetch the literal spec first** (Iron Law, §1). Save the verbatim requirements into
   context before writing anything. Pass the full spec text to any solver subagent — never
   a summary.
2. Pick the role archetype to emulate (best version of that role in the world).
3. Solve → independent reviewer → revise (§2 steps 2–4). Fan out across subagents where it
   helps; every subagent gets the verbatim spec.
4. **Spec-diff gate (§2 step 5)** — grep each requirement against the deliverables; any
   miss is a blocker. Do not declare progress past this gate with a miss.
5. Match the existing folder structure under
   `C:\Users\ariel\.claude\projects\provn-challenges\` — create `NN-short-slug/` with the
   primary deliverable, `ai-usage-log.md`, `video-script.md`, `video-metadata.json`, plus
   code/tests/config/data. Add the README table row and keep the challenge count accurate.
6. **HeyGen video (§4)** — render exactly ONCE, 720x1074 portrait, no preamble, no
   em-dashes, target length per the spec. Ask before any second render (it costs money).

## Step 3 — STOP before uploading

After deliverables pass the spec-diff gate and the video is ready, **stop and get Ariel's
explicit OK before uploading to provn.co** (§5). Uploading is the irreversible, outward
step. When cleared, follow §5 for the per-deliverable upload slots, the
"video-not-detected" resubmit loop, and the Ch94 filetype workaround. Capture each
grader's verbatim response for refinement.

## Hard rules carried from the playbook

- Repo `arielagor/provn-challenges` is **public** — grep every diff for secrets before any
  push; never let the HeyGen key land in a committed file (§6).
- **Ariel is not an engineer** — never frame him as one in any deliverable, video script,
  or email (§7).
- Default deliverable format is `.md` unless the spec demands otherwise; skip LaTeX/PDF
  unless a doc genuinely needs it.

## Don't

- Don't summarize the spec and solve from the summary.
- Don't auto-upload without an explicit go.
- Don't re-render HeyGen for minor defects — fix in post, or ask first.
