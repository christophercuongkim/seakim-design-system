/* Theme and type-trial toggles for specimen cards and guideline pages.
   Decision 0005 makes light first-class, which means every card has to be
   reviewable in both themes — a component only ever seen in dark is not done.
   The type trial (CHR-188) is reviewed the same way. This injects two fixed,
   unobtrusive controls rather than each page hand-rolling them.

   Not part of the shipped system: consumers set data-theme themselves and
   never set data-type. */
(function () {
  var THEME_KEY = 'sk-card-theme';
  var TYPE_KEY = 'sk-card-type';

  function setAttr(name, value, key) {
    if (value) document.documentElement.setAttribute(name, value);
    else document.documentElement.removeAttribute(name);
    try { localStorage.setItem(key, value || ''); } catch (e) {}
  }
  function theme() {
    return document.documentElement.getAttribute('data-theme') === 'dark' ? 'dark' : 'light';
  }
  function type() {
    return document.documentElement.getAttribute('data-type') === 'trial' ? 'trial' : 'today';
  }

  // Restore before first paint where possible.
  try {
    var t = localStorage.getItem(THEME_KEY);
    if (t === 'light' || t === 'dark') setAttr('data-theme', t, THEME_KEY);
    var y = localStorage.getItem(TYPE_KEY);
    if (y === 'trial') setAttr('data-type', 'trial', TYPE_KEY);
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

    var typeBtn = button('sk-type-toggle', '70px', 'Toggle the type trial', function () {
      setAttr('data-type', type() === 'trial' ? '' : 'trial', TYPE_KEY);
      typeBtn.textContent = 'type: ' + type();
    });
    typeBtn.textContent = 'type: ' + type();

    document.body.appendChild(themeBtn);
    document.body.appendChild(typeBtn);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', mount);
  } else {
    mount();
  }
})();
