---
name: imessage-transcript
description: Render any iMessage/SMS thread from the Mac's Messages database as an iMessage-style PDF (blue bubbles = Ariel's phone, grey = them), every bubble timestamped to the second in Pacific time, photos inline, tapbacks as small reaction labels, and autopilot-sent messages marked "sent by autopilot". Use when Ariel types /imessage-transcript, or asks for "a transcript / PDF / screenshot-style export of my texts with X", "export my messages with X", "send me the thread with X as a PDF".
---

# /imessage-transcript

`/imessage-transcript <name or number> [from YYYY-MM-DD] [to YYYY-MM-DD] [--groups]`

Default range is today (Pacific). One date = that day. Two dates = inclusive range.

## Run

```
node ~/.claude/skills/imessage-transcript/transcript.mjs <who> [from] [to] [--groups] [--out <pdf>] [--keep]
```

- `<who>`: a name from `~/.claude/personal/personal-autopilot/address-book-raw.txt` (full name, first or last name, or label), or a phone number / email in any format. Quote multi-word names.
- **Exit 2 = ambiguous or unknown name.** The candidates are printed. Ask Ariel which one (AskUserQuestion), then re-run with the full name or the number.
- `--groups` also includes group chats the person is in (sender shown above their bubbles). Default is 1:1 threads only (iMessage and SMS threads both).
- `--keep` keeps the temp work dir (HTML + images) for debugging.
- Prints one JSON line: `pdf`, `messages`, `images`/`imagesWanted`, `reactions`, `autopilot`.

Output: `~/.claude/personal/transcripts/<First>-<YYYY-MM-DD>.pdf` (range: `<First>-<from>_to_<to>.pdf`).

## Then

1. Read the PDF (Read tool) and check it against the JSON counts: images all embedded (`images == imagesWanted`), no empty bubbles, autopilot marks only on blue bubbles.
2. Deliver with `SendUserFile`. Personal message content never goes into a git repo, an artifact, email or any outside service.

## How it works

- Export: `ssh mac` runs `sqlite3 -json ~/Library/Messages/chat.db` (SQL sent on stdin, no quoting games). Messages are selected through `chat_handle_join`/`chat_message_join` so Ariel's own sent messages are included. The Mac's clock is Pacific, so `localtime` = PT.
- Text: `text`, or when null, decoded from `attributedBody` (typedstream: after `NSString`, `+`, then a length byte, `0x81` = u16 LE). U+FFFC stripped.
- Tapbacks (`associated_message_type` 2000-2006) attach as a label under the target bubble (matched on `associated_message_guid` minus `p:N/`); 3000+ removals are dropped; tapbacks on messages outside the range are listed at the end.
- Images: on the Mac, `sips` converts each attachment (HEIC included) to JPEG under `/tmp`, `scp` copies them back, embedded as data URIs; the Mac temp dir is removed. Non-image attachments show as a paperclip chip with the file name. `~` in `attachment.filename` = `/Users/agor`.
- Autopilot marks: `~/.claude/personal/personal-autopilot/review.jsonl` rows whose `h4` = last 4 digits, within the range ±1 day; a blue bubble is marked when its text equals `sent`/`proposed` (or one paragraph of it), or is a 15+ char prefix of it (the autopilot sometimes drops a trailing emoticon at send).
- PDF: headless Chrome `--headless=new --print-to-pdf --no-pdf-header-footer`. Do NOT add `--user-data-dir` (Chrome exits without printing on this machine).
