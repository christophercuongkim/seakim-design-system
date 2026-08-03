"use client";

import { useCallback, useEffect, useState } from "react";

export type SkTheme = "dark" | "light";
export type SkApp = "seakim" | "voyage" | "bench" | "reserve";

const STORAGE_KEY = "sk-theme";

/**
 * Reads and writes the theme the same way the no-flash script in app/layout.tsx
 * does, so the two never disagree.
 *
 * Initial state is read from the DOM rather than from localStorage, because the
 * inline script has already applied the stored value to the html element by the time
 * React runs. Reading the DOM keeps the first render consistent with the markup and
 * avoids a second correction.
 */
export function useSkTheme(): {
  theme: SkTheme;
  setTheme: (next: SkTheme) => void;
  toggleTheme: () => void;
  setApp: (next: SkApp) => void;
} {
  const [theme, setThemeState] = useState<SkTheme>(() => {
    if (typeof document === "undefined") return "dark";
    const attr = document.documentElement.getAttribute("data-theme");
    return attr === "light" ? "light" : "dark";
  });

  // Covers the case where the inline script was blocked (CSP) and could not run.
  useEffect(() => {
    const attr = document.documentElement.getAttribute("data-theme");
    if (attr !== theme) document.documentElement.setAttribute("data-theme", theme);
  }, [theme]);

  const setTheme = useCallback((next: SkTheme) => {
    document.documentElement.setAttribute("data-theme", next);
    try {
      localStorage.setItem(STORAGE_KEY, next);
    } catch {
      // Private mode or blocked storage — the choice just will not persist.
    }
    setThemeState(next);
  }, []);

  const toggleTheme = useCallback(() => {
    setTheme(theme === "dark" ? "light" : "dark");
  }, [theme, setTheme]);

  /**
   * Rotates the accent hue. Usually set once in the layout rather than at runtime —
   * this is here for previewing, and for a shell that hosts more than one product.
   */
  const setApp = useCallback((next: SkApp) => {
    document.documentElement.setAttribute("data-app", next);
  }, []);

  return { theme, setTheme, toggleTheme, setApp };
}
