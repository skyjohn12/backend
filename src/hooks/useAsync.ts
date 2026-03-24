import { useState, useEffect, DependencyList } from "react";

/**
 * Custom Hook - useAsync
 * Demonstrates: Async state management, error handling, loading states
 *
 * Manages async operations with loading, error, and data states
 */
interface AsyncState<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
}

export function useAsync<T>(
  asyncFunction: () => Promise<T>,
  dependencies: DependencyList = []
) {
  const [state, setState] = useState<AsyncState<T>>({
    data: null,
    loading: true,
    error: null,
  });

  useEffect(() => {
    let isMounted = true;

    setState({ data: null, loading: true, error: null });

    asyncFunction()
      .then((data) => {
        if (isMounted) {
          setState({ data, loading: false, error: null });
        }
      })
      .catch((error) => {
        if (isMounted) {
          setState({ data: null, loading: false, error });
        }
      });

    return () => {
      isMounted = false;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, dependencies);

  return state;
}

/**
 * Usage Example:
 *
 * function UserProfile({ userId }: { userId: number }) {
 *   const { data: user, loading, error } = useAsync(
 *     () => fetchUser(userId),
 *     [userId]
 *   );
 *
 *   if (loading) return <Spinner />;
 *   if (error) return <Error message={error.message} />;
 *   if (!user) return null;
 *
 *   return <div>{user.name}</div>;
 * }
 */
