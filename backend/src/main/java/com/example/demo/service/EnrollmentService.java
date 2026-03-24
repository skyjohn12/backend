package com.example.demo.service;

import com.example.demo.entity.Enrollment;
import com.example.demo.repository.CourseRepository;
import com.example.demo.repository.EnrollmentRepository;
import com.example.demo.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class EnrollmentService {

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private CourseRepository courseRepository;

    public Enrollment enrollStudent(Enrollment enrollment) {
        validateEnrollment(enrollment);

        if (!studentRepository.existsById(enrollment.getStudentId())) {
            throw new IllegalArgumentException("Student not found with ID: " + enrollment.getStudentId());
        }

        if (!courseRepository.existsById(enrollment.getCourseId())) {
            throw new IllegalArgumentException("Course not found with ID: " + enrollment.getCourseId());
        }

        if (enrollmentRepository.existsByStudentIdAndCourseId(
                enrollment.getStudentId(), enrollment.getCourseId())) {
            throw new IllegalArgumentException("Student is already enrolled in this course");
        }

        return enrollmentRepository.save(enrollment);
    }

    public List<Enrollment> getEnrollmentsForStudent(Integer studentId) {
        if (!studentRepository.existsById(studentId)) {
            throw new IllegalArgumentException("Student not found with ID: " + studentId);
        }

        return enrollmentRepository.findByStudentId(studentId);
    }

    public List<Enrollment> getEnrollmentsForCourse(Integer courseId) {
        if (!courseRepository.existsById(courseId)) {
            throw new IllegalArgumentException("Course not found with ID: " + courseId);
        }

        return enrollmentRepository.findByCourseId(courseId);
    }

    public void removeEnrollment(Integer enrollmentId) {
        if (!enrollmentRepository.existsById(enrollmentId)) {
            throw new IllegalArgumentException("Enrollment not found with ID: " + enrollmentId);
        }

        enrollmentRepository.deleteById(enrollmentId);
    }

    private void validateEnrollment(Enrollment enrollment) {
        if (enrollment == null) {
            throw new IllegalArgumentException("Enrollment data cannot be null");
        }

        if (enrollment.getStudentId() == null) {
            throw new IllegalArgumentException("Student ID is required");
        }

        if (enrollment.getCourseId() == null) {
            throw new IllegalArgumentException("Course ID is required");
        }
    }
}