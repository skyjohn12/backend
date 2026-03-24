# Frontend Coding Standards

Coding standards for TypeScript/React frontend.

## Code Style

- Consistent indentation and formatting (2 spaces)
- ES6+ syntax
- Descriptive variable/function names
- Use TypeScript strict mode
- Functional components with hooks (no class components)

## Styling Standards

### Global Styling Approach

This project maintains **all styles globally** to ensure consistency and reusability. Component-specific CSS files are **not permitted**.

### shadcn/ui Components

- **Always use shadcn/ui components** as the foundation for UI elements
- Import components from `@/components/ui/*`
- Leverage shadcn/ui variants for different component states (e.g., button variants: default, destructive, outline, ghost)
- Customize components using Tailwind utility classes, not custom CSS

### Tailwind CSS

- **Use Tailwind utility classes** exclusively for styling components
- Apply utilities directly in JSX className attributes
- Use Tailwind's responsive modifiers (sm:, md:, lg:, xl:) for responsive design
- Leverage Tailwind's state variants (hover:, focus:, active:, disabled:)
- Use the `cn()` utility function for conditional class names

### Global CSS Variables

- Define theme colors, spacing, and design tokens in global CSS (e.g., `src/index.css`)
- Use CSS custom properties for theming (light/dark mode support)
- Keep all global styles in one centralized location

### Examples

**✅ Correct - Using shadcn/ui with Tailwind:**

```tsx
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";

export function MyComponent() {
  return (
    <Card className="max-w-md mx-auto">
      <CardHeader>
        <CardTitle className="text-2xl font-bold">Title</CardTitle>
      </CardHeader>
      <CardContent>
        <Button variant="default" className="w-full">
          Click Me
        </Button>
      </CardContent>
    </Card>
  );
}
```

**❌ Incorrect - Creating component-scoped CSS:**

```tsx
// DON'T create MyComponent.css or MyComponent.module.css
import "./MyComponent.css"; // ❌ Never do this

export function MyComponent() {
  return <div className="my-custom-class">...</div>;
}
```

**❌ Incorrect - Using inline styles:**

```tsx
// ❌ Avoid inline styles
export function MyComponent() {
  return <div style={{ padding: "20px", color: "blue" }}>...</div>;
}
```
