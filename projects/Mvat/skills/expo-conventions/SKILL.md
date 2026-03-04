---
name: expo-conventions
mode: autonomous
escalation_on_ambiguity: governance/escalations/
description: Expo/React Native patterns for the Mvat platform. Relevant to engineering/testing agents.
relevant_agents: [architect, frontend-engineer, backend-engineer, code-reviewer, security-engineer, quality-sentinel, unit-test-writer, integration-test-writer, devops-engineer, mobile-platform-specialist, tech-debt-tracker, auto-healer]
---

# Expo Conventions

> **autonomous** — Agents not in `relevant_agents` may skip this skill.

## Stack

Expo managed workflow, TypeScript strict, Expo Router (file-based routing), EAS Build/Update.

## Project Structure

```
app/
├── app/          # Expo Router: _layout.tsx, index.tsx, (tabs)/, [id].tsx
├── components/   # Reusable UI components
├── hooks/        # Custom React hooks
├── constants/    # Theme tokens, defaults
├── types/        # TypeScript types
├── storage/      # StorageAdapter, AsyncStorage, Firestore adapters
├── firebase/     # Firebase config (lazy singleton)
├── monetization/ # Stripe, IAP
└── assets/       # Static assets
```

## Key Patterns

- Functional components only, hooks for state, explicit TypeScript interfaces
- `npx expo install` for packages (not npm/yarn directly)
- Prefer Expo SDK packages (`expo-secure-store` over `react-native-keychain`)
- `StyleSheet.create()` for styles, co-located with components
- Agents write code but do NOT run builds or deploys (escalate)

## AC Reference Annotations (MANDATORY)

All implementation code MUST include: `// AC-{story}.{criterion}: {description}`
Enables pipeline-judge traceability, quality-sentinel verification, and AC tracking.
