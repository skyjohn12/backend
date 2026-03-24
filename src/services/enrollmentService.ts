import { apiClient, ApiClient } from "@/config/ApiClient";
import { API_ENDPOINTS } from "@/constants/api";

export interface Enrollment {
  id?: number;
  studentId: number;
  courseId: number;
}

export class EnrollmentService {
  private api: ApiClient;
  private readonly endpoint = API_ENDPOINTS.ENROLLMENTS;

  constructor(client: ApiClient) {
    this.api = client;
  }

  async createEnrollment(payload: Omit<Enrollment, "id">): Promise<Enrollment> {
    return this.api.post<Enrollment>(this.endpoint, payload);
  }

  async getEnrollmentsForStudent(studentId: number): Promise<Enrollment[]> {
    return this.api.get<Enrollment[]>(`/api/students/${studentId}/enrollments`);
  }

  async getStudentsForCourse(courseId: number): Promise<Enrollment[]> {
    return this.api.get<Enrollment[]>(`/api/courses/${courseId}/students`);
  }

  async deleteEnrollment(id: number): Promise<void> {
    await this.api.delete(`${this.endpoint}/${id}`);
  }

  static createDefault(): EnrollmentService {
    return new EnrollmentService(apiClient);
  }
}

export const enrollmentService = EnrollmentService.createDefault();