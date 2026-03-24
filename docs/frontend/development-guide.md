# Frontend Development Guide

Development patterns and practices for the frontend.

## Development Patterns

- **Functional React components** - Use hooks, not class components
- **Organize code by feature/component** - Collocate related files
- **TypeScript best practices** - Leverage strict type checking

## Component Development Workflow

### 1. Building UI Components

#### Always Start with shadcn/ui

Before creating any UI element, check if shadcn/ui provides it:

```bash
# Install a shadcn/ui component
npx shadcn-ui@latest add button
npx shadcn-ui@latest add card
npx shadcn-ui@latest add form
```

Available components include: Button, Card, Dialog, Form, Input, Select, Table, Toast, and many more.

#### Component Structure

```tsx
// ✅ Good: Using shadcn/ui with Tailwind utilities
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { cn } from "@/lib/utils";

interface MyComponentProps {
  title: string;
  highlighted?: boolean;
}

export function MyComponent({ title, highlighted }: MyComponentProps) {
  return (
    <Card
      className={cn(
        "transition-shadow hover:shadow-lg",
        highlighted && "border-primary"
      )}
    >
      <CardHeader>
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent>
        <Button variant="default" size="lg" className="w-full">
          Action
        </Button>
      </CardContent>
    </Card>
  );
}
```

### 2. Styling Guidelines

#### Global Styling Only

**Never create component-specific CSS files.** All styling must be global:

- ✅ **Use Tailwind utilities** in className
- ✅ **Use shadcn/ui variants** (e.g., Button variant="outline")
- ✅ **Define global CSS variables** in `src/index.css`
- ❌ **Don't create** `Component.css` or `Component.module.css`
- ❌ **Avoid inline styles** except for dynamic values

#### Using Tailwind Effectively

```tsx
// Responsive design
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">

// State variants
<Button className="hover:bg-primary/90 focus:ring-2 disabled:opacity-50">

// Conditional classes with cn()
import { cn } from '@/lib/utils';
<div className={cn(
  "base-classes",
  isActive && "active-classes",
  isError && "error-classes"
)}>
```

#### shadcn/ui Component Variants

Leverage built-in variants instead of custom styling:

```tsx
// Button variants
<Button variant="default">Default</Button>
<Button variant="destructive">Delete</Button>
<Button variant="outline">Outline</Button>
<Button variant="ghost">Ghost</Button>
<Button variant="link">Link</Button>

// Sizes
<Button size="sm">Small</Button>
<Button size="default">Default</Button>
<Button size="lg">Large</Button>
```

### 3. Adding Global Styles

When you need to add custom styling that isn't covered by Tailwind:

**Edit `src/index.css`:**

```css
/* Add CSS variables for theming */
:root {
  --custom-brand-color: #1a73e8;
  --custom-spacing: 2rem;
}

.dark {
  --custom-brand-color: #8ab4f8;
}

/* Add global utility classes if absolutely necessary */
.custom-pattern {
  @apply bg-gradient-to-r from-primary to-secondary;
}
```

### 4. Best Practices Checklist

Before submitting code, ensure:

- [ ] No `.css` or `.module.css` files created for components
- [ ] All UI elements use shadcn/ui components where available
- [ ] Tailwind utilities used for spacing, layout, and customization
- [ ] `cn()` utility used for conditional classes
- [ ] Responsive design using Tailwind breakpoints
- [ ] Accessibility: proper ARIA labels and keyboard navigation
- [ ] TypeScript: strict typing with no `any` types

### 5. Common Patterns

#### Form with Validation

```tsx
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export function LoginForm() {
  return (
    <form className="space-y-4 max-w-md mx-auto">
      <div className="space-y-2">
        <Label htmlFor="email">Email</Label>
        <Input
          id="email"
          type="email"
          placeholder="you@example.com"
          className="w-full"
        />
      </div>
      <Button type="submit" className="w-full">
        Sign In
      </Button>
    </form>
  );
}
```

#### Data Display with Cards

```tsx
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export function Dashboard() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 p-6">
      <Card>
        <CardHeader>
          <CardTitle>Metric 1</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-3xl font-bold">1,234</p>
        </CardContent>
      </Card>
      {/* More cards... */}
    </div>
  );
}
```
