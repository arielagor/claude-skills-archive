---
name: yjnote
description: Write a YunoJuno application cover note that fits the hard 1000-character box, from a pasted job description. Use when Ariel types "/yjnote", pastes a YunoJuno brief and asks for a cover note, or says "write the cover note for this", "yj note for this brief", "turn this JD into a cover note". Routes the brief to the right live demo artifact, checks every employment claim against CAREER-SOURCE-OF-TRUTH.md, drafts TO the cap rather than trimming down to it, measures before presenting, and hands back one paste-ready block.
---

# /yjnote — YunoJuno cover note, built to the box

Ariel pastes a job description. This skill hands back one block he can copy straight into
YunoJuno's "Cover note (Optional)" field, already measured against the cap, with every claim
sourced.

The output is the note. Not a plan to write a note, not three options to choose between.
One note, paste-ready, with the character count stated.

## The constraint that determines everything

**The box is a hard 1000-character cap.** Measured 2026-09-10 by pasting a 5,439-char draft
into the live field and counting what survived: it truncated mid-word at exactly 1000
characters (UTF-16 length). No warning, no counter, no ellipsis. It simply cuts.

**1000 chars is 155 to 165 words. That is one idea, one proof, one link.** It is not a cover
letter and must not be written like one.

**Draft TO the cap. Never draft long and trim.** The first note ever written for this box was
945 words and 80% was discarded, which produced a worse note than starting at 160 words. A
trimmed long draft reads like a summary. A note written at 160 words reads like a position.

Target **940 to 985 characters**. Leave at least 15 chars of headroom, because some paste
paths convert straight quotes to curly ones and a few characters shift.

## What survives the cut, in priority order

1. **One line proving the post was actually read.** Quote or name the specific thing in the
   brief that reveals the real problem. Not the responsibilities list, which is boilerplate.
   The tell is usually one phrase the client wrote themselves.
2. **The single strongest insight, concrete, with a real number.** A mechanism, not an
   adjective. "It is a hash diff" beats "rigorous governance".
3. **One live, clickable URL.** The only thing they can verify in a click.
4. **One honest limit.** Buys more credibility per character than any claim, and pre-empts
   the objection they would otherwise raise without telling you.
5. **Real employment history compressed to a single clause.**

**Cut first:** the pipeline restated back to them, second examples, methodology, anything
they already know, and any sentence about how excited he is.

## Steps

### 1. Read the brief for the hook, not the requirements

Extract, in this order:

- **The client's own words.** YunoJuno briefs are usually written by the hiring company, not
  a recruiter, so there is normally one sentence that names their actual pain. Find it.
- **The disciplines or teams listed.** The interesting question is which one is the *gate*
  the others queue behind. Naming that is the fastest proof the post was read.
- **Sector and regulatory regime** (pharma/MLR, financial promotions/FCA, health data, etc.).
- **Contract shape:** rate, duration, start date, part-time vs full-time, remote, UK vs EU.
- **Named tools** (Jira, Smartsheet, MS Project, TFS). Mention at most one, and only if he
  has genuinely used it.

If the brief is thin boilerplate with no hook, say so and lead with the artifact instead.

### 2. Route to the artifact

Lead with **one** live demo. The routing is by regulatory shape, not by job title.

| Brief shape | Lead artifact | URL |
|---|---|---|
| Pharma, healthcare comms, MLR / medical review, life sciences, regulated claims | **mlr-guard** — claims-grounded generation, 7 deterministic lint rules, hash-chained audit, `published` unreachable by machine identity | `https://mlr-guard.ariel-ec1.workers.dev` |
| Clinical / patient-facing / evidence and citation integrity / decision support | **hospice-decision-guide** — 22 PubMed-verified citations, build gate fails on any uncited claim, never recommends a choice | `https://hospice-decision-guide.ariel-ec1.workers.dev` |
| Regulated marketing campaigns, financial promotions, multi-market approval, CFD/fintech | **campaign-gate** — 8 gates x 3 markets = 42 approval cells, append-only ledger beside Jira, approvals hashed at grant. Local repo, **no public URL**, so pair it with mlr-guard for the clickable link | `~/.claude/projects/campaign-gate` |
| Delivery governance, PMO, programme ops generally | The blocker digest and stage-gate images in `~/.claude/projects/yunojuno-portfolio` | portfolio assets |
| Explaining governed process to non-technical stakeholders | 86-second explainer | `https://youtu.be/xO4e5MV-9Yw` |
| Creative / production range (use last, never lead) | "The Two Owners" commercial | `https://youtu.be/CYLVF7Luu2Y` |

**Verify the URL returns 200 before citing it.** Workers get torn down. Two that appear in
old notes (`foundry-site`, `yunojuno-brief-watch`) are already 404.

```bash
curl -s -o /dev/null -w "%{http_code}\n" --max-time 15 <url>
```

A dead link in a 1000-char note wastes the single highest-value element. If the routed
artifact is down, fall back to the next row rather than citing it anyway.

### 3. Ground every employment claim

**Read `C:\Users\ariel\.claude\CAREER-SOURCE-OF-TRUTH.md` before writing any history clause.**
It is the authority, built from 16 pre-2022 resumes. `resume.md` has drifted and is not.

**Never repeat these seven. No contemporaneous document supports any of them:**

1. "highest Series 7 score in development class"
2. naming JP Morgan / Goldman / BofA / Wells Fargo as Deloitte clients (say "investment
   banking clients", or "5-7 deals per month")
3. Litigati "cut onboarding 35%" or "lifted retention 25%"
4. THC Design "improved gross margin by 11%"
5. IDF "2009-2010" (it is May to Dec 2009)
6. "Finance Roots, Deloitte / Merrill / EY, 2005-2014" as one continuous block (three
   separate stints, two multi-year gaps)
7. "pioneered Hawaii's first securitization accounting team" (he was one of the first twelve
   chosen to pioneer it)

Also: THC Design was a **~$20M/year revenue** business. Do **not** claim $20mm of inventory.

**Safe, verified clauses to draw on:**
- Deloitte structured finance, June 2005 to March 2008, guiding lawyers and bankers through
  corrections on 5-7 securitization deals per month under deadline
- VP Operations at THC Design under city, state and federal scrutiny; payroll for 120+,
  AP across 300+ vendors, AR for 350+ clinics and depots, 11 facilities
- Managing Director at Litigati, 2015-2017, 20+ process servers, ran tickets day to day
- Interim COO at Nussbaum APC concurrently, staff of 10, 1,000+ client book
- MBA Finance, Rutgers. FINRA Series 7, 66, 65.

### 4. Handle the location question

Ariel is **US Pacific** and these are **UK/EU** briefs. For any role that directs people or
runs governance across a team, the timezone is the first objection the client has. One short
clause answering it ("I am US Pacific and hold UK hours") costs about 40 characters and is
usually worth it.

Skip it when the brief is asynchronous, individual-contributor, or already US-friendly. Say
which way you went and what the note measures without it, so he can cut the clause himself.

### 5. Draft, then measure

Write to the scratchpad, then measure. Never estimate a character count.

```bash
node ~/.claude/skills/yjnote/scripts/count.mjs <file>
```

If over 1000, cut a whole element rather than shaving words. Shaving produces a cramped note;
dropping the weakest of the five elements produces a clean one.

### 6. Style gate

- **No em-dashes.** Ariel's standing rule.
- **Never the phrase "load-bearing".** Hard word ban.
- **Never price the ask in the reader's time.** No "worth 20 minutes", no "a quick look".
- No "I'm excited to", "I'd love to", "passionate about", "proven track record",
  "hit the ground running", "wealth of experience".
- Short declaratives. Concrete nouns. The sentence "So I built it." is doing real work and
  earns its place; do not decorate it.
- Run the draft past the `humanizer` skill's tells if any sentence feels generated.

### 7. Save it, then present it

The 962-char note from the Capital.com application survived only in a session temp directory
and was one cleanup from being lost. Do not repeat that.

Save to `~/.claude/projects/yunojuno-portfolio/docs/cover-notes/<role-slug>-<YYYY-MM>.txt`
and commit. That repo has **no git remote**, so it is disk-local; mention this once if it
comes up, do not create a remote unasked.

Then present:

1. The note **in a fenced block**, nothing else inside the fence, ready to select and paste.
2. The character count and headroom, stated as a measured fact.
3. Three or four lines on why this shape: which artifact and why, which claims were checked,
   and any judgment call he might want to reverse (usually the location clause).

Do not present variants unless he asks. One note, chosen and defended.

## Worked example

Brief: Freelance Project Director, healthcare and pharma, 3 months, £550/day, part-time,
fully remote, disciplines listed as Client Services, Strategy, Creative, Medical, Technology,
Media. Tools: Smartsheet, JIRA, MS Project, TFS.

The hook was that **Medical is listed as one discipline among six while being the gate the
other five queue behind**. That routed to mlr-guard, and the note ran 958 characters. It is
saved at `yunojuno-portfolio/docs/cover-notes/project-director-healthcare-pharma-2026-10.txt`
as the reference for tone and density.

## Related

- `reference_yunojuno_cover_note_1000_char_limit` (memory) — how the cap was measured
- `reference_career_source_of_truth` (memory) — why `resume.md` is not the authority
- `~/.claude/projects/yunojuno-portfolio/UPLOAD-ORDER.md` — the portfolio the note sits behind
- `~/.claude/projects/yunojuno-brief-watch` — the worker that alerts on new briefs
