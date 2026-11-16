import 'package:flutter/material.dart';

import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import 'app_icon.dart';

/// Round brass add button floating over the list; the same on the Board and
/// the Missions screen.
class AddFab extends StatelessWidget {
  const AddFab({super.key, required this.label, required this.onPressed});

  /// Already localized semantic label.
  final String label;
  final VoidCallback onPressed;

  /// Opacity of the brass glow under the button (artboard: 35%).
  static const double _glowAlpha = 0.35;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: Tooltip(
        message: label,
        child: SizedBox(
          width: Metrics.fab,
          height: Metrics.fab,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: p.brass.withValues(alpha: _glowAlpha),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: p.brass,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: const ValueKey<String>('add-fab'),
                onTap: onPressed,
                child: Center(
                  child: AppIcon(
                    IconAsset.plus,
                    size: Metrics.iconSize,
                    color: p.inkOnBrass,
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
