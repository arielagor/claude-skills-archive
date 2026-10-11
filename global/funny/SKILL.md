---
name: funny
description: Run the comedy harness (surprise search, cross-family jury, persistent comic voice, Ariel-rated reward loop). Use when Ariel types "/funny", "/funny set <topic>", "/funny on", "/funny off", "/funny rate", "/funny learn", "/funny bench", or asks to "make this funny", "punch this up with the harness", "write a set about X", "turn on funny mode". NOT for humanizing prose (humanizer) or fiction (anti-ai-narrative-tells).
---

# /funny

Repo: `C:\Users\ariel\.claude\projects\comedy-harness` (private). CLI: `npx tsx src/cli.ts <cmd>`, run from the repo root with the PowerShell tool. Read `README.md` there if anything below is unclear.

## Commands

| Ariel says | Run | Then |
|---|---|---|
| `/funny` or "make this funny" | `jokes "<situation>"` with a 1-4 sentence situation you distil from the conversation (write it to a temp file and pass `--file` if long) | Show the top 3 bits verbatim, one line each, plus the jury panel line. Say 6 bits were queued for rating. |
| `/funny set <topic>` | `set "<topic>"` (takes 3-6 min; use a 600000 ms timeout) | Send the saved `runs/set-*.md` with SendUserFile. Report words, callbacks and review scores. If exit code is 1, name the failed check. |
| `/funny on` / `off` | `on` / `off` | Funny mode starts on the NEXT prompt (UserPromptSubmit hook `~/.claude/hooks/funny-mode.mjs`). |
| `/funny rate` | Tell Ariel to run `! npx tsx C:\Users\ariel\.claude\projects\comedy-harness\src\cli.ts serve` and open the printed phone URL. It is interactive, so don't run it yourself. | |
| `/funny learn` | `learn` | Report rated count, weights before/after, Spearman, promoted/demoted. Commit `data/` and `voice/bible.md`. |
| `/funny bench` | `bench --n 20` (long: run in background) | Report the jury win rate against the 70% target and that 10 pairs went to Ariel's queue. |

## Rules

- Default families are all four. Add `--families claude` only if Ariel asks for zero API spend, and say the jury is then self-judged.
- Never post harness output anywhere outward. The only reward signal is Ariel's ratings.
- Report what the CLI printed. Don't rate the jokes yourself or call them funny; the jury and Ariel do that.
- `! ...` warnings from the CLI (a family failed) go in the report.
