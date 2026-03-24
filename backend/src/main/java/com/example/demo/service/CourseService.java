package com.example.demo.service;

import com.example.demo.entity.Course;
import com.example.demo.repository.CourseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class CourseService {

    @Autowired
    private CourseRepository courseRepository;

    public List<Course> getAllCourses() {
        return courseRepository.findAll();
    }

    public Optional<Course> getCourseById(Integer id) {
        return courseRepository.findById(id);
    }

    public Course createCourse(Course course) {
        validateCourseData(course);

        if (isCourseNameAlreadyUsed(course.getName())) {
            throw new IllegalArgumentException("Course name already exists: " + course.getName());
        }

        return courseRepository.save(course);
    }

    public Course updateCourse(Integer id, Course updatedCourse) {
        Optional<Course> existingCourseOpt = courseRepository.findById(id);

        if (existingCourseOpt.isEmpty()) {
            throw new IllegalArgumentException("Course not found with ID: " + id);
        }

        validateCourseData(updatedCourse);

        Course existingCourse = existingCourseOpt.get();

        if (!existingCourse.getName().equalsIgnoreCase(updatedCourse.getName())
                && isCourseNameAlreadyUsed(updatedCourse.getName())) {
            throw new IllegalArgumentException("Course name already exists: " + updatedCourse.getName());
        }

        existingCourse.setName(updatedCourse.getName());
        existingCourse.setDescription(updatedCourse.getDescription());

        return courseRepository.save(existingCourse);
    }

    public void deleteCourse(Integer id) {
        if (!courseRepository.existsById(id)) {
            throw new IllegalArgumentException("Course not found with ID: " + id);
        }

        courseRepository.deleteById(id);
    }

    private boolean isCourseNameAlreadyUsed(String name) {
        return courseRepository.findAll().stream()
                .anyMatch(course -> course.getName().equalsIgnoreCase(name));
    }

    private void validateCourseData(Course course) {
        if (course == null) {
            throw new IllegalArgumentException("Course data cannot be null");
        }

        if (course.getName() == null || course.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Course name is required");
        }

        if (course.getName().trim().length() < 2) {
            throw new IllegalArgumentException("Course name must be at least 2 characters long");
        }

        if (course.getName().length() > 100) {
            throw new IllegalArgumentException("Course name cannot exceed 100 characters");
        }

        if (course.getDescription() != null && course.getDescription().length() > 500) {
            throw new IllegalArgumentException("Course description cannot exceed 500 characters");
        }
    }
}