---
name: meeting-to-proposal
description: Turn a client/discovery meeting into a branded, scoped consulting proposal package using the PROVN methodology re-pointed at "win a consulting client." Use when Ariel types "/meeting-to-proposal" or "/proposal", pastes a meeting transcript or Gemini notes, or says "draft a proposal from this call", "turn this meeting into a proposal", "scope a proposal for <person/company>", or "write up <name> a proposal". Produces a partner-facing scoped proposal, a 1-page executive summary, a cover email in Ariel's voice, an optional explainer, and a spec-diff gate proving every client ask is addressed with real evidence — rendered on Agor AI letterhead. Stages a Gmail DRAFT and stops before sending.
---

# /meeting-to-proposal — Win a Consulting Client From the Playbook

Turn a discovery call into a send-ready Agor AI Advisory proposal using the methodology
hardened on PROVN challenges, re-pointed from "win a role" to "win this client." A
transcript is just a spec; grade the proposal against the client's actual asks the
same way. The deliverable ends as a Gmail **draft** in Ariel's box — review and send.

## Step 0 — Load the playbook (ALWAYS, before anything else)

Read the full playbook now and follow it exactly:

```
C:\Users\ariel\.claude\MEETING_TO_PROPOSAL_PLAYBOOK.md
```

The two-sided Iron Law, the named pipeline stages, evidence-grounding rules, the
branded-render recipe, the send discipline, the honesty/framing hard rules (including
the founding-client concealment rule and the augmentation-not-replacement rule), the
outcome log, and the embedded templates all live there. Read the current version each run.

## Step 1 — Resolve the argument

Invoked as `/meeting-to-proposal <arg>` (or `/proposal <arg>`). Interpret `<arg>`:

- **A file path** to a transcript/notes (`.md`, `.txt`, `.gdoc` pointer) → read it as
  the verbatim spec. Note: `.gdoc` files on the `H:` drive are Google Drive cloud
  pointers — read the doc via `mcp__claude_ai_Google_Drive__search_files` /
  `read_file_content`, not the local placeholder ("Incorrect function" error).
- **A participant name or email** → resolve the meeting: Google Drive search for the
  "<…> Notes by Gemini" doc, Gmail, and GBrain. Confirm the match in one line.
- **Pasted transcript / notes text** → use directly.
- **Empty** → ask which meeting (path, participant, or pasted text). Don't invent asks.

State the resolved client + meeting back in one line, then continue.

## Step 2 — Run the pipeline (per the playbook §2)

1. **`ingest` + `extract-client-spec` (Iron Law, §1)** — the full transcript + notes
   into context. Build the ask-list quoted verbatim: asks, explicit non-asks,
   constraints, decision-makers, aligned decisions. **Build the Proper-Noun Ledger
   (§1.1)** — every person/company/product/place name with its source; cross-check each
   against email domains / the company website / GBrain; surface the still-UNVERIFIED
   names to Ariel for a 30-second confirm before render. Then gather Ariel's real
   evidence: GBrain (`mcp__gbrain__query`), `agor.me/portfolio`, app/store links, repos,
   books, frameworks. Never draft from a summary of either text.
2. **`organize-folder`** — ensure `…\potential consulting projects clients\<Ariel Agor
   & Name>\` with `meetings\`, `proposals\`, and a `README.md` dossier (template §10.1);
   file the meeting (notes / transcript / recording pointer) if not already filed.
3. **`research-and-ground`** — a real domain fast-ramp (cited web research; mark Ariel's
   honest gap) + the evidence-pack pull. Don't fake domain fluency.
4. **`draft-package` → `independent-review` → `revise` (§2 steps 5–7)** — fan out across
   subagents; every subagent gets the full transcript + full evidence pack. Reviewers: a
   requirement-grader, a skeptical-partner adversary (reads as the client's hardest
   decision-maker), and a truthfulness auditor (flags any claim not in evidence, any
   over-claim, any promised metric without data).
5. **`spec-diff-gate` (§8)** — grep each client ask against the package. Every ask
   present-with-evidence or honestly-flagged-as-ramp. **Any silent miss or over-claim is
   a blocker.**
6. **`render`** — branded `{md, tex, pdf}` (+ `docx` for the main doc) on Agor AI
   letterhead: fork the Veruna preamble (§5), copy the three brand assets into the
   proposal's `source/`. Deliverables per playbook §3.

## Step 3 — STOP before sending

After the package passes the spec-diff gate, **stage a Gmail draft and STOP** (§6).
Create the draft to the client with the PDFs attached (verify the attachment landed; if
not, upload to Drive and put links in the body — §6). Then confirm recipient / subject /
body / attachments back to Ariel in one line and **get explicit OK before anything is
sent**. Prefer Ariel's own send. Never auto-send.

## Hard rules carried from the playbook

- **Ground every claim in verifiable evidence** — lead with the live Agor AI pipeline the
  prospect usually saw on the call. Never invent a capability, metric, or prior action (§1).
- **Honesty & framing (§6):** Ariel is not an engineer and not a domain expert in the
  client's industry — name the gap once, frame Discovery as the ramp; never promise a
  numeric outcome without the client's data; frame team/vendor automation as
  augmentation/alongside, never "replace"; conceal founding-client status behind a real
  charter-rate rationale.
- **One sharp pilot** with a baseline + metric; phased Discovery → Pilot → Scale;
  human-in-the-loop review-and-approve, not autonomous magic (§7).

## Don't

- Don't draft from a summarized transcript or a summarized evidence pack.
- Don't auto-send; the pipeline ends at a Gmail draft + an explicit-OK gate.
- Don't over-claim a domain to fill a slot — flag the ramp honestly instead.
- Don't put "fire your team" or "replace your vendor" in writing — augmentation framing only.
- Don't promise a % / $ lift without the client's baseline — promise measurement.
- Don't trust a proper noun from an auto-transcript — verify every person/company/product
  name against a non-transcript source (email domain, website, GBrain) or confirm it with
  Ariel before it ships (§1.1). A misheard client/decision-maker name in a partner-facing
  doc is the worst, most avoidable error.
