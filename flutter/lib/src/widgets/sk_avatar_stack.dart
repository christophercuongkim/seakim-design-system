import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import 'sk_avatar.dart';

/// One person in an [SkAvatarStack] — the same fields [SkAvatar] takes.
@immutable
class SkAvatarData {
  const SkAvatarData({required this.name, this.image, this.status});

  /// Used for the initials and, via the stack, the collective semantics count.
  final String name;

  /// Real imagery when you have it. No generated or stock fallbacks.
  final ImageProvider? image;

  final SkAvatarStatus? status;
}

/// More than one avatar in one place: overlaps them by a shared fraction of the
/// diameter ([SkSpace.avatarOverlap]), caps the visible count at [max], and
/// collapses the remainder into a "+k" count pill.
///
/// The pill is a count, not a control (0024) — a caller that wants "see all"
/// wraps the stack. When the remainder is exactly one, the avatar is shown rather
/// than "+1": a pill that saves no space is noise. [frontToBack] picks which end
/// sits on top; it defaults to first-in-front and is *not* a reading-order
/// assumption, since the system inherits no bidi position.
///
/// [SkAvatar] stays the single source of the circle, initials, and status dot;
/// the stack only arranges instances of it. For a single person use [SkAvatar].
///
/// See decision 0024 and `spec/AvatarStack.md`.
class SkAvatarStack extends StatelessWidget {
  const SkAvatarStack({
    super.key,
    required this.items,
    this.size = SkAvatarSize.sm,
    this.max = 3,
    this.frontToBack = true,
  });

  /// People to show, front-most first.
  final List<SkAvatarData> items;

  final SkAvatarSize size;

  /// Visible avatars before the remainder collapses to a "+k" pill. A remainder
  /// of exactly one shows the avatar instead of "+1".
  final int max;

  /// First avatar on top (default), or last. Not a reading-order assumption.
  final bool frontToBack;

  double get _diameter => switch (size) {
        SkAvatarSize.xs => 20,
        SkAvatarSize.sm => 24,
        SkAvatarSize.md => 32,
        SkAvatarSize.lg => 44,
        SkAvatarSize.xl => 64,
      };

  double get _fontSize => switch (size) {
        SkAvatarSize.xs || SkAvatarSize.sm => SkFontSize.xs2,
        SkAvatarSize.md => SkFontSize.xs,
        SkAvatarSize.lg => SkFontSize.sm,
        SkAvatarSize.xl => SkFontSize.lg,
      };

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final double d = _diameter;
    const double overlap = SkSpace.avatarOverlap;
    final double step = d - overlap;

    final int remainder = items.length - max;
    final bool overflow = remainder > 1;
    final List<SkAvatarData> shown = overflow ? items.take(max).toList() : items;
    final int plus = overflow ? remainder : 0;

    // A ring of --surface-card separates each mark from the one it overlaps — a
    // spread-only box shadow, the outline analogue that never changes the size.
    final List<BoxShadow> ring = <BoxShadow>[
      BoxShadow(color: c.surfaceCard, spreadRadius: 2),
    ];

    // Measure the pill so the Stack can size to it exactly.
    double pillW = 0;
    Widget? pill;
    if (plus > 0) {
      final String text = '+$plus';
      final TextStyle style = SkText.data.copyWith(
        fontSize: _fontSize,
        color: c.textSecondary,
        height: 1,
      );
      final TextPainter tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      pillW = math.max(d, tp.width + SkSpace.s2 * 2);
      pill = Container(
        width: pillW,
        height: d,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.surfaceSunken,
          borderRadius: BorderRadius.circular(SkRadius.pill),
          boxShadow: ring,
        ),
        child: Text(text, style: style),
      );
    }

    final int slots = shown.length + (plus > 0 ? 1 : 0);
    if (slots == 0) return const SizedBox.shrink();
    final double totalW = (slots - 1) * step + (plus > 0 ? pillW : d);

    final List<Widget> layers = <Widget>[];
    for (int i = 0; i < slots; i++) {
      final bool isPill = plus > 0 && i == shown.length;
      final Widget child = isPill
          ? pill!
          : DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: ring),
              child: SkAvatar(
                name: shown[i].name,
                image: shown[i].image,
                size: size,
                status: shown[i].status,
              ),
            );
      layers.add(Positioned(left: i * step, top: 0, child: child));
    }
    // A Stack paints later children on top; first-in-front means slot 0 must
    // paint last, so reverse the paint order without touching the positions.
    final List<Widget> ordered =
        frontToBack ? layers.reversed.toList() : layers;

    final String label = plus > 0
        ? '${shown.length} people, and $plus more'
        : '${items.length} ${items.length == 1 ? 'person' : 'people'}';

    return Semantics(
      container: true,
      label: label,
      child: ExcludeSemantics(
        child: SizedBox(
          width: totalW,
          height: d,
          child: Stack(clipBehavior: Clip.none, children: ordered),
        ),
      ),
    );
  }
}
