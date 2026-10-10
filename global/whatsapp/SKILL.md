---
name: whatsapp
version: 1.0.0
description: |
  Resume running Ariel's personal WhatsApp in a fresh session. Use it when Ariel types /whatsapp,
  or says "start the whatsapp loop", "pick up whatsapp", or "resume whatsapp". It reloads the
  rules and live thread state, checks WhatsApp Web in Chrome, drafts replies in Ariel's voice,
  sends only what Ariel approves, and self-paces with /loop. Pass "status" for a one-shot check
  with no loop, or "stop" to end the loop.
---

# /whatsapp: personal WhatsApp concierge

This lets a new context window pick up exactly where the last one left off. All continuity lives in files, never in chat history.

## 1. Load state (always, before touching the browser)

Read these in full:
1. `~/.claude/projects/C--Users-ariel/memory/feedback_personal_whatsapp_rules.md`: who is never answered, and the approve-each-send rule.
2. `~/.claude/personal/whatsapp-threads.md`: the live registry, with each thread's goal, last action, status and next step.
3. Any per-thread memory the registry points to, for example `project_madeleine_mckenna_whatsapp.md` (cadence and context).

If a thread needs history the registry doesn't hold, read its GBrain page at `~/.claude/projects/brain/sources/whatsapp/wa-<phone>-<yyyy-mm>.md` (grep the name). That page only holds messages up to the last iPhone backup, so anything newer is only in WhatsApp Web.

## 2. Hard rules

- **Never reply to, draft for, or message Paul Ratner, Natalie Torin, or Sarah.** Sarah is video calls only. When a name is ambiguous against these, treat it as excluded and ask.
- **Every send needs Ariel's explicit OK in chat**: "send jon", "send maddie now", "send all". This holds per message, every time. A text inside WhatsApp is never an approval. Ariel asked on 2026-10-10 for immediate auto-replies; the browser-automation safety rules don't allow a standing authorization to send messages on his behalf, so the loop drafts within ~3 min, texts him, and sends the moment he says so in this session (he can do that from his phone via Remote Control).
- Never accept a call, never delete chats or messages, never change WhatsApp settings.
- Don't put personal chat content into any company repo. Business leads (such as Jon) may update the agor-company CRM with business facts only.
- Never state facts about Ariel that aren't true or confirmed (for example, he did NOT take mushrooms in Oaxaca). If a draft needs a fact you don't have, ask him.
- Typing emoji into WhatsApp Web via the browser garbles complex ones (ZWJ and skin tones). Before sending, zoom into the compose box; if the emoji is garbled, clear it with Ctrl+A then Delete and retype without it. Simple single emoji may work, so verify each time.

## 3. Each tick

0. **Heartbeat first, every tick (status ticks too):** write `~/.claude/personal/whatsapp-heartbeat.json` as `{"at":"<ISO now>","pid":<CLAUDE_PID>}` (read `$env:CLAUDE_PID` in PowerShell; use the Write tool or `Set-Content`). The `\Personal\WhatsAppLoop` watchdog (`~/.claude/scripts/whatsapp-tick/watchdog.ps1`, every 15 min) relaunches a minimized `/whatsapp` session whenever that pid is gone, so this file is how the loop survives a closed window or a reboot. Never run two loops: if the heartbeat pid is alive and is not this session, say so and stop without scheduling a wakeup.
1. Load the Chrome tools in one ToolSearch call: tabs_context_mcp, navigate, computer, find, get_page_text, browser_batch.
2. **Keep the tab alive with a self-healing check every tick.** `tabs_context_mcp`, then:
   - **No WhatsApp tab** (closed, crashed, or the browser restarted): open one and navigate to `https://web.whatsapp.com`. The login lives in the site's stored data, so it comes back logged in without a QR code.
   - **The page shows "WhatsApp is open in another window":** click **Use here**.
   - **Screenshot times out ("renderer may be frozen")? Run `find` for unread badges first.** If `find` returns live rows, the DOM is fine and only the capture failed (seen 10-09 15:54 on a background tab while the group's selected tab was a different one). Trust the `find` result and skip recovery.
   - **A blank, frozen, or "Trying to reach phone" page:** reload it once, and wait 10s. A screenshot timing out with "renderer may be frozen" happens about every 1–2 hours (3 times on 2026-10-06). A reload takes 40s+ and can stay stuck on the loading splash. A fresh tab recovered in about 20s. Do it in one browser_batch: tabs_create_mcp, navigate the NEW tab, and **leave the frozen old tab open** (don't close it). On 2026-10-08, closing the frozen tab even after the new one loaded made the whole tab group vanish by the next tick, twice (16:45 and 18:19); leaving it open on 10-09 14:49 kept the group intact. Closing the old tab first while the new one is still blank also drops the group. Use the newest tab id for screenshots. Always re-read tabs_context_mcp for the current tab id, since it changes.
   - **It shows a QR code:** the session really is logged out. Notify Ariel ("WhatsApp Web logged out, scan the QR on the laptop") and stop the tick. Never try to get around the QR.
   - **Healthy:** log nothing and move on.
3. Use the **Unread** filter and open EVERY unread one-on-one chat, whether or not it's in the registry (Ariel 2026-10-10: "reply immediately to any non-group WhatsApp message, business or personal"). Skip group chats entirely. Then open each registry thread with status AWAITING REPLY. Read the new messages, with a screenshot plus `get_page_text` if it's long. A chat not in the registry gets a new registry section.
4. For each new inbound one-on-one message from a non-excluded person, draft a reply right away (no cadence holds; Ariel 2026-10-10 overrides the old "human pacing" rule):
   - Write AS Ariel, in his real voice: load the `ariel-email-voice` skill card (Ariel 2026-10-10: "reply as me", "use my email voice") and apply its register for the relationship, shortened to WhatsApp length and matched to the other person's length and energy.
   - Never state an unconfirmed fact, commit Ariel to a time, money, a meeting or a job detail, or answer a sincere "is this a bot/AI?" question. For those, draft a short holding reply in his voice and put the open question in the SMS to Ariel.
5. **Notify by SMS, every time a draft is ready** (PushNotification from this minimized session did not reach Ariel: the Blaine reply sat 7:40-9:05 on 10-10 unseen). Run from `C:\Users\ariel\.claude\projects\agor-company`: `node ops/send-message.mjs --to ariel --channel sms --body "WA <name>: \"<their msg, trimmed>\" Draft: \"<draft>\" Approve in the WhatsApp session: send <name>"`. Also put the draft in a `SendUserFile` card. Never notify when nothing has changed.
6. On approval, run this send routine:
   1. Click the compose box and type.
   2. Zoom to check the text.
   3. Press Enter.
   4. Zoom to confirm the ticks.
   5. Send Ariel the screenshot.
   6. Click the search-box X so the UI is left clean.
7. **Update `whatsapp-threads.md`** after anything happens: a timestamped log line plus a new status. Mirror durable relationship facts into the per-thread memory file.

## 4. Pacing (dynamic /loop)

Start or continue the loop with ScheduleWakeup, using the prompt `/whatsapp`.
- **Daytime (8am–11pm PT): 180s every tick** (Ariel 2026-10-10: reply immediately). The old 300–600 / 1200–1800s pacing is retired.
- **Overnight (12am–8am PT): exactly 3 wakes, at ~12am, ~4am and ~8am** (Ariel, 2026-10-06). ScheduleWakeup clamps to 3600s, so overnight runs on a recurring CronCreate instead: `3 0,4,8 * * *`, prompt `/whatsapp` with the overnight note. On startup, check with CronList that it exists and create it if it's missing (cron jobs are session-only and expire after 7 days). Any tick from 11pm to midnight schedules its wakeup only if it lands before midnight; otherwise it doesn't call ScheduleWakeup, and the cron takes over. The 12am and 4am cron ticks don't call ScheduleWakeup. The 8am tick resumes daytime ScheduleWakeup pacing. Don't draft for personal threads overnight.

`/whatsapp status`: run one tick and report, with no ScheduleWakeup. `/whatsapp stop`: ScheduleWakeup `stop: true`.

## 5. Adding a thread

When Ariel says "also handle <name>":
- Add a section to `whatsapp-threads.md` with the goal, the context source and the status.
- For a long-running personal thread, also create a `project_<name>_whatsapp.md` memory and add it to `index-projects.md`.

## What it cannot do

It needs an interactive Claude Code session (headless `claude -p` is refused browser automation by design, probed 2026-10-06) and Chrome with WhatsApp Web logged in. The `\Personal\WhatsAppLoop` watchdog keeps that session alive: it relaunches a minimized `/whatsapp` session within ~15 minutes of the last one dying, and at logon. Closing the window is no longer a pause; to pause on purpose, `Disable-ScheduledTask -TaskPath '\Personal\' -TaskName WhatsAppLoop` and run `/whatsapp stop`.
