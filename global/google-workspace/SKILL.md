---
name: google-workspace
description: "Structured Google Workspace access (Calendar, Docs, Sheets, Slides, Tasks, Drive) for BOTH accounts via the gws CLI: `gws-agorme` = ariel@agor.me, `gws-gmail` = ariel.agor@gmail.com. Use for agor.me calendar reads/writes, editing a Doc or Sheet's contents (cells, paragraphs), creating Slides, managing Tasks, or Drive metadata/sharing. Not for plain file copy (use the G:/H: Drive mounts) or gmail.com mail (use ~/.claude/scripts/gmail.mjs)."
---

# Google Workspace via gws (two profiles)

Installed 2026-10-09: `@googleworkspace/cli` (bin `gws`, npm global). The pasted-guide name
`@google/workspace-cli` does not exist.

## Which account
| Command | Account | Profile dir |
|---|---|---|
| `gws-agorme ...` | ariel@agor.me | `~/.config/gws-agorme` |
| `gws-gmail ...` | ariel.agor@gmail.com | `~/.config/gws-gmail` |

Never call bare `gws` (it has no profile). Wrappers live in `%APPDATA%\npm` as `.ps1` (PowerShell),
`.cmd`, and an extensionless sh script (Git Bash). From PowerShell the `.ps1` wins; the `.cmd`
strips JSON quotes, so don't call `gws-agorme.cmd` explicitly.

Scopes on both: drive, documents, spreadsheets, calendar, tasks, presentations, gmail.modify.
OAuth client = the gbrain desktop client in `mvat-focus-prod` (External, Production, so refresh
tokens don't expire weekly). Tokens are AES-encrypted files in each profile dir (keyring
backend `file`), separate from `~/.gbrain/google-tokens.json`.

## Syntax
```
gws-agorme <service> <resource> [sub-resource] <method> --params '<json>' [--json '<body json>'] [--format json|table|csv|yaml]
gws-agorme <service> --help            # resources + helpers (+read, +append, +agenda ...)
gws-agorme <service> <resource> <method> --help
```
- `--params` = URL/query params, `--json` = request body, `--page-all` = NDJSON pagination,
  `--dry-run` validates locally, `-o` saves binary output, `--upload <path>` for multipart.
- Calendar: `gws-agorme calendar events list --params '{"calendarId":"primary","timeMin":"<iso>","singleEvents":true,"orderBy":"startTime","maxResults":10}'`
- Sheets: `gws-gmail sheets spreadsheets values update --params '{"spreadsheetId":"ID","range":"Sheet1!A1","valueInputOption":"RAW"}' --json '{"values":[["x"]]}'`
- Trash a file: `drive files update --params '{"fileId":"ID"}' --json '{"trashed":true}'`
- agor.me calendars: `ariel@agor.me` (primary) and "Agor AI Consulting" (owned, `c_1171...`).

## Gotchas (found in setup)
- **Do not put `project_id` in a profile's `client_secret.json`.** gws then sends a quota-project
  header and every call fails with "Caller does not have required permission to use project
  mvat-focus-prod ... serviceUsageConsumer". Removing it fixes it.
- `gws auth login --services ...` opens an interactive picker; non-interactively it falls back
  to identity-only scopes. Re-login with explicit `--scopes` (full URLs, comma-separated), and
  with `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` + `GOOGLE_WORKSPACE_CLI_KEYRING_BACKEND=file` set.
- Every call prints `Using keyring backend: file` to stderr; ignore it.
- Writes that reach other people (invites with attendees, shares, sends) are outward actions:
  same confirmation rules as any send.
