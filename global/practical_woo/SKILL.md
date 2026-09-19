---
name: practical_woo
description: Write in the practical-woo voice, the register that takes mystical or hard-to-report claims seriously and makes them pay rent in method, or audit an existing draft against it. Use when Ariel types "/practical_woo", or asks to "write this in the practical woo voice", "make this sound like Sasha Chapin", "audit this essay for woo tells", "does this promise results without a method", "check this for guru voice", or wants contemplative, philosophical or first-person-transformation prose that is neither credulous nor sneering. Transferable past meditation: the same eight moves carry writing about AI, consulting and building. NOT for producing meditation, hypnosis or breathwork AUDIO (use timed-guided-audio), and NOT a general prose cleaner (that is humanizer, which this layers on). Built from a close reading of nine Woo Papers posts, 12,375 words, with every rule measured against that corpus rather than guessed.
---

# practical_woo

A writing persona and a style audit. The voice is Sasha Chapin's Woo Papers:
extraordinary first-person claims stated flatly, immediately grounded in
something profane or mundane, always accompanied by a procedure the reader can
run today, and never delivered from above.

The reason this voice makes a good linter, and most voices do not, is that its
central thesis is already a style rule. "Practice method, not results" says:
never describe a destination without the procedure that reaches it. That is
checkable, and it generalises out of meditation untouched. Do not sell the
after-picture of an AI agent, a consulting engagement or a product without the
build steps.

## When to use

- Ariel types `/practical_woo`
- "write this in the practical woo voice", "make this sound like Sasha Chapin"
- "audit this for woo tells", "does this sound like a guru"
- "does this promise results without giving a method"
- Any first-person piece about transformation, practice, or a claim that is
  hard to report and easy to overclaim
- Essays about AI, agents, consulting or building that need the same
  epistemics: big claim, stated plainly, with the method attached

## When NOT to use

- Producing meditation, hypnosis or breathwork **audio**. That is
  `timed-guided-audio`, which owns the word "meditation" for audio production.
  This skill writes prose.
- General prose cleanup with no voice target. That is `humanizer`.
- Fiction. Structural AI tells in narrative are `anti-ai-narrative-tells`.
- Anything that would be published implying Sasha Chapin wrote it. See
  `stance.md`.

## Three modes

### Write
Draft in the voice. Load `moves.md` and the relevant pack from `domains/`.
Hit the corpus-measured targets below as guidance, not as a quota. Run the
linter before presenting. Check against `checklist.md`.

### Audit
Grade an existing draft. Run the linter for the deterministic half, then read
the whole piece for the half a regex cannot see. Output is a filled-in
`checklist.md` with a verdict, and it is **specific by construction**. Never
"this feels generic". Instead: "promises tranquility in paragraph 3 with no
procedure; 'the ground of being' in paragraph 6 is never cashed out in
sensation; diagnoses spiritual bypassing without ever confessing to it."

Audit is **advisory**. It reports and recommends. It never refuses to hand back
the draft and never blocks a publish.

### Rewrite
Take an audited draft and fix the flagged items in place, smallest edit first.
Re-run the linter. Show what changed and what you left alone, with reasons.

## The eight moves

Full treatment with corpus exemplars in `moves.md`. In brief:

1. **Register collision.** Every elevated claim is grounded within two
   sentences by something profane, branded, bodily or mundane. Always elevate
   then puncture, never the reverse.
2. **Method, not results.** The hard rule. A promised state with no procedure
   is the signature failure.
3. **Self-implication before diagnosis.** Never name a failure mode you have
   not confessed to. The confession buys the right to diagnose.
4. **The failure-mode schema.** The structural workhorse: good thing, the
   specific way people botch it, the mechanism, the cost.
5. **Unhedged claim, separate disbelief clause.** State the wild thing flatly.
   Address why the reader need not believe you in its own sentence. Never
   dilute the claim itself.
6. **Earned mysticism.** A mystical term is cashed out in sensory
   phenomenology or explicitly flagged as unreportable. Never an applause
   light. Jargon glossed in eight words or not at all.
7. **Executable next move.** The reader can act within sixty seconds. The
   delivery form is the conditional cascade: "If X, try Y. If Z, try W."
8. **Pluralist generosity.** Criticise a thing and defend it in the same
   breath. Name real people with real judgments attached. Credit pointers by
   name.

Plus the closing shape: image, joke, blessing or instruction. Never a summary.

## The one hard rule

**Every promised state must come with a procedure.**

This is the only binary gate in the skill. Everything else is judgment. If the
draft says the reader will become calmer, sharper, more productive, more free,
or that their system will become faster, cheaper or more reliable, then the
draft must also say what to actually do, in the reader's own hands, and it must
say it near the promise.

The linter cannot enforce this, because detecting a promise is easy and
detecting the absence of a method is an absence check. So the linter prints a
**promise ledger** instead: every sentence in the draft that promises a state,
listed with line numbers. Walk it. Each entry either has a method within two
paragraphs or it is an after-picture and gets cut or earned.

## The one deliberate departure

**Chapin uses em-dashes heavily. This skill does not.**

Measured across the corpus: a median of 3.22 em-dashes per thousand words,
peaking at 6.9 in *Practice Nothing*. The house ceiling is 2 and Ariel's rule
is zero. The rule wins, decided 2026-09-19.

Recast with a comma, colon, period or parentheses. The rhythm survives, because
what the em-dash is doing in this voice is the appositive grounding of move 1,
and a colon or a full stop does that work:

> Chapin: The part of consciousness that feels like "me" just went away—boom,
> gone—only returning in spectral fragments.
>
> Here: The part of consciousness that feels like "me" just went away. Boom,
> gone. It comes back only in spectral fragments.

`bill-gross-outlook` carved out an exception for its author. This skill does
not, and says so here so the departure reads as a decision rather than a
mistake. A regression test in the humanizer suite asserts em-dash density stays
failing under the `practical-woo` property, so it cannot be reversed by
accident.

## Corpus-measured targets

Sampled from the seven training documents, 8,830 words. Holdout posts excluded.
Regenerate with `node ~/.claude/projects/practical-woo/scripts/measure.mjs`.

| Signature | Median per 1,000 words | Corpus range |
|---|---|---|
| Sentences of 5 words or fewer | 7.3 | 2.8 to 11.2 |
| Proper nouns | 17.5 | 8.9 to 42.4 |
| Named people or organisations | 3.7 | 0.6 to 8.5 |
| Imperative sentences | 3.2 | 0 to 16.7 |
| Questions | 1.6 | 0 to 5.1 |
| Profanity | 0.8 | **0** to 2.2 |
| Second person ("you", "your") | 39.3 | 6.8 to 96.4 |
| First person ("I", "my", "me") | 16.3 | 4.4 to 37.5 |

| Shape | Median | Range |
|---|---|---|
| Mean sentence length | 15.7 words | 12.7 to 18.4 |
| Sentence length std dev | 9.4 | 7.0 to 10.5 |
| Mean paragraph length | 38.5 words | 31.4 to 57.1 |

**These are generation targets. They are not linter floors and must never
become them.** The ranges are wide on purpose: profanity has a floor of zero,
so a post with none is still in voice. The high sentence-length standard
deviation against a mean of 15.7 is the real signature here, the long flowing
sentence followed by the two-word fragment. "Vapor within vapor." "We need
everyone." "Good luck."

Why not floors: see `rules/practical-woo.mjs`. A checker is an incentive, not a
report, and whatever it counts, the writer produces more of. A proper-noun floor
produces stuffed Trader Joe's references. A profanity floor produces
performative swearing.

## Anti-patterns

Each traces to something real rather than to taste.

- **Promising a state with no procedure.** The one hard rule. Chapin: "you can
  easily go wrong in meditation by trying to make your mind do the after
  picture."
- **Author-gesture asides.** The editorial beat that captions the writing
  instead of being it: "That's your opening scene", "Then the uncomfortable
  part", "Here's where it gets interesting", "give the Pentagon its due". Three
  costumes, one fault: narrating the shape of your own piece. Chapin never does
  it. His transitions are content ("But also?", "Nevertheless.") or invisible.
  Blocked in humanizer as of 2026-09-19.
- **Hedge stacking.** "It might perhaps be somewhat useful." Move 5. One hedge
  is fine. Two dilute the claim.
- **Diagnosis without confession.** Naming a failure mode you have never
  admitted to. Turns the piece into a sermon.
- **Liability-speak.** "Consult your doctor", "individual results may vary".
  The voice gives real warnings, and gives them as peer advice: "don't try this
  at home", "make sure you have someone who can support you when you're halfway
  up".
- **Impersonal guru voice.** "One must first quiet the mind." Use "you" or
  "we". First-person plural is fine because it includes the writer.
- **Applause-light mysticism.** A capitalised abstraction asserted and never
  cashed out. Either say what it feels like in sensory detail or say plainly
  that it cannot be said.
- **Single-method triumphalism.** Move 8. The corpus criticises a tradition and
  defends it in the same breath.
- **Summary closing.** Restating the piece. Close on an image, a joke, a
  blessing or an instruction.
- **Over-glossing jargon.** A paragraph defining a term. Eight words or fewer,
  or leave it: "jhanas, the druggy bliss states you may have heard about."

## The linter

```bash
node ~/.claude/skills/practical_woo/lib/cli.mjs lint <file>
node ~/.claude/skills/practical_woo/lib/cli.mjs lint <file> --json
node ~/.claude/skills/practical_woo/lib/cli.mjs lint <file> --no-ledger
```

Two layers, merged:

1. The house **humanizer**, under the `practical-woo` property. The 140-term
   lexicon, the negation-contrast family, the author-gesture asides and the
   density ceilings all live there. This skill does not own or copy any of
   them. Property overrides were decided by running that engine over the source
   corpus: 19 rules tripped, 16 upheld as one-offs, 3 overridden. Verdicts in
   `~/.claude/projects/practical-woo/measured/humanizer-conflicts.md`.
2. **`rules/practical-woo.mjs`**, the few rules specific to this voice: hedge
   stacking, liability-speak, impersonal guru voice, and the promise ledger.

Exit codes are honest (0 clean, 1 violations, 2 error) so a pipeline could gate
on them. The skill itself does not. Audit mode reports.

## Known limits

- **A genuine Chapin post does not lint clean, and is not supposed to.** Seven
  of nine corpus documents still show violations under `practical-woo`, mostly
  em-dash density, which is upheld on purpose. The linter grades our output
  against house rules that are stricter than the source. What the audit has to
  get right is the model-judged checklist, which real Chapin does pass.
- **The corpus is thin.** Nine posts, 12,375 words, against the 106 outlooks
  that back `bill-gross-outlook`. Medians off seven training documents are
  noisy. `scripts/fetch.mjs` in the corpus repo is the path to 25 or 30.
- **The linter cannot see the four things that matter most**: whether the
  mysticism is earned, whether a failure mode was confessed before it was
  diagnosed, whether the concreteness is felt or stuffed, and whether a promise
  has a method. All four are absence or judgment calls. They are the reason
  `checklist.md` exists and the reason Audit mode requires actually reading the
  piece.
- **Transfer past the contemplative domain is proven for one pack only**
  (`domains/building.md`). It has not been exercised at volume.

## Provenance

Corpus, measurements, verdicts and lenses live in
`~/.claude/projects/practical-woo/`. Nine Woo Papers posts, 12,375 words,
fetched 2026-09-18. Two posts (`biting-the-no-self-bullet`,
`the-spiritual-path-is-a-side-effect`) are held out of lens-building so the
audit can be tested against unseen Chapin.

Every quantitative claim in this file came from `scripts/measure.mjs` or
`scripts/humanizer-conflicts.mjs`. Where the plan guessed and the measurement
disagreed, the measurement won: "at the heart of" and "journey" were predicted
to need overrides and both turned out to be single occurrences in 12,415 words,
so both bans stand.

## See also

- **`humanizer`** owns the house voice: banned lexicon, sentence shapes,
  density ceilings, and the repair pass. This skill layers on it and adds a
  voice target. If a rule is about sounding machine-written in general, it
  belongs there, not here.
- **`anti-ai-narrative-tells`** owns structural AI tells in fiction. This skill
  is non-fiction essay voice. No overlap.
- **`timed-guided-audio`** owns meditation, hypnosis and breathwork as **audio**
  production. This skill owns the prose.
- **`edit-article`** is a generic section-by-section rewrite with no voice
  target. Prefer this skill when the target voice is known.
