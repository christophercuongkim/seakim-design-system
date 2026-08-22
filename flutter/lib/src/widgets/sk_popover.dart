import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';

/// Which side of the trigger the popover prefers to open on. The primitive still
/// flips to the other side when the preferred one would overflow the viewport.
enum SkPopoverSide { above, below }

/// A trigger-anchored contextual overlay — the third overlay species.
///
/// Per decision 0022 and `spec/Popover.md`. Unlike a dialog or a sheet (both
/// screen-anchored and modal), an [SkPopover] sits next to the element that
/// spawned it, because its whole meaning is "this, here": a reaction bar above a
/// message, a menu under a button, an autocomplete list under a field.
///
/// It has two modes, and the split is not cosmetic — scrim presence *is*
/// modality, and modality decides the focus rule:
///
///   * **modal** (`modal: true`, a reaction bar) — a full-screen scrim sits
///     behind the surface, focus moves into the content on open and is restored
///     to the trigger on close, and Tab is kept within the content.
///   * **non-modal** (`modal: false`, the default; a tooltip or autocomplete) —
///     no scrim, focus stays on the trigger (a popover that steals focus is
///     broken for every AT user), and the surface is pointer-live so a suggestion
///     list can be clicked.
///
/// Both modes: position against the trigger's rect, flip to stay on-screen,
/// dismiss on Escape and outside-press, and wear the overlay surface with
/// [SkDepth.popover] and a hairline border ("borders define, shadows lift").
///
/// Flipping is **approximate**: the side is chosen from the trigger's global rect
/// measured on the previous frame against a fixed content budget, not from the
/// surface's laid-out height, so a popover taller than the budget can still clip.
class SkPopover extends StatefulWidget {
  const SkPopover({
    super.key,
    required this.child,
    required this.overlayBuilder,
    required this.open,
    this.onDismiss,
    this.modal = false,
    this.side = SkPopoverSide.below,
  });

  /// The trigger the popover is anchored to.
  final Widget child;

  /// Builds the popover content shown in the overlay when [open].
  final WidgetBuilder overlayBuilder;

  final bool open;

  /// Called on Escape, outside-press, and (non-modal) trigger blur. The owner is
  /// expected to respond by setting [open] to false.
  final VoidCallback? onDismiss;

  /// Scrim + focus-trap when true; focus-inert when false (the default).
  final bool modal;

  final SkPopoverSide side;

  @override
  State<SkPopover> createState() => _SkPopoverState();
}

class _SkPopoverState extends State<SkPopover> {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  final FocusScopeNode _scopeNode = FocusScopeNode(debugLabel: 'SkPopover');
  final FocusNode _triggerFocus =
      FocusNode(skipTraversal: true, canRequestFocus: false);

  // For modal restore: the node that held focus when the popover opened.
  FocusNode? _restoreFocus;

  @override
  void initState() {
    super.initState();
    if (widget.open) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    }
  }

  @override
  void didUpdateWidget(covariant SkPopover old) {
    super.didUpdateWidget(old);
    if (widget.open != old.open) {
      // Deferred so show()/hide() never run during the build that set open.
      WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    }
  }

  @override
  void dispose() {
    _scopeNode.dispose();
    _triggerFocus.dispose();
    super.dispose();
  }

  void _sync() {
    if (!mounted) return;
    if (widget.open) {
      if (!_portal.isShowing) {
        if (widget.modal) {
          _restoreFocus = FocusManager.instance.primaryFocus;
        }
        _portal.show();
      }
    } else {
      if (_portal.isShowing) {
        _portal.hide();
        if (widget.modal) {
          _restoreFocus?.requestFocus();
          _restoreFocus = null;
        }
      }
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (widget.open &&
        event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onDismiss?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onTriggerFocusChange(bool hasFocus) {
    // Non-modal only: dismiss when focus leaves both the trigger and the popover
    // content (the overlay child is in this Focus's subtree via OverlayPortal),
    // which is the "trigger blur" dismissal 0022 asks for. Modal keeps focus.
    if (!hasFocus && widget.open && !widget.modal) {
      widget.onDismiss?.call();
    }
  }

  /// Best-effort side choice from the trigger's global rect. See the class doc:
  /// this reads the previous frame's layout, so it is approximate.
  bool _resolveAbove(BuildContext overlayContext) {
    const double budget = 240; // approximate content height budget
    final BuildContext? tctx = _triggerKey.currentContext;
    final RenderObject? ro = tctx?.findRenderObject();
    if (ro is! RenderBox || !ro.hasSize) {
      return widget.side == SkPopoverSide.above;
    }
    final Offset topLeft = ro.localToGlobal(Offset.zero);
    final Size viewport = MediaQuery.sizeOf(overlayContext);
    final double spaceBelow = viewport.height - (topLeft.dy + ro.size.height);
    final double spaceAbove = topLeft.dy;
    if (widget.side == SkPopoverSide.above) {
      // Prefer above; flip down only if above can't fit and below has more room.
      return !(spaceAbove < budget && spaceBelow > spaceAbove);
    }
    // Prefer below; flip up only if below can't fit and above has more room.
    return spaceBelow < budget && spaceAbove > spaceBelow;
  }

  Widget _buildOverlay(BuildContext context) {
    final SkColors c = context.skColors;
    final bool above = _resolveAbove(context);
    final (Alignment target, Alignment follower, Offset offset) = above
        ? (Alignment.topLeft, Alignment.bottomLeft, const Offset(0, -4))
        : (Alignment.bottomLeft, Alignment.topLeft, const Offset(0, 4));

    Widget surface = Container(
      decoration: BoxDecoration(
        color: c.surfaceOverlay,
        border: Border.all(color: c.borderDefault, width: SkDepth.hairline),
        boxShadow: SkDepth.popover(c.brightness),
      ),
      child: widget.overlayBuilder(context),
    );

    if (widget.modal) {
      // Move focus into the content and keep Tab within it. FocusScope autofocus
      // plus a traversal group is the sanctioned approximation (0022): a hard
      // trap is not attempted, but focus lands inside and cycles there first.
      surface = FocusScope(
        node: _scopeNode,
        child: FocusTraversalGroup(
          child: Focus(autofocus: true, child: surface),
        ),
      );
    }

    return Stack(
      children: <Widget>[
        // Outside-press catcher. Modal paints the system scrim; non-modal is a
        // transparent full-screen tap-away, like SkSelect.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onDismiss?.call(),
            child: ColoredBox(
              color:
                  widget.modal ? c.surfaceScrim : const Color(0x00000000),
            ),
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          targetAnchor: target,
          followerAnchor: follower,
          offset: offset,
          child: surface,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _triggerFocus,
      onKeyEvent: _onKey,
      onFocusChange: _onTriggerFocusChange,
      child: CompositedTransformTarget(
        key: _triggerKey,
        link: _link,
        child: OverlayPortal(
          controller: _portal,
          overlayChildBuilder: _buildOverlay,
          child: widget.child,
        ),
      ),
    );
  }
}
