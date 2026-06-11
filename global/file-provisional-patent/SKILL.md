---
name: file-provisional-patent
description: |
  End-to-end methodology to take an invention idea to a FILED US provisional patent
  application (35 U.S.C. 111(b)) via USPTO Patent Center, piloted with claude-in-chrome.
  Use when: (1) Ariel wants to patent a device/idea or "file a provisional", (2) reverse-
  engineering/inverting an existing patent into a new one, (3) driving USPTO Patent Center
  (account creation, ID.me, self-enrollment, Web ADS, document upload, micro-entity fee,
  submit). Covers the full pipeline (prior-art search -> patentability/council go-no-go ->
  design+adversarial-verify -> figures -> nonprovisional-quality draft+claims -> examiner-
  critic review -> file) AND the Patent Center mechanics + every hard-won gotcha (CSP blocks
  page-side file injection, OneDrive-Desktop picker, session-timeout logout, micro-entity
  fee on the fee page not the ADS, provisional needs no DOCX, SB/15A = Gross Income Basis).
  Not legal advice; pro se assistance. Human owns ID.me, final Submit, and payment.
author: Claude Code
version: 1.0.0
date: 2026-06-10
---

# File a US Provisional Patent (pro se, via Patent Center)

First proven run: deflate-valve -> US Provisional **64/087,364** filed 2026-06-10, $65 micro, in one session (most of it while Ariel slept). Worked example repo: `~/.claude/projects/deflate-valve`.

## Problem
Turning an invention idea into a filed provisional normally means coordinating a search firm, an engineer, an illustrator, a patent attorney, and a paralegal over weeks, for ~$12-22K. This skill compresses it: Claude does the labor and pilots the filing; the human supplies judgment and the three irreversible clicks. **Not legal advice. Recommend a registered practitioner before the 12-month nonprovisional conversion.**

## The pipeline (each phase gates the next)

1. **Prior-art search + patentability** (personas: searcher, examiner-adversary). Fan out 2-3 parallel research agents over: the source patent family (pull verbatim independent claims from Google Patents), the deflation/adjacent art, and the make-or-break specific combination. Build a novelty matrix; write a patentability memo with an HONEST risk rating. **Surface the bad news first** — the broad concept is usually old; find the narrow surviving novelty.
   - **HARD CHECKPOINT: present the memo, get go/no-go before drafting.** When the decision is debatable, run `/council` (it went unanimous "GO valve-per-se" on the proven run).
2. **Design + engineering** (inventor, mechanical/fluids + food-safety engineer). Functional spec with parameterized dimensions/ranges. Then an **adversarial-verify pass** (a skeptical senior-engineer agent) BEFORE drafting — on the proven run it caught a FATAL physics error (you can't evacuate a slider bag mid-zip; the open zipper ahead of the slider is a giant leak). Apply the fixes into the design.
3. **Figures** — generate line drawings programmatically (Python + matplotlib/SVG -> PDF), black & white, numbered reference characters matching a shared numeral table. Informal drawings are fine for a provisional; still target 37 CFR 1.84 conventions. ~8-10 figures. For draftsman-grade figures from real 3D CAD geometry (hidden-line removal, true sections, exploded/orthographic views + a manufacturable STEP), use `[[cad-patent-drawings]]` instead of flat matplotlib schematics.
4. **Draft at nonprovisional quality** (drafter + independent examiner-critic). Full spec: Field, Background (minimal admissions), Summary, Brief Description of Drawings, Detailed Description covering ALL embodiments + ranges, plus a draft claim set (claims aren't required for a provisional but discipline the disclosure and ease conversion). Then a **hostile examiner-critic agent** review — on the proven run it caught an admission-against-interest in the Background and a claim that limited an unclaimed element. Apply fixes.
   - A provisional protects ONLY what is disclosed — disclose broadly, with ranges.
   - **HARD CHECKPOINT: human reviews the final package PDFs before filing.**
5. **File via Patent Center** (below).

Render PDFs with the proven recipe: `pandoc spec.md -o spec.pdf --pdf-engine=xelatex -V mainfont="Calibri" -V geometry:margin=1in`.

## Patent Center filing (claude-in-chrome) — the mechanics + gotchas

**Forms:** the Web ADS (auto-generated) doubles as the §1.51(c)(1) cover sheet — no separate SB/16 needed. Micro entity certification = **form SB/15A** (download blank from uspto.gov, fill via PyMuPDF, sign).

**Account prerequisites (one-time, HUMAN does these — Claude never types credentials):**
- Create USPTO.gov account at `account.uspto.gov/profile/create-account`.
- **ID.me identity verification** (SSN + gov photo ID + selfie; ~15-30 min, interactive). Profile must show "ID.me Verified".
- After verifying, **refresh the session** (visit my.uspto.gov then back to patentcenter) — then Patent Center shows "Complete self-enrollment". Self-enroll as **Independent Inventor**, "No" existing customer numbers, accept the Subscriber Agreement (18 U.S.C. 1001 cert — human checks the box).

**The filing flow** (`New submission -> Utility-Provisional -> Web ADS`):
- **Inventors:** legal name from ID.me (e.g. middle name included). Residence + mailing address — see the `[[ariel-mailing-address]]` memory.
- **Application details:** Title; **Entity status = Small** here (the ADS dropdown only offers Regular/Small — Micro is selected later on the FEE page); drawing-sheet count. Leave "Filing by reference" UNchecked.
- **Correspondence:** physical address (country = "UNITED STATES OF AMERICA").
- Representatives/Applicant/Assignee: skip (pro se). First-inventor-to-file: leave unchecked unless it's a transition app. Authorization-to-permit-access: leave defaults.
- **Signature:** S-signature `/Ariel Agor/` (forward slashes) is USPTO-standard and binding under 37 CFR 1.4(d)(2) — see `[[ariel-s-signature-authorization]]`. (Handwritten-image signatures also valid but unnecessary; if used, overlay via PyMuPDF onto the field rect.)
- **Upload documents:** specification PDF (auto-classifies as Specification), drawings PDF (classify "Drawings-only black and white line drawings"), **SB/15A (classify "Certification of Micro Entity (Gross Income Basis)"** — NOT Education Basis). The signed ADS is already attached.
- **Calculate fees:** select **Micro** entity here; enter total page count (spec + drawings); check ONLY fee **3005 PROVISIONAL APPLICATION FILING FEE $65.00**. Leave 3091/3092 (DNA/protein sequence-listing fees) unchecked. Total should read $65.00.
- **Review & submit:** verify everything.
- **HARD CHECKPOINT: human personally clicks Submit and pays.** Claude never clicks final pay. Capture the Application #, Confirmation #, Patent Center #, and BOTH receipts (Acknowledgement + Payment) immediately.

### Gotchas (each cost real time on the first run)
- **File upload: page-side injection FAILS on Patent Center's CSP.** `mcp__claude-in-chrome__file_upload` rejects host paths; base64-inline is too big for context; localhost-fetch is blocked by `connect-src` and HANGS (CDP 45s timeout, looks like a frozen renderer). **Use the native Browse picker** (human operates) and stage files to **BOTH** `Desktop\` AND `OneDrive\Desktop\` — Windows shows the OneDrive-redirected Desktop, so files only on the literal Desktop are invisible ("I don't see them"). See `[[strict-csp-file-upload-native-picker]]`.
- **Session timeout = silent logout.** Long pauses (e.g. a hung file fetch) trip the idle timer; the "Your session may have timed out -> Continue" dialog logs you OUT. The draft auto-saves; just re-login (my.uspto.gov -> Log in) and reopen the submission URL. Don't panic — nothing is lost.
- **Provisional needs NO DOCX and NO surcharge.** The "must be DOCX or pay up to $400" notice applies to **nonprovisional** utility apps only. Provisional = PDF, no surcharge.
- **Micro entity** isn't in the ADS entity dropdown (only Regular/Small) — pick Small in the ADS, then **Micro on the fee page**. Qualify: gross income < ~3x median household (~$241K), named on < 5 prior US non-provisionals, no obligation to assign to a non-qualifying entity.
- **Don't trust submit success blindly** — verify against the on-screen Electronic Payment Receipt ("Your payment has been received") and save both receipt PDFs. Re-check the Patent Center workbench next day for the assigned filing date.

## Verification
- On-screen Payment Receipt shows the application number + "payment received".
- Both receipt PDFs saved to the repo `filing/` dir.
- Next day: app appears in Patent Center workbench with a filing date; official filing receipt issued.

## Post-filing (don't skip)
- **Docket the 12-month conversion deadline** (filing date + 1 year): nonprovisional or PCT claiming priority, else priority is lost. Month-9 review reminder. Recommend practitioner review before conversion.
- File a GBrain `projects/` page + memory + MEMORY.md + `docs/decisions/` entry (per the infra-filing rule).
- Mark products "Patent Pending" only AFTER the acknowledgement receipt exists.

## Notes
- This is pro se drafting assistance, not legal advice.
- The value of a provisional = the quality of its disclosure; that's why we draft to nonprovisional standard.
- FTO != patentability: the source family will be a §103 obviousness reference against the new claims; lead novelty on the specific construction, not the broad concept.

## References
- USPTO fee schedule (provisional micro = $65, fee code 3005): uspto.gov/learning-and-resources/fees-and-payment/uspto-fee-schedule
- Getting started / ID.me / self-enrollment: uspto.gov/patents/apply/applying-online/getting-started-new-users
- 37 CFR 1.4(d) (signatures), 1.51(c)(1) (provisional cover sheet), 1.84 (drawings), micro entity 37 CFR 1.29
- Worked example: `~/.claude/projects/deflate-valve` (memo, spec, figures, filing receipts) and `[[deflate-valve-provisional-filed]]`
- Drawings sub-skill: `[[cad-patent-drawings]]` — build123d -> hidden-line draftsman figures + STEP (the figures step's heavy-lift path)
