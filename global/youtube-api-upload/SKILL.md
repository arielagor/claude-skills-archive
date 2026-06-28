---
name: youtube-api-upload
description: |
  Upload videos to YouTube via the Data API v3 by REUSING an existing Google
  OAuth client (e.g. a Gmail/Calendar desktop client) instead of creating a new
  one. Use when: (1) asked to "upload to YouTube via API", "post a video to my
  channel programmatically", or wire a new Google account's channel; (2) you hit
  "Google hasn't verified this app" during OAuth for a sensitive scope; (3) a
  youtube.upload token works but you can't tell which channel/account it belongs
  to; (4) you need uploads to keep working long-term (refresh-token durability).
  Covers Ariel's gbrain client (project mvat-focus-prod) and the multi-account
  labeled-token pattern. NOT for HeyGen/avatar video (use heygen) or NotebookLM.
author: Claude Code
version: 1.0.0
date: 2026-06-27
---

# YouTube Upload via API (OAuth-client reuse)

## Problem
You want to upload videos to a YouTube channel programmatically. The naive
assumption is that you need a brand-new Google Cloud project + OAuth client +
verification. In fact you can reuse an existing OAuth desktop client (the one
already minting Gmail/Calendar tokens), as long as (a) YouTube Data API v3 is
enabled in that project and (b) you request the `youtube.upload` scope at consent.
The friction is entirely in the OAuth consent UX (sensitive/unverified scope) and
in token durability, not in the API.

## Context / Trigger Conditions
- "Upload a video to YouTube via API" / "post to my channel programmatically".
- A prior diagnosis claims "scope not registered / API not enabled / needs console
  work" — VERIFY before believing it; it is often already working.
- OAuth shows **"Google hasn't verified this app"** (red triangle) for a sensitive
  scope like `youtube.upload`.
- You have a working `youtube.upload` token but can't identify its channel.
- You need a second account's channel wired alongside an existing one.

## Solution

### 0. Verify before assuming it's broken
If a token file already exists, refresh it and probe BEFORE doing any console work.
A resumable-upload init returning HTTP 200 proves the API is enabled and the scope
is accepted. Don't redo console setup that's already done.

### 1. Reuse the existing OAuth client
Ariel's gbrain desktop client lives at `~/.gbrain/google-oauth.json` (project
`mvat-focus-prod`, number 715766888296). Same client as Gmail/Calendar. YouTube
Data API v3 is already enabled there. Request scopes:
`https://www.googleapis.com/auth/youtube.upload` (+ `youtube.readonly` to identify
the channel). Use a localhost redirect (`http://localhost:8914`) desktop flow with
`access_type=offline&prompt=consent`. Add `login_hint=<email>` to pre-select the
account.

### 2. Get past the "unverified app" warning (sensitive scope)
The consent shows "Google hasn't verified this app" because the scope is sensitive
and the app isn't Google-verified. For YOUR OWN app this is safe:
Advanced → **"Go to project-<num> (unsafe)"** → check the scope boxes (or
"Select all") → **Continue**. Incremental consent (account already granted some
scope) shows "wants ADDITIONAL access" and may auto-skip the warning.

### 3. Durability — the make-or-break fact
Check the OAuth app **publishing status** (Cloud Console → Google Auth Platform →
Audience, or `/auth/audience?project=<id>`):
- **"In production"** → refresh tokens DO NOT expire. Durable. ✅
- **"Testing"** → refresh tokens expire after **7 days**. Will silently break.
A long-running daily collector on the same client is strong evidence of production
mode. Sensitive unverified scopes also impose a 100-user cap (irrelevant for
personal use) and the one-time warning above.

### 4. Identify which channel a token controls
`youtube.upload` alone can't list/delete. Add `youtube.readonly` and call
`GET https://www.googleapis.com/youtube/v3/channels?part=snippet&mine=true`. The
upload response (`videos.insert`) also returns `snippet.channelId`/`channelTitle`.
Beware: distinct accounts can have channels with the SAME title — disambiguate by
channel ID.

### 5. Multi-account: labeled per-account tokens
Store one token file per account so they never clobber each other:
`~/.gbrain/youtube-token-<label>.json`. Ariel's map:
- `gmail` = ariel.agor@gmail.com → channel `UCZQQvVESiYoOuez7hfzPYdw`
- `agorme` = ariel@agor.me → channel `UCAdI_t4ACfK0rUyud0ZgXzA`
Reusable uploader: `~/.gbrain/youtube-upload.mjs` with `auth <label>` /
`whoami <label>` / `upload <label> <file> "<title>" "<desc>" [private|unlisted|public]`.

### 6. Upload mechanics (resumable)
POST to `…/upload/youtube/v3/videos?uploadType=resumable&part=snippet,status` with
`x-upload-content-length`/`x-upload-content-type` and a JSON body
(`snippet.{title,description,categoryId}`, `status.{privacyStatus,selfDeclaredMadeForKids}`).
Read the `Location` header → PUT the raw bytes there. Response JSON has the video id.

### 7. Driving consent through claude-in-chrome
Start the localhost auth server in the BACKGROUND (it must stay listening to catch
the redirect), grab the `AUTH_URL` from its output, `navigate` the controlled tab to
it, then click Advanced → Go to project → Select all → Continue. The server exchanges
the code and writes the token; it exits 0 on success.

## Verification
- `node youtube-upload.mjs whoami <label>` returns a channel id/title (token valid +
  readonly works).
- A real `upload` returns `VIDEO_ID` + `URL`. Use `private` for throwaway tests.
- Cross-check publishing status is "In production" for durability.

## Example
```bash
cd ~/.gbrain
node youtube-upload.mjs auth agorme          # one-time: drive consent in browser
node youtube-upload.mjs whoami agorme         # CHANNEL_TITLE=Ariel Agor
node youtube-upload.mjs upload agorme clip.mp4 "My title" "desc" unlisted
```

## Notes
- `youtube.upload`/`youtube.readonly` CANNOT delete a video. Deleting needs
  `youtube` or `youtube.force-ssl` (re-consent) — or delete in YouTube Studio.
- Don't put a token in `google-tokens.json` (the Gmail/Calendar file) — keep YouTube
  tokens in separate labeled files.
- Strip `ANTHROPIC_API_KEY` is irrelevant here; these are plain Google fetch calls.
- See also: memory `reference_youtube_upload_api_working` and GBrain
  `projects/youtube-upload-api-multi-account` for the concrete account/channel map.
- Multi-statement async Node → write a `.mjs` with top-level await, not `node -e`
  (see memory `feedback_node_inline_async_use_mjs_file`).

## References
- Google Identity: OAuth app verification & "unverified app" screen (sensitive scopes).
- Google Identity: refresh token expiration — apps in "Testing" status expire refresh
  tokens after 7 days; "In production" do not.
- YouTube Data API v3: `videos.insert` resumable upload protocol.
