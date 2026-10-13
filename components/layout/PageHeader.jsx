import React from 'react';

/**
 * The one header every page shares: the title as the page's `h1`, a `badge`
 * beside it (a count or a status chip), `actions` on the right, an optional
 * one-line `description`, and a `toolbar` row under it for filters, tabs, sort
 * and the view toggle.
 *
 * The references (Linear, Asana, Airtable, Todoist, Whop) put the title top-left
 * at title size, the primary action and icons right of it, and a second row for
 * everything that filters or switches the view. None puts a count beside the
 * title as text; a chip after it is the nearest, so that is the `badge` slot.
 * The view toggle lives in the toolbar, never on the title row. Not sticky.
 *
 * On a narrow container the actions stay on the title row (the title wraps,
 * the actions do not) and the toolbar wraps. No fill, no border (0037): the
 * header is type and whitespace.
 */
export function PageHeader({ title, badge, description, actions, toolbar, style, ...rest }) {
  return (
    <header
      style={{
        display: 'flex',
        flexDirection: 'column',
        gap: 'var(--space-4)',
        paddingBottom: 'var(--space-5)',
        ...style,
      }}
      {...rest}
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-5)' }}>
        <div style={{ flex: 1, minWidth: 0, display: 'flex', alignItems: 'center', gap: 'var(--space-3)', flexWrap: 'wrap' }}>
          <h1 style={{ font: 'var(--type-title)', color: 'var(--text-primary)', margin: 0, minWidth: 0, overflowWrap: 'anywhere' }}>
            {title}
          </h1>
          {badge}
        </div>
        {actions && (
          <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)', flex: 'none' }}>
            {actions}
          </div>
        )}
      </div>
      {description && (
        <p style={{ font: 'var(--type-body-sm)', color: 'var(--text-secondary)', margin: 0, maxWidth: '64ch' }}>
          {description}
        </p>
      )}
      {toolbar && (
        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)', flexWrap: 'wrap' }}>
          {toolbar}
        </div>
      )}
    </header>
  );
}
