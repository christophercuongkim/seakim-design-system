/* Theme toggle for specimen cards and guideline pages.
   Decision 0005 makes light first-class, which means every card has to be
   reviewable in both themes — a component only ever seen in dark is not done.
   This injects a fixed, unobtrusive control rather than each page hand-rolling one.

   Not part of the shipped system: consumers set data-theme themselves. */
(function () {
  var KEY = 'sk-card-theme';

  function apply(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    try { localStorage.setItem(KEY, theme); } catch (e) {}
  }

  function current() {
    return document.documentElement.getAttribute('data-theme') === 'light' ? 'light' : 'dark';
  }

  // Restore before first paint where possible.
  try {
    var stored = localStorage.getItem(KEY);
    if (stored === 'light' || stored === 'dark') apply(stored);
  } catch (e) {}

  function mount() {
    if (document.getElementById('sk-theme-toggle')) return;

    var btn = document.createElement('button');
    btn.id = 'sk-theme-toggle';
    btn.type = 'button';
    btn.setAttribute('aria-label', 'Switch theme');
    btn.style.cssText = [
      'position:fixed', 'top:10px', 'right:10px', 'z-index:9000',
      'height:26px', 'padding:0 9px', 'cursor:pointer',
      'display:inline-flex', 'align-items:center', 'gap:6px',
      'background:var(--surface-raised)', 'color:var(--text-secondary)',
      'border:1px solid var(--border-default)', 'border-radius:0',
      'font-family:var(--font-mono)', 'font-size:10px',
      'letter-spacing:0.1em', 'text-transform:uppercase',
      'transition:var(--transition-control)'
    ].join(';');

    function label() {
      btn.textContent = current();
    }

    btn.addEventListener('click', function () {
      apply(current() === 'dark' ? 'light' : 'dark');
      label();
    });
    btn.addEventListener('mouseenter', function () {
      btn.style.color = 'var(--text-primary)';
      btn.style.borderColor = 'var(--border-strong)';
    });
    btn.addEventListener('mouseleave', function () {
      btn.style.color = 'var(--text-secondary)';
      btn.style.borderColor = 'var(--border-default)';
    });

    label();
    document.body.appendChild(btn);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', mount);
  } else {
    mount();
  }
})();
