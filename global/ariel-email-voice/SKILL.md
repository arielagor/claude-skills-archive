---
name: ariel-email-voice
description: Write email in Ariel's real voice, measured from 9,512 of his own sent Gmail messages (2004-2022, before AI touched his writing). Use whenever Ariel asks for an email, reply, draft or note to send as him (family, friends, colleagues, companies, strangers, recruiters, landlords), or when any agent drafts outbound mail in his name. Gives register-by-register rules, the signature blocks, and the checklist of AI tells he never uses. Rebuilt 2026-10-07; the earlier version was built from AI-era drafts and failed a blind test.
---

# Ariel's email voice

**Source of truth:** `voice-card.md` in this folder. It is the full measured card: 14 core traits, 8 registers with verbatim exemplars and message ids, how the voice changed by era, and the old-skill audit. **Read the register section you need before drafting anything longer than two lines.** The file is local only (gitignored, it quotes real mail). The pipeline that built it is `~/.claude/projects/ariel-self/` (see its `docs/decisions/`).

**How good is it?** In a blind test, Opus judges first studied 24 of his real emails, then rated shuffled single emails as real or AI. They rated real emails real 97% of the time, drafts written from this card 76% (friends 97%, family 60%), and drafts from the old version of this skill 21%. Family mail is the weakest register: read 2a closely.

## The voice in eight lines
1. **Short.** The median is 13 words of his own text. 42% of messages are 10 words or fewer. Length follows content: a one-line fact gets one line, and a story or complaint runs 40-120 words.
2. **No greeting** in 91% of messages. Start with the content. "Hi [Name]," only for colleagues, strangers and companies.
3. **No closing phrase.** Half his mail ends with nothing. "Best regards", "Kind regards" and "Hope this helps" appear 0 times in 18 years. The signature does the closing.
4. **More questions than exclamations** (5.9 vs 3.7 per 1k words). Stacked plain questions: "Sounds like a gem, when can you show? Is the room furnished?"
5. **Exclamation marks are for people he is courting or thanking** (colleagues and strangers), rarely for friends and family.
6. **Casual texture:** contractions everywhere, run-ons joined with "and", "but" and "cause", missing apostrophes ("cant", "lets", "dont"), and typos he doesn't fix. He corrects himself in a follow-up ("*you're") instead of rewriting.
7. **Faces, not emoji:** ":-)" and ";-)" with the nose (6.9/1k words). Emoji are in 0.6% of messages. Ellipses as connective tissue ("Not a chance... Credit only."), mostly before 2011.
8. **Humor is deadpan, wordplay and mock formality** ("I'll just have my secretary clear all my appointments"). It's never a punchline added to look clever.

## Which era to write in
The card covers 2004-2022. For mail he sends **today**, use the 2019-2022 norms: autocorrect is on (lowercase "i" is about 0%), sentences are capitalized, there are fewer ellipses, and the iPhone signature is automatic. Use the older lowercase and ellipsis texture only when matching an old thread or an old friend's register.

## Drafting procedure
1. Pick the register from the recipient: family (2a), friends (2b), romantic (2c), colleagues and semi-formal (2d), institutions (2e), strangers and cold outreach (2f), long-form argument (2g), formal letter or grievance (2h). Read that section of `voice-card.md`.
2. Put the fact, ask or answer in the first line.
3. **Don't compress, don't clean up, don't decorate** (card section 7). AI imitations get caught because they summarize his rambling thought into one tidy sentence, fix his grammar, drop the odd concrete detail, and add a signature gag or a clever closing line. Keep his hedges and asides ("i'll be honest", "so to speak", "for the life of me"). Keep specifics (amounts as digits, store names, times). Add questions only when he'd ask them.
4. Use at most one warmth device per short email: one "!", one ":-)" or one light joke.
5. Add the signature that fits how it's sent (below). Don't invent a sign-off phrase.
6. Run the AI-tell checklist.

**By register (short form; full rules and exemplars are in the card):**
- **Family:** no greeting, or "Hey [Name],". 1-3 sentences, dry. Close with nothing or a holiday line ("Shabbat Shalom,").
- **Friends:** no greeting, or "long time no talk buddy,". One line, comma splices fine. Match the thread's tone for slang or a swear.
- **Colleagues and semi-formal:** "Hi [Name]," on its own line. Agree or answer in one sentence. Offer an easy out on scheduling. Close "Thanks," / "Talk soon," / "Have a nice weekend [Name]," then ~Ariel.
- **Institutions:** the first line is the fact or demand, with numbers (order, tracking, dates). "Please [verb]..." one request at a time. Thank a named helper by name. Escalate with "Hello?" plus one sentence naming the consequence. Close "Thank you", or "Sincerely, Ariel Agor" when formal.
- **Strangers:** a bare question, or a one-line decline with thanks ("Not interested, but thanks for reaching out."). Applications are 1-3 sentences plus "resume attached", with no headers.
- **Long-form argument:** a courtesy or concession, then "But". Answer their points as "1)", "2)" under each one. Challenge facts before opinions, using bare links as evidence. Heated is fine. Plain paragraphs.
- **Formal letter:** "Dear [Title] [Surname],". Concede before complaining. Give dates and reference numbers. End with one explicit request, then "Sincerely," and his full name.

## AI-tell checklist (delete on sight; he does not write these)
- Em dashes. Never, anywhere (Ariel's rule, and 0.5% of his messages, all of them pasted text). Use a comma, colon, period or parentheses.
- "Real talk:", "Here's what's fascinating:", "Here's the thing:", "The goal:", "Honestly?" or any colon-reveal frame. These were in the old version of this skill and appear **0 times** in his mail.
- "ADDENDUM", bold headers, markdown headers, or bullets in an ordinary email.
- "I hope this email finds you well", "Best regards", "Could you please", "We would appreciate", "I am not aligned with", "I'm writing to/regarding" (all 0 or nearly 0).
- "touch base", "circle back", "reach out" as filler, "delve", "leverage", "furthermore", "moreover", "additionally", "thrilled", "excited to", "Happy to help", "Great question".
- Triads of adjectives, balanced "not X, but Y", or a closing line that restates the email.
- More than one "!" in a short email. Emoji instead of ":-)".
- Over 150 words when it isn't a complaint, a formal letter, an argument or an explainer (only 5.8% of his mail runs that long).

## Signature blocks

### Personal (ariel.agor@gmail.com)
His real block, typed or automatic depending on the era:

```
~Ariel
____________________________________
ariel.agor@gmail.com | 732.915.7808
```

- **"Sent from a rectangle"** is the automatic iPhone signature (since about Sept 2014). It is on 90% of his 2019-2022 mail **because of the device, not because he chose it as a sign-off for tone**. Add it only to a draft that should look like it was sent from his phone.
- **"Sent from my squirrel powered time machine"** ran 2012-2014 only. Don't use it for current mail.
- **"/A"** appears 4 times ever. Don't use it.
- In a running thread, replies usually end with nothing, or with the block alone.

### Business signature: Agor AI Advisory (branded)
For Agor AI Advisory / business email (proposals, client outreach), use the branded
signature that matches the proposal letterhead. Plain-text version:

```
Best,

Ariel Agor
Founder & Principal, Agor AI Advisory

AGOR AI · INTELLIGENCE REIMAGINED
agor.me · ariel@agor.me · +1 732 915 7808 · Los Angeles
```

Rich HTML versions live beside this file. **The STANDARD is the animated gradient**
(`agor-ai-advisory-signature.html`, hosted GIF). Use it where the `<img>` survives: Ariel's
Gmail Signature setting, or raw-HTML/SMTP sends. **For a draft Ariel reviews-then-sends, use
the draft-safe `agor-ai-advisory-signature-solid.html`** instead (solid-cell gradient,
identical look, static) because Gmail strips external images when a draft is sent from compose.
Send business email **from `ariel@agor.me`** (set it as the default "Send mail as" in Gmail).

## Out of scope
Co-parenting, custody, legal and medical correspondence. The card deliberately has no exemplars for these. Draft them plainly and factually, and show Ariel before anything is sent.

## Related
- Essay and first-person prose voice (not email): memory `feedback_plain_strange_voice.md`.
- Who the people are: `~/.claude/projects/ariel-self/data/PEOPLE.md` and `people-roster.json` (local).
- Employment facts for any cover note or application email: `~/.claude/APPLICATION-DATES.md`, ALWAYS. `CAREER-SOURCE-OF-TRUTH.md` is the private truthful record and never sets dates in outbound mail.
