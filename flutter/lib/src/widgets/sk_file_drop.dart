import 'dart:ui' show PathMetric;

import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import 'sk_icon.dart';
import 'sk_icon_button.dart';
import 'sk_pressable.dart';
import 'sk_touch_target.dart';

/// What [SkFileDrop] shows for the chosen file.
class SkFileInfo {
  const SkFileInfo({required this.name, this.size});

  final String name;

  /// Bytes. Shown as '80.3 KB'.
  final int? size;

  /// '80.3 KB', '1.2 MB'.
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// A drop zone's affordance: dashed hairline, an icon, 'Tap to upload' with the
/// verb link-coloured, a hint line for the types and size. The chosen file is a
/// row beneath with its name, size and a remove control; uploading is a
/// labelled wait on that row (0021), never a bar; the error renders under the
/// zone. One file.
///
/// It renders the affordance and calls [onPick] when the zone is pressed; the
/// app opens its own picker, so the package takes no plugin dependency. Drag
/// and drop is a desktop gesture the app wires the same way.
class SkFileDrop extends StatelessWidget {
  const SkFileDrop({
    super.key,
    this.onPick,
    this.file,
    this.onRemove,
    this.uploading = false,
    this.error,
    this.hint,
    this.icon = SkIcons.uploadSimple,
    this.action = 'Tap to upload',
    this.label = 'a file',
    this.disabled = false,
  });

  /// Called when the zone is pressed; open the platform picker here.
  final VoidCallback? onPick;
  final SkFileInfo? file;
  final VoidCallback? onRemove;
  final bool uploading;
  final String? error;

  /// The types-and-size line: 'PDF up to 5 MB'.
  final String? hint;
  final SkGlyph? icon;

  /// The link-coloured verb.
  final String action;

  /// The rest of the line.
  final String label;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final bool coarse = skCoarsePointer(context);
    final Color ink = disabled ? c.textDisabled : c.textPrimary;
    final Color tertiary = disabled ? c.textDisabled : c.textTertiary;

    final Widget zone = SkPressable(
      onPressed: onPick,
      disabled: disabled || onPick == null,
      semanticLabel: '$action $label',
      builder: (BuildContext context, SkInteraction s) => SkFocusRing(
        visible: s.focused,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: disabled
                ? c.borderDisabled
                : error != null
                    ? c.textDanger
                    : s.liveHover
                        ? c.borderStrong
                        : c.borderDefault,
            radius: SkRadius.lg,
          ),
          child: AnimatedContainer(
            duration: SkMotion.instant,
            curve: SkMotion.out,
            constraints: BoxConstraints(
                minHeight: coarse ? SkControl.touch : SkControl.lg),
            padding: const EdgeInsets.symmetric(
                vertical: SkSpace.s6, horizontal: SkSpace.s5),
            decoration: BoxDecoration(
              color: disabled
                  ? c.fillDisabled
                  : s.liveHover
                      ? c.surfaceHover
                      : c.surfaceRaised,
              borderRadius: BorderRadius.circular(SkRadius.lg),
            ),
            child: Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  SkIcon(icon!, size: 20, color: tertiary),
                  const SizedBox(width: SkSpace.s4),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text.rich(
                        TextSpan(
                          style: SkText.body.copyWith(color: ink),
                          children: <InlineSpan>[
                            TextSpan(
                              text: action,
                              style: TextStyle(
                                  color:
                                      disabled ? c.textDisabled : c.textLink),
                            ),
                            TextSpan(text: ' $label'),
                          ],
                        ),
                      ),
                      if (hint != null) ...<Widget>[
                        const SizedBox(height: SkSpace.s1),
                        Text(hint!,
                            style: SkText.caption.copyWith(color: tertiary)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        zone,
        if (file != null) ...<Widget>[
          const SizedBox(height: SkSpace.s3),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: SkControl.md),
            child: Row(
              children: <Widget>[
                const SizedBox(width: SkSpace.s3),
                SkIcon(SkIcons.paperclip, size: 16, color: c.textTertiary),
                const SizedBox(width: SkSpace.s3),
                Flexible(
                  child: Text(
                    file!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SkText.bodySm.copyWith(color: c.textPrimary),
                  ),
                ),
                if (file!.size != null) ...<Widget>[
                  const SizedBox(width: SkSpace.s3),
                  Text(
                    SkFileInfo.formatSize(file!.size!),
                    style: SkText.caption.copyWith(color: c.textTertiary),
                  ),
                ],
                const Spacer(),
                if (uploading)
                  Semantics(
                    liveRegion: true,
                    label: 'Uploading',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        DecoratedBox(
                          decoration: BoxDecoration(color: c.surfaceShimmer),
                          child: const SizedBox(width: SkSpace.s9, height: 2),
                        ),
                        const SizedBox(width: SkSpace.s3),
                        Text('Uploading…',
                            style: SkText.caption
                                .copyWith(color: c.textSecondary)),
                      ],
                    ),
                  )
                else if (onRemove != null)
                  SkIconButton(
                    icon: SkIcons.x,
                    label: 'Remove ${file!.name}',
                    size: SkControl.sm,
                    onPressed: onRemove,
                    disabled: disabled,
                  ),
              ],
            ),
          ),
        ],
        if (error != null) ...<Widget>[
          const SizedBox(height: SkSpace.s3),
          Semantics(
            liveRegion: true,
            child: Text(error!,
                style: SkText.caption.copyWith(color: c.textDanger)),
          ),
        ],
      ],
    );
  }
}

/// A 1px dashed hairline on a rounded rect: the zone is an input, so it keeps
/// the one hairline 0037 allows, dashed to read as "put something here".
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(radius),
      ));
    const double dash = 6;
    const double gap = 4;
    for (final PathMetric metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      color != old.color || radius != old.radius;
}
