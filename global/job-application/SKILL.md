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

**Embedded ATS forms (Greenhouse / Lever / Ashby) usually can't be filled or
submitted by browser automation** — cross-origin iframe + native file-picker for the
required résumé. The apply/submit is the user's; pre-fill only what you can verify,
hand off a field guide + résumé path, and never blind-submit a form you can't read.
Try the canonical top-level board URL first. See playbook §5.

## Hard rules carried from the playbook

- **Ground every claim in verifiable evidence** — live products, public repos,
  shipped artifacts, real numbers. Never invent a skill, title, date, or metric (§1).
- **Honesty & framing (§6):** be truthful about the AI-native workflow (it's the
  asset for these roles); never claim a traditional-engineer pedigree Ariel doesn't
  have; flag genuine gaps as fast-ramp areas rather than hiding them.
- **Foreground the evidenced stack that matches the JD;** cut aspirational tools the
  JD doesn't ask for (§4).

## Rendering gate — extract the text layer and read it back (added 2026-08-29)

**A resume PDF that looks perfect can fail an ATS keyword search invisibly.** Two font bugs found
the hard way, both of which would have shipped:

- **Georgia SILENTLY DROPS SEMICOLONS** from the PDF text layer, turning every semicolon-delimited
  skills line into run-on prose for a parser. Times New Roman does it too.
- **Cambria / Calibri / Constantia / Palatino map the ASCII hyphen to U+2011** (non-breaking hyphen),
  so `OpenAI-compatible`, `full-stack` and `retrieval-augmented` stop matching a recruiter's search.

Only **XCharter** (a proper resume serif, ships with MiKTeX), TeX Gyre Pagella/Termes, and Carlito
get both right. Use:

```latex
\setmainfont{XCharter}[Extension=.otf, UprightFont=*-Roman, BoldFont=*-Bold,
                       ItalicFont=*-Italic, BoldItalicFont=*-BoldItalic, Ligatures=TeX]
\hyphenation{Cloudflare OpenAI TypeScript PostgreSQL ...}  % a line-broken keyword does not match
```

**Never ship without running the actual ATS simulation:**

```bash
pdftotext -layout -enc UTF-8 resume.pdf - > extracted.txt
# assert every JD keyword is present in WHITESPACE-NORMALIZED text (line wraps split phrases),
# and that the only non-ASCII chars are bullet / en-dash / apostrophe
```

Also: `\MakeUppercase` inside `\titleformat` breaks modern titlesec (`Use of \ttl@row@i doesn't
match its definition`) — write section names in caps instead. Use `|` not `\textbullet` for header
separators. Details: [[feedback-latex-resume-fonts-break-ats-extraction]].

**Format is a parsing constraint, not a style choice.** Agencies re-key into Bullhorn/JobDiva/Ceipal
and reformat onto their own letterhead, which is why they want **Word**. Ship a single-column `.docx`
alongside the PDF, with contact details in the BODY (parsers drop headers/footers), no tables, no
columns, no icons, no text boxes.

## Don't

- Don't draft from a summarized JD or a summarized evidence pack.
- Don't auto-send without an explicit go.
- Don't over-claim to fill a requirement slot — flag the gap honestly instead.
- **Don't claim GBrain as something Ariel built.** The engine is Garry Tan's open-source project
  (`github.com/garrytan/gbrain`, **0 commits by Ariel**); several older resumes get this wrong. His
  are `arielagor/gbrain-infra` (the ~60-script ingestion/enrichment/reliability layer) and
  `arielagor/brain` (158/161 commits). Correct phrasing and the general rule (check `git remote -v`
  before naming a system — heavy use is not authorship): [[feedback-gbrain-engine-is-garrytans-not-ariels]].
- **Don't cite `receptionist-bench` benchmark numbers** — its own README says they are placeholders.
- **Don't claim Python at scale.** Of 8,244 `.py` files, ~7,678 are vendored; authored Python is
  ~60 files. "Working Python" is the honest ceiling.
