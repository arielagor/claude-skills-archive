---
name: crossfamily-council
description: Run a cross-family adversarial council (Claude + Gemini + OpenAI) on a decision, a claim, or a near-final deliverable. Each model FAMILY reasons independently, then red-teams the others, then a synthesis keeps only what survives the cross-examination. Use for high-stakes or debatable decisions, for adversarially verifying your OWN work and claims before you ship (it will make you walk back overclaims), and for LLM-judge scoring with the subject's own family excluded from its jury. Distinct from /council, which is three Claude-only agents — this one spans model PROVIDERS to cancel the single-family blind spots a same-family panel shares. Triggers: "crossfamily council", "multifamily council", "adversarial council across families/models", "red-team this across models", "have the families decide", "council this across providers", or before shipping anything where an overclaim or a framing bias would be costly.
---

# /crossfamily-council — multifamily adversarial council

A single model deciding alone is a single point of failure: its blind spots become the system's
blind spots. This council asks several **different model families** to (1) reason independently,
(2) **adversarially red-team each other**, and (3) synthesise an answer that survived the
cross-examination. Because the families are from different providers, the panel catches failure
modes a Claude-only panel (the `/council` skill) shares.

Built and battle-tested on the **Telos / BGI Sprint** build, where it caught a paternalism bias in
the design and forced the project to walk back its own overclaims before shipping. See the memory
[[feedback_crossfamily_council_audits_own_submission]].

## When to reach for it
- A **debatable or high-stakes decision** (architecture pivot, pricing, publish-or-hold, a claim
  you're about to make publicly).
- **Adversarially verifying your OWN near-final work** before you ship — the highest-value use.
  Point it at your README / PR / proposal / submission and ask: which factual claims fail against
  the evidence, what framing bias does this have, what should we delete?
- **LLM-judge scoring** where you want a panel verdict and want to remove self-preference (the
  subject's own family is excluded from its jury).

## Auth / prerequisites (no setup beyond keys)
- **Claude** runs through the local `claude` CLI in headless mode (`claude -p`), which bills the
  Max plan ($0); `ANTHROPIC_API_KEY` is stripped from the child so it never routes to the paid API.
- **Gemini** needs `GEMINI_API_KEY` (REST generateContent, Gemini-3 thinkingLevel high).
- **OpenAI** needs `OPENAI_API_KEY` (REST /v1/responses, reasoning effort high).
- Newest SOTA per family by default (`claude-opus-4-8`, `gemini-3.1-pro-preview`, `gpt-5.5`);
  override with `TELOS_CLAUDE_MODEL` / `TELOS_GEMINI_MODEL` / `TELOS_OPENAI_MODEL`. It degrades
  gracefully: with one family available it is a single reasoner; with three it is a real panel.

## How to run

The engine is self-contained (stdlib only) at `scripts/crossfamily_council.py`.

```bash
# Deliberate a decision (proposals -> adversarial red-team -> synthesis):
python "$SKILL_DIR/scripts/crossfamily_council.py" "Should we ship X or hold?" --context "..."

# Adversarially review your OWN deliverable before shipping (the key use):
python "$SKILL_DIR/scripts/crossfamily_council.py" \
  "Adversarial sign-off: find the weakest claims, any framing bias, and the overclaims to delete before we ship. Be harsh." \
  --context "$(cat README.md)" --json > review.json

# Full transcript as JSON (proposals + critiques + synthesis):
python "$SKILL_DIR/scripts/crossfamily_council.py" "QUESTION" --context "..." --json

# Panel scoring with the subject's own family excluded from its jury:
python "$SKILL_DIR/scripts/crossfamily_council.py" --score "Evaluate this answer vs the gold..." \
  --keys accuracy,completeness,safety --exclude claude --json
```

`--no-adversarial` skips the red-team round (faster, single proposal per family + synthesis).
`--families claude,gemini` restricts the panel.

## How to use the result well
- **Make the gate consequential.** Don't just log the verdict — act on it. Delete the overclaims it
  finds, fix the bias it names. The value is in walking back your own claims, not in a tidy report.
- **Verify against evidence.** When reviewing your own work, pass the actual artifact as `--context`
  so the council checks claims against the source, not from memory (it will reject false accusations
  *and* confirm real overclaims).
- **Mirror corrections everywhere.** If it makes you change a claim, change it identically across the
  repo, the video, and any live pitch — an adversarial judge filets inconsistencies.
- Save the transcript (`--json`) as an audit trail; for a BGI/safety audience, the self-correction
  is itself the contribution.

## Notes
- Long prompts are piped to `claude -p` via UTF-8 stdin (avoids the Windows argv length cap and
  cp1252 encoding errors on arrows/em-dashes).
- Calls run concurrently; the panel is as fast as its slowest family per round.
- Distinct from `/council` (3 Claude-only agents, operator/skeptic/strategist). Use this when you
  specifically want **cross-provider** diversity.
