import { useStudents } from "./useStudents";

/**
 * Custom Hook - useDashboardStats
 * Demonstrates: Feature composition, derived state
 *
 * Provides aggregated statistics from the student data
 * Available globally for any component that needs dashboard metrics
 */
export function useDashboardStats() {
  const { students, loading } = useStudents();

  const stats = {
    totalStudents: students.length,
    recentStudents: students.filter((s) => s.isRecentlyRegistered).length,
    loading,
  };

  return stats;
}

/**
 * Usage Example:
 *
 * function DashboardWidget() {
 *   const { totalStudents, recentStudents, loading } = useDashboardStats();
 *
 *   if (loading) return <Spinner />;
 *
 *   return (
 *     <div>
 *       <p>Total: {totalStudents}</p>
 *       <p>Recent: {recentStudents}</p>
 *     </div>
 *   );
 * }
 */
