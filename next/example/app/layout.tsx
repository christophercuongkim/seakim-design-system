import type { Metadata } from "next";

// Global CSS is only legal here, in the root layout.
import "@seakim/design-system/styles.css";

// Phosphor webfont, the three weights the system uses.
import "@phosphor-icons/web/regular";
import "@phosphor-icons/web/bold";
import "@phosphor-icons/web/fill";

import { fontVariables } from "./fonts";

/** Which app's accent is live. Mirrors [data-app] in tokens/apps.css. */
const APP = "voyage";

/** The system default. A first-time visitor never sees a flash. */
const DEFAULT_THEME = "dark";

export const metadata: Metadata = {
  title: "Voyage",
  description: "Travel planning and booking.",
};

/**
 * Runs before first paint, so a returning visitor who chose light mode does not see
 * a dark frame first. This is the only inline script in the system, and it exists
 * because the server cannot read localStorage.
 *
 * Kept deliberately tiny and wrapped in try/catch — if storage is unavailable
 * (private mode, blocked cookies) it silently leaves the server default in place
 * rather than throwing before the app boots.
 */
const noFlashScript = `
(function () {
  try {
    var stored = localStorage.getItem('sk-theme');
    if (stored === 'light' || stored === 'dark') {
      document.documentElement.setAttribute('data-theme', stored);
    }
  } catch (e) {}
})();
`;

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    // suppressHydrationWarning is required, not optional: the script above may have
    // changed data-theme before React hydrates, and that difference is expected.
    <html
      lang="en"
      data-theme={DEFAULT_THEME}
      data-app={APP}
      className={fontVariables}
      suppressHydrationWarning
    >
      <head>
        <script dangerouslySetInnerHTML={{ __html: noFlashScript }} />
      </head>
      <body>{children}</body>
    </html>
  );
}
