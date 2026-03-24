import { Link, useLocation } from "react-router-dom";
import { cn } from "@/lib/utils";
import { ThemeToggle } from "./ThemeToggle";
import { ROUTES, ROUTE_LABELS } from "@/constants/routes";

export function Navigation() {
  const location = useLocation();

  const navItems = [
  { path: ROUTES.HOME, label: ROUTE_LABELS[ROUTES.HOME] },
  { path: ROUTES.STUDENTS, label: ROUTE_LABELS[ROUTES.STUDENTS] },
  { path: "/courses", label: "Courses" },
  { path: "/enrollments", label: "Enrollments" },
];

  return (
    <header className="border-b bg-card shadow-sm">
      <div className="container mx-auto px-4">
        <div className="flex items-center justify-between py-4">
          <div className="flex items-center gap-8">
            {/* Slalom Logo */}
            <a
              href="https://slalom.com"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 hover:opacity-80 transition-opacity"
            >
              <svg
                viewBox="0 0 200 60"
                className="h-10 w-auto"
                xmlns="http://www.w3.org/2000/svg"
              >
                {/* Slalom Blue background */}
                <rect width="200" height="60" fill="#0033A1" rx="4" />
                {/* Slalom text in white */}
                <text
                  x="100"
                  y="38"
                  fontFamily="Arial, sans-serif"
                  fontSize="28"
                  fontWeight="bold"
                  fill="white"
                  textAnchor="middle"
                  letterSpacing="2"
                >
                  SLALOM
                </text>
                {/* Orange accent bar */}
                <rect
                  x="20"
                  y="48"
                  width="160"
                  height="4"
                  fill="#FF6900"
                  rx="2"
                />
              </svg>
            </a>

            {/* App Title */}
            <div className="hidden md:block border-l border-border pl-6">
              <Link
                to="/"
                className="text-primary font-semibold text-lg hover:text-primary/80"
              >
                Student Management
              </Link>
            </div>
          </div>

          {/* Navigation Links */}
          <nav className="flex gap-6 items-center">
            {navItems.map((item) => (
              <Link
                key={item.path}
                to={item.path}
                className={cn(
                  "text-sm font-medium transition-colors hover:text-secondary px-3 py-2 rounded-md",
                  location.pathname === item.path
                    ? "bg-primary text-primary-foreground"
                    : "text-foreground/80"
                )}
              >
                {item.label}
              </Link>
            ))}
            <ThemeToggle />
          </nav>
        </div>
      </div>
    </header>
  );
}
