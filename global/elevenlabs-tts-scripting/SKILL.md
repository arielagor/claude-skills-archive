---
name: elevenlabs-tts-scripting
description: Expert skill for writing text scripts optimized for ElevenLabs text-to-speech generation. Use when the user asks for audio generation scripts, TTS scripts, voice-over scripts, hypnosis scripts for audio, narration scripts, dialogue scripts, or any text intended to be converted to speech via ElevenLabs. Covers both v2/v2.5 SSML-based models and v3 Audio Tag models, including voice settings, pacing, emotion, pronunciation, text normalization, and multi-speaker dialogue.
---

# ElevenLabs TTS Scripting

Write text scripts that produce natural, expressive, emotionally nuanced speech when processed through ElevenLabs text-to-speech models. This skill covers script architecture, model-specific markup, voice configuration, and genre-specific patterns.

---

## Core Principle

You are not writing text to be *read*. You are writing a **performance score** — a set of instructions that guide an AI voice model to deliver speech with the right pacing, emotion, emphasis, and rhythm. Every punctuation mark, line break, tag, and word choice is a directorial decision.

---

## Model Selection & Compatibility

ElevenLabs offers multiple model generations with different capabilities. **Always confirm which model the user intends to use** before scripting, as markup systems are incompatible across generations.

### Model Quick Reference

| Model | Markup System | Best For | Latency |
|-------|--------------|----------|---------|
| **Eleven v3** (alpha) | Audio Tags `[brackets]` + punctuation | Maximum expressiveness, audiobooks, characters, hypnosis | Higher (not real-time) |
| **Eleven v2.5 / Flash v2.5** | SSML `<break>`, `<phoneme>` | Production narration, balanced quality/speed | Low |
| **Eleven Turbo v2 / Flash v2** | SSML `<break>`, `<phoneme>` | Real-time apps, conversational agents | Ultra-low |
| **Eleven Multilingual v2** | Limited SSML, text normalization critical | Multi-language content | Medium |

**Default assumption**: If the user doesn't specify, script for **v3** with an **alternate v2.5 fallback** noted where markup differs.

---

## Voice Settings Header

Every script should begin with a **Voice Settings Block** specifying recommended configuration. These settings interact with the script's markup — a script written for low-stability creative delivery will sound wrong at high-stability robust settings.

```
---
VOICE SETTINGS
Voice: [Name or description, e.g., "British Male, Warm Contemplative" / "Female, Energetic Narrator"]
Model: [eleven_v3 / eleven_flash_v2_5 / eleven_turbo_v2_5 / etc.]
Stability: [0-100% — see guide below]
Similarity Boost: [0-100%]
Style Exaggeration: [0-100%, v2+ only]
Speaker Boost: [Enabled/Disabled]
Speed: [0.7 - 1.2, default 1.0]
---
```

### Stability Slider (Most Important Setting in v3)

| Setting | Range | Effect | Use Case |
|---------|-------|--------|----------|
| **Creative** | 0-35% | Maximum emotional range, may hallucinate | Character performances, emotional monologues |
| **Natural** | 36-65% | Balanced, closest to original voice | Narration, hypnosis, guided meditation |
| **Robust** | 66-100% | Highly stable, less responsive to tags | Consistent corporate narration, IVR |

**Rule of thumb**: The more emotional direction your script contains (audio tags, dramatic punctuation), the lower the stability should be. High stability dampens the model's responsiveness to performance cues.

### Similarity Boost
- **70-90%**: Maintains voice consistency (recommended for most uses)
- **Below 70%**: More vocal variety, risk of voice drift
- **Above 90%**: Very tight to reference, can sound constrained

---

## Pacing & Pause Control

Pacing is how you create rhythm, suspense, intimacy, and emphasis. The method depends on the model.

### V3: Punctuation + Audio Tags (NO SSML)

**V3 does NOT support SSML `<break>` tags.** Use these instead:

| Technique | Effect | Example |
|-----------|--------|---------|
| Ellipsis `...` | Natural hesitation/pause (0.5-1s) | `And as you breathe... deeper... and deeper...` |
| Em dash `—` | Sharp pause, pivot | `The door opened — and there was nothing.` |
| Double dash `--` | Short beat (0.3-0.5s) | `Stop -- and listen.` |
| Period + line break | Full stop with breath | End of paragraph = natural breathing pause |
| `[pause]` | Explicit pause tag | `[pause] Now, let that feeling settle.` |
| `[long pause]` | Extended silence | `[long pause] When you're ready...` |
| `[breathes]` | Audible breath pause | `[breathes] Okay. Let's begin.` |
| `[continues after a beat]` | Dramatic beat | `She looked at me. [continues after a beat] And smiled.` |

**Pacing principle**: Short sentences = faster pace. Long, flowing sentences with embedded commas and ellipses = slower, more contemplative delivery.

### V2/V2.5: SSML Break Tags

```xml
<break time="0.5s" />   <!-- Short pause -->
<break time="1.0s" />   <!-- Medium pause, breath beat -->
<break time="1.5s" />   <!-- Dramatic pause -->
<break time="2.0s" />   <!-- Long dramatic pause -->
<break time="3.0s" />   <!-- Maximum supported pause -->
```

**Critical warnings for SSML breaks:**
- Maximum 3.0 seconds per break
- **Do NOT overuse** — too many break tags in one generation causes instability, speed-ups, and audio artifacts
- Space them out; prefer punctuation-based pacing for natural rhythm
- Use breaks for *specific dramatic moments*, not as the primary pacing tool

### Speed Control

For v2/v2.5, the `speed` parameter (0.7-1.2) controls overall pace:
- **0.7-0.85**: Slow, meditative, hypnotic content
- **0.85-1.0**: Natural conversation, narration
- **1.0-1.2**: Energetic, urgent delivery

For v3, use audio tags:
- `[slowly]`, `[drawn out]` — decelerate
- `[rushed]`, `[quickly]` — accelerate
- `[stammers]` — broken rhythm

---

## Emotion & Delivery (V3 Audio Tags)

Audio Tags are words in **square brackets** that v3 interprets as performance cues, not spoken text. They are the primary directorial tool.

### Emotional States
```
[excited] [nervous] [frustrated] [sorrowful] [calm]
[angry] [joyful] [melancholy] [anxious] [serene]
[bored] [curious] [nostalgic] [determined] [defeated]
[tender] [wistful] [awed] [reverent] [mischievous]
```

### Reactions & Nonverbals
```
[sigh] [laughs] [chuckle] [giggle] [big laugh]
[gulps] [gasps] [whispers] [shouts] [sniffles]
[clears throat] [yawns] [groans] [hums]
[light chuckle] [sigh of relief] [suppressed laughter]
```

### Cognitive Beats
```
[pauses] [hesitates] [stammers] [resigned tone]
[trails off] [catches self] [reconsiders]
[thoughtfully] [as if remembering]
```

### Tone & Delivery Modifiers
```
[cheerfully] [flatly] [deadpan] [playfully]
[sarcastically] [warmly] [coldly] [conspiratorially]
[whispering] [shouting] [softly] [firmly]
[dramatically] [matter-of-factly] [gently]
```

### Character & Accent (V3)
```
[pirate voice] [French accent] [Australian accent]
[British accent] [old man voice] [child voice]
[robot voice] [news anchor voice]
```

### Layering Tags

Tags can be combined for nuanced delivery:
```
[hesitant][nervous] I... I'm not sure this is going to work.
[whispering][pause] Did you hear that? [rushed] Hide! Now!
[tired][sigh] I've been working for fourteen hours straight.
```

### Emotional Arcs

The best scripts evolve emotionally. Don't set one tag and leave it — shift tone as the content demands:
```
[calm] The forest was still.
[curious] But then... a sound.
[nervous] Something moving in the underbrush.
[pause]
[whispers] Don't. Move.
```

### Critical V3 Notes

1. **Audio tags are NOT spoken** — they are performance cues only
2. **Voice choice matters enormously** — the voice must be *capable* of the directed performance. A shouting voice won't convincingly whisper.
3. **IVC (Instant Voice Clones) and designed voices work best** with v3 tags. PVC (Professional Voice Clones) are not yet optimized.
4. **Lower stability = more tag responsiveness**. Creative (25-50%) for maximum expressiveness.
5. **Results are nondeterministic** — generate multiple takes and select the best one
6. **Emotional guidance text in v2/v2.5** (e.g., *"she said sadly"*) WILL be spoken and must be removed in post-production. In v3, bracketed tags are not spoken.

---

## Pronunciation Control

### V2/V2.5: SSML Phoneme Tags

Use CMU Arpabet or IPA for precise pronunciation:

```xml
<!-- CMU Arpabet -->
<phoneme alphabet="cmu-arpabet" ph="T AH0 M EY1 T OW0">tomato</phoneme>

<!-- IPA -->
<phoneme alphabet="ipa" ph="təˈmeɪtoʊ">tomato</phoneme>
```

**Rules:**
- Only works on Eleven Flash v2, Turbo v2, English v1
- Must mark stress correctly on multi-syllable words (1 = primary, 0 = no stress, 2 = secondary)
- For models without phoneme support, use alias tags:
  ```xml
  <lexeme>
    <grapheme>UN</grapheme>
    <alias>United Nations</alias>
  </lexeme>
  ```

### V3 & Universal: Creative Spelling

When tags aren't available, use creative spelling to force pronunciation:
- Capitalize for emphasis: `THIS is important`
- Hyphenate for syllable stress: `ab-so-LUTE-ly`
- Phonetic spelling: `Noo York` instead of `New York` (if mispronounced)
- Apostrophes for dropped sounds: `'cause`, `goin'`

---

## Text Normalization

TTS models can struggle with numbers, symbols, abbreviations, and acronyms. **Always normalize these in your script.**

### Numbers
| Type | Raw | Normalized |
|------|-----|-----------|
| Cardinal | `123` | `one hundred twenty-three` |
| Ordinal | `3rd` | `third` |
| Year | `2025` | `twenty twenty-five` |
| Currency | `$4.50` | `four dollars and fifty cents` |
| Phone | `555-1234` | `five five five, one two three four` |
| Time | `3:30 PM` | `three thirty PM` or `half past three` |
| Percentage | `85%` | `eighty-five percent` |

### Symbols & Abbreviations
| Raw | Normalized |
|-----|-----------|
| `&` | `and` |
| `@` | `at` |
| `Dr.` | `Doctor` |
| `vs.` | `versus` |
| `e.g.` | `for example` |
| `etc.` | `et cetera` or rephrase |
| `CEO` | `C E O` or `chief executive officer` |
| `AI` | `A I` (if you want spelled out) or leave as-is for common terms |

### General Rule
If using an LLM to generate text that feeds into TTS, instruct it: *"Write all numbers as words. Expand all abbreviations. Do not use symbols. Format text as it should be spoken aloud."*

---

## Script Architecture by Genre

### Hypnosis / Guided Meditation Scripts

This is a primary use case. Hypnosis scripts require precise pacing control, progressive relaxation cues, deepening patterns, and embedded suggestions.

**Voice Settings (Recommended):**
```
Voice: Warm, low-register voice (male or female) with natural resonance
Model: eleven_v3 (preferred) or eleven_multilingual_v2
Stability: 45-60% (Natural range — responsive but consistent)
Similarity: 75-85%
Speed: 0.75-0.85 (slower than conversational)
```

**Script Structure:**
```
1. PRE-TALK / SETTLING (1-2 min)
   - Gentle invitation to relax
   - Permission-giving language
   - Breathing synchronization

2. INDUCTION (3-8 min)
   - Progressive muscle relaxation
   - Visualization (staircase, garden, floating)
   - Counting down with embedded suggestions
   - Increasing pause lengths as depth increases

3. DEEPENER (2-5 min)
   - Body scan with heaviness/warmth suggestions
   - Ericksonian indirect methods (stories, metaphors)
   - Fractionation if needed (brief re-emergence, re-descent)

4. MAIN THERAPEUTIC CONTENT (5-20 min)
   - Core suggestions and metaphors
   - Future pacing
   - Anchoring techniques

5. POST-HYPNOTIC SUGGESTIONS (2-3 min)
   - Trigger-based suggestions for daily life
   - Reinforcement language

6. EMERGENCE or SLEEP TRANSITION
   - Counting up (emergence) OR
   - Deepening into natural sleep
```

**Hypnosis Pacing Pattern (V3):**
```
[softly][slowly] And as you settle into this comfortable position...
allow your eyes to gently close...

[pause]

Take a slow... deep breath in...

[breathes]

...and let it go.

[sigh of relief]

Good... that's right...

With each breath... you can notice...
how your body begins to feel...
just a little bit heavier...

[pause]

...a little more relaxed...

And there's nothing you need to do right now...
nothing you need to figure out...

[long pause]

Just... be here.
```

**Hypnosis Pacing Pattern (V2/V2.5):**
```
And as you settle into this comfortable position...
allow your eyes to gently close...

<break time="1.5s" />

Take a slow... deep breath in...

<break time="2.0s" />

...and let it go.

<break time="1.0s" />

Good... that's right...

<break time="1.5s" />

With each breath... you can notice...
how your body begins to feel...
just a little bit heavier...

<break time="2.0s" />

...a little more relaxed...
```

**Key Techniques for Hypnosis Scripts:**
- **Ellipses are your primary tool** — they create the characteristic slow, spacious delivery
- **Short sentences** separated by pauses create a rhythm that entrains the listener
- **Permissive language**: "you might notice", "perhaps you'll find", "allow yourself"
- **Embedded commands**: Italicize or note embedded commands for the script writer's reference — *relax deeply now* — though the AI reads them as natural text
- **Stacking adjectives with pauses**: "heavy... warm... comfortable... safe..."
- **Counting patterns**: Always slower at the bottom — increase pause time with each number
- **Avoid jarring transitions** — no sudden topic shifts or loud tag changes
- **End-of-line breathing space**: Each line should be speakable in one breath

### Narration / Audiobook Scripts

```
Voice: Match genre (warm literary fiction, crisp non-fiction, dramatic thriller)
Stability: 50-70%
Speed: 0.9-1.0
```

**Structure**: Write in natural paragraphs. Use punctuation for pacing rather than heavy tag use. Dialogue should be clearly attributed with emotional context.

```
[narrator voice] The door creaked open.

[whispers] "Is anyone there?" she called, her voice barely audible above the rain.

[pause]

[narrator voice] No response. Only the steady drumming of water against the tin roof.
```

### Comedy / Character Performance

```
Stability: 25-45% (Creative — allows vocal variety)
```

Use audio tags heavily for timing — comedy is rhythm:
```
So I walk up to the counter and I say...
[pause]
[deadpan] "I'd like to return this penguin."
[pause]
[big laugh]
The cashier just... stared at me.
[chuckle]
```

### Corporate / Educational Narration

```
Stability: 70-90% (Robust — consistent, professional)
Speed: 0.95-1.05
```

Minimal tags. Focus on clear text normalization, proper noun pronunciation, and even pacing. Use breaks sparingly for section transitions.

---

## Multi-Speaker Dialogue (V3)

V3 supports dynamic multi-speaker scripts within a single generation using a single voice. The model shifts character based on context cues:

```
[narrator voice] The detective leaned forward.

[gruff voice] "Where were you last Tuesday night?"

[nervous voice] "I... I was at home. You can check, I—"

[gruff voice][interrupting] "We already did."

[long pause]

[nervous voice][quietly] "Then you know I'm telling the truth."
```

For actual multi-speaker output with different voices, use ElevenLabs' **Create Dialogue** and **Stream Dialogue** API endpoints, which accept multiple voice IDs.

---

## Segmented Generation Strategy

For long-form content (audiobooks, full hypnosis sessions, etc.), **generate in segments** rather than one massive block:

1. **Break the script at natural transition points** (section changes, scene breaks, topic shifts)
2. **Each segment should be 500-2000 characters** for optimal quality
3. **Overlap the last sentence** of one segment with the first of the next to check tonal continuity
4. **Generate 2-3 takes per segment** and select the best
5. **Stitch in post-production** using audio editing software (Audacity, Adobe Audition, etc.)

---

## Common Pitfalls & Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Unnatural speed-ups mid-generation | Too many SSML break tags (v2) | Reduce break count, use punctuation instead |
| Audio artifacts / noise | Overstuffed markup | Simplify, reduce tag density |
| Monotone delivery | Stability too high | Lower stability, add emotional tags |
| Wrong emotion | Voice incompatible with tag | Try different voice, or adjust tag |
| Mispronunciation | Ambiguous text | Normalize numbers/acronyms, use phoneme tags |
| Inconsistent character voice | Tags not reinforced | Re-state character tags at each line |
| V3 tag spoken as text | Wrong model selected | Verify v3 is actually selected in UI/API |
| Robotic pacing | Text written like prose, not speech | Rewrite with speech rhythm — shorter clauses, more punctuation |

---

## Pre-Flight Checklist

Before delivering a script, verify:

- [ ] **Voice Settings Block** is present with model, stability, similarity, speed
- [ ] **Model-appropriate markup** (Audio Tags for v3, SSML for v2/v2.5)
- [ ] **All numbers written as words** (no digits)
- [ ] **All symbols expanded** (no &, @, %, $)
- [ ] **All abbreviations expanded** or phonetically guided
- [ ] **Pacing cues present** — ellipses, pauses, line breaks at natural breath points
- [ ] **Emotional direction** — tags or narrative context guide delivery
- [ ] **Segmentation notes** — if >2000 chars, suggest segment boundaries
- [ ] **No SSML in v3 scripts** (and no Audio Tags in v2 scripts)
- [ ] **Generation notes** — suggest number of takes, stability adjustments for tricky sections

---

## Script Template

```
================================================================
[TITLE]
ElevenLabs TTS Script — [Genre/Purpose]
================================================================

---
VOICE SETTINGS
Voice: [description]
Model: [model_id]
Stability: [X%]
Similarity Boost: [X%]
Style Exaggeration: [X%]
Speaker Boost: [Enabled/Disabled]
Speed: [X.X]
---

GENERATION NOTES:
- Recommended segment breaks: [list positions]
- Generate [N] takes per segment, select best
- [Any voice-specific notes]

================================================================
SCRIPT START
================================================================

[Script content with appropriate markup]

================================================================
SCRIPT END
================================================================

POST-PRODUCTION NOTES:
- [Any editing, stitching, or layering notes]
- [Background audio suggestions if applicable]
- [Emotional guidance text to remove (v2 only)]
```

---

## Quick Reference Card

### V3 Tags at a Glance
```
Emotions:    [excited] [nervous] [calm] [sorrowful] [curious]
Delivery:    [whispers] [shouts] [softly] [firmly] [deadpan]
Reactions:   [sigh] [laughs] [gasps] [gulps] [chuckle]
Pacing:      [pause] [long pause] [rushed] [slowly] [drawn out]
Beats:       [hesitates] [stammers] [breathes] [trails off]
Character:   [pirate voice] [French accent] [narrator voice]
Tone:        [sarcastically] [warmly] [conspiratorially] [playfully]
```

### V2/V2.5 SSML at a Glance
```xml
Pauses:        <break time="1.0s" />        (max 3.0s, use sparingly)
Pronunciation: <phoneme alphabet="cmu-arpabet" ph="...">word</phoneme>
Aliases:       <lexeme><grapheme>X</grapheme><alias>expanded</alias></lexeme>
Punctuation:   ... (hesitation)  -- (short pause)  — (pivot)
```
