import * as React from 'react';

/**
 * The page outside the shell: sign-in, a gate, a paywall, a wizard. Brand centred
 * above, one top-aligned column (36rem), optional footer, full-bleed on a phone.
 * Fills the viewport (`min-height: 100dvh`); pass `style` to override in a demo.
 */
export interface GateLayoutProps extends React.HTMLAttributes<HTMLDivElement> {
  /** The wordmark or mark. Not a heading; the page's `h1` is in `children`. */
  brand?: React.ReactNode;
  /** The column: a heading, copy, controls. */
  children?: React.ReactNode;
  /** The legal line or a support link, pinned to the bottom. */
  footer?: React.ReactNode;
  /** Wrap the column in a `Card`. Off by default; most references put the content straight on the page. */
  card?: boolean;
  /** Any CSS length. Defaults to `36rem`. */
  width?: string;
  style?: React.CSSProperties;
}
export declare function GateLayout(props: GateLayoutProps): JSX.Element;
