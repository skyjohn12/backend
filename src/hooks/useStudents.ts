import { useState, useEffect, useCallback } from "react";
import { Student, CreateStudentRequest } from "@/models/Student";
import { studentService } from "@/services/studentService";

/**
 * Custom Hook - useStudents
 * Demonstrates: Custom hook pattern, state management, useEffect, useCallback
 * Encapsulates all student-related state and operations
 */
export function useStudents() {
  const [students, setStudents] = useState<Student[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  /**
   * Fetch all students from the API
   * Uses useCallback to memoize the function
   */
  const fetchStudents = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await studentService.getAllStudents();
      setStudents(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load students");
    } finally {
      setLoading(false);
    }
  }, []);

  /**
   * Add a new student
   */
  const addStudent = useCallback(
    async (studentData: CreateStudentRequest): Promise<void> => {
      try {
        setError(null);
        await studentService.createStudent(studentData);
        await fetchStudents();
      } catch (err) {
        const errorMessage =
          err instanceof Error ? err.message : "Failed to add student";
        setError(errorMessage);
        throw err;
      }
    },
    [fetchStudents]
  );

  /**
   * Delete a student by ID
   */
  const deleteStudent = useCallback(
    async (id: number): Promise<void> => {
      try {
        setError(null);
        await studentService.deleteStudent(id);
        await fetchStudents();
      } catch (err) {
        setError(
          err instanceof Error ? err.message : "Failed to delete student"
        );
        throw err;
      }
    },
    [fetchStudents]
  );

  /**
   * Update a student
   */
  const updateStudent = useCallback(
    async (
      id: number,
      updates: Partial<CreateStudentRequest>
    ): Promise<void> => {
      try {
        setError(null);
        await studentService.updateStudent(id, updates);
        await fetchStudents();
      } catch (err) {
        setError(
          err instanceof Error ? err.message : "Failed to update student"
        );
        throw err;
      }
    },
    [fetchStudents]
  );

  /**
   * Clear any error messages
   */
  const clearError = useCallback(() => {
    setError(null);
  }, []);

  // Fetch students on mount
  useEffect(() => {
    fetchStudents();
  }, [fetchStudents]);

  return {
    students,
    loading,
    error,
    addStudent,
    deleteStudent,
    updateStudent,
    fetchStudents,
    clearError,
  };
}
