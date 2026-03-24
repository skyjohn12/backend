import { useEffect, useState } from "react";
import { courseService, Course } from "@/services/courseService";

export default function Courses() {
  const [courses, setCourses] = useState<Course[]>([]);
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [error, setError] = useState("");

  const loadCourses = async () => {
    try {
      const data = await courseService.getAllCourses();
      setCourses(data);
    } catch {
      setError("Failed to load courses");
    }
  };

  useEffect(() => {
    loadCourses();
  }, []);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    try {
      await courseService.createCourse({ name, description });
      setName("");
      setDescription("");
      loadCourses();
    } catch {
      setError("Failed to create course");
    }
  };

  const handleDelete = async (id?: number) => {
    if (!id) return;

    try {
      await courseService.deleteCourse(id);
      loadCourses();
    } catch {
      setError("Failed to delete course");
    }
  };

  return (
    <div style={{ padding: "24px" }}>
      <h1>Courses</h1>

      <form onSubmit={handleCreate} style={{ marginBottom: "24px" }}>
        <input
          placeholder="Course name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          style={{ marginRight: "8px", padding: "8px" }}
        />
        <input
          placeholder="Description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          style={{ marginRight: "8px", padding: "8px" }}
        />
        <button type="submit">Add Course</button>
      </form>

      {error && <p>{error}</p>}

      <ul>
        {courses.map((course) => (
          <li key={course.id} style={{ marginBottom: "12px" }}>
            <strong>{course.name}</strong> - {course.description}
            <button
              onClick={() => handleDelete(course.id)}
              style={{ marginLeft: "12px" }}
            >
              Delete
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}