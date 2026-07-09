---
name: "user-onboarding"
description: "Design and improve product user onboarding (first-time user experience) to drive activation and early retention. Produces an Onboarding & Activation Pack (aha moment spec, first 30 seconds + first mile plan, onboarding journey map, experiment backlog, measurement plan). Use for Growth teams."
---

# User Onboarding

## Workspace Context

**Products & Payment Rails:** iOS apps (gifloop, MVAT Focus, MVAT Mirror, Coquí Chorus) use Apple StoreKit IAP; MVAT Focus also has Stripe web tier; modelstack.digital uses Stripe Payment Links + Netlify webhook + Gmail SMTP download email; agor.me uses Google Calendar booking widget + SMS/email confirmation. Read the relevant `briefs/ios-apps.md` or `briefs/modelstack.md` before designing onboarding. All drafts to `content/<platform>/drafts/YYYY-MM-DD_*.md`.

## Operating Contract

This skill is self-contained for its frontmatter scope: use its local instructions, references, scripts, and assets as the playbook; ask only for missing task-specific inputs; hand off to adjacent skills instead of expanding scope; and return an actionable artifact, decision, plan, draft, or diagnostic.



## Scope

**Covers**
- First-time user experience (FTUE) from app launch (iOS) or checkout page (web) → first value
- Activation / “aha moment” definition and time-to-value reduction
- “First 30 seconds” experience spec and “first mile” onboarding (milestones to activation)
- In-app onboarding: progressive disclosure, guided setup, empty states, templates, feedback loops
- Post-payment onboarding (download email UX, credential delivery, setup confirmation)
- Instrumentation + experiments for activation and early retention

**When to use**
- iOS app: “Users churn before first meaningful action” / “time-to-IAP is too long”
- Stripe/modelstack: “Download email doesn’t convert to first use” / “file arrives but users don’t open it”
- “First session doesn’t feel valuable” / “users don’t complete setup”
- “Design a first-30-seconds experience and first-mile plan”
- “Create onboarding experiments + measurement plan”

**When NOT to use**
- Employee onboarding, service training, HR processes (use dedicated HR/ops tools)
- No stable value prop / ICP yet (use `product-market-fit-analysis` first)
- Need full retention strategy beyond onboarding (use `customer-success-and-retention`)
- Need checkout page copy review (use `conversion-rate-optimization`)

## Inputs

**Minimum required**
- Product + ICP/segment(s) (1–2) and the primary job-to-be-done
- Platform + payment rail + entry point (iOS IAP / web Stripe checkout / Google Calendar booking)
- Best-available baseline metrics (even rough):
  - iOS: app install → first action → IAP prompt → purchase → post-purchase engagement
  - Web: checkout click → payment → download email → file open → first use
  - D1/D7 retention (if available)
- Current FTUE summary (steps/screens) + biggest drop-off point(s)
- Constraints: eng/design capacity, privacy/legal limits, can't change payment rails themselves

**Missing-info strategy**
- Ask up to 5 questions from [references/INTAKE.md](references/INTAKE.md), then proceed.
- If metrics are missing, proceed with explicit assumptions and label confidence.
- Do not request secrets or PII; prefer aggregated funnels and redacted screenshots.

## Outputs (deliverables)

Produce an **Onboarding & Activation Pack** (Markdown in-chat; or as files if requested) containing:

1) Context snapshot (goal, segment, constraints, baseline)
2) Current FTUE map (step-by-step) + friction log
3) Activation / aha moment spec (behavioral definition + threshold + validation plan)
4) “First 30 seconds” experience spec (magic moment + success criteria)
5) “First mile” onboarding plan (milestones to activation; mechanics per milestone)
6) Experiment backlog (prioritized) + 3–5 experiment cards
7) Measurement + instrumentation plan (events, properties, dashboards, guardrails)
8) Rollout/rollback + risk plan
9) Risks / Open questions / Next steps (always included)

Templates and checklists:
- [references/TEMPLATES.md](references/TEMPLATES.md)
- [references/WORKFLOW.md](references/WORKFLOW.md)
- [references/CHECKLISTS.md](references/CHECKLISTS.md)
- [references/RUBRIC.md](references/RUBRIC.md)

## Workflow (7 steps)

### 1) Intake + goal framing (activation-first)
- **Inputs:** User prompt; [references/INTAKE.md](references/INTAKE.md).
- **Actions:** Define the primary segment and the activation outcome. Make the goal measurable (baseline → target, date). Capture constraints and guardrails (e.g., don’t increase drop-off, don’t add dark patterns).
- **Outputs:** Context snapshot + goal statement.
- **Checks:** Goal is one sentence with a metric, baseline, target, and date.

### 2) Map the current first-time journey (FTUE)
- **Inputs:** Current flow description/screens; funnel + drop-offs; support/sales notes if available.
- **Actions:** Create a step-by-step journey map from entry → first value. Log frictions (confusion, time, permissions, empty states, choice overload). Identify the single biggest leak.
- **Outputs:** FTUE map table + friction log + primary leak.
- **Checks:** Every step has a user goal, product action, and a measurable checkpoint (event or proxy).

### 3) Define the activation / “aha moment” (behavioral)
- **Inputs:** Candidate value behaviors; available events; retention definition (if any).
- **Actions:** Propose 3–5 candidate “aha” behaviors and pick one activation definition with a threshold (e.g., “creates X and shares Y within 7 days”). Specify how to validate (correlation with D7/D30; holdout if possible).
- **Outputs:** Activation/aha moment spec + validation plan + instrumentation needs.
- **Checks:** Activation is observable, repeatable, and measurable (not “understands value”).

### 4) Design the “first 30 seconds” (make it feel magical)
- **Inputs:** Primary leak + activation spec; constraints.
- **Actions:** Specify what the user should see/do/feel in the first 30 seconds:
  - Remove or defer non-essential setup (progressive disclosure).
  - Deliver a fast, native, interactive win (avoid passive carousel “tours”).
  - Provide immediate feedback and a clear next action.
- **Outputs:** First 30 seconds spec (screen/script + success criteria).
- **Checks:** A new user can reach a meaningful “win” within ~30 seconds (or you document why not and the best proxy).

### 5) Build the “first mile” plan (milestones → activation)
- **Inputs:** Activation spec; journey map; UX constraints.
- **Actions:** Break activation into 3–6 milestones (the “first mile”). For each milestone, define mechanics (guided setup, defaults, empty states, templates, checklists, feedback, progress). Ensure onboarding is “inside the product,” not detached from real actions.
- **Outputs:** First mile onboarding plan + updated journey map.
- **Checks:** Each milestone reduces time-to-value and has a leading-indicator metric.

### 6) Instrumentation + measurement plan
- **Inputs:** Current analytics/events; proposed milestones; guardrails.
- **Actions:** Define the minimum event schema and dashboards needed (funnel, time-to-value, activation rate, early retention). Add guardrails (support tickets, cancellations, performance).
- **Outputs:** Measurement plan + event list/properties + dashboard outline.
- **Checks:** Every experiment and milestone has a primary metric and at least one guardrail metric.

### 7) Prioritize experiments + quality gate
- **Inputs:** Candidate interventions; measurement plan; [references/CHECKLISTS.md](references/CHECKLISTS.md) and [references/RUBRIC.md](references/RUBRIC.md).
- **Actions:** Convert top opportunities into experiment cards; prioritize (Impact × Confidence ÷ Effort). Add rollout/rollback guidance. Run checklist + score rubric. Always include **Risks / Open questions / Next steps**.
- **Outputs:** Final Onboarding & Activation Pack.
- **Checks:** Top 3 experiments are runnable within constraints and have “win/lose/learn” criteria.

## Quality gate (required)
- Use [references/CHECKLISTS.md](references/CHECKLISTS.md) and [references/RUBRIC.md](references/RUBRIC.md).
- Always include: **Risks**, **Open questions**, **Next steps**.

## Examples

**Example 1 (iOS app, time-to-value):**  
“Product: gifloop (GIF maker). Segment: casual iOS users. Baseline: D1 retention 35%, but most users don't export before churning. Problem: FTUE is just a blank canvas, no guidance. Constraint: 2-week sprint, 1 engineer. Output: first-30-seconds spec (template GIF or quick tutorial), first-mile plan (milestones to first export), and 3 experiments (splash tutorial, template library, export button prominence).”

**Example 2 (Stripe + download, post-payment conversion):**  
“Product: modelstack.digital (templates). Problem: 30% of purchase emails are never opened; of those opened, only 15% download the file. Baseline: 55% of downloaders actually open the template. Output: download email UX spec, unboxing flow spec (landing page vs. inline download), and experiments (subject line + send time, preview snippet in email, CTA clarity).”

**Example 3 (Web tier booking, signup flow):**  
“Product: MVAT Focus web. Segment: users considering Pro subscription. Problem: signup-to-purchase conversion is 8%. Baseline: 45% of signups complete account setup, 18% reach subscribe button. Output: first-30-seconds spec (why upgrade now?), first-mile plan (3 milestones to subscribe button), experiment backlog.”

**Boundary example:**  
“Create an employee onboarding program for new hires.”  
Response: this is HR onboarding, not product onboarding; use an HR/ops process instead.
