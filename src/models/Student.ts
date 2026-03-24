import { VALIDATION } from "@/constants/validation";

/**
 * Student Model Class
 * Demonstrates: Constructor, class properties, methods, static methods, getters
 */
export class Student {
  // Class properties with TypeScript typing
  id?: number;
  name: string;
  email: string;
  registrationDate: string;

  /**
   * Constructor - called when creating new Student instances
   * @param name - Student's full name
   * @param email - Student's email address
   * @param registrationDate - ISO date string of registration
   * @param id - Optional student ID (assigned by backend)
   */
  constructor(
    name: string,
    email: string,
    registrationDate: string,
    id?: number
  ) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.registrationDate = registrationDate;
  }

  /**
   * Instance method - Get formatted registration date
   */
  getFormattedDate(): string {
    return new Date(this.registrationDate).toLocaleDateString("en-US", {
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  }

  /**
   * Instance method - Get student's display name (uppercase)
   */
  getDisplayName(): string {
    return this.name.toUpperCase();
  }

  /**
   * Instance method - Check if email is valid
   */
  isValidEmail(): boolean {
    return VALIDATION.EMAIL.test(this.email);
  }

  /**
   * Instance method - Convert to plain object (for API calls)
   */
  toJSON(): StudentDTO {
    return {
      id: this.id,
      name: this.name,
      email: this.email,
      registrationDate: this.registrationDate,
    };
  }

  /**
   * Static method - Create Student from API response
   */
  static fromJSON(data: StudentDTO): Student {
    return new Student(data.name, data.email, data.registrationDate, data.id);
  }

  /**
   * Static method - Create multiple Students from array
   */
  static fromJSONArray(dataArray: StudentDTO[]): Student[] {
    return dataArray.map((data) => Student.fromJSON(data));
  }

  /**
   * Static method - Create new student with today's date
   */
  static createNew(name: string, email: string): Student {
    return new Student(name, email, new Date().toISOString().split("T")[0]);
  }

  /**
   * Getter - Check if student is recently registered (within 30 days)
   */
  get isRecentlyRegistered(): boolean {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    return new Date(this.registrationDate) > thirtyDaysAgo;
  }

  /**
   * Getter - Get initials from name
   */
  get initials(): string {
    return this.name
      .split(" ")
      .map((part) => part[0])
      .join("")
      .toUpperCase();
  }
}

/**
 * Data Transfer Object type (matches API response)
 */
export interface StudentDTO {
  id?: number;
  name: string;
  email: string;
  registrationDate: string;
}

/**
 * Create Student Request type
 */
export interface CreateStudentRequest {
  name: string;
  email: string;
  registrationDate: string;
}
