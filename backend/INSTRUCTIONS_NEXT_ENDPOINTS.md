# Instructions: Implement Course Setup and Student Enrollment Endpoints

This document outlines the steps to add new endpoints for course setup and student enrollment in your Spring Boot backend. Follow these instructions to extend your application with course management and enrollment features.

---

## 1. Course Setup Endpoints

### a. Create Course
- **Endpoint:** `POST /api/courses`
- **Description:** Add a new course to the system.
- **Request Body:**
  ```json
  {
    "name": "Course Name",
    "description": "Course Description"
  }
  ```
- **Business Logic:**
  - Validate that the course name is unique.
  - Save the course to the database.

### b. Get All Courses
- **Endpoint:** `GET /api/courses`
- **Description:** Retrieve a list of all available courses.
- **Business Logic:**
  - Return all courses from the database.

### c. Get Course by ID
- **Endpoint:** `GET /api/courses/{id}`
- **Description:** Retrieve details of a specific course.
- **Business Logic:**
  - Return course details if found, else return 404.

### d. Update Course
- **Endpoint:** `PUT /api/courses/{id}`
- **Description:** Update course information.
- **Request Body:**
  ```json
  {
    "name": "Updated Name",
    "description": "Updated Description"
  }
  ```
- **Business Logic:**
  - Validate updates (e.g., name uniqueness).
  - Update course in the database.

### e. Delete Course
- **Endpoint:** `DELETE /api/courses/{id}`
- **Description:** Remove a course from the system.
- **Business Logic:**
  - Delete course and handle any related enrollments.

---

## 2. Student Enrollment Endpoints

### a. Enroll Student in Course
- **Endpoint:** `POST /api/enrollments`
- **Description:** Enroll a student in a course.
- **Request Body:**
  ```json
  {
    "studentId": 1,
    "courseId": 2
  }
  ```
- **Business Logic:**
  - Validate that both student and course exist.
  - Prevent duplicate enrollments (student cannot enroll in the same course twice).
  - Save enrollment record.

### b. Get Enrollments for Student
- **Endpoint:** `GET /api/students/{id}/enrollments`
- **Description:** List all courses a student is enrolled in.
- **Business Logic:**
  - Return all courses for the given student.

### c. Get Students in a Course
- **Endpoint:** `GET /api/courses/{id}/students`
- **Description:** List all students enrolled in a specific course.
- **Business Logic:**
  - Return all students for the given course.

### d. Remove Student Enrollment
- **Endpoint:** `DELETE /api/enrollments/{enrollmentId}`
- **Description:** Unenroll a student from a course.
- **Business Logic:**
  - Delete the enrollment record.

---

## 3. Business Logic Considerations
- Ensure referential integrity between students, courses, and enrollments.
- Handle edge cases (e.g., enrolling in non-existent courses, duplicate enrollments).
- Return appropriate HTTP status codes (e.g., 404 for not found, 409 for conflicts).
- Add validation and error handling in service layer.

---

## 4. Suggested Implementation Steps
1. **Create Course Entity, Repository, Service, and Controller.**
2. **Create Enrollment Entity, Repository, Service, and Controller.**
3. **Implement endpoints as described above.**
4. **Add unit and integration tests for new endpoints and business logic.**

---

Refer to this file as a checklist for implementing the next set of features.
