import { useState, useEffect } from "react";
import { useStudents } from "@/hooks/useStudents";
import { CreateStudentRequest } from "@/models/Student";
import { useToggle } from "@/hooks/useToggle";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Navigation } from "@/components/Navigation";
import { StudentTable } from "@/components/StudentTable";
import { StudentForm } from "@/components/StudentForm";

/**
 * Students Page Component
 * Demonstrates: Custom hook usage, conditional rendering, component composition
 */
export function Students() {
  const [showAddForm, , openForm, closeForm] = useToggle(false);
  const [submitting, setSubmitting] = useState(false);

  // Use custom hook for student management
  const { students, loading, error, addStudent, deleteStudent, clearError } = useStudents();

  // Show toast for errors and clear them
  useEffect(() => {
    if (error) {
      const message = error.toLowerCase().includes("network") 
        ? "Network error: cannot make request"
        : error;
      
      toast.error(message, {
        style: {
          background: "#dc2626",
          color: "white",
          border: "1px solid #b91c1c",
        },
      });
      
      // Clear the error after showing the toast
      clearError();
    }
  }, [error, clearError]);

  const handleAddStudent = async (studentData: CreateStudentRequest) => {
    try {
      setSubmitting(true);
      await addStudent(studentData);
      // Show success toast
      toast.success("Student added successfully!", {
        style: {
          background: "#16a34a",
          color: "white",
          border: "1px solid #15803d",
        },
      });
      // Don't close the form - stay on intake form
    } catch (err) {
      // Error is already handled by the hook and toast
      console.error("Failed to add student:", err);
    } finally {
      setSubmitting(false);
    }
  };

  const handleDeleteStudent = async (id: number) => {
    if (
      !confirm("Are you sure you want to remove this student from the roster?")
    ) {
      return;
    }
    try {
      await deleteStudent(id);
    } catch (err) {
      // Error is already handled by the hook and toast
      console.error("Failed to delete student:", err);
    }
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <Navigation />

      {/* Page Header */}
      <div className="bg-primary text-white py-8">
        <div className="container mx-auto px-4">
          <h1 className="text-3xl md:text-4xl font-bold">Student Roster</h1>
          <p className="text-primary-foreground/90 mt-2 text-lg">
            Manage your student enrollment and records
          </p>
        </div>
      </div>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-8">
        {/* Add Student Form */}
        {showAddForm && (
          <StudentForm
            onSubmit={handleAddStudent}
            onCancel={closeForm}
            isSubmitting={submitting}
          />
        )}

        {/* Students Table */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle>Current Students</CardTitle>
                <CardDescription>
                  {loading
                    ? "Loading students..."
                    : `${students.length} student${
                        students.length !== 1 ? "s" : ""
                      } enrolled`}
                </CardDescription>
              </div>
              {!showAddForm && (
                <Button
                  onClick={openForm}
                  className="bg-secondary hover:bg-secondary/90"
                >
                  Add Student
                </Button>
              )}
            </div>
          </CardHeader>
          <CardContent>
            <StudentTable
              students={students}
              onDelete={handleDeleteStudent}
              isLoading={loading}
            />
          </CardContent>
        </Card>
      </main>

      {/* Footer */}
      <footer className="border-t mt-16 py-8 bg-card">
        <div className="container mx-auto px-4 text-center">
          <p className="text-sm text-muted-foreground">
            Powered by{" "}
            <a
              href="https://slalom.com"
              target="_blank"
              rel="noopener noreferrer"
              className="text-primary font-semibold hover:text-primary/80"
            >
              Slalom Build
            </a>
          </p>
          <p className="text-xs text-muted-foreground mt-2">
            Delivering innovative solutions with quality engineering excellence
          </p>
        </div>
      </footer>
    </div>
  );
}
