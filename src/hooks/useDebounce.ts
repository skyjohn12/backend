import { useState, useEffect } from "react";

/**
 * Custom Hook - useDebounce
 * Demonstrates: Performance optimization, delayed updates
 *
 * Delays updating a value until after a specified delay period
 * Useful for search inputs, API calls, expensive operations
 */
export function useDebounce<T>(value: T, delay: number = 500): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    // Set up the timeout
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    // Clean up the timeout if value changes or component unmounts
    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);

  return debouncedValue;
}

/**
 * Usage Example:
 *
 * function SearchComponent() {
 *   const [searchTerm, setSearchTerm] = useState('');
 *   const debouncedSearch = useDebounce(searchTerm, 300);
 *
 *   useEffect(() => {
 *     // Only triggers API call 300ms after user stops typing
 *     if (debouncedSearch) {
 *       searchAPI(debouncedSearch);
 *     }
 *   }, [debouncedSearch]);
 *
 *   return <input onChange={(e) => setSearchTerm(e.target.value)} />;
 * }
 */
