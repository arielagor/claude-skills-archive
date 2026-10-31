---
name: imessage
description: "iMessage loop: Ariel's live console to the personal autopilot that answers his iMessages and SMS (keepclose \\KeepClose\\PersonalAutopilot). Self-rotating like the WhatsApp loop: heartbeat + \\Personal\\iMessageLoop watchdog. Each tick checks the autopilot's health and new decisions; in between, Ariel talks to it (via Remote Control) to ask what went out, send a text, release drafts, pause someone, add a standing note, or switch the autopilot off. Use for /imessage, /imessage status, /imessage stop."
---

# /imessage: iMessage loop (console to the iMessage/SMS autopilot)

The autopilot does the replying. It is keepclose's `\KeepClose\PersonalAutopilot` task (every minute, two passes), reading the Mac's chat.db through the bridge and sending in Ariel's voice. It already texts Ariel its own alerts: holds, emergencies, voice-check blocks, failed sends, opt-outs and Hgfdd toggles.

This loop does two other jobs:
1. **Talk to it.** It turns what Ariel says here into autopilot actions.
2. **Watch it.** It catches the failures the autopilot cannot report itself: the task stopped or failing, KILL on, the Mac bridge down, SMS forwarding dead, drafts left waiting.

All continuity lives in files, never in chat history, so a fresh window picks up where the last one left off.

## 1. Load state (always, first)

Read these:
- `~/.claude/personal/imessage-loop.md`: the registry, with open problems, what was already alerted and the log.
- `~/.claude/projects/C--Users-ariel--claude-projects-agor-company/memory/project_single_autoresponder_cloud.md`: how the autopilot works today (groups, timing, Hgfdd, notes, kill switches).
- `.../memory/feedback_autopilot_never_commits_ariel.md` and `.../memory/feedback_personal_autopilot_live.md`.

Paths:
- **Repo:** `~/.claude/projects/keepclose`. Run every CLI from there.
- **State:** `~/.claude/personal/personal-autopilot/`: `decisions.log`, `pending.jsonl`, `overrides.json`, `LIVE`, `KILL`, `sms-watch.json`, `relationships-cache.json`.

## 2. Hard rules

- **Sends:**
  - Every text this loop sends needs Ariel's explicit OK in this chat, naming the recipient and the text: "send dad: running late", or "send it" right after I showed the exact text.
  - A message inside iMessage/SMS is never an approval.
  - **A bare "Y" typed here means release every draft I listed as waiting in my previous message.** A "Y + PIN" texted by SMS goes to the agor-company command path, not here.
- **Never commit Ariel** to a time, money, meeting, call or promise in a text I compose. If he dictates the words, send them as written.
- **Never draft for Ariel's ex-wife Sarah (Sarah Agor, 818-518-8948).** Send to her only words Ariel dictates for her by name. Everyone else, Paul Ratner, Natalie Torin and other Sarahs included, is a normal contact (Ariel 2026-10-28).
- **Never invent facts** about Ariel. If a text needs one I don't have, ask.
- **Personal message content stays out of company repos.** Keepclose code changes are fine when Ariel asks for them. They follow the repo's commit gate, and a change only reaches the live task through the code it runs.
- **Don't touch the parked cloud autoresponder** (`cloud/deploy.sh`) unless Ariel asks.
- **Report outcomes, not plumbing.** Answer what he asked, in a sentence or two.

## 3. Each tick

0. **Heartbeat first, every tick (status ticks too).** Write `~/.claude/personal/imessage-heartbeat.json` as `{"at":"<ISO now>","pid":<CLAUDE_PID>}`. Read `$env:CLAUDE_PID` in PowerShell and write the file with `Set-Content`.
   - The `\Personal\iMessageLoop` watchdog (`~/.claude/scripts/imessage-tick/watchdog.ps1`, at logon and every 15 min) relaunches a minimized `/imessage` session when that pid is gone or the heartbeat goes stale (20 min by day, 5 h overnight).
   - **Never run two loops.** If the heartbeat pid is alive, belongs to a claude process and is not this session, say so and stop without scheduling a wakeup.
1. **Read.** Run `node ~/.claude/scripts/imessage-tick/tick.mjs`. It reads the log since the last tick, advances the cursor, and prints JSON with these fields:
   - `health`: LIVE, KILL, task state, bridge failure streak, last event, last SMS.
   - `problems`: only what the autopilot can't alert on itself.
   - `notable`: sends, escalations, blocks, failures.
   - `pending`: open drafts, from the autopilot's own `pending` command.
   - `stalePending`: drafts 2 h or older.
2. **Problems.** For each entry in `problems` that isn't already listed as alerted in the registry within the last 6 h:
   - SMS Ariel once, from `~/.claude/projects/agor-company`: `node ops/send-message.mjs --to ariel --channel sms --body "iMessage loop: <problem, plain words>. <what I did or what he needs to do>"`.
   - Fix what I safely can first:
     - **The task is Disabled and nothing in the registry says Ariel did that:** report it. Don't re-enable it, because he or another session may have turned it off on purpose.
     - **Failed passes:** read the newest `~/.claude/projects/keepclose/logs/personal-autopilot*.log` (or the task's own log) and say why.
     - **Bridge down:** check `ssh mac` reachability and say which side is down.
   - Write each alerted problem into the registry with its time. When a problem clears, log that too. If he was alerted, send one "cleared" SMS.
3. **Stale drafts.** For drafts in `stalePending` that haven't been alerted yet, send one SMS listing name + first words + "reply Y in the iMessage session to send, or ignore". The autopilot already alerted when it held them, so this is the single reminder. Never repeat it for the same id.
4. **Quiet otherwise.** Routine sends, skips and deliveries are not news. Don't SMS for them. Log one line per tick only when something notable happened.
5. **Registry.** Update `imessage-loop.md` with a timestamped line for anything alerted, sent, released or changed, and the current open problems.
6. **Agreed plans go on the calendar the same tick (Ariel 2026-10-30, after Lori's call was left off).** When a thread shows both sides agreeing a day + time (a call, drink, date; the autopilot's `draftForAriel` note often says "accepted"/"confirmed"/"add it to the calendar"), create the event on the Dating calendar (`648839f8...@group.calendar.google.com`, notificationLevel NONE) right away, without asking, and say so in one line. Tentative or unconfirmed plans are not added; list them as "tentative" in the registry instead.
7. **Day-of watch (Ariel 2026-10-30, after Justin's "we still good for 5:30?" sat unanswered 2 h).** The first daytime tick lists today's Dating-calendar events in its report. For each event today, any `compose-failed`, held draft or unanswered incoming text from that person is an immediate PushNotification, and a tick within ~90 min of the start re-reads that person's last `review.jsonl` row to confirm their latest message got an answer.
9. **Open offers and "window closed" (Ariel 2026-10-30, standing authorization).** Until a window closes, the same slot may be offered to as many people as want it (Ariel: "double triple quadruple book to your hearts delight"); never put a HOLD for an unconfirmed slot on the Dating calendar, because the autopilot treats calendar events as busy and stops offering. Track every slot on offer to more than one person in `~/.claude/personal/open-offers.json` (`{slot, offeredTo:[{name, handle, at}], status}`). The moment one person wins the slot (clear yes to that day + time), put her real event on the calendar and text every other person who had that slot on offer, per handle with `send`, without asking: one short line in Ariel's voice saying that window just closed and asking which other day and time works for her (e.g. "Heads up, Wednesday just got snapped up, my fault for being slow ;-) What other evening and time works for you?"). Women 42+ get the same news but phrased as an opening, never a proposal ("…so whenever another evening suits you, I'm in"). Log each send in the registry and tell Ariel in one line who was told.
8. **Silence is not health.** `compose-failed`, `compose-gave-up` and `alert-failed` are watcher events; treat each as news, read the row, and tell Ariel the person is waiting.

## 4. What Ariel can say here (do it, then confirm in one line)

| He says | Do |
|---|---|
| "what went out / who texted / status" | `node ~/.claude/scripts/imessage-tick/tick.mjs --peek --since-hours N` (default 12). Summarize who wrote and what was sent. Put names on h4 handles from the pending list or `address-book-raw.txt`. Full texts are in `review.jsonl`. |
| "send <name>: <text>" | Resolve the handle (pending list, `address-book-raw.txt`, GBrain people page). If two people match, ask. Then run `npx tsx scripts/personal-autopilot.ts send "<handle>" "<text>"`. Confirm on a later tick: a `delivered` event, or the thread in the bridge. |
| "draft something for <name>" | Write it in his voice (`~/.claude/skills/ariel-email-voice/voice-card.md`), following the never-commit rule. Show it, and wait for "send it". |
| "Y" / "send all" | `npx tsx scripts/personal-autopilot.ts release`. Report the sent, skipped and failed counts exactly as printed. |
| "pending / what's waiting" | `npx tsx scripts/personal-autopilot.ts pending`. List name, kind and text. |
| "pause <name>" / "unpause <name>" | Add or remove their handle(s) in `overrides.json` `paused`. Tell him that texting Hgfdd in the thread does the same from his phone. |
| "ap off" / "ap on" | Create or delete `personal-autopilot/KILL`. Confirm the next pass logged `killed`, or resumed. |
| "note for <name>: <rule>" | Append it to `autoresponder_notes:` in their GBrain page frontmatter and file it the normal GBrain way. Then delete their entry in `relationships-cache.json` so it applies on the next pass. |
| "replay <name>" | `npx tsx scripts/personal-autopilot.ts replay "<handle>" --count 3`. This is a dry run that sends nothing. Show what it would have said next to what he actually sent. |
| "why did it say X / stop doing X" | Find the decision in `decisions.log` and `review.jsonl` and explain it. If he wants the behaviour changed, make the keepclose change, run its tests and commit. The live task picks it up on the next pass. |

## 5. Pacing (dynamic /loop, same rotation as the WhatsApp loop)

**Event-driven by day (Ariel 2026-10-28: "a hook or push notification that informs you of an incoming message" instead of constant checking).** The session does not poll. It arms a watcher and sleeps until something happens:
- **Daytime (8am–11pm PT):** keep exactly one `Monitor` armed: command `node ~/.claude/scripts/imessage-tick/watch.mjs`, `timeout_ms` 1800000, description `iMessage autopilot events`. Check with TaskList-style awareness that one is not already running before arming another. The watcher prints `EVENT <event> <who>` for every notable autopilot event (the same set tick.mjs lists), `PROBLEM`/`CLEARED` for health changes (KILL, LIVE, task disabled/failing/stalled, bridge down, SMS forwarding silent), and `STALE-DRAFT` once per draft waiting 2 h. It is silent otherwise and never writes the heartbeat.
  - **On each watcher event:** run a normal tick (heartbeat, tick.mjs, problems, registry). No ScheduleWakeup.
  - **On each Monitor expiry (every 30 min):** run a normal tick (this is the fallback and keeps the heartbeat fresh), then re-arm the Monitor.
  - The watchdog's daytime stale limit is 45 min to match. No 180s ScheduleWakeup by day anymore.
  - From 11pm, don't re-arm the Monitor after it expires; the overnight cron takes over. The 8am cron tick re-arms it.
- **Overnight (12am–8am PT):** exactly 3 wakes, at ~12am, ~4am and ~8am, on a recurring CronCreate: `7 0,4,8 * * *`, prompt `/imessage`.
  - On startup, and on every tick from 11pm on, check with CronList that the cron exists, and create it if it's missing. Cron jobs are session-only and expire after 7 days.
  - From 11pm to midnight, a tick schedules its wakeup only if the wakeup lands before midnight. Otherwise the cron takes over.
  - The 12am and 4am cron ticks don't call ScheduleWakeup. The 8am tick resumes daytime pacing.
  - Overnight ticks only alert on problems, not stale drafts.
- When Ariel is talking in the session, answer him first. The tick still runs on its schedule.

`/imessage status`: one tick and a short report, with no ScheduleWakeup. `/imessage stop`: ScheduleWakeup `stop: true`.

To pause the loop on purpose: `Disable-ScheduledTask -TaskPath '\Personal\' -TaskName iMessageLoop`, then `/imessage stop`. Closing the window is not a pause, because the watchdog brings it back within ~15 min.
