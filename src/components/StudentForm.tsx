import { useState } from "react";
import { CreateStudentRequest } from "@/models/Student";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

interface StudentFormProps {
  onSubmit: (student: CreateStudentRequest) => Promise<void>;
  onCancel?: () => void;
  isSubmitting?: boolean;
}

interface FormErrors {
  name?: string;
  email?: string;
  registrationDate?: string;
}

export function StudentForm({
  onSubmit,
  onCancel,
  isSubmitting = false,
}: StudentFormProps) {
  const [formData, setFormData] = useState<CreateStudentRequest>({
    name: "",
    email: "",
    registrationDate: new Date().toISOString().split("T")[0],
  });
  const [errors, setErrors] = useState<FormErrors>({});

  const validateForm = (): boolean => {
    const newErrors: FormErrors = {};

    // Name validation
    if (!formData.name.trim()) {
      newErrors.name = "Name is required";
    }

    // Email validation
    if (!formData.email.trim()) {
      newErrors.email = "Email is required";
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = "Please enter a valid email address";
    }

    // Registration date validation
    if (!formData.registrationDate) {
      newErrors.registrationDate = "Registration date is required";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }

    await onSubmit(formData);
    // Reset form after successful submission
    setFormData({
      name: "",
      email: "",
      registrationDate: new Date().toISOString().split("T")[0],
    });
    setErrors({});
  };

  return (
    <Card className="mb-6">
      <CardHeader>
        <CardTitle>Add New Student</CardTitle>
        <CardDescription>
          Enter the student information to add them to the roster
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="name">Name *</Label>
              <Input
                id="name"
                value={formData.name}
                onChange={(e) => {
                  setFormData({ ...formData, name: e.target.value });
                  if (errors.name) setErrors({ ...errors, name: undefined });
                }}
                placeholder="John Doe"
                disabled={isSubmitting}
                className={errors.name ? "border-red-600 focus-visible:ring-red-600" : ""}
              />
              {errors.name && (
                <p className="text-sm" style={{ color: "#dc2626" }}>
                  {errors.name}
                </p>
              )}
            </div>
            <div className="space-y-2">
              <Label htmlFor="email">Email *</Label>
              <Input
                id="email"
                type="email"
                value={formData.email}
                onChange={(e) => {
                  setFormData({ ...formData, email: e.target.value });
                  if (errors.email) setErrors({ ...errors, email: undefined });
                }}
                placeholder="john.doe@example.com"
                disabled={isSubmitting}
                className={errors.email ? "border-red-600 focus-visible:ring-red-600" : ""}
              />
              {errors.email && (
                <p className="text-sm" style={{ color: "#dc2626" }}>
                  {errors.email}
                </p>
              )}
            </div>
            <div className="space-y-2">
              <Label htmlFor="registrationDate">Registration Date *</Label>
              <Input
                id="registrationDate"
                type="date"
                value={formData.registrationDate}
                onChange={(e) => {
                  setFormData({
                    ...formData,
                    registrationDate: e.target.value,
                  });
                  if (errors.registrationDate) setErrors({ ...errors, registrationDate: undefined });
                }}
                disabled={isSubmitting}
                className={errors.registrationDate ? "border-red-600 focus-visible:ring-red-600" : ""}
              />
              {errors.registrationDate && (
                <p className="text-sm" style={{ color: "#dc2626" }}>
                  {errors.registrationDate}
                </p>
              )}
            </div>
          </div>
          <div className="flex gap-4 pt-4">
            <Button
              type="submit"
              className="bg-secondary hover:bg-secondary/90"
              disabled={isSubmitting}
            >
              {isSubmitting ? "Adding..." : "Add Student"}
            </Button>
            {onCancel && (
              <Button
                type="button"
                variant="outline"
                onClick={onCancel}
                disabled={isSubmitting}
              >
                Cancel
              </Button>
            )}
          </div>
        </form>
      </CardContent>
    </Card>
  );
}
