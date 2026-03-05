---
name: expo-conventions
mode: autonomous
escalation_on_ambiguity: governance/escalations/
description: Expo/React Native patterns and conventions for the Mvat platform.
---

# Expo Conventions

Expo/React Native patterns and conventions for the Mvat platform.

> **Skill Mode: autonomous** — This skill never requires human input.
> When ambiguity arises, write an escalation to `governance/escalations/` and
> continue with the conservative default. Do NOT prompt for user input.

## Stack

- **Framework**: Expo (managed workflow) — never eject to bare workflow without escalation
- **Language**: TypeScript strict mode
- **Routing**: Expo Router (file-based routing)
- **Builds**: EAS Build (cloud) — never touch Xcode or Gradle directly
- **Updates**: EAS Update (OTA) for JS-only changes

## Project Structure

```
app/
├── app/                    # File-based routing (Expo Router)
│   ├── _layout.tsx         # Root layout
│   ├── index.tsx           # Home screen
│   ├── (tabs)/             # Tab navigator group
│   │   ├── _layout.tsx     # Tab layout
│   │   ├── index.tsx       # First tab
│   │   └── settings.tsx    # Settings tab
│   └── [id].tsx            # Dynamic route
├── components/             # Reusable UI components
├── hooks/                  # Custom React hooks
├── utils/                  # Utility functions
├── constants/              # App constants, theme tokens
├── types/                  # TypeScript type definitions
├── assets/                 # Static assets (images, fonts)
├── app.json                # Expo config
├── tsconfig.json           # TypeScript config (strict: true)
├── package.json
└── eas.json                # EAS Build/Update config
```

## Component Patterns

- **Functional components only** — no class components
- **Hooks for state** — `useState`, `useReducer`, custom hooks
- **Props with TypeScript interfaces** — explicit prop types, no `any`

```tsx
interface UserCardProps {
  name: string;
  email: string;
  onPress: () => void;
}

export function UserCard({ name, email, onPress }: UserCardProps) {
  return (
    <Pressable onPress={onPress}>
      <Text>{name}</Text>
      <Text>{email}</Text>
    </Pressable>
  );
}
```

## Package Installation

Always use Expo's installer to get SDK-compatible versions:

```bash
npx expo install {package-name}
```

Never use `npm install` or `yarn add` directly for packages that have Expo SDK versions.

Prefer Expo SDK packages over community alternatives:
- `expo-camera` over `react-native-camera`
- `expo-location` over `react-native-geolocation`
- `expo-secure-store` over `react-native-keychain`

## Navigation (Expo Router)

- Screens are files in `app/` directory
- Layouts are `_layout.tsx` files
- Groups use `(group-name)/` directories
- Dynamic routes use `[param].tsx`
- Tab navigation via `(tabs)/` group with tab layout

## TypeScript Configuration

```json
{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true
  }
}
```

## Build and Deploy

- **Development**: `npx expo start`
- **Build**: `eas build --platform {ios|android}` (escalation required — agents do not run builds)
- **OTA Update**: `eas update` (escalation required)
- **Preview builds**: `eas build --profile preview` (escalation required)

Agents write code and configuration but do NOT execute build or deploy commands.

## Common Patterns

### Data fetching
Use `useEffect` + `fetch` for simple cases. For complex state, use React Query or SWR.

### State management
Start with React Context for shared state. Escalate to Zustand or Redux only if Context proves insufficient.

### Styling
Use `StyleSheet.create()` for performance. Keep styles co-located with components.

### Error boundaries
Wrap screen-level components in error boundaries. Log errors to crash reporting.

## AC Reference Annotations (MANDATORY)

All implementation code MUST include Acceptance Criteria reference annotations. This is a requirement discovered from R1 pipeline run 1 — the architect's annotations made traceability verification dramatically easier for the pipeline-judge.

Format: `// AC-{story}.{criterion}: {description}`

Examples:
- `// AC-1.5: Keep screen awake while timer is running`
- `// AC-3.3: Reset does NOT count as completed session`
- `// AC-4.5: Long break after every 4 completed focus sessions`

Every line of code that directly implements an acceptance criterion MUST have this annotation. This enables:
1. pipeline-judge to trace implementation to requirements
2. quality-sentinel to verify coverage of all ACs
3. Automated tracking of which ACs are implemented vs pending
