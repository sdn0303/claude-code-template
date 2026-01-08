---
name: frontend-design
description: Frontend architecture patterns including Feature-Sliced Design, state management, and modern UI/UX principles. Use when designing frontend applications.
---

# Frontend Design Skill

Modern frontend architecture and design patterns.

## Feature-Sliced Design (FSD)

### Layer Hierarchy
```
src/
├── app/           # Application initialization, providers, routing
├── processes/     # Complex multi-page flows (optional)
├── pages/         # Page components, route-level composition
├── widgets/       # Large self-contained UI blocks
├── features/      # User interactions, business logic
├── entities/      # Business entities
└── shared/        # Reusable utilities, UI kit
```

### Dependency Rule
- Upper layers can import from lower layers only
- Same-level imports are forbidden
- `shared` → `entities` → `features` → `widgets` → `pages` → `app`

### Slice Structure
```
features/
└── auth/
    ├── ui/              # UI components
    │   ├── LoginForm/
    │   └── LogoutButton/
    ├── model/           # State, actions, selectors
    │   ├── store.ts
    │   └── types.ts
    ├── api/             # API calls
    │   └── authApi.ts
    ├── lib/             # Utilities
    │   └── validateCredentials.ts
    └── index.ts         # Public API
```

### Public API Pattern
```typescript
// features/auth/index.ts
// Only export what other slices need

export { LoginForm } from './ui/LoginForm';
export { LogoutButton } from './ui/LogoutButton';
export { useAuth } from './model/store';
export type { User, AuthState } from './model/types';
```

## Component Architecture

### Presentational vs Container
```typescript
// Presentational (pure, reusable)
interface ButtonProps {
  variant: 'primary' | 'secondary';
  children: React.ReactNode;
  onClick?: () => void;
}

export function Button({ variant, children, onClick }: ButtonProps) {
  return (
    <button className={styles[variant]} onClick={onClick}>
      {children}
    </button>
  );
}

// Container (connected to state)
export function SubmitOrderButton() {
  const { submitOrder, isLoading } = useOrderActions();
  
  return (
    <Button 
      variant="primary" 
      onClick={submitOrder}
      disabled={isLoading}
    >
      {isLoading ? 'Submitting...' : 'Submit Order'}
    </Button>
  );
}
```

### Composition Pattern
```typescript
// Compound components
<Card>
  <Card.Header>
    <Card.Title>Title</Card.Title>
  </Card.Header>
  <Card.Body>Content</Card.Body>
  <Card.Footer>Footer</Card.Footer>
</Card>

// Render props
<DataFetcher url="/api/users">
  {({ data, loading, error }) => (
    loading ? <Spinner /> : <UserList users={data} />
  )}
</DataFetcher>
```

## State Management Patterns

### State Colocation
```typescript
// 1. Component state (most local)
const [isOpen, setIsOpen] = useState(false);

// 2. Context (shared within subtree)
const ThemeContext = createContext<Theme>('light');

// 3. Global store (app-wide)
const useAuthStore = create<AuthState>((set) => ({
  user: null,
  login: (user) => set({ user }),
}));
```

### Server State vs Client State
```typescript
// Server state (TanStack Query)
const { data: users } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
});

// Client state (Zustand)
const { theme, setTheme } = useUIStore();
```

### State Machine Pattern
```typescript
type OrderState = 
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; order: Order }
  | { status: 'error'; error: Error };

function orderReducer(state: OrderState, action: Action): OrderState {
  switch (action.type) {
    case 'FETCH_START':
      return { status: 'loading' };
    case 'FETCH_SUCCESS':
      return { status: 'success', order: action.payload };
    case 'FETCH_ERROR':
      return { status: 'error', error: action.payload };
    default:
      return state;
  }
}
```

## Unidirectional Data Flow

```
┌─────────────────────────────────────┐
│                                     │
│   User Action                       │
│        │                            │
│        ▼                            │
│   Action/Event                      │
│        │                            │
│        ▼                            │
│   State Update                      │
│        │                            │
│        ▼                            │
│   UI Re-render ──────────────►──────┘
│                                     
└─────────────────────────────────────┘
```

## Performance Patterns

### Code Splitting
```typescript
// Route-based splitting
const Dashboard = lazy(() => import('./pages/Dashboard'));

// Component-based splitting
const HeavyChart = lazy(() => import('./components/HeavyChart'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Dashboard />
    </Suspense>
  );
}
```

### Memoization
```typescript
// Memoize expensive computations
const sortedItems = useMemo(
  () => items.sort((a, b) => a.name.localeCompare(b.name)),
  [items]
);

// Memoize callbacks
const handleClick = useCallback(
  () => onSelect(item.id),
  [item.id, onSelect]
);

// Memoize components
const MemoizedList = memo(function List({ items }: Props) {
  return items.map(item => <Item key={item.id} {...item} />);
});
```

### Virtualization
```typescript
import { useVirtualizer } from '@tanstack/react-virtual';

function VirtualList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null);
  
  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50,
  });
  
  return (
    <div ref={parentRef} style={{ height: 400, overflow: 'auto' }}>
      <div style={{ height: virtualizer.getTotalSize() }}>
        {virtualizer.getVirtualItems().map(virtualRow => (
          <div
            key={virtualRow.key}
            style={{
              position: 'absolute',
              top: virtualRow.start,
              height: virtualRow.size,
            }}
          >
            {items[virtualRow.index].name}
          </div>
        ))}
      </div>
    </div>
  );
}
```

## Design System Integration

### Token-Based Design
```typescript
// Design tokens
const tokens = {
  colors: {
    primary: '#3B82F6',
    secondary: '#6B7280',
    error: '#EF4444',
  },
  spacing: {
    xs: '4px',
    sm: '8px',
    md: '16px',
    lg: '24px',
  },
  typography: {
    heading: { fontSize: '24px', fontWeight: 700 },
    body: { fontSize: '16px', fontWeight: 400 },
  },
};

// Usage with Tailwind
<button className="bg-primary text-white px-md py-sm" />
```

### Component Variants
```typescript
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md font-medium',
  {
    variants: {
      variant: {
        primary: 'bg-blue-600 text-white hover:bg-blue-700',
        secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300',
        ghost: 'hover:bg-gray-100',
      },
      size: {
        sm: 'h-8 px-3 text-sm',
        md: 'h-10 px-4',
        lg: 'h-12 px-6 text-lg',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
);

interface ButtonProps extends VariantProps<typeof buttonVariants> {
  children: React.ReactNode;
}

export function Button({ variant, size, children }: ButtonProps) {
  return (
    <button className={buttonVariants({ variant, size })}>
      {children}
    </button>
  );
}
```

## Accessibility

### Essential Practices
```typescript
// Semantic HTML
<nav aria-label="Main navigation">
  <ul role="menubar">
    <li role="menuitem"><a href="/">Home</a></li>
  </ul>
</nav>

// Focus management
function Modal({ isOpen, onClose }: ModalProps) {
  const closeRef = useRef<HTMLButtonElement>(null);
  
  useEffect(() => {
    if (isOpen) closeRef.current?.focus();
  }, [isOpen]);
  
  return (
    <dialog open={isOpen} aria-modal="true">
      <button ref={closeRef} onClick={onClose}>Close</button>
    </dialog>
  );
}

// Keyboard navigation
function Menu() {
  const handleKeyDown = (e: KeyboardEvent) => {
    switch (e.key) {
      case 'ArrowDown': focusNext(); break;
      case 'ArrowUp': focusPrevious(); break;
      case 'Escape': close(); break;
    }
  };
}
```
