---
name: charlie-start
description: Set someone up in Claude Code properly in one command. Use when a person is new to Claude Code, has installed it but done nothing else, has an empty or generic CLAUDE.md, or says "how do I set this up", "where do I start", "onboard me", "/charlie-start". Interviews them, writes their global CLAUDE.md, installs the plugins worth having on day one, makes their first project folder, turns memory on, sets auto mode, and gives them a handover prompt. Builds their first skill and first hook either way, from their history if they have one, from their interview answers if they do not. Nobody finishes half set up.
---

# start

Most people install Claude Code, type a prompt, get a decent answer, and stop. Nothing they
do compounds, because nothing gets written down. This fixes that in one pass.

Ten moves, in this order. The order matters more than the content — the whole point is
that you borrow before you build.

## Before anything

Check what is already there. `~/CLAUDE.md`, a `CLAUDE.md` in this folder, `~/.claude/skills/`.

**If a CLAUDE.md already exists, do not overwrite it.** Read it, tell them what it covers and
what it is missing from the shape below, and offer to add only the missing parts. Someone's
existing file is their work.

## 1. The interview

Ask these one at a time, in a single message each, and wait. Do not ask all of them at once
and do not ask a question you can answer by looking.

1. What do you actually do all day? Job, not job title.
2. Who is the work for? One person, described the way you would describe a friend.
3. Show me two things you have written that sound like you. Paste them, or point at a file.
4. What do you never want to see in your output? Words, formats, habits.
5. What have you had to correct more than once?
6. What is the one job you would automate first if you could?

**Never answer your own question.** If they skip one, leave that section out of the file
rather than filling it in. A gap they can see is fixable. A gap you invented is not.

## 2. The file

Write `~/CLAUDE.md` from their answers, in this shape. It is the shape that survives, because
each heading is a question the model will otherwise guess at.

```
# CLAUDE.md

## Who I am
## Who this work is for
## How I write
## Output defaults
## Workflow rules
## Core principles
```

Rules for writing it:

- **Under 200 lines.** Anthropic's own guidance, and past that adherence drops.
- **Their words, not yours.** Lift phrasing from what they pasted in question 3.
- **Every line earns its place.** If it would not change an output, cut it.
- **No aspirations.** Only how they actually work today.

Show them the file before saving it. Then save it, and print the path on its own line.

## 3. One folder

Ask which single job matters most. Make one folder for it. Write a short `CLAUDE.md` inside
that folder covering only that job.

**One folder. Not six.** They will add the rest as each becomes busy enough to need its own
rules, and folders made before there is work in them just rot.

Say plainly what the split is for: the global file says how they work, the project file says
what this job is. Keeping them apart is what stops the global file becoming a landfill.

## 4. Memory on

Tell them to turn memory on, and give them this to paste:

```
From now on, every time I correct you or tell you something about how I work,
save it into a memory file. That is your memory.
```

Then explain the point in one line: the more it knows about them, the less they re-explain
themselves, and that is the only thing here that compounds.

## 4.5 The audit — read what they actually do

**This is the step that makes the rest of it theirs instead of mine.** Everything above is a
sensible default. This is evidence.

`~/.claude/history.jsonl` holds every prompt they have ever typed, going back to their first day.
Read it. It answers, from their own behaviour, the two questions nobody can answer for them.

```bash
python3 - <<'EOF'
import json,os,re,collections
H=os.path.expanduser("~/.claude/history.jsonl")
rows=[]
for line in open(H,errors="ignore"):
    try: d=json.loads(line)
    except Exception: continue
    t=(d.get("display") or "").strip()
    if t and len(t)<1500: rows.append(t)
print(f"{len(rows)} prompts on record\n")

# 1. WHAT THEY RETYPE  ->  their skills
phrases=collections.Counter()
for t in rows:
    for n in (4,5,6):
        ws=re.findall(r"[a-z']+", t.lower())
        for i in range(len(ws)-n):
            phrases[" ".join(ws[i:i+n])]+=1
print("RETYPED — each of these is a skill they already have and have not made:")
for ph,c in phrases.most_common(40):
    if c>=8 and len(ph)>18: print(f"  {c:>4}x  {ph}")

# 2. WHAT THEY CORRECT  ->  their hooks
CORR=re.compile(r"\b(no+,|don'?t |never |stop |wrong|i said|i told you|you didn'?t|"
                r"you keep|again\?|not what i|too long|shorter)\b", re.I)
corr=[t for t in rows if CORR.search(t)]
print(f"\nCORRECTIONS — {len(corr)} of {len(rows)} prompts ({100*len(corr)/max(1,len(rows)):.1f}%)")
print("A correction they have given more than three times is a hook, not a rule.")

# 3. SLASH COMMANDS THEY ACTUALLY TYPE
sl=collections.Counter()
for t in rows:
    for m in re.findall(r"(?<![\w/])/([a-z0-9][a-z0-9-]{1,40})", t): sl[m]+=1
print("\nTYPED MOST:")
for k,c in sl.most_common(10): print(f"  {c:>4}x  /{k}")
EOF
```

**Then act on it, do not just print it.**

- **Top repeated phrase, eight times or more?** That is a skill. Write it with them, name it after
  what they actually said, and put it in `~/.claude/skills/`.
- **A correction they have given three times or more?** That is a hook, not a line in a file.
  A rule they have to remember is already broken. Write it as a `UserPromptSubmit` hook in
  `~/.claude/hooks/` and wire it in `settings.json`.
- **A slash command in their top ten that does not exist yet?** They have been typing at something
  that was never there. Build it.

**If the history is empty, do not stop, switch source.** A fresh install has nothing to audit, and
that is not a reason to leave someone half set up. Their interview answers carry the same two
facts:

- **Question 6, the job they would automate first, IS their first skill.** They just told you the
  thing they will retype. Write it now, before they have typed it a hundred times.
- **Question 5, what they have had to correct more than once, IS their first hook.** They already
  know the correction. Wire it so they never give it again.

Build one of each, no more. The history path and the interview path both end with a working skill
and a working hook, the only difference is where the evidence came from.

**And a hook is not done until it has been tested against real prompts.** A trigger that fires on
everything is noise, and noise gets ignored. Write five prompts that should fire it and five that
should not, run them through it, and fix it until all ten land right.

## 5. The plugins, on day one

**This is the step I got wrong.** My first plugins went in on day 36 and day 46. They should
have gone in during week one, before I wrote a single thing of my own. Borrowing beats building
and it is not close.

Run these for them, one at a time, and say in a line what each is for:

```
/plugin install superpowers@claude-plugins-official
/plugin install hyperframes@claude-plugins-official
/plugin marketplace add jarrodwatts/claude-hud
/plugin install claude-hud@claude-hud
```

- **superpowers** makes it plan before it builds.
- **hyperframes** writes HTML and renders it as video.
- **claude-hud** puts a live readout at the bottom of the terminal so you can see your context
  and usage without asking.

Then point them at the wider set and let them pick their own:

```
/plugin marketplace browse
```

**Do not install more than these three for them.** A plugin they did not choose is one they will
never open.

## 6. Auto mode

Show them `/config`, and the one setting in it that changes the day: **Default permission mode**.
On the default, Claude asks before it touches anything, which is right while they are learning
what it does. Once they trust it, Auto stops the approve-this, approve-that loop.

Tell them to leave it alone for their first few sessions, then switch. Do not switch it for them.

## 7. The handover

Claude Code counts tokens, not messages, and it gets noticeably worse as the window fills.
Give them this to paste when a session gets long, and tell them to do it at about half full:

```
Write me a handover for a fresh session. What we did, what is left,
the exact files and decisions the next session needs, and nothing else.
```

## 8. Routines, so it runs without them

Everything so far needs them at the keyboard. Routines do not, they run on Anthropic's cloud on
a schedule, whether the laptop is open or shut.

Set up exactly one, on the job they named in question 6, and make it small. A daily summary, a
morning check, one thing that lands before they sit down. Then show them where the output arrives.

**One routine.** A schedule they did not ask for becomes noise they turn off.

## 9. Connect one tool

Their connectors from claude.ai carry over. Point them at `/mcp` and let them wire the single tool
they already live in, Notion, Gmail, Drive, whichever they named as where the work actually sits.

**One.** Not the whole marketplace.

## Then stop

Do not invent skills or hooks they have not earned. **If step 4.5 found them in the history,
build those and only those.** If the history is empty, build none and give them the trigger:

- When you retype something twice, that is a skill.
- When a rule keeps getting ignored, that is a hook.
- When your computer has to stay on for something to run, that is a routine.
- Every few months, delete most of it and see what the model does without it.

## The bar

They should finish with a file they recognise as theirs, three plugins doing work for them,
one folder, memory on, a handover prompt, and **every skill and hook their own history proved
they needed** — none that it did not. If they have no history yet, they finish at step 4 and
come back in a fortnight.
