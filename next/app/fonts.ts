import { Instrument_Sans, JetBrains_Mono } from "next/font/google";

/**
 * Self-hosted at build time, assigned to the same CSS variables the design system
 * already reads. Because the variable names match, no component or token file
 * changes — but remember to comment out the @import line in tokens/fonts.css so
 * the families are not also fetched from Google at runtime.
 *
 * One text family (0031). `--font-display` is loaded as its own variable rather
 * than aliased to `--font-sans`: it is the slot the wordmark and every heading
 * read, so a future display face is one edit here.
 *
 * Weights are pinned to what the system actually uses. Adding a weight here without
 * adding it to the type scale is how font payloads quietly double.
 */
export const fontDisplay = Instrument_Sans({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
  variable: "--font-display",
  display: "swap",
});

export const fontSans = Instrument_Sans({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
  style: ["normal", "italic"],
  variable: "--font-sans",
  display: "swap",
});

export const fontMono = JetBrains_Mono({
  subsets: ["latin"],
  weight: ["400", "500", "600"],
  variable: "--font-mono",
  display: "swap",
});

export const fontVariables = [
  fontDisplay.variable,
  fontSans.variable,
  fontMono.variable,
].join(" ");
