/**
 * Slalom Brand Colors and Theme Constants
 * Official Slalom color palette and design system values
 */

/**
 * Slalom Brand Colors (HEX)
 */
export const SLALOM_COLORS = {
  BLUE: "#0033A1",
  ORANGE: "#FF6900",
  WHITE: "#FFFFFF",
  BLACK: "#000000",
} as const;

/**
 * HSL Color Values for Tailwind/CSS Variables
 */
export const COLOR_HSL = {
  PRIMARY: "210 100% 35%", // Slalom Blue
  SECONDARY: "28 100% 50%", // Slalom Orange
} as const;

/**
 * Theme Mode Values
 */
export const THEME_MODE = {
  LIGHT: "light",
  DARK: "dark",
} as const;

/**
 * Local Storage Keys
 */
export const STORAGE_KEYS = {
  THEME: "theme",
  USER_PREFERENCES: "userPreferences",
} as const;

/**
 * Breakpoints (matches Tailwind defaults)
 */
export const BREAKPOINTS = {
  SM: 640,
  MD: 768,
  LG: 1024,
  XL: 1280,
  "2XL": 1536,
} as const;
