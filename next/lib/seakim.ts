"use client";

/**
 * Kept for the copy-into-`src/seakim` consumption model, where components are
 * reached through a path alias rather than from node_modules.
 *
 * It deliberately holds no export list of its own. Maintaining a second one is
 * how `Table`, `DatePicker` and `Slider` came to exist everywhere except here —
 * they shipped to Flutter and to `components/`, and a Next app simply could not
 * import them. One list, re-exported.
 *
 *     import { Button, Field, Input } from "@/lib/seakim";
 *
 * Apps installing the package from git should import from
 * "@seakim/design-system" directly and can ignore this file.
 */

export * from "@/seakim/index.js";
export { useSkTheme } from "./useSkTheme";
