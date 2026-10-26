---
name: michelin-recipe-guide
description: >-
  Turn a few basic answers (ingredients, a theme, a meal idea, an event) into a
  three-Michelin-star, step-by-step recipe guide published as an interactive
  artifact: checklists, kitchen timers, tap-to-define technical verbs, SVG and
  animated "what it should look like" figures, a to-scale prep timeline, a
  shopping list, a plating build animation and, for contests and parties, a
  trend-aware punny name with a poster image prompt. Use when someone types
  /michelin-recipe-guide, or asks for "a recipe guide like the chili one",
  "make this a Michelin-level recipe", "turn my idea into a cook-off entry",
  "help us win the chili/bake-off/potluck", or gives ingredients or a theme and
  wants a polished interactive cooking guide.
---

# Michelin recipe guide

Simple input in, a finished interactive guide out. This skill replays the path
that produced the "K-PB&J Demon Hunters" chili guide (2026-10-22), with every
correction from that session built in, so nobody has to repeat them.

The user answers one short round of questions. Everything after that is your
job. Do not stop between phases to ask permission. Stop only at the two
checkpoints marked **CHECKPOINT**.

Files in this skill:
- `reference/example-guide.html`: the finished chili guide. Copy it as the
  starting file for every new guide. Its script is generic.
- `reference/components.md`: the markup contract for every component (steps,
  timers, verbs, figures, build animation) and how to draw the figures.
- `reference/poster-prompt.md`: the image-model prompt template, the edit
  prompts, and the QA checklist for a generated poster.

## Phase 1: Intake (one round, AskUserQuestion)

Ask at most 4 questions in one AskUserQuestion call. Offer sensible options so
the user can tap instead of type. Anything they skip gets the default in
brackets.

1. **What are we making?** The dish, ingredients, theme or meal idea, in their
   words. (Required. If they already said it in the request, skip this.)
2. **What's the occasion?** Cook-off or contest / dinner party / holiday / just
   for us. [just for us]. Ask for the date if it is an event.
3. **Who's eating, and what's off the table?** Servings or batch size, and
   allergies, diets and banned ingredients (for example "no pork").
   [4 L batch / 6 servings, no restrictions]
4. **How far do we go?** Full from-scratch Michelin (multi-day prep) / Michelin
   in one day / weeknight version. [full from-scratch]

Then decide these yourself, without asking:
- Food-safety temperature rules (cooling curves, reheat minimums): leave them
  out unless the user asks. Kitchen hazards (hot oil, sharp blades) and
  allergen labels always stay in.
- Metric weights, with the US equivalent only where people buy by unit.
- If the occasion is a contest, the guide also gets a name, a sign, and a
  poster prompt (Phase 6).

## Phase 2: Concept that actually works

A themed idea ("PB&J chili") fails when it tastes like a gimmick. Ground it:

- Find the real culinary precedent for each odd pairing and say it in one line
  (peanut and chile: mole, satay, West African groundnut stew; grape and chili:
  grape-jelly party meatballs; dried anchos taste of raisin, so fruit has a
  place to land).
- Name the one thing that will make it fail (in the chili, sweetness reading
  as candy) and design the fix into the recipe (acid at the end, the sweet
  element added in halves and tasted).
- Pick the star flavor and give it at least two textures (garlic roasted to a
  purée in the base, fried to chips on top).
- Apply every restriction from intake. Swap, do not just delete (no pork:
  80/20 ground beef does the ground pork's job; lamb if they want depth).

## Phase 3: The three-star recipe

Write it as a 3-star chef would hand it to a sous chef, then keep only the
content (the voice goes in Phase 4).

Rules:
- **Weights, not cups.** Grams and millilitres for everything, temperatures in
  °C, times in minutes, sizes in mm or cm.
- **House-made by default.** Run a make-or-buy audit on every bought
  component. Anything a judge sees on the plate or that defines the flavor is
  made from scratch. In the chili session the user rejected a jar of pepper
  jelly ("3 Michelin star, not premade garbage"), so a sauce, a jelly, a stock,
  a dressing or a garnish is never a jar or a box. Bought is fine only for
  staples nobody can taste the difference in (peanut butter, bread for
  croutons, roasted nuts). Name what you kept as bought, and why, in one line.
- **Restaurant technique where it earns its place.** For example: agar fluid
  gel at 0.8% of liquid weight for a pipeable sauce that holds a line on hot
  food; stock started in cold water, skimmed, never boiled; weigh an empty pan
  to reduce to a target weight; dry meat uncovered on a rack before searing.
- **A schedule by day.** Work backwards from service: stock and long
  reductions the day before the cook, the cook the day before service when the
  dish improves overnight, garnishes the afternoon before, service day only
  reheats and builds.
- **A garnish build in a fixed order**, identical on every plate or cup,
  crispy element last.
- **Taste checkpoints** with the fix for each failure (flat: acid; too sweet:
  acid then salt; heavy: vinegar).

## Phase 4: Plain-English rewrite (~80% ASD-STE100)

Rewrite every instruction at about 80% Simplified Technical English, the level
Ariel used for the CAM workbook guide script. Strict STE reads like a
maintenance manual; 80% reads like a clear person.

- One instruction per sentence; at most 20 words per sentence in a step.
- Active voice, imperative verbs, the condition before the action ("If a chile
  smokes, discard it.").
- A measured result instead of a vague one ("Cook for 3 minutes, until it turns
  dark red", not "until fragrant").
- One name per thing for the whole guide (always "the pot", always "the garlic
  oil"). Terminology drift is the most common lint failure.
- Warnings before the step they protect.
- No em dashes. No "-ing" forms where a plain verb works.
- Keep the reason when it helps people remember ("Dry meat browns. Wet meat
  goes grey.").
- **Technical verbs** (toast, simmer, deglaze, reduce, skim, strain, whisk...)
  stay, and every one goes into the glossary with a one-sentence STE meaning.

## Phase 5: Optional test batch

If the event is more than two days away, offer (in the final message, not as a
question) a quarter-size test batch: shortcut ingredients, and four cups that
each change one variable (more sweet, a different sweet, more of the star,
baseline), tasted blind. Its purpose is to lock the ratios.

## Phase 6: Name, sign and poster (contests and parties only)

The winning formula is a pun on something everyone at the event already knows
from the last few weeks, plus a physical prop. ("Crooked Chillary" won in 2016
with a bent ladle in the pot.)

1. **Search for what is trending now.** Run WebSearch (standard mode first,
   extended if thin) for the month's biggest news, viral moments and Halloween
   or holiday costume rankings. Never use remembered events; verify each one
   is current and cite the sources.
2. Write 6 to 10 names. Rank them by: how widely known the reference is, how
   well it fits the dish's real ingredients, and how buildable the prop is.
   Give one pick from pop culture and one political or newsy pick in the
   Chillary style, each with a sign concept, a tagline and a prop.
3. Write the poster prompt from `reference/poster-prompt.md`. Characters stay
   original, inspired by the reference rather than copied from it. If the user
   attaches photos, the characters become them.
4. **When the user posts the generated poster, QA it** against the checklist
   in that file before anything else. In the chili session the model wrote
   "J-PB&J" instead of "K-PB&J", drew an onion instead of garlic, added a
   stray circled "U", and put a crossed-out peanut (meaning "peanut-free") next
   to "CONTAINS PEANUTS". Give fixes as single-change edit prompts so the faces
   survive.

## Phase 7: Build the artifact

1. Call `Artifact` with `action: "quickstart"`, `intent: "other"`. It is a
   plain page, not a typed artifact.
2. Copy `reference/example-guide.html` to the scratchpad under a new name and
   rewrite the content. Keep the script block. Follow
   `reference/components.md` for every component. The page needs:
   - Hero: the dish's name in the display face, the one-line concept, facts
     (makes, start, serve, contains), and an SVG of the sign or poster.
   - Sticky bar: step progress (real count of steps) plus nav chips to every
     section.
   - The plan: a timeline drawn to scale by the hour, plus the kitchen-hazard
     and allergen warning.
   - Shopping list with checkboxes and exact quantities. Combine duplicates
     across components (two garlic uses become one line, with the total).
   - One section per day or phase, labelled with its start time.
   - Steps with checkboxes, quantities in bold, a timer on every timed step
     (repeating timers for "stir every N minutes"), and verbs tapped to
     define.
   - A figure wherever the cook has to judge something by eye: doneness
     color, right versus wrong (with the wrong one marked), pan spacing,
     simmer versus boil, consistency. Animate a figure only when the change
     over time is the lesson.
   - A plating build that animates the garnish layers in order and rests
     complete.
   - Technical verbs glossary.
3. **Design rules.** Read `~/.claude/DESIGN-TELLS.md`. One accent color taken
   from the dish (grape purple for a grape chili), two typefaces (a display
   face from the event's world plus a high-legibility body face), no
   monospace, no emoji, no colored card edges, no loop arrows, no meter
   without a real quantity behind it. Food colors in drawings are content and
   stay literal. Both light and dark themes.
4. Publish with `icon: "recipe"` and a one-sentence description. Every later
   change in the session is Edit plus republish to the same file path, so the
   URL never changes.
5. State in the final message which tells you checked, that the page was not
   previewed (unless it was), and that the link is private until shared from
   the page's Share menu.

## Phase 8: Hand-off message

Keep it short:
- The link.
- **CHECKPOINT:** the two or three things the user must decide or buy first
  (anything from a butcher counter, anything that needs a special store, such
  as agar or Fresno chiles).
- What is still bought and why (one line).
- The offer of a test batch, if Phase 5 applies.
- Where to shop. No connector reaches Whole Foods or Amazon. Instacart and
  Shipt connectors exist in the claude.ai connector directory if the user
  connects one, and then the shopping list can become a cart (stop before
  checkout). Butcher items are better bought in person.

## Checkpoints, summarised

- **CHECKPOINT 1:** after intake, only if a restriction or the occasion makes
  the request impossible as asked. Otherwise go straight through.
- **CHECKPOINT 2:** the hand-off message.

## Lessons from the session that built this skill

- People ask in loose words: "80% of the way to adst-ste" meant ~80% ASD-STE100
  as used in the CAM guide video script. When a term looks garbled, check
  `~/.claude/memory-home` before guessing.
- The user wants the guide to look like what it should look like. Pictures of
  targets beat adjectives.
- A recipe at Michelin level that still contains a jar is the fastest way to
  lose the user's trust.
- Trending-name ideas must come from a search done in the session.
