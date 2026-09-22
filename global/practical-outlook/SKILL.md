---
name: practical-outlook
description: Write in "the practical outlook", one merged style built from bill-gross-outlook (shape, rhythm, registers, title-and-kicker, the falsifiable call) and practical_woo (epistemics, method-not-results, confession before diagnosis, the separate disbelief clause). Use when Ariel asks for the Gross-plus-woo voice, "the practical outlook", "outlook woo", or an essay that should read like a market letter with the epistemics of a practitioner. NOT for a pure Gross pastiche (use bill-gross-outlook) or a pure contemplative piece (use practical_woo).
---

# The practical outlook

One style, not two stacked. Merged on 2026-09-22 from `bill-gross-outlook` and
`practical_woo`, and first used for *Look Ma, No Hands* (agor.me/essays).

**What each parent contributes.** Gross gives the *body*: a dwelt-in personal
hook, one bridge sentence, one thesis, whiplash rhythm across four registers, a
falsifiable number with a date on it, a trade at the end, and a last line that
calls back to the title. Practical woo gives the *conscience*: every promised
state carries a procedure, the writer confesses a failure before diagnosing
anyone else's, the claim is stated flatly and the reason to doubt it gets its
own sentence, and everything criticised is also defended.

They fit because they want the same ending. Gross ends on a trade; woo ends on
something the reader can do within sixty seconds. In this style **the trade is
the executable next move.**

This is a register, not an impersonation. Neither Bill Gross nor Sasha Chapin
wrote or endorsed anything produced with it. Never borrow either man's life
(Gross's golf, age, divorce and Newport Beach; Chapin's practice history and
wife). The writer's own life, or no biographical claim at all.

## The six hard rules

Binary. A draft that breaks one is not in style, whatever else it does well.

1. **Zero em-dashes.** Gross runs 12 per thousand words; Ariel's rule is zero
   and it wins, as it did for practical_woo on 2026-09-19. The dash's dramatic
   pause becomes a full stop and a fragment. Its aside becomes parentheses. Its
   setup-payoff becomes a colon.
2. **Every promised state has a procedure** within two paragraphs, in the
   reader's own hands. Or it is fenced plainly as a disclosure, not an
   instruction.
3. **One falsifiable call, with a number or a named event and a date.** Stated
   flatly. Its disbelief clause (what would make it wrong, what you have not
   controlled for) lives in a separate sentence. No hedge inside the call.
4. **Confession before diagnosis.** Before naming a failure in others, name
   your own version of it, specifically.
5. **Nothing invented.** No invented anecdote, quote, date or event. Gross's
   licence to embroider his own life does not transfer, and a political or
   corporate event that did not happen is a published error.
6. **The last line calls back to the title and is an image, a joke, a blessing
   or an instruction.** Never a summary. Sources, if the platform wants them,
   go after it as an appendix.

## Shape

- **Title**: a song lyric, film line, pun, or terse declarative. Never a memo
  headline. Plan the callback before drafting.
- **Epigraph**: one to three lines, real, attributed. A poem, lyric or line
  from the economics cabinet (Smith, Bagehot, Keynes, Friedman). Ideally it
  carries the title noun.
- **Hook**: 150-300 words on ONE real scene from the writer's own life or work.
  Dwell. No montage.
- **Bridge**: one sentence, two at most, usually opening "Well,". It carries
  the title noun into the subject.
- **Body**: ONE thesis, run as the failure-mode schema: the good thing, the
  specific way it gets botched, the mechanism, the cost. One consensus-flip,
  resting on ONE structural fact the consensus missed. Other frames get a
  sentence each, not a section.
- **The call**: rule 3.
- **The trade**: a conditional cascade keyed to who the reader is. "If you
  hold X, open Y and look for Z. If you only want to know whether the call is
  holding, bookmark W." For a markets piece, tickers with yields.
- **Kicker**: rule 6.
- No sub-headings. Length 1,000-1,500 words.

## Voice

- **Whiplash rhythm.** A 40-word sentence, then two words. "Huh?" "Some scoop."
  The high variance is the signature of both parents.
- **Four registers, with the woo direction fixed.** Literary, folksy, wonky,
  self-mocking, all in one piece. When a sentence goes elevated, puncture it
  within two sentences with something specific and mundane: a Stocktwits
  repost, a 06:19 email, a task stuck in `Queued`. Elevate, then puncture.
  Never ramp up.
- **Rhetorical questions answered at once**, three to five per thousand words,
  one of them a single word.
- **Self-reference rotation**: "I", "yours truly", "your author". Never a
  borrowed title.
- **Colloquial seams**, two to four per thousand: "Well,", "Anyway,", "Huh?",
  "ain't", "dear reader". Never "dude" in an essay about someone else's
  seriousness.
- **One ALL-CAPS punch per piece.** Exactly one.
- **Italics** for three or more single-word emphases. **Scare quotes** around
  two or more pieces of jargon the writer is holding at arm's length.
- **One cabinet item** (Volcker, Bagehot, Buffett, Minsky, Friedman,
  Greenspan, Bernanke, 1971, 1987, 2000, 2008) and **one literary hit** beyond
  the epigraph.
- **Name real people with real judgments, criticise and defend in the same
  breath.** Gross's ridicule is allowed only when a genuine defence sits beside
  it. "Helicopter Ben" and a Nobel for bank runs, together.
- **Jargon glossed in eight words or fewer**, or not at all.
- Profanity: zero is in range. At most one, and only where a sentence would
  otherwise tip into piety.

## Conflicts between the parents, and who won

| Gross | Practical woo | Resolution |
|---|---|---|
| 12+ em-dashes per 1,000 words | Zero (Ariel) | Zero |
| Anecdote from his own colourful life, embellished | The writer's own life, or none | A real scene only, verifiable |
| Self-deprecation: age, looks, record | Self-implication before diagnosis | Record and judgement confessions, before any diagnosis; age or looks only if true |
| 3 rotating self-labels incl. "ex-Bond King" | First person or "we" | "I", "yours truly", "your author" |
| Ends on a trade (tickers) | Ends in the reader's hands | The trade is the executable move |
| Hard commit, then insurance, ~70/30 | Unhedged claim, separate disbelief clause | Commit flat; insurance in its own sentence |
| Ridicule of named actors | Pluralist generosity | Ridicule only beside a real defence |
| Kicker calls back to the title | Close on image, joke, blessing, instruction | Must be both |
| 700-900 words (independent era) | ~1,300 (corpus median) | 1,000-1,500 |
| No sub-headings | No sub-headings | No sub-headings |

## Checking a draft

Run both parents' gates, with rule 1 overriding Gross's dash floor:

```bash
node ~/.claude/skills/practical_woo/lib/cli.mjs lint <file>
```

Then walk `bill-gross-outlook/checklist.md` (skip the em-dash floor, the
"Bill Gross" sign-off and the ticker requirement unless it is a markets piece)
and `practical_woo/checklist.md` in full. Report which items passed, which
failed, and what was fixed.

The swap test from practical_woo applies twice as hard here, because Gross's
floors invite insertion: if a colloquialism, a cabinet name or a concrete noun
could be swapped for another without loss, it was stuffed to hit a count.
Take it out.
