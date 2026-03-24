package com.example.demo.controller;

import com.example.demo.entity.Enrollment;
import com.example.demo.service.EnrollmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
public class EnrollmentController {

    @Autowired
    private EnrollmentService enrollmentService;

    @PostMapping("/enrollments")
    public ResponseEntity<?> enrollStudent(@RequestBody Enrollment enrollment) {
        try {
            Enrollment savedEnrollment = enrollmentService.enrollStudent(enrollment);
            return new ResponseEntity<>(savedEnrollment, HttpStatus.CREATED);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>("Internal server error", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/students/{id}/enrollments")
    public ResponseEntity<?> getEnrollmentsForStudent(@PathVariable("id") Integer studentId) {
        try {
            List<Enrollment> enrollments = enrollmentService.getEnrollmentsForStudent(studentId);
            return new ResponseEntity<>(enrollments, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>("Internal server error", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/courses/{id}/students")
    public ResponseEntity<?> getStudentsForCourse(@PathVariable("id") Integer courseId) {
        try {
            List<Enrollment> enrollments = enrollmentService.getEnrollmentsForCourse(courseId);
            return new ResponseEntity<>(enrollments, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>("Internal server error", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @DeleteMapping("/enrollments/{enrollmentId}")
    public ResponseEntity<?> removeEnrollment(@PathVariable Integer enrollmentId) {
        try {
            enrollmentService.removeEnrollment(enrollmentId);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>("Internal server error", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}