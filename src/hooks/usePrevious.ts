import { useEffect, useRef } from "react";

/**
 * Custom Hook - usePrevious
 * Demonstrates: useRef for storing values, tracking changes
 *
 * Returns the previous value of a state or prop
 */
export function usePrevious<T>(value: T): T | undefined {
  const ref = useRef<T>();

  useEffect(() => {
    ref.current = value;
  }, [value]);

  return ref.current;
}

/**
 * Usage Example:
 *
 * function Counter() {
 *   const [count, setCount] = useState(0);
 *   const previousCount = usePrevious(count);
 *
 *   return (
 *     <div>
 *       <p>Current: {count}</p>
 *       <p>Previous: {previousCount}</p>
 *       <button onClick={() => setCount(count + 1)}>Increment</button>
 *     </div>
 *   );
 * }
 */
