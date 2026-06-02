---
name: job-application
description: Craft a winning, tailored job application end to end using the PROVN methodology re-pointed at a specific role. Use when the user types "/job-application", "/apply", pastes a job description or a LinkedIn/greenhouse/lever job URL and asks to apply, or says "tailor my resume to this role", "write my application", or "craft an application for <company>". Produces a tailored resume, an application email (with the "project I'm proud of" note when asked), and a spec-diff gate proving every JD requirement is addressed with real evidence. Stops before sending.
---

# /job-application — Win a Role From the Playbook

Craft a winning application for a specific role using the methodology hardened on
PROVN challenges, re-pointed from "solve a graded challenge" to "win this job."
A job description is just a spec; grade the application against it the same way.

## Step 0 — Load the playbook (ALWAYS, before anything else)

Read the full playbook now and follow it exactly:

```
C:\Users\ariel\.claude\JOB_APPLICATION_PLAYBOOK.md
```

The Iron Law, the pipeline stages, evidence-grounding rules, send discipline, and
the honesty/framing hard rules all live there. Read the current version each run.

## Step 1 — Resolve the argument

Invoked as `/job-application <arg>` (or `/apply <arg>`). Interpret `<arg>`:

- **A job URL** (LinkedIn / Greenhouse / Lever / company careers page) → fetch the
  live page and capture the JD verbatim. If login-walled, ask the user to paste the
  full text.
- **Pasted JD text** → use it directly as the verbatim spec.
- **A company/role name only** → ask the user for the JD text or URL; do not invent
  requirements.
- **Empty** → ask which role (URL or pasted JD). Don't proceed without it.

State the resolved company + role back in one line, then continue.

## Step 2 — Run the pipeline (per the playbook §2)

1. **Spec capture (Iron Law, §1)** — JD verbatim into context. Then gather the
   candidate's real evidence: GBrain (`mcp__gbrain__query`), LinkedIn profile, the
   live portfolio page (for Ariel: `agor.me/portfolio`), most-recent resume files,
   GitHub, App Store links. Never draft from a summary of either text.
2. **Map** — build the requirement→evidence matrix (STRONG / PARTIAL / GAP).
3. **Solve → Review → Revise (§2 steps 3–5)** — fan out across subagents where it
   helps; every subagent gets the full JD + full evidence pack, never a digest.
   Reviewers: a line-by-line JD grader, an adversarial hiring-manager critic, and a
   truthfulness auditor that flags any claim not in the evidence pack.
4. **Spec-diff gate (§2 step 6)** — grep each JD requirement against the
   deliverables. Every requirement present-with-evidence or honestly-flagged-as-ramp.
   Any silent miss or over-claim is a blocker.
5. **Write deliverables** under
   `C:\Users\ariel\.claude\projects\job-applications\<company-role>\` — `resume.md`
   (+ rendered PDF/DOCX), `application-email.md`, `spec-diff-gate.md`,
   `evidence-pack.md`. Match the playbook §3 structure.

## Step 3 — STOP before sending

After the deliverables pass the spec-diff gate, **stop and get the user's explicit
OK before sending anything** (§5). Confirm recipient address, subject, body, and
attachments in one line. Follow the JD's literal "how to apply" instructions
(recipient, required links, required attachments). Prefer the user's own send unless
they explicitly delegate it.

## Hard rules carried from the playbook

- **Ground every claim in verifiable evidence** — live products, public repos,
  shipped artifacts, real numbers. Never invent a skill, title, date, or metric (§1).
- **Honesty & framing (§6):** be truthful about the AI-native workflow (it's the
  asset for these roles); never claim a traditional-engineer pedigree Ariel doesn't
  have; flag genuine gaps as fast-ramp areas rather than hiding them.
- **Foreground the evidenced stack that matches the JD;** cut aspirational tools the
  JD doesn't ask for (§4).

## Don't

- Don't draft from a summarized JD or a summarized evidence pack.
- Don't auto-send without an explicit go.
- Don't over-claim to fill a requirement slot — flag the gap honestly instead.
