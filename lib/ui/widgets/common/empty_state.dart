import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';

/// The pinned blank parchment slip: the board is waiting for its first note.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel and onAction go together',
       );

  /// Already localized heading.
  final String title;

  /// Already localized guidance sentence.
  final String? body;

  /// Label of the optional brass button below the text.
  final String? actionLabel;
  final VoidCallback? onAction;

  static const double _liftAboveMiddle = 90;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: SingleChildScrollView(
        // The artboard lifts the block above the middle (90px extra below) so it
        // clears the floating add button.
        padding: const EdgeInsets.fromLTRB(
          Space.s24,
          Space.s32,
          Space.s24,
          Space.s32 + _liftAboveMiddle,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ExcludeSemantics(child: BlankSlip()),
            const SizedBox(height: Space.s24),
            Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: context.displayText.headlineMedium,
              ),
            ),
            if (body != null) ...<Widget>[
              const SizedBox(height: Space.s12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: context.bodyText.bodyLarge!.copyWith(color: p.textDim),
                ),
              ),
            ],
            if (actionLabel != null) ...<Widget>[
              const SizedBox(height: Space.s24),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: Metrics.touchTarget,
                  minHeight: Metrics.touchTarget,
                ),
                child: FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(
                      Metrics.touchTarget,
                      Metrics.touchTarget,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Space.s24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Radii.control),
                    ),
                  ),
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A tilted blank slip held by a brass pin with a few faint ruled lines.
class BlankSlip extends StatelessWidget {
  const BlankSlip({super.key});

  /// Tilt from the artboard (-3 degrees).
  static const double _tilt = -3 * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Transform.rotate(
      angle: _tilt,
      child: SizedBox(
        width: Metrics.slipWidth,
        height: Metrics.slipHeight + Metrics.slipPin,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: Metrics.slipHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: p.parchment,
                  borderRadius: BorderRadius.circular(Radii.control),
                  border: Border.all(
                    color: p.parchmentEdge,
                    width: Metrics.hairline,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: p.scrim,
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Space.s22, Space.s26, Space.s22, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _Rule(color: p.inkFaint),
                      const SizedBox(height: Space.s18),
                      _Rule(color: p.inkFaint),
                      const SizedBox(height: Space.s18),
                      FractionallySizedBox(
                        widthFactor: 0.6,
                        child: _Rule(color: p.inkFaint),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: (Metrics.slipWidth - Metrics.slipPin) / 2,
              width: Metrics.slipPin,
              height: Metrics.slipPin,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: p.brass,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: p.scrim,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Space.s2,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Metrics.hairline),
      ),
    );
  }
}
