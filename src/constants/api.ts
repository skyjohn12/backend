/**
 * API Configuration Constants
 * Centralized API-related constants for the application
 */

/**
 * API Base URL - Falls back to localhost if not set in environment
 */
export const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL || "http://localhost:8080";

/**
 * API Endpoints
 */
export const API_ENDPOINTS = {
  STUDENTS: "/api/students",
  COURSES: "/api/courses",
  ENROLLMENTS: "/api/enrollments",
  HEALTH: "/api/health",
} as const;

/**
 * API Request Timeouts (in milliseconds)
 */
export const API_TIMEOUT = {
  DEFAULT: 30000, // 30 seconds
  LONG: 60000, // 1 minute
  SHORT: 10000, // 10 seconds
} as const;

/**
 * HTTP Methods
 */
export const HTTP_METHODS = {
  GET: "GET",
  POST: "POST",
  PUT: "PUT",
  DELETE: "DELETE",
  PATCH: "PATCH",
} as const;

/**
 * HTTP Status Codes
 */
export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  SERVER_ERROR: 500,
} as const;
