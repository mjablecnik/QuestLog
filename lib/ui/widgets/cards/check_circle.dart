import 'package:flutter/material.dart';

import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../common/app_icon.dart';

/// The round check of a Quest: 28px painted inside a 44x44 hit area.
///
/// Unchecked it is an outlined circle, checked a brass disc with a tick. The
/// tick fades (and scales) in; under reduced motion it only fades.
class CheckCircle extends StatefulWidget {
  const CheckCircle({
    super.key,
    required this.checked,
    required this.semanticLabel,
    this.onTap,
  });

  final bool checked;

  /// Already localized, for example "Complete quest X" or "Reopen quest X".
  final String semanticLabel;

  /// Null disables the control (no pressed state, no semantic action).
  final VoidCallback? onTap;

  @override
  State<CheckCircle> createState() => _CheckCircleState();
}

class _CheckCircleState extends State<CheckCircle> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bool reduced = MediaQuery.disableAnimationsOf(context);
    final Duration duration = reduced ? Motion.reducedFade : Motion.hover;
    final bool enabled = widget.onTap != null;
    final bool checked = widget.checked;

    return Semantics(
      container: true,
      button: true,
      checked: checked,
      enabled: enabled,
      label: widget.semanticLabel,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: SizedBox(
          width: Metrics.touchTarget,
          height: Metrics.touchTarget,
          child: Center(
            child: AnimatedContainer(
              duration: duration,
              curve: Motion.curve,
              width: Metrics.checkPainted,
              height: Metrics.checkPainted,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked ? p.brass : (_pressed ? p.brassSoft : null),
                border: Border.all(
                  color: checked
                      ? p.brass
                      : (_pressed ? p.brass : p.slipTextFaint),
                  width: 2,
                ),
              ),
              child: AnimatedOpacity(
                duration: duration,
                curve: Motion.curve,
                opacity: checked ? 1 : 0,
                child: AnimatedScale(
                  duration: duration,
                  curve: Motion.curve,
                  scale: (checked || reduced) ? 1 : 0.6,
                  child: Center(
                    child: AppIcon(
                      IconAsset.tick,
                      size: Metrics.iconSmall,
                      color: p.inkOnBrass,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
