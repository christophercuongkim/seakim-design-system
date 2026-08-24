/* SeaKim dev shim.
   Resolves the design-system component namespace two ways:
     1. If the compiled bundle (_ds_bundle.js) is on the page, use its namespace.
     2. Otherwise fetch the component sources, strip module syntax, transform the
        JSX with the already-loaded Babel standalone, and evaluate them together.
   This exists so specimen cards and UI kits render when opened directly, before
   the bundle has been compiled. It is a development convenience, not part of the
   shipped system — consumers link styles.css and import the bundle. */
(function () {
  // Babel standalone defaults preset-react to the automatic JSX runtime, which
  // needs a bundler. Register a classic-runtime alias so inline
  // <script type="text/babel" data-presets="sk-react"> blocks compile to
  // React.createElement against the UMD global.
  if (window.Babel && window.Babel.registerPreset) {
    window.Babel.registerPreset('sk-react', {
      presets: [[window.Babel.availablePresets.react, { runtime: 'classic' }]]
    });
  }

  var FILES = [
    'components/core/Icon.jsx',
    'components/core/useCoarsePointer.js',
    'components/core/match.js',
    'components/core/Button.jsx',
    'components/core/IconButton.jsx',
    'components/core/Badge.jsx',
    'components/core/Tag.jsx',
    'components/core/Card.jsx',
    'components/core/Avatar.jsx',
    'components/core/AvatarStack.jsx',
    'components/core/Stat.jsx',
    'components/forms/Field.jsx',
    'components/forms/Input.jsx',
    'components/forms/Textarea.jsx',
    'components/forms/Select.jsx',
    'components/forms/Checkbox.jsx',
    'components/forms/Radio.jsx',
    'components/forms/Switch.jsx',
    'components/forms/SegmentedControl.jsx',
    'components/forms/Slider.jsx',
    'components/forms/DatePicker.jsx',
    'components/feedback/Dialog.jsx',
    'components/feedback/Toast.jsx',
    'components/feedback/Tooltip.jsx',
    'components/feedback/Popover.jsx',
    'components/feedback/Combobox.jsx',
    'components/feedback/EmptyState.jsx',
    'components/feedback/ErrorState.jsx',
    'components/feedback/Skeleton.jsx',
    'components/feedback/LoadingState.jsx',
    'components/data/Table.jsx',
    'components/data/Range.jsx',
    'components/navigation/Tabs.jsx',
    'components/navigation/SideNav.jsx',
    'components/navigation/TabBar.jsx'
  ];

  function fromBundle() {
    for (var k in window) {
      try {
        var v = window[k];
        if (v && typeof v === 'object' && typeof v.Button === 'function' && typeof v.Card === 'function') return v;
      } catch (e) { /* cross-origin getters */ }
    }
    return null;
  }

  window.SeaKimReady = function (root) {
    root = root || '';
    var hit = fromBundle();
    if (hit) return Promise.resolve(hit);
    return Promise.all(FILES.map(function (p) {
      return fetch(root + p).then(function (r) {
        if (!r.ok) throw new Error('missing ' + p);
        return r.text();
      });
    })).then(function (sources) {
      // Let Babel do the module transform properly, then feed each file a
      // `require` that resolves 'react' to the UMD global and every relative
      // sibling to the namespace built so far (files are listed in dep order).
      var ns = {};
      function req(spec) { return spec === 'react' ? window.React : ns; }
      sources.forEach(function (raw, i) {
        var code = Babel.transform(raw, {
          presets: [['react', { runtime: 'classic' }]],
          plugins: ['transform-modules-commonjs'],
          filename: FILES[i],
          sourceType: 'module'
        }).code;
        var mod = { exports: {} };
        new Function('require', 'module', 'exports', code)(req, mod, mod.exports);
        Object.keys(mod.exports).forEach(function (k) {
          if (k !== '__esModule') ns[k] = mod.exports[k];
        });
      });
      window.SeaKim = ns;
      return ns;
    });
  };
})();

/* Mount one or more demo/screen modules (their own .jsx files, same transform
   path as the components) into an element. Later modules can import earlier
   ones. Keeps specimen-card and UI-kit HTML free of inline JSX.
     SeaKimMount(root, 'components/core/core.demo.jsx', 'root')
     SeaKimMount(root, ['ui_kits/voyage/TripsScreen.jsx', 'ui_kits/voyage/App.jsx'], 'root', 'App')
*/
window.SeaKimMount = function (root, demoPaths, elementId, exportName) {
  var paths = [].concat(demoPaths);
  return window.SeaKimReady(root).then(function (ns) {
    function req(spec) { return spec === 'react' ? window.React : ns; }
    return paths.reduce(function (chain, p) {
      return chain.then(function () {
        return fetch(root + p).then(function (r) {
          if (!r.ok) throw new Error('missing ' + p);
          return r.text();
        }).then(function (raw) {
          var code = Babel.transform(raw, {
            presets: [['react', { runtime: 'classic' }]],
            plugins: ['transform-modules-commonjs'],
            filename: p,
            sourceType: 'module'
          }).code;
          var mod = { exports: {} };
          new Function('require', 'module', 'exports', code)(req, mod, mod.exports);
          Object.keys(mod.exports).forEach(function (k) {
            if (k !== '__esModule') ns[k] = mod.exports[k];
          });
        });
      });
    }, Promise.resolve()).then(function () {
      var Root = exportName ? ns[exportName] : (ns.Demo || ns.App);
      if (!Root) throw new Error('no ' + (exportName || 'Demo/App') + ' export');
      ReactDOM.createRoot(document.getElementById(elementId || 'root')).render(React.createElement(Root));
      return ns;
    });
  }).catch(function (e) {
    var host = document.getElementById(elementId || 'root');
    if (host) host.textContent = 'load error: ' + (e && e.message ? e.message : e);
    console.error(e);
  });
};
