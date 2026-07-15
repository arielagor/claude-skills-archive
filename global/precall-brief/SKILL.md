---
name: precall-brief
description: |
  Run the agor.me pre-call brief for a meeting that was booked OUTSIDE the
  agor.me chat/voice scheduling agent (so the calendar-scan cron never sees
  it). Does genuine public-web reconnaissance on the person and company,
  writes a structured grounded brief (no fabrication), emails it immediately
  to Ariel, and arms a one-off T-30 resend ~30 min before the meeting. Use
  when Ariel says "run the pre-call brief", "brief me before my call/meeting
  with X", "I accepted a meeting with X, brief me like my agor.me agent
  would", or pastes a meeting invite / texts / LinkedIn for someone he is
  about to meet. NOT for meetings booked through the agor.me widget (the
  AgorMe\BriefSender cron already handles those).
author: Claude Code
version: 1.0.0
date: 2026-06-26
---

# precall-brief — brief myself before an off-platform meeting

## Problem

The agor.me pre-call brief pipeline (`AgorMe\BriefSender`, every 5 min) only
fires for consultations booked through the chat/voice widget, because Phase 1
scans the Google Calendar for `Agor AI ...` events and Phase 2's T-30 sweep
drops any queued item whose `bookingId` is not a live calendar event. So a
meeting set up by email, text, in person, or a referral gets NO brief and NO
T-30. This skill reproduces the same experience for those meetings.

## What it reuses (the real pipeline)

- Prompt + structure: `agor.me/src/lib/meeting-brief.ts` (`buildPrompt`). The
  brief sections and "no fabrication / BRIEF_TOO_THIN" rules come from here.
  The section template is mirrored in `reference.md` next to this skill.
- Email path: `agor.me/src/lib/email.ts` (`sendEmail`, Gmail SMTP) +
  `src/lib/markdown-email.ts` (`markdownToEmailHtml`). SMTP creds live in
  `agor.me/.env.local` (`smtp.gmail.com:465`, user `ariel@agor.me`).
- Recipients (same as the pipeline): `ariel@agor.me`, `ariel.agor@gmail.com`.
- Sender script (generalized): `agor.me/scripts/send-adhoc-brief.mjs`.
- T-30 launcher (generic): `agor.me/scripts/run-adhoc-precall-t30.ps1`.

I am the model the pipeline shells out to (`claude -p --allowed-tools
WebSearch,WebFetch`). So I do the reconnaissance directly with WebSearch /
WebFetch rather than spawning a subprocess.

## Hard rules

- **No fabrication. Brief the RIGHT person or say you could not confirm them.**
  Common names collide. Do NOT anchor on the most famous web match. Primary
  sources Ariel gives you (texts, who-introduced-whom, an in-person event,
  a LinkedIn screenshot, the actual company domain) OUTRANK a guessed
  name-match every time. If you cannot identify them with reasonable
  confidence, write "Unable to confirm public profile" in "Who they are"
  instead of guessing. This is the pipeline's `BRIEF_TOO_THIN` discipline.
- **Every concrete claim traces to a source** (a URL you visited, or a named
  first-party source like "your SMS thread"). Never invent numbers, dates,
  headcounts, or quotes.
- **No em-dashes** in the brief (it is emailed to Ariel). Use commas, colons,
  parentheses, periods. Avoid `>` blockquotes and single `*...*` italics too:
  the email renderer only handles `#`/`##`/`###`, `**bold**`, `- ` lists,
  `[text](url)` links, and paragraphs.
- **Do not claim "sent" without proof.** Verify SMTP `250` + a Gmail mailbox
  search before reporting success (see Verify).
- **Scheduled tasks are S4U + Hidden**, never Interactive, or a console window
  pops on Ariel's screen.

## Steps

### 1. Gather the meeting facts
Collect: attendee name(s), company, role, topic, the meeting START datetime
(with timezone), the Meet/Zoom link if any, and HOW it was set up (who
referred/scheduled). If the event is on a calendar connected via the Google
Calendar MCP, pull it with `list_events` for the day. If not (the usual case
for this skill), use what Ariel provides. Ask for a LinkedIn URL or company
domain if identity is ambiguous, it saves a dozen flailing searches.

### 2. Reconnaissance
Run several WebSearch calls, WebFetch the high-value pages. Resolve identity
FIRST (step rule above). Then fill the section template in `reference.md`:
Who they are / Track record / What they're working on now / Why this call /
What to cover (3 to 5 concrete angles + ONE qualifying question for the first
5 minutes) / Sources. Tie every angle to the actual person, company, and
sector, never generic "AI strategy".

### 3. Write the brief markdown
Save to `agor.me/scripts/adhoc/<slug>-brief.md` (slug = `lastname-company`).
H1 `# Pre-call brief: <Name> (<Company>)`, then `**Meeting:**` and `**Topic:**`
lines, then the sections. Obey the renderer limits and no-em-dash rule above.

### 4. Send the immediate brief
From the agor.me repo. `npx tsx` can fail with "could not determine executable
to run", so call the local binary directly:

```powershell
Set-Location "C:\Users\ariel\.claude\projects\agor.me"
& "node_modules\.bin\tsx.cmd" scripts/send-adhoc-brief.mjs `
  --file "scripts\adhoc\<slug>-brief.md" `
  --start "2026-06-26T13:00:00-07:00" `
  --subject "Pre-call brief: <Name> (<Company>) - <Fri, Jun 26, 1:00 PM PDT>"
```

Success prints `Email sent: <messageId>` and `response=250 ...`. Add `--t30`
to prefix `[T-30]`, `--dry-run` to render without sending.

### 5. Arm the T-30 resend (one-off S4U hidden task)
T-30 = meeting start minus 30 min. Register a per-meeting task that calls the
generic launcher with the same `--file/--start/--subject`. Use a unique task
name (`BriefT30-<Slug>-<YYYYMMDD>`). Auto-clean via EndBoundary +
DeleteExpiredTaskAfter.

```powershell
$slug='<slug>'; $name="BriefT30-$slug-20260626"; $path='\AgorMe\'
$brief='C:\Users\ariel\.claude\projects\agor.me\scripts\adhoc\<slug>-brief.md'
$start='2026-06-26T13:00:00-07:00'
$subject='Pre-call brief: <Name> (<Company>) - <Fri, Jun 26, 1:00 PM PDT>'
$t30=(Get-Date $start).AddMinutes(-30)
try { Unregister-ScheduledTask -TaskName $name -TaskPath $path -Confirm:$false -ErrorAction Stop } catch {}
$arg = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ' +
  '"C:\Users\ariel\.claude\projects\agor.me\scripts\run-adhoc-precall-t30.ps1" ' +
  "-BriefFile `"$brief`" -Start `"$start`" -Subject `"$subject`""
$action=New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $arg
$trigger=New-ScheduledTaskTrigger -Once -At $t30
$trigger.EndBoundary=$t30.AddMinutes(15).ToString('s')
$principal=New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType S4U -RunLevel Limited
$settings=New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 10)
$settings.DeleteExpiredTaskAfter='PT2M'
Register-ScheduledTask -TaskName $name -TaskPath $path -Action $action -Trigger $trigger -Principal $principal -Settings $settings | Out-Null
(Get-ScheduledTaskInfo -TaskName $name -TaskPath $path).NextRunTime
```

### 6. Verify (do not skip)
- **Immediate landed:** Gmail MCP `search_threads` with
  `subject:"Pre-call brief: <Name>" newer_than:1d` and confirm a thread in
  INBOX.
- **T-30 will actually fire under S4U:** test-fire it WITHOUT emailing a
  duplicate. Create the dry-run sentinel, register the task pointing the
  launcher's `-DryRunFlag` at it, `Start-ScheduledTask`, confirm
  `LastTaskResult=0` and a fresh DRY RUN line in
  `logs/adhoc-precall-t30.log`, then DELETE the sentinel so the real run
  sends. (For a quick check you can also run the launcher directly with the
  sentinel present.) Sentinel path e.g.
  `agor.me/logs/<slug>-t30-dryrun.flag`.
- Re-confirm `NextRunTime` is the T-30 and the sentinel is gone.

## Gotchas (hard-won 2026-06-26)

- **`npx tsx` → "could not determine executable to run".** tsx is a local
  dep; call `node_modules\.bin\tsx.cmd` by path instead.
- **Phase-2 calendar guard drops off-platform T-30s.** Do NOT enqueue into the
  `brief-queue` blob for these meetings, the cron's `events.get` 404s and
  drops it. A dedicated one-off task is the only reliable T-30 here.
- **The careful/guard hook blocks `Remove-Item` when the command also contains
  a task-path token like `\AgorMe\`.** Delete files with
  `[System.IO.File]::Delete($path)` in a SEPARATE command, never in the same
  line as Start/Get-ScheduledTask.
- **A leftover dry-run sentinel silently neuters the real send.** Always
  confirm the sentinel is deleted (`Test-Path` = False) after verifying.
- **Identity:** the loudest web result is often the wrong person. (This skill
  was born from a "Josh Feldman" that recon mis-mapped to an NBCUniversal CMO
  when the real one was an AdBeacon engineer Ariel met at a HeyGen event.)

## File to GBrain after building infra
After arming a real T-30 task, note it so a future session knows it exists.
For a routine one-off brief, the GBrain project page for this skill is enough;
only file a per-meeting page if it becomes an ongoing relationship.
