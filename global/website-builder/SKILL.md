---
name: website-builder
description: 9-prompt website builder workflow covering architecture, design, copy, components, UI, animation, responsive, data, and QA
---

# Website Builder — 9-Prompt Workflow

Build a complete, production-ready website using a structured 9-prompt chain. This workflow was designed for Claude + Figma Make but works with any AI-assisted design/dev pipeline.

When the user invokes this command, walk them through the following 9 prompts **sequentially**. Before starting, ask the user for these inputs:

- **Website type** (portfolio, SaaS, e-commerce, landing page, etc.)
- **Brand attributes** (minimal, bold, luxury, playful, etc.)
- **Target audience**
- **Key features** (3-5)
- **Brand voice** (professional, casual, bold)
- **Primary goal** (conversion, awareness, retention)

Then execute each prompt below, filling in the user's inputs where indicated by `[BRACKETS]`. Wait for the user to approve each step before moving to the next.

---

## Prompt 1: The Architecture Strategist

You are a Principal Architect at Vercel. I need to build a **$ARGUMENTS** website.

Requirements:
- Target audience: [as provided by user]
- Key features: [as provided by user]
- Tech considerations: Responsive, SEO-optimized, high performance

Deliver:
1. Site map (all pages with hierarchy)
2. User flows (3 primary journeys)
3. Data models (if dynamic content)
4. API requirements (if applicable)
5. Component inventory (30+ components needed)
6. Page templates (wireframe descriptions)
7. Technical stack recommendation
8. Performance budgets (load time targets)
9. SEO structure (meta templates, URL patterns)

Format as a technical specification that can be handed to a UI builder or developer.

---

## Prompt 2: The Design System Generator

You are a Design Director at Apple. Create a design system for the project.

Brand attributes: [as provided by user]

Generate:
1. Color palette (primary, secondary, semantic, dark mode)
2. Typography scale (9 levels with font recommendations)
3. Spacing system (8px base grid)
4. Component specs (30 components with states)
5. Layout patterns (responsive breakpoints)
6. Animation guidelines (easing, duration)
7. Accessibility requirements (WCAG AA)

Export as:
- Design tokens (JSON)
- CSS variables
- Component descriptions ready for UI implementation

---

## Prompt 3: The Content Architect

You are a Conversion Copywriter at Ogilvy. Write all copy for the website.

Brand voice: [as provided by user]
Target: [as provided by user]
Goal: [as provided by user]

Deliver for each page:
1. Hero section (headline: 6 words, subhead: 15 words, CTA)
2. Feature sections (3 blocks with headlines + descriptions)
3. Social proof (testimonial framework + stats)
4. FAQ section (8 questions with answers)
5. Footer (navigation, social, legal)

Formatting instructions:
- Use emotional triggers (urgency, scarcity, authority)
- Include power words (exclusive, proven, instant)
- Specify character counts for each element
- Note which text should be H1, H2, body

---

## Prompt 4: The Component Logic Builder

You are a Frontend Architect. Design the logic for these interactive components:

Components needed:
1. Multi-step form (validation, progress, state management)
2. Dynamic pricing calculator (inputs, formulas, real-time updates)
3. Search with filters (faceted search, sorting, pagination)
4. User dashboard (data visualization, CRUD operations)
5. Authentication flow (login, signup, password reset)

For each component:
- State machine diagram (describe in text)
- Data flow (props, events, API calls)
- Error handling strategy
- Loading states
- Empty states
- Edge cases

Generate React component structure (functions, hooks, handlers).

---

## Prompt 5: The UI Prompt Engineer

You are an AI Prompt Engineer specializing in UI generation tools (Figma Make, v0, Bolt, etc.).

Convert the technical specification from previous steps into 5 UI-generation prompts.

Each prompt must:
1. Start with the outcome (not the process)
2. Include brand context (colors, typography, mood)
3. Specify interactions (hover, click, scroll, animate)
4. Define responsive behavior (mobile/tablet/desktop)
5. Request specific sections (hero, features, CTA, footer)

Format:
"Build a [TYPE] website with [MOOD] aesthetic. Use [COLOR] primary and [FONT] typography. Include: 1) Hero with [SPECIFIC ELEMENTS], 2) Features grid with [INTERACTIONS], 3) [CTA TYPE] section. Make it fully responsive with [ANIMATION STYLE] animations."

Generate 5 variations from simple to complex.

---

## Prompt 6: The Animation & Interaction Designer

You are a Motion Designer at Apple. Design interactions for each website section.

Interaction requirements:
- Page load sequence (stagger, duration, easing)
- Scroll behaviors (parallax, pin, reveal)
- Hover states (micro-interactions, feedback)
- Click transitions (page transitions, modal opens)
- Gesture support (swipe, pinch, pull)

Technical specs:
- Easing curves (spring, ease-out, cubic-bezier)
- Durations (ms for each interaction type)
- Performance considerations (GPU acceleration, will-change)

Describe the animations in natural language:
"On scroll: Navbar shrinks from 80px to 60px with ease-out over 300ms. Hero text fades up from 20px below with 0.6s duration and 0.1s stagger between lines..."

---

## Prompt 7: The Responsive Behavior Strategist

You are a Responsive Design Specialist. Plan breakpoints for the website.

Breakpoints:
- Mobile: 375px
- Tablet: 768px
- Desktop: 1440px

For each page section, define:
1. Layout transformation (grid to stack, sidebar to drawer)
2. Typography scaling (font sizes at each breakpoint)
3. Image behavior (crop, scale, hide, swap)
4. Navigation adaptation (hamburger, sidebar, horizontal)
5. Spacing adjustments (padding, margin, gap)
6. Content prioritization (hide secondary content on mobile)

Create a responsive decision matrix:
Section | Mobile | Tablet | Desktop | Notes

---

## Prompt 8: The Data Integration Planner

You are a Full-Stack Architect. Design data integration for the website.

Requirements:
1. Data models (schema definitions)
2. API endpoints needed (GET, POST, PUT, DELETE)
3. Authentication strategy (JWT, OAuth, API keys)
4. Real-time considerations (WebSockets, polling)
5. Caching strategy (CDN, local storage)
6. Error handling (fallbacks, retries, offline)

User-facing features:
- Dynamic content loading (infinite scroll, pagination)
- Form submissions (validation, success/error states)
- User accounts (profiles, preferences)
- Search functionality (indexing, filters, sorting)

Design the database schema and API layer for full integration.

---

## Prompt 9: The QA & Optimization Checklist

You are a QA Engineer at Google. Review the complete website specification.

Checklist:
- Performance (Core Web Vitals targets)
- Accessibility (WCAG 2.2 AA compliance)
- SEO (meta tags, structured data, sitemap)
- Security (HTTPS, CSP, input sanitization)
- Browser compatibility (Chrome, Safari, Firefox, Edge)
- Mobile optimization (touch targets, viewport)
- Analytics integration (events, goals, funnels)

For each issue found:
- Severity (Critical/High/Medium/Low)
- Location (page/section/component)
- Issue description
- Fix recommendation

Generate a final punch list for iteration.
