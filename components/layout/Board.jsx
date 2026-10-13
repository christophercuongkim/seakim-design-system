import React, { createContext, useContext, useId, useState } from 'react';
import { useMeasuredBreakpoint } from '../core/useMeasuredBreakpoint.js';

const Scope = createContext({ narrow: false, collapseEmpty: false });

/**
 * Kanban columns. Each `BoardColumn` has a header (label, count, an optional
 * status dot, a menu), its cards, and a footer for the add row; the column is
 * a sunken fill against the page, 22rem wide with a `--space-4` gap, which is
 * where ClickUp, Wrike, Asana, Programa, Slack and Trello all land. Cards are
 * the app's content, usually a `Card` with an eyebrow, a title and one chip.
 *
 * Empty columns stay full width unless `collapseEmpty` is set: no reference
 * collapses one by default and ClickUp offers it as a toggle, off. A collapsed
 * column is a narrow vertical header that expands on click. Under `md`,
 * measured on the container, the row becomes a scroll-snap strip with one
 * column at 85% and the next peeking, page dots under it: Jira, Asana and
 * Notion all do this and none uses a tab picker.
 */
export function Board({ children, collapseEmpty = false, columnWidth = '22rem', style, ...rest }) {
  const { ref, bp } = useMeasuredBreakpoint();
  const narrow = bp === 'sm';
  const [page, setPage] = useState(0);
  const columns = React.Children.toArray(children).filter(Boolean);
  return (
    <Scope.Provider value={{ narrow, collapseEmpty, columnWidth }}>
      <div ref={ref} style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-3)', minWidth: 0, ...style }} {...rest}>
        <div
          onScroll={narrow ? (e) => {
            const el = e.currentTarget;
            const step = el.scrollWidth / Math.max(columns.length, 1);
            setPage(Math.round(el.scrollLeft / step));
          } : undefined}
          style={{
            display: 'flex', alignItems: 'flex-start', gap: 'var(--space-4)',
            overflowX: 'auto', overflowY: 'hidden',
            scrollSnapType: narrow ? 'x mandatory' : undefined,
            padding: narrow ? '0 var(--space-5)' : 0,
            scrollPaddingLeft: narrow ? 'var(--space-5)' : undefined,
          }}
        >
          {columns}
        </div>
        {narrow && columns.length > 1 && (
          <div aria-hidden="true" style={{ display: 'flex', justifyContent: 'center', gap: 'var(--space-2)' }}>
            {columns.map((c, i) => (
              <span key={c.key ?? i} style={{ width: 6, height: 6, borderRadius: 'var(--radius-circle)', background: i === page ? 'var(--text-secondary)' : 'var(--border-strong)', transition: 'var(--transition-control)' }} />
            ))}
          </div>
        )}
      </div>
    </Scope.Provider>
  );
}

/** One column of a `Board`. */
export function BoardColumn({ label, count, tone, menu, footer, children, empty, style, ...rest }) {
  const { narrow, collapseEmpty, columnWidth } = useContext(Scope);
  const id = useId();
  const [expanded, setExpanded] = useState(false);
  const cards = React.Children.toArray(children).filter(Boolean);
  const isEmpty = empty != null ? empty : cards.length === 0;
  const collapsed = collapseEmpty && isEmpty && !narrow && !expanded;
  const dot = tone && <span aria-hidden="true" style={{ width: 8, height: 8, borderRadius: 'var(--radius-circle)', background: `var(--text-${tone})`, flex: 'none' }} />;

  if (collapsed) {
    return (
      <button
        type="button"
        aria-expanded="false"
        onClick={() => setExpanded(true)}
        style={{
          flex: 'none', width: 'var(--space-10)', minHeight: 'var(--space-12)', alignSelf: 'stretch',
          display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 'var(--space-3)',
          padding: 'var(--space-4) 0', border: 0, cursor: 'pointer',
          background: 'var(--surface-sunken)', borderRadius: 'var(--radius-xl)', color: 'inherit', font: 'inherit',
          ...style,
        }}
        {...rest}
      >
        {dot}
        <span style={{ writingMode: 'vertical-rl', font: 'var(--type-eyebrow)', letterSpacing: 'var(--tracking-caps)', textTransform: 'uppercase', color: 'var(--text-tertiary)' }}>{label}</span>
        <span style={{ font: 'var(--type-caption)', fontFamily: 'var(--font-mono)', color: 'var(--text-tertiary)' }}>{count ?? 0}</span>
      </button>
    );
  }

  return (
    <section
      aria-labelledby={id}
      style={{
        flex: narrow ? '0 0 85%' : `0 0 ${columnWidth}`, scrollSnapAlign: narrow ? 'start' : undefined,
        display: 'flex', flexDirection: 'column', gap: 'var(--space-3)', minWidth: 0,
        padding: 'var(--space-4)', borderRadius: 'var(--radius-xl)', background: 'var(--surface-sunken)',
        ...style,
      }}
      {...rest}
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)', minHeight: 'var(--control-h-sm)' }}>
        {dot}
        <h3 id={id} style={{ font: 'var(--type-eyebrow)', letterSpacing: 'var(--tracking-caps)', textTransform: 'uppercase', color: 'var(--text-tertiary)', margin: 0, minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{label}</h3>
        {count != null && <span style={{ font: 'var(--type-caption)', fontFamily: 'var(--font-mono)', color: 'var(--text-tertiary)', fontVariantNumeric: 'tabular-nums' }}>{count}</span>}
        <span style={{ flex: 1 }} />
        {menu}
      </div>
      <div role="list" style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-3)' }}>
        {cards.map((card, i) => <div role="listitem" key={card.key ?? i}>{card}</div>)}
      </div>
      {footer}
    </section>
  );
}
