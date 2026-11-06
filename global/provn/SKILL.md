---
name: provn
description: Solve a PROVN challenge end to end using the hardened playbook, including Provn job challenges. Use when the user types "/provn", "/provn <N>", "/provn <challenge-url>", or asks to start/solve/run a PROVN challenge. Loads the full methodology so a fresh context window picks up without re-onboarding.
---

# /provn: run a Provn challenge

The National AI Competition ended 2026-11-01. Live use is Provn job challenges. Competition material stays as history.

## Step 0: load the rules

Read the playbook's Iron Law (§1) and framing rules (§7) in `C:\Users\ariel\.claude\PROVN_PLAYBOOK.md`, then use this map. Each rule has one owner; read the owner, not your memory of it.

| Topic | Owner |
|---|---|
| Pipeline, paths, submission, upload gotchas | this file |
| Solver rules and the preserve list | `SOLVER-BRIEF.md` |
| Jury loop, AI Fluency, honesty rule, attempt-2 gates, package | `DRIVER-BRIEF.md` |
| Every video rule, voice included | `VIDEO.md` (commands in `tools/MOTION-RECIPE.md`) |
| Rubric for a role | `ladders/<ladder>.md` |
| Grader log, predicted versus actual | playbook §10 |
| Evidence and history | `LESSONS.md`, `competition-rules.md` |

Where an older note disagrees, this skill wins. Two are known: memory `feedback_provn_rules_literal_full_automation.md` ("minimal disclosure", "omit the unaided note") and the "Decisions (live)" in `provn-challenges-repo\HANDOFF.md` are closed history, replaced by the DRIVER-BRIEF honesty rule and VIDEO.md.

**Ariel's background, if any challenge, profile field or video mentions it:** take every date, title and employer from `C:\Users\ariel\.claude\APPLICATION-DATES.md`, ALWAYS (Ariel's ruling, 2026-10-07). `CAREER-SOURCE-OF-TRUTH.md` is the private truthful record. Use it for detail only, and never copy its dates or gaps into anything submitted. Submissions normally carry no biography at all (SOLVER-BRIEF "Truth"); this rule covers the profile and any exception.

## Step 1: resolve the argument

- **A number** (e.g. `140`): the URL is `https://provn.co/challenges/<N>`. Confirm it resolves; if it 404s, find the card at `https://provn.co/challenges`.
- **A full URL:** use it directly. A job URL looks like `provn.co/org/<org>/jobs/<id>/<slug>`, and its page links the challenge.
- **Empty:** ask for the challenge number or URL. Do not proceed without it.

State the resolved number and URL in one line, then continue.

## Step 2: attempt 1

1. **Folder.** Job challenge: `C:\Users\ariel\.claude\projects\provn-challenges-repo\jobs-<yyyy-mm>\<id>-<slug>\` (the batch folder also holds `TRACKER.md`; the current one is `jobs-2026-11`). Competition, history only: `...\competition-2026\<ladder>\w<N>-<slug>\`.
2. **Spec capture.** Save the verbatim page as `spec-source.txt` in that folder: `node C:\Users\ariel\.claude\skills\provn\tools\provn-public-fetch.mjs <url> --out <folder>\spec-source.txt` for public pages, or Chrome for pages that need the session. Pass the full text to every subagent, never a summary.
3. **Job checks** (below), for any job challenge.
4. **Standing terms.** Before the solver starts, write `standing-terms.md`: the literal terms this run works under, for the AI Usage Log (DRIVER-BRIEF "AI Fluency").
5. **Solve.** A solver subagent gets the verbatim spec, `SOLVER-BRIEF.md`, `standing-terms.md` and the ladder card, and emulates the best version of that role in the world. Fan out where it helps.
6. **Jury, AI Usage Log and video.** Run `DRIVER-BRIEF.md` attempt 1: at most 3 rounds, with the video rendered per `VIDEO.md` inside that loop, before round 2.
7. **Spec-diff gate.** Grep each requirement against the deliverables and write `spec-diff.md`. Any miss is a blocker.
8. **Package.** `submission-package/attempt-N/` per DRIVER-BRIEF "Finish". The challenge folder also holds `video-script.md`, `video-shows.json` or `video-kinetic.json`, and `video-report.json`.
9. **Submit.** Claude submits in Chrome (below). There is no stop for approval: the portal gate was retired for good on 2026-11-02.
10. **Apply, for a job.** Submitting the challenge does not file an application. Read Ariel's rulings first, then apply only to the jobs they allow: "Applying", under "Job challenges".
11. **Log it.** When the score lands, add a row to the "Original run" table in playbook §10. The "Competition scores" table is closed. On an attempt 2, fill "Predicted fixes versus actual" too.

Default deliverable format is `.md` unless the spec demands otherwise. The repo `arielagor/provn-challenges` is private; still grep every diff for secrets before a push (playbook §6).

## Job challenges

Competition facts do not carry over. Check each of these on the page and write the answer at the top of `spec-diff.md`, with "unknown" where the page is silent:
- **Attempts and feedback.** Whether a job challenge allows two attempts or returns feedback is unknown in general (#140 was "resubmittable until the deadline"). Check per challenge; never assume either.
- **Deadline.** Application deadlines are real and short.
- **Rubric.** The page's rubric beats the nearest ladder card. Use the card for shape only.
- **Video.** Length, and any face-on-camera line: VIDEO.md "Live presence" says what to do. Never imply he is on camera. If the page says an accommodation must be requested before starting (#140), flag it to Ariel and continue.
- **Role fit.** Flag requirements such as years of engineering experience or location to Ariel and continue. Never claim them.
- **Resume.** Apply sends the Provn profile resume, so it must already comply with `APPLICATION-DATES.md`. `/job-application` is for a job that wants a tailored application outside Provn.

**Finding jobs:** `GET https://provn.co/api/jobs`, then each job page's embedded `challenges` array. One challenge can serve several jobs (#167, #168).

**Applying.** Apply is an outward action, so Ariel's rulings come first. Before any click, read the "Rulings" and "Not applying" lines in the batch `TRACKER.md`, plus that folder's `HANDOFF.md` if there is one. In a new batch, read the latest batch's too: rulings stand until Ariel changes them. Check each linked job against them:
- **Location.** The stated preference decides between twin postings (2026-11-04: prefer SF or NY, Chicago twins dropped).
- **Per-company role limit.** Count the roles already applied to at that company (2026-11-04: AZX capped at two named roles, its other 4 not applied to).
- **Relocation.** Follow the ruling (2026-11-04: relocation roles yes).

Never apply to a job the rulings exclude: record it under "Not applying" with the reason. Everything else goes ahead. After Submit My Work, open each job page that passed, `provn.co/org/<org>/jobs/<id>/<slug>`, and click Apply. It is one click with no form, and it sends the profile, the profile resume and the completed challenges. Confirm it in the Applied tab at `provn.co/applications`, then update the batch `TRACKER.md`.

The solver rules always apply. Attempt-2 rules apply only if a second attempt exists.

## Step 3: attempt 2

Applies only where the page allows a second attempt or a resubmission. Then:
1. Read Provn's attempt-1 report first.
2. Run the decision gate. On the competition's 24 it would have stopped 4, all at 97 or above.
3. Follow the work order and the remaining gates.

All of that is in `DRIVER-BRIEF.md` "Attempt 2: the gates", including the one exception for a challenge that returns no report.

## Submitting in Chrome

Load the `claude-in-chrome` skill. Log in as `arielagor@gmail.com` (no dot) by magic link, read from Gmail with `node ~/.claude/scripts/gmail.mjs`. Profile: provn.co/u/arielagor. Fill the "how did you use AI" field honestly (DRIVER-BRIEF honesty rule).

### Upload gotchas
- **One slot per deliverable.** The right file in the right slot.
- **The Code slot holds ONE file.** Merge modules first.
- **Over 10 MB:** `file_upload` caps there. Put the video in through a page `fetch` of a CORS-enabled GCS object plus DataTransfer, then delete the bucket. A localhost fetch hangs on Chrome's local-network gate.
- **Never `.zip` or `.docx`:** Provn's evaluator failed to open them. Use `.md`, PDF with images embedded, or plain-text code.
- **Filetype mismatch (Ch94):** some video slots accept only document types. Upload a `.md` with a link that plays when signed out, such as unlisted YouTube. A release asset in the private repo will not play.
- **Slow uploads** can pass the tool's 30-second timeout and still complete. Check again before retrying.
- **Blank screenshot after an upload:** read the DOM (`get_page_text`); do not re-shoot.
- **"No video narration" when one was uploaded (Ch86)** is a detection failure. Confirm receipt before the attempt is final. A platform failure goes to info@provn.co for a replacement attempt; never spend attempt 2 on it.
- **The linked job is chosen by the platform** and cannot be edited from the challenge page. Read the "APPLYING FOR" card before building, because the level can change the video length.
- **Staff email versus page:** when they disagree, build to the page and say so.
- **Page quirks:** target buttons by y-coordinate, and contenteditable fields need the Selection API plus execCommand. See memory `feedback_provn_profile_automation.md`.

## Don't
- Don't summarize the spec and solve from the summary.
- Don't start an attempt 2 before reading the real report.
- Don't treat a jury or emulator number as a forecast.
- Don't frame Ariel as an engineer, in anything.
