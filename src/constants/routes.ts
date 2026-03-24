/**
 * Application Routes
 * Centralized route paths for navigation
 */
export const ROUTES = {
  HOME: "/",
  STUDENTS: "/students",
} as const;

/**
 * Route Labels for Navigation
 */
export const ROUTE_LABELS = {
  [ROUTES.HOME]: "Home",
  [ROUTES.STUDENTS]: "Student Roster",
} as const;
