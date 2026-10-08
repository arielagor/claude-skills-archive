---
name: yjnote
description: Write a YunoJuno application cover note that fits the hard 1000-character box, from a pasted job description. Use when Ariel types "/yjnote", pastes a YunoJuno brief and asks for a cover note, or says "write the cover note for this", "yj note for this brief", "turn this JD into a cover note". Routes the brief to the right live demo artifact, checks every employment claim against APPLICATION-DATES.md (never the truth file's dates), drafts TO the cap rather than trimming down to it, always in Ariel's own email voice (the ariel-email-voice card), measures before presenting, and hands back one paste-ready block.
---

# /yjnote — YunoJuno cover note, built to the box

Ariel pastes a job description. This skill hands back one block he can copy straight into
YunoJuno's "Cover note (Optional)" field, already measured against the cap, with every claim
sourced.

The output is the note. Not a plan to write a note, not three options to choose between.
One note, paste-ready, with the character count stated.

**Every note is written in Ariel's email voice, ALWAYS** (Ariel's ruling, 2026-10-08). Load
the `ariel-email-voice` skill and read `voice-card.md` sections 2d (semi-formal), 2f
(strangers) and 7 (what imitations get wrong) before drafting. The note should read like an
email he typed to someone he wants to work with, not like copy. See step 6.

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
   the objection they would otherwise raise without telling you. Say it the way he would
   ("I'll be honest, I haven't administered a commercial DAM."), never as a labelled
   "Honest limit:" line.
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

**Read `C:\Users\ariel\.claude\APPLICATION-DATES.md` before writing any history clause, ALWAYS.**
It is the authority for every date, title, role and number in a cover note (Ariel's ruling,
2026-10-07). Its "Claims Ariel ruled to include" and "Never on an application" lists override
the list below wherever they differ. `CAREER-SOURCE-OF-TRUTH.md` is the private truthful
record, for detail only; never copy its dates or gaps into a note. `resume.md` has drifted.

**Never write these:**
1. IDF "2009-2010" (applications say 2009)
2. "Finance Roots, Deloitte / Merrill / EY, 2005-2014" as one continuous block
3. "pioneered Hawaii's first securitization accounting team", or any team size (say
   "founding member of Deloitte's Honolulu securitization team")
4. $20M anything for THC Design. It was a **$15M+ revenue** business, 120 people.

The four self-reported claims (Series 7 top score, named bank deal teams, Litigati -35%/+25%,
THC margin +11%) are Ariel's call. They are allowed per APPLICATION-DATES.md, but a 1000-character
note rarely needs them.

**Safe clauses to draw on (years per APPLICATION-DATES.md):**
- Deloitte structured finance, 2005-2008, guiding lawyers and bankers through
  corrections on 5-7 securitization deals per month under deadline
- VP Operations at THC Design under city, state and federal scrutiny; payroll for 120+,
  AP across 300+ vendors, AR for 350+ clinics and depots, 11 facilities
- Managing Director at Litigati, 2015-2017, 20+ process servers, ran tickets day to day
- Interim COO at Nussbaum APC concurrently, staff of 10, 1,000+ client book
- MBA Finance, Rutgers. FINRA Series 7, 66, 65.

### 4. Handle the location question

Ariel is **US Pacific** and most of these are **UK/EU** briefs. For any role that directs people or
runs governance across a team, the timezone is the first objection the client has. One short
clause answering it ("I'm in LA and I keep UK hours") costs about 40 characters and is
usually worth it. For **AU/NZ** briefs (AUD or NZD rate, Xero and similar), the overlap is
natural: "I'm in LA, so my afternoons are your mornings."

Skip it when the brief is asynchronous, individual-contributor, or already US-friendly. Say
which way you went and what the note measures without it, so he can cut the clause himself.

### 5. Draft, then measure

Draft in his voice from the first word. Don't write neutral copy and convert it afterwards:
a converted note keeps the copywriter's structure under his phrasing. Write to the
scratchpad, then measure. Never estimate a character count.

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
**His email voice (from `voice-card.md`; read it, these are the points that bite here):**
- **Write the thought the way he would say it.** Run-ons joined with "and", "so", "but"
  and commas are his, and so are hedges and asides like "I'll be honest" or "jumped out at
  me". Don't compress it into tidy punchy declaratives; that reads as copywriting.
- **No colon-reveal labels** ("Honest limit:", "Live:", "Here's the thing:"). Put the URL
  bare at the end of a sentence ("you can try it here https://...").
- **No balanced "not X, but Y" / "X, not Y" constructions**, and no closing line that
  restates the note. Each one is an AI tell he never writes.
- Contractions everywhere (I'd, I'm, haven't). Normal capitals and full sentences, since
  this is mail to strangers, so no deliberate typos or lowercase "i".
- **At most one "!"**, and it goes on the warm line (usually the closing one). No emoji.
- No greeting, or "Hi [Name]," if the brief names a person. No "Best regards" or other
  closing phrase. End with `~Ariel` on its own line (8 chars, count it).
- Keep the specifics: digits, real names, the number from the artifact.
- Run the `ariel-email-voice` AI-tell checklist before measuring the final version.

### 7. Save it, then present it

The 962-char note from the Capital.com application survived only in a session temp directory
and was one cleanup from being lost. Do not repeat that.

Save to `~/.claude/projects/yunojuno-portfolio/docs/cover-notes/<role-slug>-<YYYY-MM>.txt`
and commit. That repo's remote is `github.com/arielagor/yunojuno-portfolio` (private), and
the auto-push hook pushes each commit there. Report the hook's push line truthfully.

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
saved at `yunojuno-portfolio/docs/cover-notes/project-director-healthcare-pharma-2026-10.txt`.
It is the reference for **hook and density only**: it was written before the voice rule and
uses the "Honest limit:" label and punchy declaratives that step 6 now bans.

**Voice reference:** `yunojuno-portfolio/docs/cover-notes/dam-automation-manager-xero-2026-10.txt`
(Xero DAM Automation Manager, AUD, 1 month, 975 chars). The hook was "Less single person
dependency" in their success list. The note routes to mlr-guard as the same pattern rather
than DAM experience, admits he hasn't run a commercial DAM, uses the THC software-selection
work, and is written in his email voice throughout.

## Related

- `reference_yunojuno_cover_note_1000_char_limit` (memory) — how the cap was measured
- `reference_career_source_of_truth` (memory) — why `resume.md` is not the authority
- `~/.claude/projects/yunojuno-portfolio/UPLOAD-ORDER.md` — the portfolio the note sits behind
- `~/.claude/projects/yunojuno-brief-watch` — the worker that alerts on new briefs
