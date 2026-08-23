import 'package:flutter/material.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

/// The canonical list of every SeaKim widget, demonstrated once.
///
/// One [SkDemo] entry per widget file exported from `seakim_flutter.dart`. The
/// gallery ([SkWidgetGallery]) renders from this list, and `preview_coverage_test`
/// verifies it: the completeness test counts widget exports and asserts one demo
/// each, the buildability test pumps every [build] and expects no exception.
///
/// Each [build] references the widget's real Dart TYPE, so the compiler — not a
/// grep — guarantees the widget exists and its arguments are valid. Rename or
/// remove a widget and this file stops compiling.
typedef SkDemoBuilder = Widget Function(BuildContext context);

class SkDemo {
  const SkDemo(this.section, this.label, this.build);

  /// Grouping heading in the gallery, e.g. 'Avatars', 'Inputs'.
  final String section;

  /// Short human label shown above the demo.
  final String label;

  /// Builds a live instantiation of the widget's primary type.
  final SkDemoBuilder build;
}

class _Player {
  const _Player(this.name, this.role, this.pts);
  final String name;
  final String role;
  final double pts;
}

const List<_Player> _players = <_Player>[
  _Player('Okafor', 'Guard', 18.2),
  _Player('Ruiz', 'Forward', 14.7),
  _Player('Njoku', 'Center', 11.3),
];

/// Exactly one entry per `export 'src/widgets/sk_*.dart'` in the barrel.
final List<SkDemo> skShowcase = <SkDemo>[
  // sk_avatar.dart
  SkDemo('Avatars', 'Sizes and status', (BuildContext context) => const Wrap(
        spacing: SkSpace.s4,
        runSpacing: SkSpace.s4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          SkAvatar(name: 'Ada Okafor', size: SkAvatarSize.sm),
          SkAvatar(name: 'Ravi Patel', status: SkAvatarStatus.live),
          SkAvatar(
              name: 'Mei Lin',
              size: SkAvatarSize.lg,
              status: SkAvatarStatus.idle),
          SkAvatar(
              name: 'Jonas Berg',
              size: SkAvatarSize.xl,
              status: SkAvatarStatus.out),
        ],
      )),

  // sk_avatar_stack.dart
  SkDemo('Avatars', 'Overlapping facepile', (BuildContext context) =>
      const SkAvatarStack(
        max: 3,
        items: <SkAvatarData>[
          SkAvatarData(name: 'Dana Okafor'),
          SkAvatarData(name: 'Marcus Reid', status: SkAvatarStatus.live),
          SkAvatarData(name: 'Priya Shah'),
          SkAvatarData(name: 'Lena Cruz'),
          SkAvatarData(name: 'Sam Iwu'),
        ],
      )),

  // sk_badge.dart
  SkDemo('Badges', 'Tones', (BuildContext context) => const Wrap(
        spacing: SkSpace.s3,
        runSpacing: SkSpace.s3,
        children: <Widget>[
          SkBadge(label: 'Confirmed', tone: SkBadgeTone.success),
          SkBadge(label: 'Pending'),
        ],
      )),

  // sk_button.dart
  SkDemo('Buttons', 'Primary and ghost', (BuildContext context) => Wrap(
        spacing: SkSpace.s4,
        runSpacing: SkSpace.s4,
        children: <Widget>[
          SkButton(
            label: 'Save trip',
            iconLeft: SkIcons.bookmarkSimple,
            onPressed: () {},
          ),
          SkButton(
            label: 'Discard',
            variant: SkButtonVariant.ghost,
            onPressed: () {},
          ),
        ],
      )),

  // sk_card.dart
  SkDemo('Cards', 'Surface with stat and badge',
      (BuildContext context) => const SkCard(
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
          )),

  // sk_checkbox.dart
  SkDemo('Selection', 'Checkbox', (BuildContext context) {
    bool value = true;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => SkCheckbox(
        value: value,
        label: 'Add trip insurance',
        hint: 'Covers cancellation up to the fare',
        onChanged: (bool v) => setState(() => value = v),
      ),
    );
  }),

  // sk_combobox.dart
  SkDemo('Inputs', 'Combobox (searchable)', (BuildContext context) {
    String? value;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) =>
          SkCombobox<String>(
        value: value,
        placeholder: 'Currency',
        onChanged: (String v) => setState(() => value = v),
        options: const <SkComboboxOption<String>>[
          SkComboboxOption<String>(value: 'usd', label: 'US Dollar'),
          SkComboboxOption<String>(value: 'eur', label: 'Euro'),
          SkComboboxOption<String>(value: 'gbp', label: 'British Pound'),
          SkComboboxOption<String>(value: 'jpy', label: 'Japanese Yen'),
          SkComboboxOption<String>(value: 'chf', label: 'Swiss Franc'),
        ],
      ),
    );
  }),

  // sk_date_picker.dart
  SkDemo('Date picker', 'Departure', (BuildContext context) {
    DateTime? date = DateTime(2026, 8, 20);
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => SkDatePicker(
        value: date,
        label: 'Depart',
        hint: 'Pick a departure date',
        onChanged: (DateTime d) => setState(() => date = d),
      ),
    );
  }),

  // sk_dialog.dart
  SkDemo('Dialog', 'Confirm discard', (BuildContext context) => SkButton(
        label: 'Discard trip',
        variant: SkButtonVariant.ghost,
        onPressed: () => showSkDialog<void>(
          context: context,
          builder: (BuildContext context) => SkDialog(
            title: 'Discard this trip?',
            description:
                'The itinerary and holds are removed. This cannot be undone.',
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
      )),

  // sk_empty_state.dart
  SkDemo('Empty state', 'No saved trips',
      (BuildContext context) => SkEmptyState(
            title: 'No saved trips yet',
            description: 'Trips you save appear here, across every device.',
            compact: true,
            action: SkButton(label: 'Plan a trip', onPressed: () {}),
          )),

  // sk_field.dart
  SkDemo('Inputs', 'Field wrapping an input',
      (BuildContext context) => SkField(
            label: 'Passenger name',
            hint: 'Exactly as printed on the passport',
            required: true,
            child: SkInput(
              placeholder: 'Full name',
              iconLeft: SkIcons.user,
              onChanged: (String _) {},
            ),
          )),

  // sk_icon.dart
  SkDemo('Icon', 'Duotone glyph', (BuildContext context) =>
      SkIcon(SkIcons.bookmarkSimple, color: context.skColors.textAccent)),

  // sk_icon_button.dart
  SkDemo('Icon buttons', 'Variants and states',
      (BuildContext context) => Wrap(
            spacing: SkSpace.s3,
            runSpacing: SkSpace.s3,
            children: <Widget>[
              SkIconButton(
                icon: SkIcons.pencilSimple,
                label: 'Edit',
                onPressed: () {},
              ),
              SkIconButton(
                icon: SkIcons.bookmarkSimple,
                label: 'Save',
                active: true,
                onPressed: () {},
              ),
              SkIconButton(
                icon: SkIcons.trash,
                label: 'Delete',
                variant: SkIconButtonVariant.secondary,
                onPressed: () {},
              ),
              const SkIconButton(
                icon: SkIcons.gear,
                label: 'Settings',
                disabled: true,
              ),
            ],
          )),

  // sk_input.dart
  SkDemo('Inputs', 'Input with suffix', (BuildContext context) => const SkInput(
        placeholder: '412',
        suffix: 'USD',
        mono: true,
      )),

  // sk_loading_state.dart
  SkDemo('Loading', 'Full-page gate', (BuildContext context) => const SkLoadingState(
        title: 'Checking 40 airlines…',
        description: 'Holding your dates while we compare fares.',
      )),

  // sk_popover.dart
  SkDemo('Popover', 'Anchored menu', (BuildContext context) {
    bool open = false;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => SkPopover(
        open: open,
        onDismiss: () => setState(() => open = false),
        overlayBuilder: (BuildContext context) => Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: SkSpace.s5, vertical: SkSpace.s3),
          child: Text('Rename · Duplicate · Delete',
              style:
                  SkText.bodySm.copyWith(color: context.skColors.textPrimary)),
        ),
        child: SkButton(
          label: 'Actions',
          variant: SkButtonVariant.ghost,
          onPressed: () => setState(() => open = !open),
        ),
      ),
    );
  }),

  // sk_pressable.dart
  SkDemo('Pressable', 'Custom press target', (BuildContext context) {
    int presses = 0;
    final SkColors c = context.skColors;
    final TextTheme t = Theme.of(context).textTheme;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => SkPressable(
        onPressed: () => setState(() => presses++),
        builder: (BuildContext context, SkInteraction s) => Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SkSpace.s5, vertical: SkSpace.s3),
          decoration: BoxDecoration(
            color: s.liveHover ? c.surfaceHover : c.surfaceCard,
            border: Border.all(color: c.borderDefault, width: SkDepth.hairline),
          ),
          child: Text('Pressed $presses times', style: t.bodyMedium),
        ),
      ),
    );
  }),

  // sk_radio.dart
  SkDemo('Selection', 'Radio group', (BuildContext context) {
    String value = 'aisle';
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) =>
          SkRadioGroup<String>(
        value: value,
        onChanged: (String v) => setState(() => value = v),
        options: const <SkRadioOption<String>>[
          SkRadioOption<String>(
            value: 'aisle',
            label: 'Aisle',
            hint: 'Easy to get up mid-flight',
          ),
          SkRadioOption<String>(
            value: 'window',
            label: 'Window',
            hint: 'A wall to lean on',
          ),
        ],
      ),
    );
  }),

  // sk_range.dart
  SkDemo('Range', 'Floor / mid / ceiling',
      (BuildContext context) => const SizedBox(
            width: 220,
            child: SkRange(low: 120, mid: 180, high: 260, domain: (0, 320)),
          )),

  // sk_segmented_control.dart
  SkDemo('Selection', 'Segmented control', (BuildContext context) {
    String value = 'list';
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) =>
          SkSegmentedControl<String>(
        value: value,
        onChanged: (String v) => setState(() => value = v),
        segments: const <SkSegment<String>>[
          SkSegment<String>(value: 'list', label: 'List', icon: SkIcons.list),
          SkSegment<String>(
              value: 'grid', label: 'Grid', icon: SkIcons.gridFour),
          SkSegment<String>(
              value: 'map', label: 'Map', icon: SkIcons.mapTrifold),
        ],
      ),
    );
  }),

  // sk_select.dart
  SkDemo('Inputs', 'Select', (BuildContext context) {
    String value = 'economy';
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) =>
          SkSelect<String>(
        value: value,
        placeholder: 'Cabin',
        onChanged: (String v) => setState(() => value = v),
        options: const <SkSelectOption<String>>[
          SkSelectOption<String>(value: 'economy', label: 'Economy'),
          SkSelectOption<String>(value: 'premium', label: 'Premium economy'),
          SkSelectOption<String>(value: 'business', label: 'Business'),
          SkSelectOption<String>(value: 'first', label: 'First'),
        ],
      ),
    );
  }),

  // sk_side_nav.dart
  SkDemo('Side navigation', 'Grouped nav', (BuildContext context) {
    String active = 'trips';
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => SizedBox(
        height: 320,
        child: Row(
          children: <Widget>[
            SkSideNav<String>(
              brand: 'SeaKim',
              active: active,
              onNavigate: (String v) => setState(() => active = v),
              groups: const <SkNavGroup<String>>[
                SkNavGroup<String>(
                  items: <SkNavItem<String>>[
                    SkNavItem<String>(
                        value: 'explore',
                        label: 'Explore',
                        icon: SkIcons.compass),
                    SkNavItem<String>(
                        value: 'trips',
                        label: 'Trips',
                        icon: SkIcons.suitcase),
                  ],
                ),
                SkNavGroup<String>(
                  label: 'Account',
                  items: <SkNavItem<String>>[
                    SkNavItem<String>(
                        value: 'settings',
                        label: 'Settings',
                        icon: SkIcons.gear),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }),

  // sk_skeleton.dart
  SkDemo('Loading', 'Skeleton rows', (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SkSkeleton(width: 220, height: SkSpace.s5),
          SizedBox(height: SkSpace.s2),
          SkSkeleton(width: 160),
          SizedBox(height: SkSpace.s2),
          SkSkeleton(width: 190),
        ],
      )),

  // sk_slider.dart
  SkDemo('Slider', 'Nightly budget', (BuildContext context) {
    double value = 40;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => SkSlider(
        value: value,
        label: 'Nightly budget',
        format: (double v) => '\$${v.toStringAsFixed(0)}',
        onChanged: (double v) => setState(() => value = v),
      ),
    );
  }),

  // sk_stat.dart
  SkDemo('Stat', 'Fare with delta', (BuildContext context) => const SkStat(
        label: 'Fare',
        value: '412',
        unit: 'USD',
        delta: '-18',
      )),

  // sk_switch.dart
  SkDemo('Selection', 'Switch', (BuildContext context) {
    bool value = true;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => SkSwitch(
        value: value,
        label: 'Sync across devices',
        hint: 'Trips appear on every signed-in device',
        onChanged: (bool v) => setState(() => value = v),
      ),
    );
  }),

  // sk_tab_bar.dart
  SkDemo('Bottom tab bar', 'Explore / Trips / Account', (BuildContext context) {
    String active = 'explore';
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) =>
          SkTabBar<String>(
        active: active,
        onChanged: (String v) => setState(() => active = v),
        items: const <SkTabBarItem<String>>[
          SkTabBarItem<String>(
              value: 'explore', label: 'Explore', icon: SkIcons.compass),
          SkTabBarItem<String>(
              value: 'trips', label: 'Trips', icon: SkIcons.suitcase),
          SkTabBarItem<String>(
              value: 'account', label: 'Account', icon: SkIcons.user),
        ],
      ),
    );
  }),

  // sk_tabs.dart
  SkDemo('Tabs', 'Itinerary / Lodging / Messages',
      (BuildContext context) {
    String value = 'itinerary';
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => SkTabs<String>(
        value: value,
        onChanged: (String v) => setState(() => value = v),
        tabs: const <SkTab<String>>[
          SkTab<String>(
              value: 'itinerary', label: 'Itinerary', icon: SkIcons.path),
          SkTab<String>(value: 'lodging', label: 'Lodging', icon: SkIcons.bed),
          SkTab<String>(
              value: 'messages',
              label: 'Messages',
              icon: SkIcons.chatCircle,
              count: 3),
        ],
      ),
    );
  }),

  // sk_table.dart
  SkDemo('Table', 'Roster', (BuildContext context) => SkTable<_Player>(
        rowKey: (_Player p) => p.name,
        columns: <SkTableColumn<_Player>>[
          SkTableColumn<_Player>(
            key: 'name',
            label: 'Player',
            identifying: true,
            cell: (_Player p) => Text(p.name),
            secondary: (_Player p) => p.role,
          ),
          SkTableColumn<_Player>(
            key: 'role',
            label: 'Role',
            cell: (_Player p) => Text(p.role),
          ),
          SkTableColumn<_Player>(
            key: 'pts',
            label: 'Pts',
            numeric: true,
            survives: true,
            cell: (_Player p) => Text(p.pts.toStringAsFixed(1)),
          ),
        ],
        rows: _players,
      )),

  // sk_tag.dart
  SkDemo('Tags', 'Selectable and removable', (BuildContext context) {
    bool selected = true;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => Wrap(
        spacing: SkSpace.s3,
        runSpacing: SkSpace.s3,
        children: <Widget>[
          SkTag(
            label: 'Nonstop',
            icon: SkIcons.airplane,
            selected: selected,
            onPressed: () => setState(() => selected = !selected),
          ),
          SkTag(label: 'Refundable', onPressed: () {}),
          SkTag(label: 'Window seat', onRemove: () {}),
        ],
      ),
    );
  }),

  // sk_textarea.dart
  SkDemo('Inputs', 'Textarea', (BuildContext context) => const SkTextarea(
        placeholder: 'Trip notes — anything the crew should know',
        minLines: 3,
        maxLines: 6,
      )),

  // sk_toast.dart
  SkDemo('Toast', 'Trip saved', (BuildContext context) => SkButton(
        label: 'Save trip',
        iconLeft: SkIcons.bookmarkSimple,
        onPressed: () => showSkToast(context, message: 'Trip saved'),
      )),

  // sk_tooltip.dart
  SkDemo('Tooltip', 'On an icon', (BuildContext context) => SkTooltip(
        label: 'Saved to your trips',
        child:
            SkIcon(SkIcons.bookmarkSimple, color: context.skColors.textAccent),
      )),
];
