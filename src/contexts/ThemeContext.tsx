import React, { createContext, useContext, useEffect } from "react";
import { THEME_MODE, STORAGE_KEYS } from "@/constants/theme";
import { useLocalStorage } from "@/hooks/useLocalStorage";

type Theme = typeof THEME_MODE.LIGHT | typeof THEME_MODE.DARK;

interface ThemeContextType {
  theme: Theme;
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  // Get initial theme from system preference
  const getInitialTheme = (): Theme => {
    if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
      return THEME_MODE.DARK;
    }
    return THEME_MODE.LIGHT;
  };

  // Use our custom useLocalStorage hook
  const [theme, setTheme] = useLocalStorage<Theme>(
    STORAGE_KEYS.THEME,
    getInitialTheme()
  );

  useEffect(() => {
    // Apply theme class to document root
    const root = document.documentElement;
    if (theme === THEME_MODE.DARK) {
      root.classList.add("dark");
    } else {
      root.classList.remove("dark");
    }
  }, [theme]);

  const toggleTheme = () => {
    setTheme((prevTheme) =>
      prevTheme === THEME_MODE.LIGHT ? THEME_MODE.DARK : THEME_MODE.LIGHT
    );
  };

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error("useTheme must be used within a ThemeProvider");
  }
  return context;
};
