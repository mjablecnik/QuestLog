import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';

/// Caps section label on the left and "N quests · M XP" on the right.
class DetailSectionHead extends StatelessWidget {
  const DetailSectionHead({
    super.key,
    required this.label,
    required this.count,
    required this.xp,
  });

  final String label;
  final int count;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final TextStyle style = context.bodyText.labelSmall!.copyWith(
      color: p.textFaint,
    );
    return Padding(
      padding: const EdgeInsets.only(top: Space.s24, bottom: Space.s12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(label.toUpperCase(), style: style),
          ),
          Flexible(
            child: Text(
              l.mission_sectionSummary(count, xp).toUpperCase(),
              style: style,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// The dashed "Add quest to mission" row below the open Quests.
class AddQuestRow extends StatelessWidget {
  const AddQuestRow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final BorderRadius radius = BorderRadius.circular(Radii.card);
    return Semantics(
      button: true,
      label: l.mission_addQuestToMission,
      excludeSemantics: true,
      onTap: onTap,
      child: CustomPaint(
        foregroundPainter: _DashedOutlinePainter(
          color: p.textFaint,
          radius: Radii.card,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: Metrics.touchTarget + Space.s8,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.s16,
                  vertical: Space.s12,
                ),
                child: Row(
                  children: <Widget>[
                    CustomPaint(
                      foregroundPainter: _DashedOutlinePainter(
                        color: p.textFaint,
                        radius: Metrics.checkPainted / 2,
                      ),
                      child: SizedBox(
                        width: Metrics.checkPainted,
                        height: Metrics.checkPainted,
                        child: Center(
                          child: AppIcon(
                            IconAsset.plus,
                            size: Metrics.iconSmall - Space.s4,
                            color: p.textDim,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Space.s12),
                    Expanded(
                      child: Text(
                        l.mission_addQuestToMission,
                        style: context.bodyText.bodyLarge!.copyWith(
                          color: p.textDim,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a dashed rounded-rectangle outline around its child.
class _DashedOutlinePainter extends CustomPainter {
  const _DashedOutlinePainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = Metrics.dashStroke
      ..color = color;
    final Path outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in outline.computeMetrics()) {
      double at = 0;
      while (at < metric.length) {
        final double end = math.min(at + Metrics.dashLength, metric.length);
        canvas.drawPath(metric.extractPath(at, end), paint);
        at += Metrics.dashLength + Metrics.dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedOutlinePainter old) =>
      old.color != color || old.radius != radius;
}
