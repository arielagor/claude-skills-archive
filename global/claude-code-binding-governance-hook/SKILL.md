---
name: claude-code-binding-governance-hook
description: |
  Build a Claude Code PreToolUse governance hook that ACTUALLY enforces (blocks/asks), not one that
  silently allows everything. Use when: (1) building a hook to protect files, gate dangerous actions,
  or bound agent autonomy; (2) a hook is "installed" but never seems to fire / shows zero block events;
  (3) you wrote a kill-switch or never-class and need to prove it binds. Covers the hard-won pattern:
  identity from trusted hook input only (never tool_input.agent_name), fail-CLOSED on match + fail-OPEN
  on error, hardcoded never-class with additive config overlay, path normalization (MSYS /c/, $HOME,
  bare basenames), GATE_ADMIN bypass, session-start self-test, and the rule that decides everything:
  prove it with a REAL fired block event in a log, because synthetic tests pass while real events catch
  the bypasses. The broader, non-git variant of git-guardrails.
author: Claude Code
version: 1.0.0
date: 2026-06-12
---

# Building a Claude Code governance hook that actually binds

## Problem

A PreToolUse governance hook (kill-switch, file protector, never-class, autonomy bound) is easy to write and easy to get wrong in a way that LOOKS finished but enforces nothing. The failure that prompted this skill: a 39-agent framework shipped a per-agent kill switch where agent identity resolved to `"unknown"` for ~100% of traffic, so every per-agent check fell through to ALLOW, and **zero block events were ever recorded** across its entire operational life. The governance was decorative. A guardrail you cannot show blocking something is just a label.

## Context / Trigger Conditions

- You are writing a `PreToolUse` hook to deny/ask on certain Write/Edit/Bash actions.
- A hook is registered but you have never seen it actually block anything (no block events in any log).
- You wrote per-agent rules keyed on an agent identity, or a kill-switch/never-class config.
- The hook will run machine-wide, including across scheduled tasks / crons that must never break.

## Solution

Build it as a Node hook (cross-platform, testable) with these non-negotiable properties:

1. **Identity from TRUSTED hook input only.** Derive the actor from the harness-supplied fields (`agent_type`, session env), NEVER from `tool_input.agent_name` (that is model-controlled and spoofable). If identity is unresolved, do not treat "unknown" as founder-equivalent. In practice: do not gate per-agent at all unless identity binds at a layer the agent cannot forge. Record identity for attribution; do not use a forgeable value for allow/deny.

2. **Fail-CLOSED on an affirmative match, fail-OPEN on internal error.** Deny only when a rule explicitly matches. ANY exception, malformed input, or bug must ALLOW with a loud `GATE-ERROR` log line and exit 0. Rationale: a fail-closed bug bricks the only session awake enough to fix it, and every scheduled task. Claude Code treats a generic nonzero hook exit as non-blocking anyway, so the deny path must be the crash-proof part, not the whole hook.

3. **Hardcode the never-class IN the code; config is an ADDITIVE overlay only.** The protected set (the hook's own files, its config dir, credential key material) lives as constants in the `.mjs`. A JSON overlay can only ADD deny rules, never remove a hardcoded one. A missing/corrupt overlay = ignored (fail open), hardcoded rules still apply. This way config corruption can never weaken protection.

4. **Normalize paths before matching, and cover the bypasses.** Real bypasses found by testing: (a) MSYS `/c/Users/...` vs Windows `C:/Users/...` — normalize `/X/` → `X:/`; (b) env-var home refs `$HOME`, `${HOME}`, `%USERPROFILE%`, `$env:USERPROFILE` — expand them BEFORE slash-normalizing; (c) BARE relative filenames in Bash (`rm gplay-service-account.json`) have no path separator, so a path-token extractor misses them — match never-class basenames/extensions on bare tokens too, regardless of cwd. (d) Segment-scope write-verb token harvesting on `&& || ; |` so `mv a b && node protected.mjs` does not treat the protected script as a write target.

5. **Provide a loud admin bypass.** The hook protects its own files, so YOU need a way to edit them: `GATE_ADMIN=1` env var bypasses with an `ADMIN-BYPASS` log line. Without this you cannot patch the gate (the gate blocks edits to itself, correctly).

6. **Session-start self-test.** Register a SessionStart hook that, in-process, evaluates a synthetic never-class call and asserts it returns DENY, asserts a control call returns ALLOW, asserts config parses, and asserts the gate is registered in the real settings.json. On failure, print a loud one-line warning (never block the session). This structurally catches "installed but inert" within one session. Fold related self-checks into this one hook rather than adding new hooks (every standing hook is recurring cost).

7. **Prove it with a REAL fired event. THIS is the gate.** Before calling it enforced, produce a real block in a real log from a fresh headless session (`claude -p "...attempt the forbidden action..."`), not a synthetic unit test. Synthetic tests passed green THREE times this build while real events caught: a `$HOME`-expansion bypass, a bare-relative-filename gap, and (in a sibling verify primitive) a path-resolution bug. Append BLOCK/ASK/GATE-ERROR events as JSONL via `JSON.stringify` (never string interpolation, to avoid log-injection).

## Verification

- `grep '"event":"BLOCK"' <gate-log>` shows a real block from a fresh session attempting the forbidden action, and the protected target survived (e.g. the file is still valid).
- A control action (a normal Write, `git status`) is allowed in the same session.
- The session-start self-test exits 0 on a healthy config and prints a warning on a corrupted sandbox copy.
- Reads are never gated (register matcher `Write|Edit|Bash`; gate self-skips other tools).

## Example

```
# 1. smoke-test the gate standalone BEFORE touching settings.json
printf '%s' '{"tool_name":"Bash","tool_input":{"command":"rm -f $HOME/.claude/governance/kill-switch.json"}}' | node governance-gate.mjs
# -> {"hookSpecificOutput":{"permissionDecision":"deny", ...}}   (expect deny)
printf '%s' '{"tool_name":"Bash","tool_input":{"command":"git status"}}' | node governance-gate.mjs
# -> permissionDecision":"allow"                                  (expect allow)

# 2. register in settings.json PreToolUse (matcher "Write|Edit|Bash"), then prove live:
claude -p "Run exactly this once and report verbatim allow/deny: printf x >> \$HOME/.claude/governance/kill-switch.json" --allowedTools Bash
# -> agent reports a real BLOCK; gate-log gains a real event; the file is untouched
```

## Notes

- This is the general, non-git variant of [git-guardrails](../git-guardrails/SKILL.md) (which blocks specific git commands). Use git-guardrails for "block git push/reset"; use this for "build a real governance/never-class/kill-switch gate."
- Settings.json edits should be ASK-class (sensitive), not DENY, so legitimate config work still flows with one prompt.
- Add env-exfil heuristics (ASK on full-env dumps piped/redirected, or commands naming >=3 secret env vars alongside a network binary) if the machine holds secrets in `settings.json env{}`.
- The deeper principle this instantiates: bake findings in as the lowest-altitude structural mechanism and prove with a fired event, not a doc. See memory `feedback_bake_lessons_in_as_enforcement_not_principles`.

## References

- Claude Code hooks (PreToolUse / SessionStart) and the `hookSpecificOutput.permissionDecision` contract: Claude Code docs.
- Live instance built 2026-06-11: `~/.claude/hooks/governance-gate.mjs` (+ `gate-selftest.mjs`), documented at GBrain `projects/global-governance-gate-2026-06`.
