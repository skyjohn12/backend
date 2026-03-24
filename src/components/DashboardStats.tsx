import { useDashboardStats } from "@/hooks/useDashboardStats";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";

/**
 * Dashboard Stats Component
 * Demonstrates: Feature composition, consuming multiple features
 */
export function DashboardStats() {
  const { totalStudents, recentStudents, loading } = useDashboardStats();

  if (loading) {
    return <div className="text-muted-foreground">Loading stats...</div>;
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Total Students</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-4xl font-bold text-primary">{totalStudents}</p>
        </CardContent>
      </Card>
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Recent Enrollments</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-4xl font-bold text-secondary">{recentStudents}</p>
          <p className="text-sm text-muted-foreground mt-2">Last 30 days</p>
        </CardContent>
      </Card>
    </div>
  );
}
