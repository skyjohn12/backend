/**
 * Shared Custom Hooks
 *
 * This folder contains reusable custom hooks that can be used across
 * multiple features and components throughout the application.
 *
 * Feature-specific hooks should live in the feature's hooks/ folder.
 * Only truly shared hooks belong here.
 */

export { useToggle } from "./useToggle";
export { useLocalStorage } from "./useLocalStorage";
export { useDebounce } from "./useDebounce";
export { useMediaQuery } from "./useMediaQuery";
export { useAsync } from "./useAsync";
export { usePrevious } from "./usePrevious";
export { useUpdateEffect } from "./useUpdateEffect";
export { useStudents } from "./useStudents";
export { useDashboardStats } from "./useDashboardStats";

/**
 * Hook Categories:
 *
 * State Management:
 * - useToggle: Boolean toggle state
 * - useLocalStorage: Persistent state with localStorage
 *
 * Performance:
 * - useDebounce: Delay value updates
 *
 * Browser APIs:
 * - useMediaQuery: Responsive design queries
 *
 * Async Operations:
 * - useAsync: Manage async state (loading, error, data)
 *
 * Lifecycle & Effects:
 * - usePrevious: Track previous values
 * - useUpdateEffect: Run effect only on updates, not mount
 *
 * Feature Composition:
 * - useDashboardStats: Aggregate student statistics
 */
