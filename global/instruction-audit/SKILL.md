---
name: instruction-audit
description: Audit and slim everything that loads on every request (~/.claude/CLAUDE.md, memory/MEMORY.md, project CLAUDE.md files, skill and agent descriptions, settings.json, hooks). Use when Ariel types /instruction-audit, says "audit my instructions/prompt", "slim CLAUDE.md", "run the quarterly audit", or when the monthly report at ~/.claude/cron-health/instruction-audit/ says "Full pass flagged: YES". The monthly half runs unattended (\Claude\InstructionAudit, report only); this skill is the interactive half that applies findings.
---

# Instruction audit

Built 2026-10-20 from three past passes (memory index split 2026-06, prompt audit 2026-09-12 `0276a75`, context diet 2026-10-04 `7ec4d59`) plus an outside 4-step checklist. Scope: everything loaded on every request.

## Monthly (unattended: `\Claude\InstructionAudit`, 1st of the month 06:00, report only)

`node ~/.claude/scripts/instruction-audit.mjs` runs steps 1-9 and writes `~/.claude/cron-health/instruction-audit/instruction-audit-<date>.md`. It never edits an instruction file.

1. Measure first. Tokens per always-loaded surface, compared with the last line of `runs.jsonl`. Growth over 10%, or any verified high finding, flags the full pass.
2. Back up everything. Dated copy of CLAUDE.md, MEMORY.md, settings.json plus `inventory.json` (link set, line counts) under `cron-health/instruction-audit/backups/<date>/`.
3. Ask the three questions directly: duplicated rules, rules for turned-off features, conflicting orders (including old and superseding versions both still loaded).
4. Check every claim against reality: paths, scheduled tasks, settings values. Replace quoted counts with the query that answers them.
5. Name settings instead of copying them. A number or list that lives in settings.json or a hook constant is replaced by the setting's name and location.
6. Keep only how to work. Dated history, "raised from", this-week state move to the named memory file.
7. Find hook candidates: rules broken twice (recent feedback memories) or that must hold every time. A rule a hook already enforces shrinks to one line naming the hook.
8. Delete instead of prohibiting: a "never X" about something retired keeps X in context.
9. Grade and report: high, medium, low with evidence; the model must quote verbatim and unmatched quotes are marked UNVERIFIED.

## Quarterly (interactive, Jan/Apr/Jul/Oct, or when a report flags it)

Start from the newest report. Re-run `node ~/.claude/scripts/instruction-audit.mjs` first if it is older than a week.

10. Apply only verified high and medium findings, by moving text: moved text goes word for word into a `memory/reference_*.md` file and the prompt keeps the rule plus a pointer. GUESS flags are questions, not verdicts: check each before acting.
11. Prove nothing was lost. Diff the backup `inventory.json` link set against the new files: every missing link or rule must be in the archive or on an explicit deliberate-delete list. Re-measure.
12. Build approved hooks. Test each one blocks a real violation (`hooks/tests/`), then shrink the prompt rule to one line. Hook changes go through governance-gate.
13. Retire what is unused: `node ~/.claude/scripts/usage-audit/feature-usage.mjs` for skills, plugins and connectors unused 90 days; hooks that never fired. Back up settings.json before switching anything off.
14. Second opinion: `/crossfamily-council` on the diff before committing.
15. Smoke-test the pointers: in a fresh lean `claude -p` with the new CLAUDE.md, ask five questions whose answers now sit behind pointers. All five must come back right.
16. Record: commit in `~/.claude` with before/after numbers, update `project_instruction_audit` memory, report to Ariel what changed and what needs his call.

## Off-schedule triggers
- The same correction lands twice: run step 7 now.
- Always-loaded tokens up more than 10%, or a new model family ships: run the quarterly pass.

## Hard rules
- The unattended run never edits instruction files. Edits happen only in an interactive session.
- Backups holding settings.json stay in gitignored `cron-health/`; never commit them.
- Never trust a finding whose quote is UNVERIFIED without reading the file.
