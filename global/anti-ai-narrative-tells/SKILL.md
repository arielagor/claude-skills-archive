---
name: anti-ai-narrative-tells
description: Writes fiction that resists the structural fingerprints AI models share. Use whenever Claude is asked to write a short story, novel chapter, scene, flash fiction, dialogue exchange, or any narrative prose intended to feel human-authored. Also use to AUDIT a draft — Claude's own or a third party's — against the 30 core narrative features from the StoryScope study (Russell et al., 2026), flag AI-leaning patterns, and propose targeted rewrites. Built on a dataset of 61,608 stories where narrative structure alone hit 93.2% F1 detecting AI — so generic "write more human" prompts won't save a draft from these tells; specific structural moves will.
---

# Anti-AI Narrative Tells

Source: **StoryScope** (Russell, Rajendhran, Pham, Iyyer, Wieting — arXiv 2604.03136v4, 2026). Findings across 61,608 stories from Claude, GPT, Gemini, DeepSeek, Kimi, and humans.

The five major AI models converge on a **shared region of narrative space, well-separated from humans**. Narrative-only classifiers (no style cues) detect AI at 93.2% macro-F1, and **stay at 93.9% after style is edited out**. The tells are structural, not stylistic. Paraphrasing won't fix them; rewriting plot architecture will.

---

## Three modes

### Mode 1 — Write (default when asked to draft fiction)
Before drafting, pick **at least 4 deliberate counter-defaults** from the checklist below. Plan them at outline time, not paragraph time. Writing prose first and then editing for "humanness" is too late; the structural choices are baked in by then.

### Mode 2 — Audit (when asked to score, review, or detect AI in fiction)
Walk the draft against the **30 core features** (see `references/storyscope-30-core-features.md`). Tally AI-leaning vs human-leaning. Flag the **Claude-specific fingerprints** as priority — those are *our* tells, not generic AI ones. Report which features tilt AI and propose specific rewrites.

### Mode 3 — Rewrite (when asked to humanize a draft)
Don't paraphrase. Pick the 2–3 highest-tilt structural choices from the audit and rewrite **architecture**: reorder time, fracture the causal chain, add a subplot, change how the protagonist is introduced, give the narrator a real voice with named references and direct reader address. See `references/rewrite-moves.md`.

---

## The Default-Killer Checklist

Pick **at least 4** before drafting. The more, the better. None of these are bad in isolation — the problem is doing all the AI defaults at once.

### Plot & event structure
- [ ] **Break the single causal chain.** AI defaults to "inciting incident → escalation → resolution" with continuity 3.94/5 vs human 3.28/5. Drop a thread on purpose. Leave a loose end. Let two threads run in parallel without merging.
- [ ] **Don't let the protagonist drive the resolution.** AI ends with protagonist-choice resolution 69% of the time vs 46% human. Try: external fate, an accident, an offstage decision, ambiguous non-resolution.
- [ ] **Add at least one subplot.** 79% of AI stories have NO subplots vs 57% of human. Even a single thematically-parallel B-plot reframes the whole shape.
- [ ] **Don't resolve through internal acceptance/understanding.** AI does this 47% of the time vs 27% human. Try external resolution, or leave it unresolved.

### Time
- [ ] **Use anachrony.** Flashbacks, flash-forwards, in medias res, nonlinear framing. Human stories average 2.95/5 anachrony intensity vs AI 2.27/5. Open at the funeral. Tell it backwards. Stack two timelines.
- [ ] **Stage a revelation that forces re-reading.** Human "recontextualization depth after surprise" is 3.28/5 vs AI 2.95/5. The reader should want to flip back to chapter 2.

### Character
- [ ] **Don't introduce the protagonist by external description.** AI does this 69% of the time. Try: introduce them in-dialogue, in-action, in someone else's thought, via a document, via what they're NOT doing.
- [ ] **Make the protagonist morally ambivalent.** AI frames protagonists as "morally ambivalent/mixed" only 38% of the time vs 59% human. Give them a choice that's defensible AND ugly.
- [ ] **Sometimes just name the feeling.** AI conveys emotion through bodies/sensations 81% of the time vs 38% human. Tightening chests and dimming lamplight are AI camouflage. Sometimes the line is just: "She was tired of him."

### Theme & narrator
- [ ] **Don't have the narrator state the theme.** AI narrators explicitly comment on theme 59% of the time vs 34% human. Trust the reader. Cut the line where the lesson lands.
- [ ] **Lower thematic unity.** AI scores 3.94/5 vs human 3.28/5 on "subplots and flourishes serve a central theme." It's okay if the story is *about* multiple things, or about something you can't summarize.
- [ ] **Use specific named references, not vague allusions.** 47% of human stories use explicit named intertextual references vs 24% AI. Name the book. Name the band. Name the brand of cigarette. Don't write "an ancient text" — write "the King James."

### Voice & reader
- [ ] **Address the reader directly at least once.** 28% of human stories do this vs 7% of AI. "You, dear reader." "If you've ever..." Pick a spot.
- [ ] **Break the fourth wall.** Human stories do this 67% of the time vs 39% AI. The narrator can know they're telling a story.
- [ ] **Vary dialogue function.** AI uses dialogue for philosophical debate 59% of the time vs 34% human. Let dialogue gossip, evade, mislead, advance plot, be comic — not just teach.

### Setting & senses
- [ ] **Setting doesn't have to mirror inner state.** AI overuses pathetic fallacy. The funeral can be on a beautiful day. The breakup scene can be in a Costco.
- [ ] **Cut a sense.** AI is sensory-dense (3.93/5 vs 3.66/5) and especially smell-heavy (82% vs 57%). Write a scene with no olfactory detail. Or write one with only sound.
- [ ] **Use multiple, varied locations.** Human stories range across more locales.

---

## Claude-specific fingerprints (priority targets when *I* am writing)

These are MY tells per Table 16 of the study. Override them more aggressively than generic AI defaults.

1. **Flat event escalation.** Claude's stories have the lowest event escalation of any source studied. I write quiet and uniform. **Counter:** let stakes rise sharply. Put real escalation in the middle, not just a soft crescendo.
2. **Low event-type diversity.** I tend to repeat the same kind of beat. **Counter:** mix event types — action, overheard conversation, a document/letter, a memory, a physical task, a confrontation, a silence.
3. **Epilogue / flash-forward endings.** I disproportionately close with a "years later..." coda. **Counter:** end inside the scene. Resist the temporal step-back.
4. **No dreams or visions.** I avoid them. **Counter:** if it serves the story, let it in.
5. **Uncanny/haunted setting mood as default.** I drift to atmospheric unease. **Counter:** try a flat-lit office. A summer party. A diner at noon.
6. **Reverent/continuist literary stance.** I honor and extend conventions (62% Claude vs 39–56% others). **Counter:** subvert. Refuse the expected genre move.
7. **Quiet endings over avalanche endings.** **Counter:** sometimes blow it up.

Full per-model fingerprint table: `references/per-model-fingerprints.md`.

---

## When to use this skill

**Always trigger on:**
- Asks to write a short story, scene, chapter, flash fiction, novel passage, dialogue
- Asks to "write something" with creative/literary framing
- Asks to audit, review, score, or detect AI in fiction
- Asks to "humanize" or "make more human" an existing draft
- Any task that produces narrative prose ≥ ~500 words

**Don't trigger on:**
- Technical writing, documentation, copy, emails, blog posts that aren't narrative
- Non-fiction essays (these have their own tells — different paper)
- Single-line prompts, jokes, snippets too short to have plot structure

---

## Operating notes

- **Surface paraphrasing won't save the draft.** The study explicitly tested this: LAMP-edited Gemini stories that had cliché, redundant exposition, and purple prose rewritten out still got detected at 93.9% F1. If you've just edited word choice, you haven't done the work.
- **Don't perform humanness.** Sprinkling em-dashes, typos, or "raw" voice is style, not structure. The 30 core features are all about plot architecture, time, character framing, and narrator stance.
- **Counter-defaults aren't always right.** A genuinely tight, linear, single-track story with a moral protagonist and an internal resolution can be great. The point is *choosing it*, not falling into it. If 9 of the AI defaults fire in one story, that's the convergence.
- **For the audit mode, be specific.** Don't say "this feels AI." Say "this hits 11 of 17 AI-elevated features: linear causal chain (3), no subplots, protagonist-choice resolution, narrator states theme, embodied emotion (81%), pathetic-fallacy setting, vague intertext, no reader address."

---

## References (load on demand)

- `references/storyscope-30-core-features.md` — Full Tables 13/14/15 from the paper with means, gaps, and option values. Load this for audit mode.
- `references/per-model-fingerprints.md` — Table 16. Per-model tells for all five LLMs (Claude, GPT, Gemini, DeepSeek, Kimi). Load when auditing prose that might be from another model, or to know which Claude tells to fight hardest.
- `references/rewrite-moves.md` — Concrete rewrite patterns: how to break a single causal chain, how to introduce a protag without external description, how to use anachrony without confusing the reader.
- `references/study-summary.md` — One-page summary of the paper's methodology and key findings. Load for context or when explaining to others why these patterns matter.
