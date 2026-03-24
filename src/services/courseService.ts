import { apiClient, ApiClient } from "@/config/ApiClient";
import { API_ENDPOINTS } from "@/constants/api";

export interface Course {
  id?: number;
  name: string;
  description?: string;
}

export class CourseService {
  private api: ApiClient;
  private readonly endpoint = API_ENDPOINTS.COURSES;

  constructor(client: ApiClient) {
    this.api = client;
  }

  async getAllCourses(): Promise<Course[]> {
    return this.api.get<Course[]>(this.endpoint);
  }

  async createCourse(course: Omit<Course, "id">): Promise<Course> {
    return this.api.post<Course>(this.endpoint, course);
  }

  async deleteCourse(id: number): Promise<void> {
    await this.api.delete(`${this.endpoint}/${id}`);
  }

  static createDefault(): CourseService {
    return new CourseService(apiClient);
  }
}

export const courseService = CourseService.createDefault();