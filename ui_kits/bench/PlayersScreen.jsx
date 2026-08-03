import React, { useState } from 'react';
import { Input } from '../../components/forms/Input.jsx';
import { Tag } from '../../components/core/Tag.jsx';
import { Button } from '../../components/core/Button.jsx';
import { EmptyState } from '../../components/feedback/EmptyState.jsx';
import { RosterList } from './RosterList.jsx';
import { pagePad } from './BenchShell.jsx';
import { POOL } from './roster.js';

const POSITIONS = ['All', 'PG', 'SG', 'SF', 'PF', 'C'];

export function PlayersScreen({ bp, onOpenPlayer }) {
  const [q, setQ] = useState('');
  const [pos, setPos] = useState('All');
  const isSm = bp === 'sm';
  const list = POOL.filter(p =>
    p.name.toLowerCase().includes(q.toLowerCase()) && (pos === 'All' || p.pos === pos)
  );

  const addButton = () => <Button size="sm" variant="secondary" iconLeft="plus">Add</Button>;

  return (
    <div style={{ padding: pagePad(bp), display: 'flex', flexDirection: 'column', gap: isSm ? 0 : 'var(--space-6)' }}>
      <div style={{
        display: 'flex', alignItems: isSm ? 'stretch' : 'center', gap: isSm ? 'var(--space-4)' : 'var(--space-5)',
        flexDirection: isSm ? 'column' : 'row', flexWrap: 'wrap',
        padding: isSm ? 'var(--space-5)' : 0,
        borderBottom: isSm ? '1px solid var(--border-subtle)' : 'none',
      }}>
        <div style={{ width: isSm ? '100%' : 280 }}>
          <Input size="sm" iconLeft="magnifying-glass" placeholder="Search by name" value={q} onChange={e => setQ(e.target.value)} />
        </div>
        <div style={{ display: 'flex', gap: 'var(--space-3)', flexWrap: 'wrap' }}>
          {POSITIONS.map(p => (
            <Tag key={p} selected={pos === p} onClick={() => setPos(p)}>{p}</Tag>
          ))}
        </div>
        {!isSm && (
          <span style={{ marginLeft: 'auto', font: 'var(--type-caption)', color: 'var(--text-tertiary)' }}>
            214 free agents · waivers clear Wednesday
          </span>
        )}
      </div>

      {list.length ? (
        <RosterList bp={bp} rows={list} onOpen={onOpenPlayer} actions={addButton} liveLabel="Season avg" />
      ) : (
        <div style={{ padding: isSm ? 'var(--space-6) var(--space-5)' : 'var(--space-8)', border: isSm ? 'none' : '1px solid var(--border-subtle)' }}>
          <EmptyState
            compact
            icon="magnifying-glass"
            title="No players match"
            description={'Nothing in the free agent pool matches "' + q + '" at ' + pos + '. Try a surname, or clear the filters.'}
            action={<Button size="sm" variant="secondary" onClick={() => { setQ(''); setPos('All'); }}>Clear filters</Button>}
          />
        </div>
      )}
    </div>
  );
}
