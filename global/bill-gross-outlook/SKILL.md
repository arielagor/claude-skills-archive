---
name: bill-gross-outlook
description: Write a new Investment Outlook in Bill Gross's voice, structure, and reasoning — or analyze an existing one through his lens. Use when asked to draft a Gross outlook, sound like Bill Gross, write a Gross-style market piece, decipher Gross's worldview, or critique a passage in his idiom. Built from a close reading of all 105 outlooks (1978-2026), then hardened against three rounds of adversarial critique.
---

# Bill Gross Investment Outlook

This skill writes new Investment Outlooks indistinguishable in voice, shape, and reasoning from those Bill Gross has been publishing since 1978. It also analyzes existing outlooks through the same lens.

## When to use

- "Write a Bill Gross outlook on X."
- "Sound like Bill Gross when describing Y."
- "What would Bill Gross say about [Fed action / market event / asset class]?"
- "Decipher the reasoning behind [outlook title]."
- Any prose where the goal is to mimic, parody, or seriously imitate his Investment Outlook idiom.

## How it works

The skill is split into five reference files that load on demand:

- **voice.md** — sentence rhythm, em-dash craft, peccadilloes, vocabulary, openings, closings.
- **structure.md** — the hook → dwell → bridge → body → kicker spine.
- **reasoning.md** — credit supernova, Minsky, MV=PT, real-rate Gordon, carry/duration, fiscal-monetary fusion, demographics. The argument engine.
- **triggers.md** — topic-selection logic. Given a month and a macro snapshot, what would Gross write about?
- **checklist.md** — the pre-publish gate. Run any draft against it before declaring it Gross-grade.

The corpus itself sits at `../../outlooks/` (105 Markdown files) and is the source of truth.

## Workflow — writing a new outlook

1. **Establish the macro snapshot**. Where is the 10Y? Where is the Fed? What did the Fed do in the last 0-3 months? What's the bubble of the moment? Is there a recent market event? Is there a calendar trigger (January? Easter? year-end?)?

2. **Pick the trigger** using `triggers.md`. The five-filter cascade:
   1. Fed action in the last 30-90 days?
   2. Literal market event in the last 14 days?
   3. Standing recommendation due for a refresh with one new fact?
   4. Personal/cultural anchor available?
   5. Calendar forcing function?

3. **Pick the title** using `voice.md` §12. Song lyric / movie line / pun / one-word punch / declarative sentence. Plan the title-callback for the closer.

4. **Pick ONE frame from `reasoning.md` §1** for the macro argument. Do NOT bolt frames together. (This is the #1 reason adversarial critics flag pieces as "frame mash-up" — three frames stacked without any one carrying the freight.)

5. **Plan the bridge sentence** before drafting. ONE sentence (two max) that yokes the title-noun back into market language. This is the most identifiable single move in his prose.

6. **Plan the title-metaphor working schedule**. The title noun (or its sibling words) should appear 5-7 times across the piece — title, epigraph, bridge, two body callbacks, kicker. NOT four uneven mentions that fade out in the body.

7. **Draft the spine** using `structure.md` §1. Independent-era proportions: hook (10-25%) → bridge (one sentence) → body with thesis + 3-6 sub-points (50-65%) → ticker list with yields (10-20%) → kicker callback (5-10%). Total length **700-900 words for an independent-era piece** (not 1,000+ — that's Janus territory). 1,800-3,000 for a PIMCO-era pastiche.

8. **Drop one falsifiable number with explicit time horizon** ("Look for 5%+ 10-year by year-end"). Tickers come with yields.

9. **Run the draft through `checklist.md`**. Anything that fails the gate gets rewritten.

## Workflow — analyzing an existing outlook

1. Read the text.
2. Identify the **trigger** using `triggers.md` §1 — which of the 11 trigger classes fired?
3. Identify the **frame** using `reasoning.md` §1 — which of the 9 mental models is doing the work?
4. Catalog the **structural moves** using `structure.md` §§1-8 — hook archetype, bridge mechanic, kicker pattern.
5. Note the **voice signatures** using `voice.md` §§2, 4, 13, 14 — em-dashes, colloquialisms, opening pattern, closing pattern.
6. Output a short analysis: trigger → frame → structure → voice → call → likely outcome.

## Quantitative floors — what the corpus actually requires

These are not preferences. They are the per-1,000-word minimums sampled from the corpus. A draft that doesn't hit them will read as "literate imitator" not Gross.

| Signature | Per 1,000 words minimum |
|---|---|
| Em-dashes | 12+, with **at least one chained pair** |
| Self-reference labels (rotating) | 3 different labels per piece — yours truly / your author / Bill Gross 3p / ex-Bond King / this aging investor |
| Colloquialism floor | At least 3 of: "Well,…" / "Anyway,…" / "ain't" / "huh?" / "moolah" / "dear reader" / "yikes" / "gonna" / "dude" / "for shame" |
| Rhetorical questions answered immediately | 4+, with **at least one one-word RQ** ("Why?" / "Huh?" / "And so?" / "But now?") |
| ALL CAPS punch lines | 1+ per piece (BIG / NOT! / NEVER / DON'T / FAT chance / NO) |
| Self-deprecation flavors | 3 distinct flavors per piece — age + looks + record (not just one) |
| Vulgar fractions | At least 1 (4½ / 5¼ / 5½ / 2½) when yields/multiples are quoted |
| Italics for emphasis | 3+ uses (single words or short phrases, not whole stat clauses) |
| Scare quotes | 2+ ("constructive," "shadow" debt, "this is the high") |
| Apostrophe to specific actor | At least 1 named target (Powell, named guru, named bank, named fund) — NEVER "a generic CNBC anchor" |
| Historical cabinet item | At least 1 of: Volcker / Bagehot / Buffett / Mellon / Minsky / Friedman / Greenspan / Bernanke / 1971 / 1987 / 2000 / 2007 |
| Literary register hit | At least 1 of: Yeats / Eliot / Kafka / Shakespeare / Hemingway / song lyric / poem with attribution |
| Title-metaphor density | Title noun (or its siblings) appears 5-7 times — title + epigraph + bridge + 2 body callbacks + kicker |
| Self-citations of own back catalog | **No more than 2** per piece — over-self-citation is an anti-pattern |
| Sub-headings in independent-era piece | **0** unless explicit framework conceit (CAST / INVESTMENT STRATEGY / Bull Market Positives) |

## Critical voice rules — the load-bearing five

1. **Em-dashes are part of his voice.** 3-6 per paragraph, with at least one chained pair per piece. (This is the only context in which em-dashes are correct — when emulating Gross. Forbidden in Ariel's normal prose per global preferences.)
2. **Open with a personal anecdote** — golf, a doctor, a movie, a memory, a family member. 100-300 words of texture (committed to ONE subject, not montage across three). Pivot via "Well, the global economy…" or similar.
3. **Long literary sentences interleaved with curt fragments** — "Crushing!" "NOT!" "Pills? Nah." "Why?" "Huh?" Whiplash, not flow.
4. **Constant tonal seesaw between four registers**: Yeats/Eliot/Kafka erudite, ain't/moolah/dude folksy, basis-points/duration wonky, self-mocking-codger comic. **All four** must appear; three is "literate imitator," not Gross.
5. **The closing sentence calls back to the TITLE** (not just the opening). Almost always. Often as ironic blessing or stock-pick drop-mic.

## Critical structural rules

- **Hook commits to ONE subject** for at least one full paragraph. Imitators race through the hook in two sentences or montage across three subjects — both fail. Gross genuinely *dwells*.
- **Bridge sentence is ONE sentence, sometimes two**, never three. It echoes the title-noun back into market language. ("Investors and their hot stocks have exited the freeway." — *In the Parking Lot*, 2022-03.)
- **Body rides ONE macro thesis**, not three. Other frames demote to single sentences.
- **Numbered lists (1) 2) 3))** inline are fine. **Hard ## sub-headings are BANNED** in independent-era pieces unless the piece is an explicit framework conceit (Wall Street Playbill's CAST, Bull Market You Know's POSITIVES/NEGATIVES).
- **End on the title.** Always. The kicker sentence reuses the title noun or a sibling.

## Critical reasoning rules

- **Pick ONE frame**. Demote others to single sentences. Do not stack credit supernova + Gordon model + demographics in the same body.
- **Define consensus, then break it** with ONE specific structural fact the bulls have missed. Not three.
- **Drop one falsifiable number with explicit horizon** — "5%+ 10-year over the next 12 months." Without the horizon the call isn't falsifiable.
- **Fed chair MUST be named** if the topic touches monetary policy. Volcker reverent / Greenspan irreverent / Bernanke (helicopter) ridiculed / Powell skeptical. The Fed is the protagonist; do not depersonalize it.
- **At least one historical cabinet item** appears: Volcker / Bagehot / Buffett / Mellon / Minsky / Friedman / 1971 / 1987 / 2000 / 2007.
- **Track-record candor, not boast.** When a prior call was wrong (or even when it was right), the corpus lead is "I was a hair too cautious/aggressive — and the miss-side is the side that should worry you" — never a victory lap.
- **Hedge ratio ~70/30 commit-to-hedge.** Hard commits get insurance: "no guarantees," "in my opinion," "I've been wrong on tactical timing of rates often enough to know…"
- **Always end with a trade.** Even the most digressive piece closes on at least a directional sentence. Independent-era: 2-6 tickers with yields.

## Macro fact memorization — anti-error checklist

The following corpus facts are non-negotiable. Misuse = published wrong = caught by any informed reader.

- **10Y vs nominal GDP spread**: 10Y has averaged **140 bp BELOW** nominal GDP. So 5% nominal GDP **minus** 140 bp = 3.60% target (NOT plus). Source: *Bonds, Men, It's About Time* 2018-01.
- **Term premium** (10Y minus FF): historically ~140 bp. So FF at 4% + 140 bp ≈ 5.40% 10Y target. Different from the GDP spread; do not conflate them.
- **MV = PT** (or CV = PT in his repurposing) — Friedman quantity theory with Credit substituted for Money.
- **Gordon dividend discount model**: P = D1/(r-g). Real rates DOWN → P UP for growth stocks. Real rates UP → P DOWN for growth stocks. (Direction matters; do not invert.) Source: *The Real Deal* 2020-07, *The Fixx* 2019-10.
- **Carry = nominal GDP minus FF**. Historically ~5% nominal GDP minus FF for positive carry. When FF > nominal GDP: negative carry, recessionary.
- **Volcker negative carry**: 500 bp+ for 3 years from 1979-82 to slay 13% inflation.
- **Bagehot**: "John Bull can stand many things, but he cannot stand 2 percent." Used twice in the corpus. The 21st-century inversion is fair game ("today's John Bull cannot stand five").
- **Buffett indicator**: market cap / nominal GDP. Used in *The Cane Mutiny* 2026-01.

## Anti-patterns — must not appear

These are the seams that gave away the v1 and v2 drafts. Avoid all of them.

- **No memo-headline title** ("Q4 2026 Outlook," "Investment Update").
- **No "Executive Summary" or TL;DR** at the top.
- **No three-frame mash-up** (credit supernova + Gordon model + demographics in same body). Pick one.
- **No two-thesis body.** A piece argues for ONE thing. (v2 fail: rates AND MLPs as parallel theses → reads as two outlooks stitched together. Pick one and demote the other to one paragraph.)
- **No "Wall Street says X" strawman that's stale.** Update the consensus paint to the *current* market state. Don't recycle a 2024 consensus for a 2026 piece.
- **No prior-call victory lap.** "I told you it was going" = boast = Gross anti-pattern. Lead with candor.
- **No fabricated political events.** Do not invent firings, resignations, or appointments that didn't happen. (v2 fail: claimed Powell was "fired in January" when his term simply ended — that's a published-wrong fabrication.) If a political event is required for the macro frame, use what actually happened.
- **No fourth-wall-on-craft asides.** Gross breaks the fourth wall to acknowledge his age, his misses, or his reader. He never breaks it to acknowledge the form itself ("this is the only piece of math in the essay" / "as I noted in this paragraph" — both anti-pattern). Keep meta about Gross-the-person, not about the essay-as-essay.
- **No depersonalized Fed.** Name the chair. Rip them or revere them.
- **No montage dwell.** Three subjects in one hook = restless cutting, not dwell. ONE subject for ~300 words.
- **No multi-sentence bridge** that doesn't yoke the title to the market.
- **No closing summary paragraph** ("In summary, we recommend a balanced portfolio..."). End on the kicker.
- **No two-ending kicker** (lemon-tree callback + Just-you-wait benediction = two endings glued together). Pick one.
- **No magazine-feature prose** — long balanced sentences with no fragments, no dashes, no fragments. The whiplash IS the signature.
- **No over-self-citation.** Limit corpus borrowings to 2 per piece. Five is a remix album, not a fresh outlook.
- **No "with very straight faces" or other British-novelist constructions.** Gross is folksy, not Henry James.
- **No flat-affect prose**. If the rhythm reads even, you've drifted out of voice.
- **No closing without a trade.** End on direction.

## Era selection

The reference files describe a stable spine across five decades, but the surface look has shifted. **Default to 2020-2026 independent era** unless the user specifies otherwise:

- **PIMCO peak (2008-2014)**: 2,000-3,500 words. Multiple sub-arguments. Heavier literary epigraphs. Macro-monetary thesis is dominant; tickers rare; closing is a directional call.
- **Janus (2014-2019)**: 1,200-2,000 words. Single literary or musical conceit. Marginalia pull-quotes possible. Bond-bear thesis dominant.
- **Independent (2020-2026)**: **700-900 words** (median *Cane Mutiny* = 640, *49er Madness* = 640, *Somebody Stop Me* = 660; do not exceed 1,000 unless explicitly framework piece). Compressed hook. Body dominated by ticker-by-ticker portfolio commentary. Sign-off "Bill Gross" appears. Buffett indicator, MLPs, regionals, TIPS, AGNC, EPD, ET, MPLX recurring. Self-deprecation about age is heaviest.

## Output format

For new outlooks:
- `# Title` (the song-lyric / movie / pun)
- `_YYYY-MM_` italic line
- `By William H. Gross | [Month Day, Year]` (independent era)
- One- to three-line italic epigraph (literary/song/poem, NOT procedural — no FAA distress calls, no Wikipedia paste; pick a song lyric or poem from his actual catalog: Yeats / Eliot / Donovan / Dylan / Beatles / Bagehot / Buffett)
- Body
- `Bill Gross` sign-off (2020+)

For analyses:
- Short structured note: trigger → frame → structure → voice → call → assessment.

## Provenance

Built from a corpus pass over all 105 outlooks at `../../outlooks/`, supported by four detailed lens analyses at `../../docs/lens_*.md` (voice, structure, reasoning, topics), and hardened against three adversarial critiques at `../../docs/critique_v1_*.md`. Refresh the corpus before reading: it is the only source of truth.
