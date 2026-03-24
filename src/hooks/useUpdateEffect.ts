import { useEffect, useRef, EffectCallback, DependencyList } from "react";

/**
 * Custom Hook - useUpdateEffect
 * Demonstrates: Conditional effects, component lifecycle
 *
 * Like useEffect, but skips running on initial mount
 * Only runs when dependencies change after mount
 */
export function useUpdateEffect(effect: EffectCallback, deps?: DependencyList) {
  const isMounted = useRef(false);

  useEffect(() => {
    if (isMounted.current) {
      return effect();
    } else {
      isMounted.current = true;
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);
}

/**
 * Usage Example:
 *
 * function SearchResults({ query }: { query: string }) {
 *   const [results, setResults] = useState([]);
 *
 *   // Only run search when query changes, NOT on initial mount
 *   useUpdateEffect(() => {
 *     searchAPI(query).then(setResults);
 *   }, [query]);
 *
 *   return <ResultsList results={results} />;
 * }
 */
