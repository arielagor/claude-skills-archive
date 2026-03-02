# Expo Conventions

Expo/React Native patterns and conventions for the Mvat platform.

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
