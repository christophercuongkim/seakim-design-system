import React, { useState } from 'react';
import { AppShell } from './AppShell.jsx';
import { TripsScreen } from './TripsScreen.jsx';
import { SearchScreen } from './SearchScreen.jsx';
import { TripDetailScreen } from './TripDetailScreen.jsx';
import { CheckoutScreen } from './CheckoutScreen.jsx';
import { AccountScreen } from './AccountScreen.jsx';
import { Viewport, KitBar } from '../shared/Frames.jsx';
import { Button } from '../../components/core/Button.jsx';
import { EmptyState } from '../../components/feedback/EmptyState.jsx';

const TITLES = {
  trips: ['Trips', null],
  search: ['SFO → LIS', 'Search'],
  detail: ['Lisbon', 'Trips'],
  checkout: ['Checkout', 'Trips / Lisbon'],
  saved: ['Saved fares', null],
  account: ['Account', null],
};

function VoyageProduct({ bp, theme, onToggleTheme }) {
  const [screen, setScreen] = useState('trips');
  const [trip, setTrip] = useState(null);
  const [title, breadcrumb] = TITLES[screen] || TITLES.trips;
  const navActive = screen === 'detail' || screen === 'checkout' ? 'trips' : screen;

  return (
    <AppShell
      bp={bp}
      active={navActive}
      onNavigate={setScreen}
      theme={theme}
      onToggleTheme={onToggleTheme}
      title={title}
      breadcrumb={breadcrumb}
      actions={screen === 'trips' ? <Button size="sm" variant="secondary" iconLeft="upload-simple">Import</Button> : null}
    >
      {screen === 'trips' && (
        <TripsScreen bp={bp} onOpenTrip={t => { setTrip(t); setScreen('detail'); }} onSearch={() => setScreen('search')} />
      )}
      {screen === 'search' && <SearchScreen bp={bp} onContinue={() => setScreen('checkout')} />}
      {screen === 'detail' && (
        <TripDetailScreen bp={bp} trip={trip} onCheckout={() => setScreen('checkout')} onBack={() => setScreen('trips')} />
      )}
      {screen === 'checkout' && <CheckoutScreen bp={bp} onDone={() => setScreen('detail')} />}
      {screen === 'account' && <AccountScreen bp={bp} />}
      {screen === 'saved' && (
        <div style={{ padding: 'var(--space-11) var(--space-6)' }}>
          <EmptyState
            icon="bookmark-simple"
            title="No saved fares"
            description="Save a fare from any search result and Voyage watches it for you."
            action={<Button iconLeft="magnifying-glass" onClick={() => setScreen('search')}>Search flights</Button>}
          />
        </div>
      )}
    </AppShell>
  );
}

export function VoyageApp() {
  const [width, setWidth] = useState(0);
  const [theme, setTheme] = useState('dark');
  const [meta, setMeta] = useState({ bp: 'lg', width: 0 });

  function toggleTheme() {
    const next = theme === 'dark' ? 'light' : 'dark';
    setTheme(next);
    document.documentElement.setAttribute('data-theme', next);
  }

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', minHeight: 0 }}>
      <KitBar
        app="Voyage · travel"
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
            <VoyageProduct bp={bp} theme={theme} onToggleTheme={toggleTheme} />
          </Reporter>
        )}
      </Viewport>
    </div>
  );
}

/** Lifts the measured breakpoint up to the kit bar without re-rendering the tree twice. */
function Reporter({ bp, width, onChange, children }) {
  React.useEffect(() => { onChange({ bp, width }); }, [bp, width, onChange]);
  return children;
}
