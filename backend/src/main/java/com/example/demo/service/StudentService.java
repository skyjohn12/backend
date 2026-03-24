package com.example.demo.service;

import com.example.demo.entity.Student;
import com.example.demo.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class StudentService {
    
    @Autowired
    private StudentRepository studentRepository;
    
    /**
     * Get all students
     */
    public List<Student> getAllStudents() {
        return studentRepository.findAll();
    }
    
    /**
     * Get student by ID
     */
    public Optional<Student> getStudentById(Integer id) {
        return studentRepository.findById(id);
    }
    
    /**
     * Create a new student with business validation
     */
    public Student createStudent(Student student) throws IllegalArgumentException {
        // Business validation
        validateStudentData(student);
        
        // Check for duplicate email
        if (isEmailAlreadyRegistered(student.getEmail())) {
            throw new IllegalArgumentException("Email already registered: " + student.getEmail());
        }
        
        // Set registration date if not provided
        if (student.getRegistrationDate() == null) {
            student.setRegistrationDate(LocalDate.now());
        }
        
        // Validate registration date is not in the future
        if (student.getRegistrationDate().isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("Registration date cannot be in the future");
        }
        
        return studentRepository.save(student);
    }
    
    /**
     * Update an existing student
     */
    public Student updateStudent(Integer id, Student updatedStudent) throws IllegalArgumentException {
        Optional<Student> existingStudentOpt = studentRepository.findById(id);
        
        if (existingStudentOpt.isEmpty()) {
            throw new IllegalArgumentException("Student not found with ID: " + id);
        }
        
        Student existingStudent = existingStudentOpt.get();
        
        // Validate updated data
        validateStudentData(updatedStudent);
        
        // Check for duplicate email (excluding current student)
        if (!existingStudent.getEmail().equals(updatedStudent.getEmail()) && 
            isEmailAlreadyRegistered(updatedStudent.getEmail())) {
            throw new IllegalArgumentException("Email already registered: " + updatedStudent.getEmail());
        }
        
        // Update fields
        existingStudent.setName(updatedStudent.getName());
        existingStudent.setEmail(updatedStudent.getEmail());
        existingStudent.setRegistrationDate(updatedStudent.getRegistrationDate());
        
        return studentRepository.save(existingStudent);
    }
    
    /**
     * Delete a student
     */
    public void deleteStudent(Integer id) throws IllegalArgumentException {
        if (!studentRepository.existsById(id)) {
            throw new IllegalArgumentException("Student not found with ID: " + id);
        }
        studentRepository.deleteById(id);
    }
    
    /**
     * Search students by name or email
     */
    public List<Student> searchStudents(String searchTerm) {
        if (searchTerm == null || searchTerm.trim().isEmpty()) {
            return getAllStudents();
        }
        
        String lowerSearchTerm = searchTerm.toLowerCase();
        return studentRepository.findAll().stream()
                .filter(student -> 
                    student.getName().toLowerCase().contains(lowerSearchTerm) ||
                    student.getEmail().toLowerCase().contains(lowerSearchTerm))
                .collect(Collectors.toList());
    }
    
    /**
     * Get students registered in a specific year
     */
    public List<Student> getStudentsByRegistrationYear(int year) {
        return studentRepository.findAll().stream()
                .filter(student -> student.getRegistrationDate().getYear() == year)
                .collect(Collectors.toList());
    }
    
    /**
     * Get students registered in a date range
     */
    public List<Student> getStudentsByDateRange(LocalDate startDate, LocalDate endDate) {
        return studentRepository.findAll().stream()
                .filter(student -> {
                    LocalDate regDate = student.getRegistrationDate();
                    return !regDate.isBefore(startDate) && !regDate.isAfter(endDate);
                })
                .collect(Collectors.toList());
    }
    
    /**
     * Get total count of students
     */
    public long getTotalStudentCount() {
        return studentRepository.count();
    }
    
    /**
     * Get students registered today
     */
    public List<Student> getTodaysRegistrations() {
        LocalDate today = LocalDate.now();
        return getStudentsByDateRange(today, today);
    }
    
    /**
     * Bulk register students
     */
    public List<Student> bulkRegisterStudents(List<Student> students) {
        // Validate all students first
        for (Student student : students) {
            validateStudentData(student);
            if (isEmailAlreadyRegistered(student.getEmail())) {
                throw new IllegalArgumentException("Duplicate email in bulk registration: " + student.getEmail());
            }
        }
        
        // Set registration dates if not provided
        students.forEach(student -> {
            if (student.getRegistrationDate() == null) {
                student.setRegistrationDate(LocalDate.now());
            }
        });
        
        return studentRepository.saveAll(students);
    }
    
    /**
     * Check if email is already registered
     */
    private boolean isEmailAlreadyRegistered(String email) {
        return studentRepository.findAll().stream()
                .anyMatch(student -> student.getEmail().equalsIgnoreCase(email));
    }
    
    /**
     * Validate student data according to business rules
     */
    private void validateStudentData(Student student) throws IllegalArgumentException {
        if (student == null) {
            throw new IllegalArgumentException("Student data cannot be null");
        }
        
        // Validate name
        if (student.getName() == null || student.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Student name is required");
        }
        
        if (student.getName().trim().length() < 2) {
            throw new IllegalArgumentException("Student name must be at least 2 characters long");
        }
        
        if (student.getName().length() > 100) {
            throw new IllegalArgumentException("Student name cannot exceed 100 characters");
        }
        
        // Validate email
        if (student.getEmail() == null || student.getEmail().trim().isEmpty()) {
            throw new IllegalArgumentException("Email is required");
        }
        
        if (!isValidEmail(student.getEmail())) {
            throw new IllegalArgumentException("Invalid email format: " + student.getEmail());
        }
        
        if (student.getEmail().length() > 100) {
            throw new IllegalArgumentException("Email cannot exceed 100 characters");
        }
        
        // Validate registration date if provided
        if (student.getRegistrationDate() != null) {
            LocalDate minDate = LocalDate.of(2000, 1, 1);
            if (student.getRegistrationDate().isBefore(minDate)) {
                throw new IllegalArgumentException("Registration date cannot be before year 2000");
            }
        }
    }
    
    /**
     * Simple email validation
     */
    private boolean isValidEmail(String email) {
        return email != null && 
               email.contains("@") && 
               email.contains(".") && 
               email.indexOf("@") < email.lastIndexOf(".") &&
               email.indexOf("@") > 0 &&
               email.lastIndexOf(".") < email.length() - 1;
    }
    
    /**
     * Get registration statistics
     */
    public StudentRegistrationStats getRegistrationStatistics() {
        List<Student> allStudents = studentRepository.findAll();
        
        long totalCount = allStudents.size();
        long todayCount = getTodaysRegistrations().size();
        long thisYearCount = getStudentsByRegistrationYear(LocalDate.now().getYear()).size();
        
        return new StudentRegistrationStats(totalCount, todayCount, thisYearCount);
    }
    
    /**
     * Inner class for statistics
     */
    public static class StudentRegistrationStats {
        private final long totalStudents;
        private final long registrationsToday;
        private final long registrationsThisYear;
        
        public StudentRegistrationStats(long totalStudents, long registrationsToday, long registrationsThisYear) {
            this.totalStudents = totalStudents;
            this.registrationsToday = registrationsToday;
            this.registrationsThisYear = registrationsThisYear;
        }
        
        public long getTotalStudents() { return totalStudents; }
        public long getRegistrationsToday() { return registrationsToday; }
        public long getRegistrationsThisYear() { return registrationsThisYear; }
    }
}