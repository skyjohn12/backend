import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Link } from "react-router-dom";
import { Navigation } from "@/components/Navigation";
import { FeatureCard } from "@/components/FeatureCard";
import { DashboardStats } from "@/components/DashboardStats";
import { UserPlus, ClipboardList, Database } from "lucide-react";

export function Home() {
  const features = [
    {
      icon: UserPlus,
      title: "Add Students",
      description:
        "Quickly register new students with their name, email, and enrollment date",
      variant: "primary" as const,
    },
    {
      icon: ClipboardList,
      title: "View Roster",
      description:
        "Access a complete, organized list of all enrolled students in one view",
      variant: "secondary" as const,
    },
    {
      icon: Database,
      title: "Manage Records",
      description:
        "Update or remove student information to keep your records current",
      variant: "primary" as const,
    },
  ];

  return (
    <div className="min-h-screen bg-background">
      <Navigation />

      {/* Hero Section */}
      <main className="container mx-auto px-4">
        <section className="py-20 text-center">
          <div className="max-w-4xl mx-auto">
            {/* Welcome Title */}
            <h1 className="text-5xl md:text-6xl font-bold mb-6 text-foreground">
              Welcome to the{" "}
              <span className="text-primary">Student Management</span>{" "}
              <span className="text-secondary">System</span>
            </h1>

            {/* Description */}
            <p className="text-xl md:text-2xl text-muted-foreground mb-4 leading-relaxed">
              Streamline your student enrollment process with our modern,
              intuitive platform.
            </p>
            <p className="text-lg text-muted-foreground mb-10 max-w-2xl mx-auto">
              Add, view, and manage student records with ease. Track
              registration dates, contact information, and maintain an organized
              roster—all in one place.
            </p>

            {/* CTA Button */}
            <Link to="/students">
              <Button
                variant="secondary"
                size="lg"
                className="text-lg px-8 py-6 h-auto font-semibold shadow-lg hover:shadow-xl transition-all"
              >
                Get Started →
              </Button>
            </Link>
          </div>
        </section>

        {/* Dashboard Stats Section */}
        <section className="py-12 max-w-5xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-8 text-foreground">
            Quick Stats
          </h2>
          <DashboardStats />
        </section>

        {/* Features Section */}
        <section className="py-16 max-w-5xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-12 text-foreground">
            Key Features
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {features.map((feature) => (
              <FeatureCard
                key={feature.title}
                icon={feature.icon}
                title={feature.title}
                description={feature.description}
                variant={feature.variant}
              />
            ))}
          </div>
        </section>

        {/* Additional Info Section */}
        <section className="py-16 max-w-3xl mx-auto text-center">
          <Card className="bg-gradient-to-br from-primary/5 to-secondary/5 border-primary/20">
            <CardContent className="pt-8 pb-8">
              <h3 className="text-2xl font-bold mb-4 text-foreground">
                Ready to manage your students?
              </h3>
              <p className="text-muted-foreground mb-6">
                Start organizing your student data today with our easy-to-use
                platform.
              </p>
              <Link to="/students">
                <Button
                  size="lg"
                  variant="outline"
                  className="border-primary text-primary hover:bg-primary hover:text-white"
                >
                  View Student Roster
                </Button>
              </Link>
            </CardContent>
          </Card>
        </section>
      </main>

      {/* Footer */}
      <footer className="border-t mt-20 py-8 bg-card">
        <div className="container mx-auto px-4 text-center">
          <p className="text-sm text-muted-foreground">
            Powered by{" "}
            <a
              href="https://slalom.com"
              target="_blank"
              rel="noopener noreferrer"
              className="text-primary font-semibold hover:text-primary/80"
            >
              Slalom Build
            </a>
          </p>
          <p className="text-xs text-muted-foreground mt-2">
            Delivering innovative solutions with quality engineering excellence
          </p>
        </div>
      </footer>
    </div>
  );
}
