import 'package:flutter/material.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

import 'sk_showcase.dart';

/// Every SeaKim widget on one screen, so nothing ships undemonstrated.
///
/// The companion to [GalleryScreen]: that one is stock Material proving the theme
/// adopts, this one is the `Sk*` set proving each widget renders and reacts. It
/// renders straight from [skShowcase] — the same canonical list the coverage test
/// verifies — so a widget cannot be added without appearing here.
class SkWidgetGallery extends StatelessWidget {
  const SkWidgetGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;

    // Group by section, preserving each section's first-seen order.
    final Map<String, List<SkDemo>> bySection = <String, List<SkDemo>>{};
    for (final SkDemo demo in skShowcase) {
      bySection.putIfAbsent(demo.section, () => <SkDemo>[]).add(demo);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SeaKim widgets'),
        actions: <Widget>[
          SkIconButton(
            icon: SkIcons.bell,
            label: 'Notifications',
            onPressed: () {},
          ),
          const SizedBox(width: SkSpace.s2),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(SkSpace.s6),
        children: <Widget>[
          for (final MapEntry<String, List<SkDemo>> section
              in bySection.entries) ...<Widget>[
            Padding(
              padding: const EdgeInsets.only(top: SkSpace.s8, bottom: SkSpace.s4),
              child: Text(section.key.toUpperCase(), style: t.labelSmall),
            ),
            for (final SkDemo demo in section.value) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: SkSpace.s2),
                child: Text(demo.label, style: t.labelSmall),
              ),
              Builder(builder: demo.build),
              const SizedBox(height: SkSpace.s4),
            ],
          ],
          const SizedBox(height: SkSpace.s12),
        ],
      ),
    );
  }
}
