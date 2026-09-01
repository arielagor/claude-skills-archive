---
name: write-longform-fiction
description: |
  Run a long-form narrative build so a human actually wants to read it: a novella, a novel, a
  screenplay, or a novella-to-treatment-to-screenplay chain. Use when asked to "write a novella /
  novel / short story collection / screenplay / feature", to "turn this idea into a film", or to
  adapt prose into a script. Also use as a RESCUE when a draft has been rejected as "unreadable",
  "reads like it was written for an AI", "none of the terms make sense", or when a reader bounced
  off invented vocabulary. Enforces: research the craft and commit a rules file BEFORE any prose,
  cap invented vocabulary at three ordinary words, give the protagonist a concrete blockable want
  on a clock, never reproduce an in-world document, and lint AGAINST jargon rather than for it.
  Complements anti-ai-narrative-tells, which covers structural AI tells but not lexicon or process.
author: Claude Code
version: 1.0.0
date: 2026-09-01
---

# Write Long-Form Fiction

## Problem

Long-form narrative fails expensively. A rejected novella is 10,000 words gone, a rejected
screenplay is 80 pages gone, and the rejection usually arrives only after the whole thing exists.

The two failure modes that cost the most are both invisible while you are writing:

1. **Vocabulary-first construction.** You invent the world's terminology, then write prose that
   serves the lexicon. The result is technically coherent and unreadable.
2. **Producing before the rules exist.** You draft immediately, so the structure is baked before you
   know what good looks like, and a rejection is mysterious rather than diagnosable.

Neither is caught by a spellcheck, a lint, a word count, or an adversarial review of the premise.
All of those can pass on a draft nobody wants to read.

## Context / Trigger Conditions

Fire this skill when:

- Asked for a novella, novel, screenplay, feature, short story collection, or a multi-artifact chain
  (prose then treatment then script).
- Asked to adapt prose to screen, or to write something intended for a human audience at length.
- A draft has been rejected with any of: "unreadable", "reads like it was written for an AI",
  "none of the terms make sense", "I don't care about anyone in it", "what is a [invented noun]".
- You are about to write a "story bible" or a glossary before writing any prose. Stop and read this.

Do NOT fire for: a single scene, a short blog post, documentation (use `doc-coauthoring`), or an
article edit (use `edit-article`).

## Solution

### Phase 1: Research the craft, before any prose

Do actual research, not recall. Search for what makes the specific form work and what makes it
adaptable. Useful queries: what makes a novel adaptable to film, commercial narrative drive, beat
structure and positions, and how a specific admired book achieves its effect.

Convert the findings into a **committed rules file** (`docs/STORY-RULES.md`) with numbered, checkable
constraints. Not advice. Constraints you can fail. Commit it before writing a sentence of prose.

### Phase 2: The rules that always bind

Whatever else the research produces, these are non-negotiable, because each one has been paid for:

**R1. One-sentence premise.** If it needs a second sentence, it is not ready. It must attach to an
anxiety the reader already has, so the speculative element is a lens on something they felt this
morning.

**R2. Three invented terms maximum, all ordinary English words given a sinister job, never defined.**
Kazuo Ishiguro's entire invented vocabulary in *Never Let Me Go* is *donor*, *carer*, *completion*.
They sound like nothing. That is why they work: the horror is human language turning a tragedy into
a procedure. A capitalised compound noun ("Creditable Served Head") is a tax the reader pays before
any sentence can mean anything. An ordinary word repurposed costs nothing up front and detonates
later. Meaning arrives from the second or third use; nobody ever explains a term.

**R3. The protagonist wants something concrete, on a clock, and can be blocked.** A condition is not
a story. "She lives under a system" is a condition. "She has eleven days to reach her sister's
funeral four hundred miles away" is a story.

**R4. Never reproduce an in-world document on the page.** No forms, no clauses, no regulations. A
reader will not read a form. Whatever the form does to a person, show the person.

**R5. Curiosity and concern on every page.** Intellectual (what is going on) and emotional (what
happens to her). One without the other is a puzzle or a wallow.

**R6. The reader learns alongside the character, never ahead of her via exposition.**

**R7. Delete every science fiction element and ask whether the human story still hurts.** If not,
you have a premise, not a book.

### Phase 3: Gate before drafting

Deliver the rules file plus a brainstorm and get agreement. Do not write prose on an unapproved
premise. If two drafts have already been rejected, this gate is mandatory: stop producing entirely
and bring back rules plus a plan.

### Phase 4: Draft against the rules

Write in numbered parts assembled by a script so sections can be reordered without a rewrite.
Keep a small cast (five or six named). Externalise interiority into behaviour, image and dialogue,
because that is what survives adaptation and it is better prose regardless.

### Phase 5: Lint AGAINST vocabulary

This is the counter-intuitive one and it is the trap that cost the most.

**A checker is an incentive, not a report. Whatever it counts, you will produce more of.**

A lint that lists invented terms and flags them as "declared but unused" will cause you to insert
jargon to clear the warnings. If the right answer is "as few as possible", the tool must flag
OCCURRENCES, never absences. `scripts/lint-fiction.mjs` in this skill does it the right way round.

Tripwire: if you ever edit the manuscript to satisfy a check you wrote yourself, stop and re-read
the check.

### Phase 6: Derive the other artifacts

Order matters: **novella, then treatment derived from the novella, then screenplay derived from the
treatment.** Each derives from the finished previous artifact, never from the original plan, so
discoveries made while drafting propagate forward.

## Verification

Before delivering anything, answer all five out loud:

1. Can I say the premise in one sentence to somebody who does not read the genre?
2. Are there three invented words or fewer, and is each one an ordinary word?
3. Is there a page anywhere that explains a rule instead of showing it?
4. What does she want, who is stopping her, and what has it cost her by the one-third mark?
5. If I deleted every genre element, would the human story still hurt?

Then run the lint and confirm it reports zero banned terms and no dead vocabulary from any
abandoned draft.

Word count is a constraint to design within, not a target to optimise toward. When a draft comes in
short, the honest moves are to cut the target, add material that independently earns its place, or
report the number. Filling to a number is none of those.

## Example

A session on 2026-08-26/27 produced three complete works. The first two were rejected.

- **Draft 1** rejected on premise: an individual-scale conceit where the real extrapolation was
  population-scale.
- **Draft 2** rejected as unreadable. It had sixteen invented compound nouns and a lint that
  rewarded using them. It had survived a three-family adversarial council (Grok, GPT, Gemini) across
  three rounds, because that panel tested whether the mechanism was consistent, never whether the
  prose was any good.
- **Draft 3** accepted. Research first, an 18-constraint rules file committed before any prose,
  three invented phrases total, and a protagonist with a concrete want on an eleven-day clock.

Roughly 24,000 words were written and thrown away to learn this.

Reference implementation: `~/.claude/projects/good-company` (`docs/STORY-RULES.md`,
`docs/BRAINSTORM.md`, `scripts/lint.mjs`, `scripts/assemble.py`, `scripts/splice.py`,
`scripts/fountain-to-tex.mjs`).

## Notes

- **Relationship to `anti-ai-narrative-tells`:** that skill covers structural AI fingerprints (plot
  shape, anachrony, character framing, narrator stance) from the StoryScope study, and it is worth
  loading alongside this one. It does not cover lexicon or process. It was active during the session
  above and did not prevent either rejection, which is precisely why this skill exists. See also:
  `anti-ai-narrative-tells`.
- **An adversarial council will not save you here.** It tests claims and internal consistency, not
  whether an artifact is enjoyable, because the panel is not the audience. Ask one reviewer the flat
  question "is this any good to read, and would you finish it?" with no mention of the mechanism.
- **Screenplay rendering:** Fountain as the source of truth, converted onto the installed MiKTeX
  `screenplay.cls` via xelatex, gives true industry format with no new dependency. Note that a blank
  line inside a dialogue block ends the dialogue, so a V.O.-heavy script needs an explicit
  intra-dialogue break marker.
- **Any scripted find-and-insert must assert its anchor is unique** across the whole manuscript
  before mutating. A one-shot replace takes the first match, which will silently splice your closing
  scenes next to your opening ones if the work mirrors its first scene in its last.
- House style for Ariel: no em-dashes anywhere.

## References

- [Storgy, on restraint and ordinary language in *Never Let Me Go*](https://storgy.com/tools/work-qa/never-let-me-go/)
- [The Conversation, on Ishiguro](https://theconversation.com/kazuo-ishiguro-said-he-won-the-nobel-prize-for-making-people-cry-20-years-later-never-let-me-go-should-make-us-angry-259282)
- [Reedsy, Save the Cat beat sheet](https://reedsy.com/blog/guide/story-structure/save-the-cat-beat-sheet/)
- [StudioBinder, Blake Snyder's beats](https://www.studiobinder.com/blog/what-is-save-the-cat-screenwriting/)
- [Savannah Gilbo, narrative drive](https://www.savannahgilbo.com/blog/narrative-drive)
- [Reedsy, commercial fiction](https://reedsy.com/blog/commercial-fiction/)
- [Fiveable, novel-to-screen adaptation](https://fiveable.me/storytelling-for-film-and-television/unit-9/screen-adaptation/study-guide/Vku88ribFok1fEW3)
- [Television Academy, on *Severance*](https://www.televisionacademy.com/news/features/emmy-magazine/articles/cover-2025-03)
