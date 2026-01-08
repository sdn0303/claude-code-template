---
name: typescript
description: TypeScript and JavaScript best practices for frontend and backend. Use when writing React, Next.js, Node.js, or general TypeScript code.
---

# TypeScript Development Skill

Best practices for TypeScript/JavaScript development.

## Project Structure (Next.js 15 / Feature-Sliced)

```
src/
├── app/                    # Next.js App Router
│   ├── (routes)/          # Route groups
│   │   └── feature/
│   ├── layout.tsx
│   └── page.tsx
├── features/              # Feature modules (FSD)
│   └── auth/
│       ├── ui/           # Components
│       ├── model/        # State/logic
│       ├── api/          # API calls
│       └── lib/          # Utilities
├── entities/             # Business entities
├── shared/               # Shared code
│   ├── ui/              # UI primitives
│   ├── lib/             # Utilities
│   └── api/             # API client
├── widgets/              # Composed components
└── types/                # Global types
```

## TypeScript Fundamentals

### Type Definitions
```typescript
// Prefer interfaces for objects
interface User {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

// Use type for unions/intersections
type Status = 'pending' | 'active' | 'inactive';
type UserWithRole = User & { role: Role };

// Generics for reusability
interface Repository<T> {
  findById(id: string): Promise<T | null>;
  save(entity: T): Promise<T>;
}
```

### Strict Typing
```typescript
// Enable strict mode in tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true
  }
}

// Avoid `any`, use `unknown` for unknown types
function parseJSON(json: string): unknown {
  return JSON.parse(json);
}

// Type guards for narrowing
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'name' in value
  );
}
```

### Utility Types
```typescript
// Partial - all properties optional
type UpdateUser = Partial<User>;

// Required - all properties required
type CompleteUser = Required<User>;

// Pick - subset of properties
type UserPreview = Pick<User, 'id' | 'name'>;

// Omit - exclude properties
type UserInput = Omit<User, 'id' | 'createdAt'>;

// Record - object with specific key/value types
type UserMap = Record<string, User>;
```

## React Patterns

### Component Structure
```typescript
// Props interface
interface ButtonProps {
  variant?: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  onClick?: () => void;
  children: React.ReactNode;
}

// Functional component with defaults
export function Button({
  variant = 'primary',
  size = 'md',
  disabled = false,
  onClick,
  children,
}: ButtonProps) {
  return (
    <button
      className={cn(variants[variant], sizes[size])}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
}
```

### Custom Hooks
```typescript
// Naming: use* prefix
function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;
    
    async function fetchUser() {
      try {
        const data = await api.getUser(userId);
        if (!cancelled) setUser(data);
      } catch (e) {
        if (!cancelled) setError(e as Error);
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    fetchUser();
    return () => { cancelled = true; };
  }, [userId]);

  return { user, loading, error };
}
```

### Server Components (Next.js 15)
```typescript
// Default: Server Component
async function UserList() {
  const users = await fetchUsers(); // Direct async
  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}

// Client Component (when needed)
'use client';

import { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

## State Management

### TanStack Query
```typescript
// Query
const { data, isLoading, error } = useQuery({
  queryKey: ['users', userId],
  queryFn: () => fetchUser(userId),
});

// Mutation
const mutation = useMutation({
  mutationFn: createUser,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['users'] });
  },
});
```

### Zustand (Simple State)
```typescript
interface AuthStore {
  user: User | null;
  setUser: (user: User | null) => void;
  logout: () => void;
}

const useAuthStore = create<AuthStore>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
  logout: () => set({ user: null }),
}));
```

## Error Handling

### Async/Await
```typescript
async function fetchData(): Promise<Data> {
  try {
    const response = await fetch('/api/data');
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    return response.json();
  } catch (error) {
    console.error('Fetch failed:', error);
    throw error;
  }
}
```

### Result Pattern
```typescript
type Result<T, E = Error> = 
  | { ok: true; value: T }
  | { ok: false; error: E };

async function safeOperation(): Promise<Result<Data>> {
  try {
    const data = await fetchData();
    return { ok: true, value: data };
  } catch (error) {
    return { ok: false, error: error as Error };
  }
}
```

## Testing

### Component Testing
```typescript
import { render, screen, fireEvent } from '@testing-library/react';

describe('Button', () => {
  it('calls onClick when clicked', () => {
    const onClick = vi.fn();
    render(<Button onClick={onClick}>Click me</Button>);
    
    fireEvent.click(screen.getByRole('button'));
    
    expect(onClick).toHaveBeenCalledTimes(1);
  });
});
```

### Hook Testing
```typescript
import { renderHook, waitFor } from '@testing-library/react';

describe('useUser', () => {
  it('fetches user data', async () => {
    const { result } = renderHook(() => useUser('123'));
    
    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });
    
    expect(result.current.user).toBeDefined();
  });
});
```

## Tools

```bash
# Package management (pnpm)
pnpm install
pnpm add <package>
pnpm add -D <dev-package>

# Development
pnpm dev

# Build
pnpm build

# Test
pnpm test

# Lint & Format
pnpm lint
pnpm format
```

## Path Aliases

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@/features/*": ["src/features/*"],
      "@/shared/*": ["src/shared/*"]
    }
  }
}
```
