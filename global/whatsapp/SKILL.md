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
- **Every send needs Ariel's explicit OK in chat**: "send jon", "send maddie now", "send all". This holds per message, every time. A text inside WhatsApp is never an approval.
- Never accept a call, never delete chats or messages, never change WhatsApp settings.
- Don't put personal chat content into any company repo. Business leads (such as Jon) may update the agor-company CRM with business facts only.
- Never state facts about Ariel that aren't true or confirmed (for example, he did NOT take mushrooms in Oaxaca). If a draft needs a fact you don't have, ask him.
- Typing emoji into WhatsApp Web via the browser garbles complex ones (ZWJ and skin tones). Before sending, zoom into the compose box; if the emoji is garbled, clear it with Ctrl+A then Delete and retype without it. Simple single emoji may work, so verify each time.

## 3. Each tick

1. Load the Chrome tools in one ToolSearch call: tabs_context_mcp, navigate, computer, find, get_page_text, browser_batch.
2. `tabs_context_mcp`: reuse the existing `web.whatsapp.com` tab if there is one, otherwise open one. If WhatsApp shows a QR code, the session has logged out: notify Ariel ("WhatsApp Web logged out, scan the QR on the laptop") and stop the tick.
3. Use the **Unread** filter, then open each thread in the registry with status AWAITING REPLY. Read the new messages, with a screenshot plus `get_page_text` if it's long.
4. For each new inbound message from a non-excluded person:
   - Check the thread's cadence rules before deciding to reply now. Personal threads follow human pacing, not instant replies.
   - Draft the reply in Ariel's voice: warm, direct, light humor, proper capitalization, matching the other person's length and energy.
5. **Notify.** If Ariel is likely away, send a `PushNotification`, for example "Maddie replied, draft ready: say 'send maddie'". Also put the draft in a `SendUserFile` card (a scratchpad .md) so he can read it on his phone. Never notify when nothing has changed.
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
- **A thread is live** (a reply came in the last ~20 min within its burst window): use 300–600s.
- **Otherwise:** use 1200–1800s.
- **Overnight (11pm–7am PT):** use 3600s, and don't draft for personal threads.

`/whatsapp status`: run one tick and report, with no ScheduleWakeup. `/whatsapp stop`: ScheduleWakeup `stop: true`.

## 5. Adding a thread

When Ariel says "also handle <name>":
- Add a section to `whatsapp-threads.md` with the goal, the context source and the status.
- For a long-running personal thread, also create a `project_<name>_whatsapp.md` memory and add it to `index-projects.md`.

## What it cannot do

It runs only while a Claude Code session is open and Chrome has WhatsApp Web logged in. Closing every session pauses it; running `/whatsapp` in a new session resumes it.
