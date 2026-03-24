package com.example.demo.controller;

import com.example.demo.entity.Course;
import com.example.demo.entity.Enrollment;
import com.example.demo.entity.Student;
import com.example.demo.repository.CourseRepository;
import com.example.demo.repository.EnrollmentRepository;
import com.example.demo.repository.StudentRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
public class EnrollmentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private CourseRepository courseRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    private Student testStudent;
    private Course testCourse;

    @BeforeEach
    void setUp() {
        enrollmentRepository.deleteAll();
        courseRepository.deleteAll();
        studentRepository.deleteAll();

        Student student = new Student();
        student.setName("Test Student");
        student.setEmail("teststudent@example.com");
        student.setRegistrationDate(LocalDate.now());
        testStudent = studentRepository.save(student);

        Course course = new Course();
        course.setName("Test Course For Enrollment");
        course.setDescription("Enrollment test course");
        testCourse = courseRepository.save(course);
    }

    @Test
    void shouldCreateEnrollment() throws Exception {
        Enrollment enrollment = new Enrollment();
        enrollment.setStudentId(testStudent.getId());
        enrollment.setCourseId(testCourse.getId());

        mockMvc.perform(post("/api/enrollments")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(enrollment)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.studentId").value(testStudent.getId()))
                .andExpect(jsonPath("$.courseId").value(testCourse.getId()));
    }

    @Test
    void shouldFailOnDuplicateEnrollment() throws Exception {
        Enrollment enrollment = new Enrollment();
        enrollment.setStudentId(testStudent.getId());
        enrollment.setCourseId(testCourse.getId());

        mockMvc.perform(post("/api/enrollments")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(enrollment)))
                .andExpect(status().isCreated());

        mockMvc.perform(post("/api/enrollments")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(enrollment)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void shouldGetEnrollmentsForStudent() throws Exception {
        Enrollment enrollment = new Enrollment();
        enrollment.setStudentId(testStudent.getId());
        enrollment.setCourseId(testCourse.getId());
        enrollmentRepository.save(enrollment);

        mockMvc.perform(get("/api/students/" + testStudent.getId() + "/enrollments"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].studentId").value(testStudent.getId()))
                .andExpect(jsonPath("$[0].courseId").value(testCourse.getId()));
    }

    @Test
    void shouldDeleteEnrollment() throws Exception {
        Enrollment enrollment = new Enrollment();
        enrollment.setStudentId(testStudent.getId());
        enrollment.setCourseId(testCourse.getId());
        Enrollment savedEnrollment = enrollmentRepository.save(enrollment);

        mockMvc.perform(delete("/api/enrollments/" + savedEnrollment.getId()))
                .andExpect(status().isOk());
    }

    @Test
    void shouldFailWhenCourseDoesNotExist() throws Exception {
        Enrollment enrollment = new Enrollment();
        enrollment.setStudentId(testStudent.getId());
        enrollment.setCourseId(99999);

        mockMvc.perform(post("/api/enrollments")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(enrollment)))
                .andExpect(status().isBadRequest());
    }
}