import { createBrowserRouter } from "react-router-dom";
import { Home } from "@/pages/Home";
import { Students } from "@/pages/Students";
import { StudentDetails } from "@/pages/StudentDetails";
import Courses from "@/pages/Courses";
import Enrollments from "@/pages/Enrollments";

export const router = createBrowserRouter([
  {
    path: "/",
    element: <Home />,
  },
  {
    path: "/students",
    element: <Students />,
  },
  {
    path: "/students/:id",
    element: <StudentDetails />,
  },
  {
    path: "/courses",
    element: <Courses />,
  },
  {
    path: "/enrollments",
    element: <Enrollments />,
  },
]);