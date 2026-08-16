import 'package:flutter/material.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

import 'gallery.dart';
import 'sk_gallery.dart';

/// A working starting point, and the proof that both adoption paths hold.
///
/// The scaffold, app bar, card, text field and buttons below are **stock
/// Material widgets** — nothing about them knows SeaKim exists. They take the
/// brand purely from `theme:`. The `Sk*` widgets in the second half sit beside
/// them, reading tokens from `SkThemeScope`.
///
///     flutter run                  # from example/
///     flutter build web --release  # check fonts are tree-shaken
void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  SkAppBrand _brand = SkAppBrand.voyage;
  ThemeMode _mode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeaKim example',
      debugShowCheckedModeBanner: false,
      theme: SkMaterialTheme.light(_brand),
      darkTheme: SkMaterialTheme.dark(_brand),
      themeMode: _mode,
      // Puts SeaKim tokens in scope so Sk* widgets can be mixed in. Follows the
      // ambient Material brightness, so it tracks themeMode on its own.
      builder: (BuildContext context, Widget? child) =>
          SkThemeScope(brand: _brand, child: child!),
      home: _Home(
        brand: _brand,
        mode: _mode,
        onBrand: (SkAppBrand b) => setState(() => _brand = b),
        onMode: (ThemeMode m) => setState(() => _mode = m),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({
    required this.brand,
    required this.mode,
    required this.onBrand,
    required this.onMode,
  });

  final SkAppBrand brand;
  final ThemeMode mode;
  final ValueChanged<SkAppBrand> onBrand;
  final ValueChanged<ThemeMode> onMode;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
        actions: <Widget>[
          IconButton(
            tooltip: 'SeaKim widget gallery',
            icon: const SkIcon(SkIcons.shapes),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                  builder: (BuildContext _) => const SkWidgetGallery()),
            ),
          ),
          IconButton(
            tooltip: 'Material coverage gallery',
            icon: const SkIcon(SkIcons.squaresFour),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                  builder: (BuildContext _) => const GalleryScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Toggle theme',
            icon: SkIcon(mode == ThemeMode.dark ? SkIcons.sun : SkIcons.moon),
            onPressed: () => onMode(
                mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(SkSpace.s6),
        children: <Widget>[
          // ---------------------------------------------------------------
          // Stock Material. Not one of these widgets is SeaKim-aware; they
          // are branded entirely by SkMaterialTheme.
          // ---------------------------------------------------------------
          Text('Stock Material widgets',
              style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: SkSpace.s4),
          const Card(
            child: ListTile(
              title: Text('Lisbon'),
              subtitle: Text('3 nights · Sea view'),
            ),
          ),
          const SizedBox(height: SkSpace.s4),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Destination',
              hintText: 'Where to?',
            ),
          ),
          const SizedBox(height: SkSpace.s4),
          Row(
            children: <Widget>[
              FilledButton(onPressed: () {}, child: const Text('Book')),
              const SizedBox(width: SkSpace.s4),
              OutlinedButton(onPressed: () {}, child: const Text('Hold')),
              const SizedBox(width: SkSpace.s4),
              TextButton(onPressed: () {}, child: const Text('Cancel')),
            ],
          ),

          const SizedBox(height: SkSpace.s8),
          const Divider(),
          const SizedBox(height: SkSpace.s8),

          // ---------------------------------------------------------------
          // SeaKim widgets, mixed into the same screen. These carry the feel
          // the theme cannot express — the scale-press, the duotone glyph.
          // ---------------------------------------------------------------
          Text('SeaKim widgets', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: SkSpace.s4),
          const SkCard(
            child: Padding(
              padding: EdgeInsets.all(SkSpace.s5),
              child: Row(
                children: <Widget>[
                  SkStat(label: 'Fare', value: '412', unit: 'USD', delta: '-18'),
                  Spacer(),
                  SkBadge(label: 'Confirmed', tone: SkBadgeTone.success),
                ],
              ),
            ),
          ),
          const SizedBox(height: SkSpace.s4),
          Row(
            children: <Widget>[
              SkButton(
                label: 'Save trip',
                iconLeft: SkIcons.bookmarkSimple,
                onPressed: () => showSkToast(context, message: 'Trip saved'),
              ),
              const SizedBox(width: SkSpace.s4),
              SkButton(
                label: 'Discard',
                variant: SkButtonVariant.ghost,
                onPressed: () => showSkDialog<void>(
                  context: context,
                  builder: (BuildContext context) => SkDialog(
                    title: 'Discard this trip?',
                    description: 'The itinerary and holds are removed. This cannot be undone.',
                    onClose: () => Navigator.of(context).pop(),
                    actions: <Widget>[
                      SkButton(
                        label: 'Keep trip',
                        variant: SkButtonVariant.ghost,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      SkButton(
                        label: 'Discard',
                        variant: SkButtonVariant.danger,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SkSpace.s6),

          // One accent hue live at a time — switching brand retints everything.
          Text('Brand', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: SkSpace.s3),
          Wrap(
            spacing: SkSpace.s3,
            children: SkAppBrand.values
                .map((SkAppBrand b) => SkButton(
                      label: b.name,
                      variant: b == brand
                          ? SkButtonVariant.primary
                          : SkButtonVariant.secondary,
                      size: SkButtonSize.sm,
                      onPressed: () => onBrand(b),
                    ))
                .toList(),
          ),
          const SizedBox(height: SkSpace.s6),
          SkEmptyState(
            title: 'No saved trips yet',
            description: 'Trips you save appear here, across every device.',
            compact: true,
            action: SkButton(label: 'Plan a trip', onPressed: () {}),
          ),
          const SizedBox(height: SkSpace.s6),
          TextButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: 'SeaKim example',
            ),
            child: Text('Licences', style: TextStyle(color: c.textAccent)),
          ),
        ],
      ),
    );
  }
}
