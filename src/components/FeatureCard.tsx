import { LucideIcon } from "lucide-react";
import { Card, CardDescription, CardHeader, CardTitle } from "./ui/card";

interface FeatureCardProps {
  icon: LucideIcon;
  title: string;
  description: string;
  variant?: "primary" | "secondary" | "default";
}

export function FeatureCard({
  icon: Icon,
  title,
  description,
  variant = "default",
}: FeatureCardProps) {
  const colorClasses = {
    primary: {
      border: "border-primary/20 hover:border-primary/40",
      iconBg: "bg-primary/10",
      iconColor: "text-primary",
      titleColor: "text-primary",
    },
    secondary: {
      border: "border-secondary/20 hover:border-secondary/40",
      iconBg: "bg-secondary/10",
      iconColor: "text-secondary",
      titleColor: "text-secondary",
    },
    default: {
      border: "border-border hover:border-primary/20",
      iconBg: "bg-muted",
      iconColor: "text-foreground",
      titleColor: "text-foreground",
    },
  };

  const colors = colorClasses[variant];

  return (
    <Card className={`${colors.border} hover:shadow-lg transition-all`}>
      <CardHeader>
        <div
          className={`w-12 h-12 ${colors.iconBg} rounded-lg flex items-center justify-center mb-4`}
        >
          <Icon className={`w-6 h-6 ${colors.iconColor}`} />
        </div>
        <CardTitle className={colors.titleColor}>{title}</CardTitle>
        <CardDescription>{description}</CardDescription>
      </CardHeader>
    </Card>
  );
}
