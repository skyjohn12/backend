export interface Student {
  id?: number;
  name: string;
  email: string;
  registrationDate: string; // ISO date string from backend
}

export interface CreateStudentRequest {
  name: string;
  email: string;
  registrationDate: string;
}
