# Frontend System Architecture

Describes the architecture of the React/TypeScript frontend.

## Tech Stack

- **React 18** - UI library
- **TypeScript** - Type-safe JavaScript
- **Vite** - Build tool and dev server
- **Tailwind CSS** - Utility-first CSS framework
- **shadcn/ui** - Re-usable component library built on Radix UI

## Project Structure

- **Modular components** - Organized by feature/domain
- **Pages** - Route-level components
- **Features** - Business logic organized by feature
- **Shared UI components** - Located in `src/components/ui/` (shadcn/ui)

## Styling Architecture

### Global Styling System

This project uses a **centralized, global styling approach** to ensure consistency and maintainability across all components.

#### Core Principles

1. **No component-scoped CSS files** - All styling is managed globally through Tailwind and shadcn/ui
2. **shadcn/ui as the component foundation** - All UI primitives come from shadcn/ui
3. **Tailwind utilities for customization** - Component-specific styling uses Tailwind classes
4. **CSS variables for theming** - Global design tokens defined in `src/index.css`

#### Styling Layers

**Layer 1: Global CSS Variables**

- Location: `src/index.css` or equivalent
- Contains: Theme colors, spacing, typography scales, CSS custom properties
- Purpose: Centralized design tokens for consistent theming

**Layer 2: shadcn/ui Components**

- Location: `src/components/ui/*`
- Contains: Pre-built, accessible component primitives
- Purpose: Consistent, reusable UI building blocks with built-in variants

**Layer 3: Tailwind Utilities**

- Applied directly in component JSX
- Purpose: Layout, spacing, responsive design, and component-specific styling
- Composable through the `cn()` utility function

#### Benefits

- **Consistency**: All components share the same design system
- **Reusability**: No duplicated styles across components
- **Maintainability**: Single source of truth for styling
- **Performance**: No CSS module overhead
- **Flexibility**: Easy to update themes globally

#### File Organization

```
src/
  components/
    ui/           # shadcn/ui components (Button, Card, Input, etc.)
      button.tsx
      card.tsx
      input.tsx
    feature/      # Feature-specific composite components
  index.css       # Global styles and CSS variables
  ...
```

### Component Development Pattern

When creating new components:

1. Start with shadcn/ui primitives
2. Compose using Tailwind utilities
3. Never create `.css` or `.module.css` files
4. Use the `cn()` helper for conditional classes
