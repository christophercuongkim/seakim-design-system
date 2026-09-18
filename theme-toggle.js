/* Theme toggle for specimen cards and guideline pages.
   Decision 0005 makes light first-class, which means every card has to be
   reviewable in both themes — a component only ever seen in dark is not done.
   This injects one fixed, unobtrusive control rather than each page
   hand-rolling it.

   Not part of the shipped system: consumers set data-theme themselves. */
(function () {
  var THEME_KEY = 'sk-card-theme';

  function setAttr(name, value, key) {
    if (value) document.documentElement.setAttribute(name, value);
    else document.documentElement.removeAttribute(name);
    try { localStorage.setItem(key, value || ''); } catch (e) {}
  }
  function theme() {
    return document.documentElement.getAttribute('data-theme') === 'dark' ? 'dark' : 'light';
  }

  // Restore before first paint where possible.
  try {
    var t = localStorage.getItem(THEME_KEY);
    if (t === 'light' || t === 'dark') setAttr('data-theme', t, THEME_KEY);
  } catch (e) {}

  function button(id, right, label, onClick) {
    var btn = document.createElement('button');
    btn.id = id;
    btn.type = 'button';
    btn.setAttribute('aria-label', label);
    btn.style.cssText = [
      'position:fixed', 'top:10px', 'right:' + right, 'z-index:9000',
      'height:26px', 'padding:0 9px', 'cursor:pointer',
      'display:inline-flex', 'align-items:center', 'gap:6px',
      'background:var(--surface-raised)', 'color:var(--text-secondary)',
      'border:1px solid var(--border-default)', 'border-radius:0',
      'font-family:var(--font-mono)', 'font-size:10px',
      'letter-spacing:0.1em', 'text-transform:uppercase',
      'transition:var(--transition-control)'
    ].join(';');
    btn.addEventListener('click', onClick);
    btn.addEventListener('mouseenter', function () {
      btn.style.color = 'var(--text-primary)';
      btn.style.borderColor = 'var(--border-strong)';
    });
    btn.addEventListener('mouseleave', function () {
      btn.style.color = 'var(--text-secondary)';
      btn.style.borderColor = 'var(--border-default)';
    });
    return btn;
  }

  function mount() {
    if (document.getElementById('sk-theme-toggle')) return;

    var themeBtn = button('sk-theme-toggle', '10px', 'Switch theme', function () {
      setAttr('data-theme', theme() === 'dark' ? 'light' : 'dark', THEME_KEY);
      themeBtn.textContent = theme();
    });
    themeBtn.textContent = theme();

    document.body.appendChild(themeBtn);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', mount);
  } else {
    mount();
  }
})();
