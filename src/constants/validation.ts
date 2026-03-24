/**
 * Validation Constants
 * Regular expressions and validation rules
 */

/**
 * Validation Patterns
 */
export const VALIDATION = {
  EMAIL: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  PHONE: /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/,
  URL: /^(https?:\/\/)?([\da-z.-]+)\.([a-z.]{2,6})([/\w .-]*)*\/?$/,
} as const;

/**
 * Field Length Limits
 */
export const FIELD_LIMITS = {
  NAME: {
    MIN: 2,
    MAX: 100,
  },
  EMAIL: {
    MIN: 5,
    MAX: 255,
  },
} as const;

/**
 * Date Formats
 */
export const DATE_FORMATS = {
  ISO: "YYYY-MM-DD",
  US: "MM/DD/YYYY",
  LONG: "MMMM DD, YYYY",
} as const;

/**
 * Pagination Defaults
 */
export const PAGINATION = {
  DEFAULT_PAGE_SIZE: 10,
  PAGE_SIZE_OPTIONS: [10, 25, 50, 100],
} as const;
