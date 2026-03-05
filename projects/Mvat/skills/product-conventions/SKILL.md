---
name: product-conventions
mode: autonomous
escalation_on_ambiguity: governance/escalations/
description: How to discover and follow product-specific conventions. Replaces hardcoded expo-conventions with a configurable approach.
---

# Product Conventions

How to discover and follow product-specific conventions for the active product.

> **Skill Mode: autonomous** — This skill never requires human input.
> When ambiguity arises, write an escalation to `governance/escalations/` and
> continue with the conservative default. Do NOT prompt for user input.

## Resolving the Active Product

1. Read `products/active-product.json` for the product configuration
2. The `repo_path` field gives the relative path to the product repo
3. The `platform` field indicates the tech stack (e.g., "expo")
4. Read the product repo's `CLAUDE.md` for product-specific conventions

```bash
# Example resolution
jq -r '.repo_path' products/active-product.json
# Returns: ../mvat-focus
```

## Fallback (Monorepo Mode)

If `products/active-product.json` doesn't exist, assume monorepo mode:
- Product code is at `app/` in the current repo
- Read `.claude/skills/expo-conventions/SKILL.md` if it exists
- This is the legacy mode from before framework/product separation

## Product-Specific Instructions

After resolving the product path, read `{repo_path}/CLAUDE.md` for:
- Stack and framework details
- Component patterns and coding conventions
- Build and deploy commands
- Business rules (tiers, pricing, feature flags)

## AC Reference Annotations (Framework-Wide)

All implementation code MUST include Acceptance Criteria reference annotations,
regardless of product. This is a framework convention, not product-specific.

Format: `// AC-{story}.{criterion}: {description}`

This enables pipeline-judge to trace implementation to requirements.
