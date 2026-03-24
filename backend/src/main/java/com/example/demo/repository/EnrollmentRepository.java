package com.example.demo.repository;

import com.example.demo.entity.Enrollment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface EnrollmentRepository extends JpaRepository<Enrollment, Integer> {
    List<Enrollment> findByStudentId(Integer studentId);
    List<Enrollment> findByCourseId(Integer courseId);
    boolean existsByStudentIdAndCourseId(Integer studentId, Integer courseId);
}