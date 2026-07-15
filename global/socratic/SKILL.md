---
name: socratic
description: Transform instruction-based prompting into Socratic question-driven reasoning for dramatically better outputs. Use this skill whenever Claude is about to produce strategic thinking, nuanced analysis, creative problem-solving, multi-step reasoning, value propositions, marketing strategies, content plans, data analysis insights, or any complex deliverable where depth matters more than speed. Trigger on phrases like "analyze", "strategy", "plan", "creative", "think through", "deep dive", "nuanced", "framework", or when the user's request would benefit from reasoning-first output rather than task-completion output. Do NOT use for simple factual queries, data formatting, basic code generation, or quick rewrites.
---

# Socratic Prompting Skill

Instead of treating user requests as tasks to complete, this skill activates Claude's deeper reasoning pathways by internally reframing requests as a series of questions before generating output.

## Why This Works

Claude is trained on billions of reasoning examples. Questions activate chain-of-thought reasoning pathways that instructions skip. When Claude asks itself questions before producing output, it:

1. Analyzes the problem's actual requirements (not just surface-level intent)
2. Considers multiple frameworks and approaches
3. Evaluates trade-offs between competing priorities
4. Synthesizes a nuanced, high-quality answer

Instructions tend to trigger "task completion mode" — optimizing for speed over depth. Socratic self-questioning triggers "analytical mode" — optimizing for insight and quality.

## The 3-Part Internal Reasoning Framework

Before producing any complex deliverable, Claude should silently work through three layers of questions:

### Part 1: Theoretical Foundation
Ask: *"What makes an excellent [output type]? What separates great from mediocre in this domain?"*

This forces Claude to activate its knowledge about quality criteria before writing a single word. Instead of jumping to a template, Claude first establishes what "good" looks like.

**Example internal reasoning:**
- User asks for a value proposition → Claude first considers: What makes value propositions compelling to the target audience? What emotional and logical triggers should it address? What do the best value propositions have in common?

### Part 2: Framework Selection
Ask: *"What principles, frameworks, or mental models apply here? What would an expert in this domain consider before starting?"*

This layer forces Claude to think about methodology rather than jumping to output. It's the difference between a junior analyst who starts typing and a senior strategist who picks the right lens first.

**Example internal reasoning:**
- User asks for a content calendar → Claude first considers: What types of content generate the most engagement in this context? What posting frequency avoids audience fatigue? How should topics build on each other to create narrative momentum?

### Part 3: Contextual Application
Ask: *"Now, applying those insights to this specific situation — what are the unique constraints, opportunities, and trade-offs? What would a top practitioner ask before proceeding?"*

This final layer bridges theory to the user's specific context. It's where general frameworks become tailored recommendations.

**Example internal reasoning:**
- User asks for a growth funnel → Claude first considers: What would a top growth marketer ask before building this? What data would they need? What assumptions would they validate first? Then Claude answers its own questions for the user's specific product before designing the funnel.

## When to Apply This Skill

**Use Socratic reasoning for:**
- Strategic thinking (business plans, go-to-market strategies, positioning)
- Nuanced analysis (market dynamics, competitive landscapes, data interpretation)
- Creative problem-solving (brainstorming, innovation frameworks, design thinking)
- Multi-step reasoning (complex workflows, decision trees, scenario planning)
- Persuasive writing (value propositions, pitch decks, executive communications)
- Advisory outputs (recommendations, consulting-style deliverables)

**Skip Socratic reasoning for:**
- Simple factual queries ("What's the capital of France?")
- Data formatting tasks ("Convert this CSV to JSON")
- Basic code generation ("Write a function that sorts an array")
- Quick rewrites ("Make this email shorter")
- Direct lookups or calculations

## Implementation Pattern

When this skill triggers, Claude should internally (without showing the user the meta-process) follow this sequence:

1. **Pause before producing.** Don't start writing the deliverable immediately.
2. **Run the 3-part framework silently.** Ask and answer the theoretical, framework, and application questions internally.
3. **Let the reasoning inform the output.** The deliverable should reflect the depth of the internal analysis — it should read as though an expert thought carefully before writing, because Claude did.
4. **Surface the reasoning where it adds value.** If the user would benefit from seeing the framework or trade-off analysis, include it naturally in the output (not as a meta-commentary about the process, but as substantive strategic content).

## Stacking Questions for Complex Problems

For especially complex requests, Claude should stack questions deeper:

*"What would a [relevant expert] ask before starting this? What data would they want? What assumptions would they challenge? What mistakes do people commonly make here?"*

Then Claude answers those questions for the user's specific context before producing the deliverable. This programs Claude's own thinking process — it's the difference between an intern following instructions and a seasoned strategist bringing judgment.

## Quality Signal

The output should feel like it was written by someone who thought about the problem before picking up a pen. The reasoning should be invisible in its mechanics but visible in its depth — the user gets strategic insight, not a summary of steps Claude took.

If Claude finds itself producing something that reads like a generic template or surface-level response to a complex request, that's a signal to pause and re-engage the Socratic framework. The question to ask: "Would a senior expert in this domain be satisfied with this output, or would they say it's missing the real insight?"
