import 'package:flutter/material.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

/// Every Material widget the theme claims to cover, on one screen.
///
/// This is the drop-in check: nothing here is a SeaKim widget, so anything that
/// still looks like stock Material — rounded corners, a pill-shaped selection
/// indicator, an ink ripple — is a gap in [SkMaterialTheme], not in the app.
/// Scan it after changing the theme.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _nav = 0;
  bool _switchOn = true;
  bool _checked = true;
  String _radio = 'a';
  double _slider = 0.4;
  final Set<String> _segments = <String>{'list'};

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Material coverage'),
        actions: <Widget>[
          IconButton(icon: const SkIcon(SkIcons.bell), onPressed: () {}),
          const Badge(
            label: Text('3'),
            child: Padding(
              padding: EdgeInsets.only(right: SkSpace.s5),
              child: SkIcon(SkIcons.envelope),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(child: Text('SeaKim')),
            ListTile(leading: const SkIcon(SkIcons.house), title: const Text('Home'), onTap: () {}),
            ListTile(leading: const SkIcon(SkIcons.gear), title: const Text('Settings'), onTap: () {}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const SkIcon(SkIcons.plus),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _nav,
        onDestinationSelected: (int i) => setState(() => _nav = i),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: SkIcon(SkIcons.compass), label: 'Explore'),
          NavigationDestination(icon: SkIcon(SkIcons.suitcase), label: 'Trips'),
          NavigationDestination(icon: SkIcon(SkIcons.user), label: 'Account'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(SkSpace.s6),
        children: <Widget>[
          _section('Typography', t),
          Text('Display', style: t.displayMedium),
          Text('Headline', style: t.headlineMedium),
          Text('Title', style: t.titleMedium),
          Text('Body — the quick brown fox jumps over the lazy dog.', style: t.bodyMedium),
          Text('LABEL SMALL', style: t.labelSmall),

          _section('Buttons', t),
          Wrap(spacing: SkSpace.s3, runSpacing: SkSpace.s3, children: <Widget>[
            FilledButton(onPressed: () {}, child: const Text('Filled')),
            ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
            OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
            TextButton(onPressed: () {}, child: const Text('Text')),
            IconButton(icon: const SkIcon(SkIcons.heart), onPressed: () {}),
          ]),

          _section('Selection', t),
          SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(value: 'list', label: Text('List')),
              ButtonSegment<String>(value: 'grid', label: Text('Grid')),
            ],
            selected: _segments,
            onSelectionChanged: (Set<String> s) => setState(() {
              _segments
                ..clear()
                ..addAll(s);
            }),
          ),
          SwitchListTile(
            value: _switchOn,
            onChanged: (bool v) => setState(() => _switchOn = v),
            title: const Text('Switch'),
          ),
          CheckboxListTile(
            value: _checked,
            onChanged: (bool? v) => setState(() => _checked = v ?? false),
            title: const Text('Checkbox'),
          ),
          RadioGroup<String>(
            groupValue: _radio,
            onChanged: (String? v) => setState(() => _radio = v ?? 'a'),
            child: const Column(
              children: <Widget>[
                RadioListTile<String>(value: 'a', title: Text('Radio A')),
                RadioListTile<String>(value: 'b', title: Text('Radio B')),
              ],
            ),
          ),
          Slider(
            value: _slider,
            onChanged: (double v) => setState(() => _slider = v),
          ),

          _section('Inputs', t),
          const TextField(
            decoration: InputDecoration(labelText: 'Label', hintText: 'Hint'),
          ),
          const SizedBox(height: SkSpace.s4),
          const DropdownMenu<String>(
            initialSelection: 'one',
            dropdownMenuEntries: <DropdownMenuEntry<String>>[
              DropdownMenuEntry<String>(value: 'one', label: 'One'),
              DropdownMenuEntry<String>(value: 'two', label: 'Two'),
            ],
          ),

          _section('Containers', t),
          const Card(child: ListTile(title: Text('Card'), subtitle: Text('Flat, hairline border'))),
          const SizedBox(height: SkSpace.s4),
          const ExpansionTile(
            title: Text('Expansion tile'),
            children: <Widget>[ListTile(title: Text('Inside'))],
          ),
          const SizedBox(height: SkSpace.s4),
          Wrap(spacing: SkSpace.s3, children: <Widget>[
            Chip(label: const Text('Chip'), onDeleted: () {}),
            const Chip(label: Text('Plain')),
          ]),

          _section('Data', t),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('PLAYER')),
                DataColumn(label: Text('PTS')),
              ],
              rows: const <DataRow>[
                DataRow(cells: <DataCell>[DataCell(Text('Okafor')), DataCell(Text('18.2'))]),
                DataRow(cells: <DataCell>[DataCell(Text('Ruiz')), DataCell(Text('14.7'))]),
              ],
            ),
          ),
          const SizedBox(height: SkSpace.s4),
          const LinearProgressIndicator(value: 0.6),

          const SizedBox(height: SkSpace.s6),
          Text('Range — floor / expected / ceiling on one shared domain (0017)',
              style: t.labelSmall),
          const SizedBox(height: SkSpace.s3),
          _rangeRow(t, 'Chase', 12.1, 18.4, 24.0),
          // Njoku's tight band is the safe start; Robinson's wide one is boom-or-bust —
          // same projected figure, different risk. One row promoted to show the state.
          _rangeRow(t, 'Robinson', 5.2, 12.6, 22.8, accent: true),
          _rangeRow(t, 'Njoku', 15.6, 17.1, 18.9),

          _section('Overlays', t),
          Wrap(spacing: SkSpace.s3, runSpacing: SkSpace.s3, children: <Widget>[
            FilledButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Material dialog'),
                  content: const Text('Squared and bordered by the theme.'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close')),
                  ],
                ),
              ),
              child: const Text('Dialog'),
            ),
            FilledButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Snack bar')),
              ),
              child: const Text('Snack bar'),
            ),
            FilledButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) => const SizedBox(
                  height: 180,
                  child: Center(child: Text('Bottom sheet')),
                ),
              ),
              child: const Text('Sheet'),
            ),
            FilledButton(
              onPressed: () => showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDate: DateTime(2026, 8, 3),
              ),
              child: const Text('Date picker'),
            ),
            const Tooltip(
              message: 'Tooltip',
              child: Padding(
                padding: EdgeInsets.all(SkSpace.s3),
                child: Text('Hover me'),
              ),
            ),
          ]),
          const SizedBox(height: SkSpace.s12),
        ],
      ),
    );
  }

  Widget _section(String label, TextTheme t) => Padding(
        padding: const EdgeInsets.only(top: SkSpace.s8, bottom: SkSpace.s4),
        child: Text(label.toUpperCase(), style: t.labelSmall),
      );

  Widget _rangeRow(TextTheme t, String name, double low, double mid, double high,
          {bool accent = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: SkSpace.s3),
        child: Row(
          children: <Widget>[
            SizedBox(width: 72, child: Text(name, style: t.bodySmall)),
            Expanded(
              child: SkRange(
                low: low,
                mid: mid,
                high: high,
                domain: const (0, 30),
                accent: accent,
                label: '$name: floor $low, projected $mid, ceiling $high',
              ),
            ),
            SizedBox(
              width: 44,
              child: Text('$mid', textAlign: TextAlign.right, style: t.bodySmall),
            ),
          ],
        ),
      );
}
