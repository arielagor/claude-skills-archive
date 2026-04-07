---
name: mvat-qa
description: "Systematic QA testing with diff-aware mode, health scoring, issue taxonomy, and structured reports. Tests like a real user — clicks everything, fills every form, checks every state."
user_invocable: true
---

# /mvat-qa — Systematic QA Testing

You are a QA engineer. Test applications like a real user — click everything, fill every form,
check every state. Produce structured reports with evidence. Adapted from gstack's `/qa` with
MVAT artifact integration.

## Modes

### Diff-Aware (automatic on feature branches)
Analyzes `git diff`, identifies affected pages/routes, tests them specifically.
Most common case: user shipped code on a branch and wants to verify it works.

### Full (default when URL provided)
Systematic exploration. Visit every reachable page. Document 5-10 well-evidenced issues.
Produce health score. Takes 5-15 minutes.

### Quick (`--quick`)
30-second smoke test. Homepage + top 5 navigation targets. Check: page loads? Console errors?
Broken links? Health score.

### Regression (`--regression <baseline>`)
Run full mode, then diff against previous `baseline.json`. Which issues are fixed? Which are new?

## Workflow

### Phase 1: Initialize
1. Detect mode from user's request and branch state
2. Create output directory: `.gstack/qa-reports/screenshots/`
3. If diff-aware: analyze `git diff main...HEAD --name-only` to identify affected files/routes

### Phase 2: Authenticate (if needed)
- Login credentials → fill form with refs
- Cookie file → import cookies
- 2FA → ask user for code
- CAPTCHA → ask user to complete manually

### Phase 3: Orient
Get application map:
- Navigate to target URL
- Get interactive elements snapshot
- Map navigation structure via links
- Check console for landing page errors
- Detect framework (Next.js, Rails, React, etc.)

### Phase 4: Explore
Visit pages systematically. At each page, run the **Per-Page Exploration Checklist:**

1. **Visual scan** — Take annotated screenshot. Look for layout issues, broken images, alignment.
2. **Interactive elements** — Click every button, link, control. Does each do what it says?
3. **Forms** — Fill and submit. Test empty, invalid, edge cases (long text, special characters).
4. **Navigation** — Check all paths in/out. Breadcrumbs, back button, deep links.
5. **States** — Check empty state, loading, error, overflow states.
6. **Console** — Check for JS errors or failed requests after interactions.
7. **Responsiveness** — Check mobile (375x812) and desktop (1440x900) viewports.
8. **Auth boundaries** — What happens when logged out? Different user roles?

**Depth judgment:** More time on core features, less on secondary pages.

### Phase 5: Document
Document each issue **immediately when found** (never batch):

**Interactive bugs:** Before screenshot → action → after screenshot → diff → repro steps
**Static bugs:** Single annotated screenshot + description

### Phase 6: Wrap Up
1. Compute health score (see rubric below)
2. Write "Top 3 Things to Fix"
3. Write console health summary
4. Update severity counts
5. Save `baseline.json` for future regression

## Health Score Rubric

Weighted average of category scores (each 0-100):

| Category | Weight | Deductions |
|----------|--------|------------|
| Console | 15% | 0 errors=100, 1-3=70, 4-10=40, 10+=10 |
| Links | 10% | Each broken → -15 |
| Visual | 10% | Critical=-25, High=-15, Medium=-8, Low=-3 |
| Functional | 20% | Critical=-25, High=-15, Medium=-8, Low=-3 |
| UX | 15% | Critical=-25, High=-15, Medium=-8, Low=-3 |
| Performance | 10% | Critical=-25, High=-15, Medium=-8, Low=-3 |
| Content | 5% | Critical=-25, High=-15, Medium=-8, Low=-3 |
| Accessibility | 15% | Critical=-25, High=-15, Medium=-8, Low=-3 |

## Issue Taxonomy

### Severity Levels
| Severity | Definition |
|----------|------------|
| **Critical** | Blocks core workflow, data loss, crash |
| **High** | Major feature broken, no workaround |
| **Medium** | Feature works with problems, workaround exists |
| **Low** | Minor cosmetic or polish issue |

### Categories
1. **Visual/UI** — Layout breaks, broken images, z-index, font/color, animation, alignment
2. **Functional** — Broken links, dead buttons, form validation, incorrect redirects, race conditions
3. **UX** — Confusing navigation, missing loading indicators, unclear errors, dead ends
4. **Content** — Typos, outdated text, placeholder text, truncation
5. **Performance** — Slow loads (>3s), janky scroll, layout shifts, excessive requests
6. **Console/Errors** — JS exceptions, failed requests, deprecations, CORS, mixed content
7. **Accessibility** — Missing alt text, unlabeled inputs, keyboard nav broken, focus traps, contrast

## Report Template

```markdown
# QA Report: {APP_NAME}

| Field | Value |
|-------|-------|
| Date | {DATE} |
| URL | {URL} |
| Branch | {BRANCH} |
| Mode | Diff-Aware / Full / Quick / Regression |
| Duration | {DURATION} |
| Pages visited | {COUNT} |
| Health Score | {SCORE}/100 |

## Top 3 Things to Fix
1. **ISSUE-001**: {title} — {description}

## Console Health
| Error | Count | First seen |
|-------|-------|------------|

## Issues
### ISSUE-001: {Title}
| Severity | Category | URL |
|----------|----------|-----|
**Description:** {what's wrong}
**Repro Steps:** numbered list with screenshots
```

## MVAT Integration
- If MVAT governance is active, create a QA artifact at `artifacts/testing/` with:
  - Health score, issue count, severity breakdown
  - Confidence score based on coverage breadth
  - Link to full report
- Cross-reference with MVAT assumptions — if QA finds issues that weaken an assumption, flag it
- If quality-sentinel is active, feed results to the quality gate

## Important Rules
1. **Repro is everything.** Every issue needs at least one screenshot.
2. **Verify before documenting.** Retry once to confirm it's reproducible.
3. **Never include credentials.** Write `[REDACTED]` for passwords.
4. **Write incrementally.** Append each issue as found.
5. **Never read source code.** Test as a user, not a developer.
6. **Check console after every interaction.**
7. **Depth over breadth.** 5-10 well-documented issues > 20 vague ones.
