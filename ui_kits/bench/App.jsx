import React, { useState } from 'react';
import { BenchShell } from './BenchShell.jsx';
import { LineupScreen } from './LineupScreen.jsx';
import { MatchupScreen } from './MatchupScreen.jsx';
import { PlayersScreen } from './PlayersScreen.jsx';
import { LeagueScreen } from './LeagueScreen.jsx';
import { PlayerSheet } from './PlayerSheet.jsx';
import { Viewport, KitBar } from '../shared/Frames.jsx';
import { Button } from '../../components/core/Button.jsx';

const TITLES = {
  lineup: ['Your lineup', 'Week 14 · Sunday'],
  matchup: ['Matchup', 'Week 14 · in progress'],
  players: ['Players', 'Free agents'],
  league: ['League', 'East · 6 teams'],
};

function BenchProduct({ bp, theme, onToggleTheme, player, onOpenPlayer, onClosePlayer }) {
  const [screen, setScreen] = useState('lineup');
  const [title, eyebrow] = TITLES[screen] || TITLES.lineup;
  return (
    <div style={{ position: 'relative', flex: 1, minHeight: 0, display: 'flex' }}>
      <BenchShell
        bp={bp}
        active={screen}
        onNavigate={setScreen}
        title={title}
        eyebrow={eyebrow}
        theme={theme}
        onToggleTheme={onToggleTheme}
        actions={screen === 'lineup' ? <Button size="sm" variant="secondary" iconLeft="arrows-clockwise">Optimise</Button> : null}
      >
        {screen === 'lineup' && <LineupScreen bp={bp} onOpenPlayer={onOpenPlayer} />}
        {screen === 'matchup' && <MatchupScreen bp={bp} />}
        {screen === 'players' && <PlayersScreen bp={bp} onOpenPlayer={onOpenPlayer} />}
        {screen === 'league' && <LeagueScreen bp={bp} />}
      </BenchShell>
      <PlayerSheet player={player} onClose={onClosePlayer} bp={bp} />
    </div>
  );
}

export function BenchApp() {
  const [width, setWidth] = useState(0);
  const [theme, setTheme] = useState('dark');
  const [player, setPlayer] = useState(null);
  const [meta, setMeta] = useState({ bp: 'lg', width: 0 });

  function toggleTheme() {
    const next = theme === 'dark' ? 'light' : 'dark';
    setTheme(next);
    document.documentElement.setAttribute('data-theme', next);
  }

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', minHeight: 0 }}>
      <KitBar
        app="Bench · fantasy sport"
        width={width}
        onWidth={setWidth}
        theme={theme}
        onTheme={toggleTheme}
        bp={meta.bp}
        measured={meta.width}
      />
      <Viewport width={width}>
        {({ bp, width: measured }) => (
          <Reporter bp={bp} width={measured} onChange={setMeta}>
            <BenchProduct
              bp={bp}
              theme={theme}
              onToggleTheme={toggleTheme}
              player={player}
              onOpenPlayer={setPlayer}
              onClosePlayer={() => setPlayer(null)}
            />
          </Reporter>
        )}
      </Viewport>
    </div>
  );
}

function Reporter({ bp, width, onChange, children }) {
  React.useEffect(() => { onChange({ bp, width }); }, [bp, width, onChange]);
  return children;
}
