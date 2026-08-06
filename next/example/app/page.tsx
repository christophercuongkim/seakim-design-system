import { Badge, Card, Icon } from "@seakim/design-system";

/**
 * The front door.
 *
 * One design system, four bindings, each one actually running — not screenshots.
 * The point is comparison: the same components, rendered by different platforms,
 * side by side. A divergence like Flutter tinting a badge border while React drew
 * a neutral one went unnoticed for as long as both existed, because nobody could
 * see them together.
 *
 * Everything except /next is served statically from public/ — see the Dockerfile.
 */

interface Target {
  href: string;
  name: string;
  icon: string;
  what: string;
  how: string;
  live: boolean;
}

const targets: Target[] = [
  {
    href: "/next",
    name: "Next.js",
    icon: "browsers",
    what: "The package, installed and server-rendered",
    how: "App Router, React 19, components imported from @seakim/design-system with the barrel's single client boundary. This page is part of it.",
    live: true,
  },
  {
    href: "/flutter",
    name: "Flutter",
    icon: "device-mobile",
    what: "Compiled to web, the real widget layer",
    how: "The SkMaterialTheme gallery and the Sk* widgets, built with `flutter build web`. Same Dart that ships to mobile, so a difference here is a real difference.",
    live: true,
  },
  {
    href: "/preview/index.html",
    name: "Plain HTML",
    icon: "file-html",
    what: "Tokens and CSS with no framework at all",
    how: "styles.css and its token imports, nothing else. The floor: if it looks right here, the tokens are right.",
    live: true,
  },
  {
    href: "/preview/ui_kits/voyage/index.html",
    name: "React",
    icon: "atom",
    what: "The reference binding, in the browser",
    how: "The Voyage kit running on React 18 via ds-shim.js. No build step — this is the binding the others are checked against.",
    live: true,
  },
];

export default function Page() {
  return (
    <main
      style={{
        maxWidth: 860,
        margin: "0 auto",
        padding: "var(--space-9) var(--space-6)",
      }}
    >
      <p
        style={{
          font: "var(--text-eyebrow)",
          color: "var(--text-tertiary)",
          textTransform: "uppercase",
          marginBottom: "var(--space-3)",
        }}
      >
        SeaKim · QA
      </p>
      <h1 style={{ font: "var(--text-title)", marginBottom: "var(--space-4)" }}>
        One system, four bindings
      </h1>
      <p
        style={{
          font: "var(--text-body)",
          color: "var(--text-secondary)",
          maxWidth: 620,
          marginBottom: "var(--space-9)",
        }}
      >
        Each of these is running, not pictured. Open two and compare the same
        component — that is the only way a divergence between bindings shows up
        before someone ships it.
      </p>

      <div style={{ display: "grid", gap: "var(--space-5)" }}>
        {targets.map((t) => (
          <a key={t.href} href={t.href} style={{ textDecoration: "none" }}>
            <Card interactive style={{ padding: "var(--space-6)" }}>
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "var(--space-4)",
                  marginBottom: "var(--space-3)",
                }}
              >
                <Icon name={t.icon} size={24} />
                <span style={{ font: "var(--text-heading)", color: "var(--text-primary)" }}>
                  {t.name}
                </span>
                <Badge tone={t.live ? "success" : "neutral"}>
                  {t.live ? "Live" : "Not built"}
                </Badge>
              </div>
              <p
                style={{
                  font: "var(--text-body-sm)",
                  color: "var(--text-primary)",
                  marginBottom: "var(--space-2)",
                }}
              >
                {t.what}
              </p>
              <p style={{ font: "var(--text-caption)", color: "var(--text-tertiary)" }}>
                {t.how}
              </p>
            </Card>
          </a>
        ))}
      </div>

      <p
        style={{
          font: "var(--text-caption)",
          color: "var(--text-tertiary)",
          marginTop: "var(--space-9)",
        }}
      >
        Deployed from the <code>qa</code> branch. Whichever PR deployed last is what
        you are looking at — QA is a single shared slot.
      </p>
    </main>
  );
}
