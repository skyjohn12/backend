# Shared Hooks

This folder contains **reusable custom hooks** that can be used across multiple features and components.

## Why Custom Hooks?

Custom hooks let you:

- **Extract reusable logic** - Use the same stateful logic in multiple components
- **Separate concerns** - Keep components focused on UI, move logic to hooks
- **Compose behavior** - Build complex hooks from simpler ones
- **Follow React conventions** - Hooks must start with "use"

## Available Hooks

### State Management

#### `useToggle`

Boolean state management with convenience methods.

```tsx
const [isOpen, toggle, open, close] = useToggle(false);

<Button onClick={open}>Open Modal</Button>
<Modal isOpen={isOpen} onClose={close} />
```

**Use for:** Modals, dropdowns, visibility toggles

#### `useLocalStorage<T>`

Persist state to localStorage with automatic sync.

```tsx
const [user, setUser] = useLocalStorage<User>("user", null);
const [theme, setTheme] = useLocalStorage("theme", "light");

setUser({ name: "John", email: "john@example.com" });
```

**Features:**

- Generic type support
- Automatic persistence
- Cross-tab synchronization
- Error handling

**Use for:** User preferences, auth tokens, cached data

### Performance Optimization

#### `useDebounce<T>`

Delay value updates to reduce expensive operations.

```tsx
const [searchTerm, setSearchTerm] = useState("");
const debouncedSearch = useDebounce(searchTerm, 300);

useEffect(() => {
  // Only calls API after user stops typing for 300ms
  if (debouncedSearch) {
    searchAPI(debouncedSearch);
  }
}, [debouncedSearch]);
```

**Use for:** Search inputs, API calls, expensive calculations, auto-save

### Browser APIs

#### `useMediaQuery`

Responsive design based on CSS media queries.

```tsx
const isMobile = useMediaQuery("(max-width: 768px)");
const isTablet = useMediaQuery("(min-width: 769px) and (max-width: 1024px)");
const isDark = useMediaQuery("(prefers-color-scheme: dark)");

return isMobile ? <MobileView /> : <DesktopView />;
```

**Use for:** Responsive components, conditional rendering, theme detection

### Async Operations

#### `useAsync<T>`

Manage async operations with loading, error, and data states.

```tsx
const {
  data: user,
  loading,
  error,
} = useAsync(() => fetchUser(userId), [userId]);

if (loading) return <Spinner />;
if (error) return <Error message={error.message} />;
return <UserProfile user={user} />;
```

**Use for:** Data fetching, async operations, loading states

### Lifecycle & Effects

#### `usePrevious<T>`

Access the previous value of state or props.

```tsx
const [count, setCount] = useState(0);
const previousCount = usePrevious(count);

return (
  <div>
    <p>Current: {count}</p>
    <p>Previous: {previousCount}</p>
  </div>
);
```

**Use for:** Tracking changes, animations, comparing values

#### `useUpdateEffect`

Run effect only on updates, skip initial mount.

```tsx
// Only runs when query changes, NOT on initial mount
useUpdateEffect(() => {
  searchAPI(query).then(setResults);
}, [query]);
```

**Use for:** Skipping initial render effects, update-only operations

## Hook Concepts Demonstrated

### 1. **Custom Hook Pattern**

```tsx
function useCustomHook(initialValue) {
  const [state, setState] = useState(initialValue);

  const customMethod = () => {
    // Custom logic
  };

  return { state, customMethod };
}
```

### 2. **Generic Hooks**

```tsx
function useLocalStorage<T>(key: string, initialValue: T) {
  // Type-safe, works with any data type
}
```

### 3. **Hook Composition**

```tsx
function useComplexHook() {
  const toggle = useToggle();
  const storage = useLocalStorage("key", "value");
  // Combine multiple hooks
}
```

### 4. **useEffect Patterns**

- Cleanup functions
- Dependency arrays
- Conditional effects
- Event listeners

### 5. **useRef Usage**

- Storing mutable values
- Tracking previous values
- Avoiding re-renders

### 6. **useCallback**

- Memoizing functions
- Preventing unnecessary re-renders

## When to Create a Custom Hook

Create a custom hook when:

- ✅ Logic is reused in multiple components
- ✅ Component is getting too complex
- ✅ State logic can be isolated
- ✅ Need to abstract browser APIs
- ✅ Want to share stateful behavior

Don't create a custom hook if:

- ❌ Logic is only used once
- ❌ It's just wrapping a single hook
- ❌ No stateful logic involved

## Usage Examples in App

### ThemeContext using `useLocalStorage`

```tsx
// src/contexts/ThemeContext.tsx
const [theme, setTheme] = useLocalStorage<Theme>(
  STORAGE_KEYS.THEME,
  getInitialTheme()
);
```

### Students Page using `useToggle`

```tsx
// src/features/students/pages/StudentsPage.tsx
const [showAddForm, , openForm, closeForm] = useToggle(false);
```

## Best Practices

1. **Name hooks with "use" prefix** - Required by React
2. **Only call hooks at top level** - Not in conditions or loops
3. **Document parameters and return values** - Help other developers
4. **Handle edge cases** - Null checks, error handling
5. **Clean up side effects** - Return cleanup functions from useEffect
6. **Make hooks testable** - Pure logic, minimal dependencies

## Feature-Specific Hooks

Feature-specific hooks should live in the feature's `hooks/` folder:

```
features/
  students/
    hooks/
      useStudents.ts        # Student-specific logic
  dashboard/
    hooks/
      useDashboardStats.ts  # Dashboard-specific logic
```

Only truly **shared** hooks belong in `/src/hooks/`.

## Adding New Shared Hooks

1. Create `use<HookName>.ts` in this folder
2. Follow naming convention (useXxx)
3. Add TypeScript types
4. Include JSDoc comments with usage example
5. Export from `index.ts`
6. Update this README

---

These hooks make the codebase more maintainable and demonstrate advanced React patterns! 🎣
