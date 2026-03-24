import { useEffect, useState } from "react";
import { studentService } from "@/services/studentService";
import { courseService, Course } from "@/services/courseService";
import { enrollmentService, Enrollment } from "@/services/enrollmentService";
import { Student } from "@/models/Student";

export default function Enrollments() {
  const [students, setStudents] = useState<Student[]>([]);
  const [courses, setCourses] = useState<Course[]>([]);
  const [selectedStudent, setSelectedStudent] = useState("");
  const [selectedCourse, setSelectedCourse] = useState("");
  const [studentEnrollments, setStudentEnrollments] = useState<Enrollment[]>([]);
  const [error, setError] = useState("");

  useEffect(() => {
    const load = async () => {
      try {
        const [studentData, courseData] = await Promise.all([
          studentService.getAllStudents(),
          courseService.getAllCourses(),
        ]);
        setStudents(studentData);
        setCourses(courseData);
      } catch {
        setError("Failed to load students or courses");
      }
    };

    load();
  }, []);

  const handleEnroll = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    try {
      await enrollmentService.createEnrollment({
        studentId: Number(selectedStudent),
        courseId: Number(selectedCourse),
      });

      if (selectedStudent) {
        const data = await enrollmentService.getEnrollmentsForStudent(
          Number(selectedStudent)
        );
        setStudentEnrollments(data);
      }
    } catch {
      setError("Failed to create enrollment");
    }
  };

  const handleStudentChange = async (studentId: string) => {
    setSelectedStudent(studentId);

    if (!studentId) {
      setStudentEnrollments([]);
      return;
    }

    try {
      const data = await enrollmentService.getEnrollmentsForStudent(
        Number(studentId)
      );
      setStudentEnrollments(data);
    } catch {
      setError("Failed to load enrollments");
    }
  };

  return (
    <div style={{ padding: "24px" }}>
      <h1>Enrollments</h1>

      <form onSubmit={handleEnroll} style={{ marginBottom: "24px" }}>
        <select
          value={selectedStudent}
          onChange={(e) => handleStudentChange(e.target.value)}
          style={{ marginRight: "8px", padding: "8px" }}
        >
          <option value="">Select student</option>
          {students.map((student) => (
            <option key={student.id} value={student.id}>
              {student.name}
            </option>
          ))}
        </select>

        <select
          value={selectedCourse}
          onChange={(e) => setSelectedCourse(e.target.value)}
          style={{ marginRight: "8px", padding: "8px" }}
        >
          <option value="">Select course</option>
          {courses.map((course) => (
            <option key={course.id} value={course.id}>
              {course.name}
            </option>
          ))}
        </select>

        <button type="submit">Enroll</button>
      </form>

      {error && <p>{error}</p>}

      <h2>Selected Student Enrollments</h2>
      <ul>
        {studentEnrollments.map((enrollment) => (
          <li key={enrollment.id}>
            Enrollment #{enrollment.id} — Student {enrollment.studentId} / Course{" "}
            {enrollment.courseId}
          </li>
        ))}
      </ul>
    </div>
  );
}