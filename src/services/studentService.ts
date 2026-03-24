import { apiClient, ApiClient } from "@/config/ApiClient";
import { Student, StudentDTO, CreateStudentRequest } from "@/models/Student";
import { API_ENDPOINTS } from "@/constants/api";

/**
 * StudentService Class
 * Demonstrates: Dependency injection via constructor, private properties, async methods
 */
export class StudentService {
  // Private property - API client instance
  private api: ApiClient;
  private readonly endpoint = API_ENDPOINTS.STUDENTS;

  /**
   * Constructor - Dependency injection pattern
   * @param client - API client instance for making HTTP requests
   */
  constructor(client: ApiClient) {
    this.api = client;
  }

  /**
   * Get all students from the API
   * @returns Promise resolving to array of Student instances
   */
  async getAllStudents(): Promise<Student[]> {
    const data = await this.api.get<StudentDTO[]>(this.endpoint);
    return Student.fromJSONArray(data);
  }

  /**
   * Get a single student by ID
   * @param id - Student ID
   * @returns Promise resolving to Student instance
   */
  async getStudentById(id: number): Promise<Student> {
    const data = await this.api.get<StudentDTO>(`${this.endpoint}/${id}`);
    return Student.fromJSON(data);
  }

  /**
   * Create a new student
   * @param studentData - Student creation data
   * @returns Promise resolving to created Student instance
   */
  async createStudent(studentData: CreateStudentRequest): Promise<Student> {
    const data = await this.api.post<StudentDTO>(
      `${this.endpoint}/createStudent`,
      studentData
    );
    return Student.fromJSON(data);
  }

  /**
   * Update an existing student
   * @param id - Student ID
   * @param updates - Partial student data to update
   * @returns Promise resolving to updated Student instance
   */
  async updateStudent(
    id: number,
    updates: Partial<CreateStudentRequest>
  ): Promise<Student> {
    const data = await this.api.put<StudentDTO>(
      `${this.endpoint}/updateStudent/${id}`,
      updates
    );
    return Student.fromJSON(data);
  }

  /**
   * Delete a student
   * @param id - Student ID
   */
  async deleteStudent(id: number): Promise<void> {
    await this.api.delete(`${this.endpoint}/deleteStudent/${id}`);
  }

  /**
   * Search students by name
   * @param searchTerm - Name to search for
   * @returns Promise resolving to array of matching Student instances
   */
  async searchStudentsByName(searchTerm: string): Promise<Student[]> {
    const allStudents = await this.getAllStudents();
    return allStudents.filter((student) =>
      student.name.toLowerCase().includes(searchTerm.toLowerCase())
    );
  }

  /**
   * Get recently registered students (within 30 days)
   * @returns Promise resolving to array of recent Student instances
   */
  async getRecentStudents(): Promise<Student[]> {
    const allStudents = await this.getAllStudents();
    return allStudents.filter((student) => student.isRecentlyRegistered);
  }

  /**
   * Static factory method - Create service with default API client
   */
  static createDefault(): StudentService {
    return new StudentService(apiClient);
  }
}

// Export singleton instance for use throughout the app
export const studentService = StudentService.createDefault();
