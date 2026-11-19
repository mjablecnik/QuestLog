import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';

/// Fraction of the full circle covered by [done] of [total] quests, in `[0, 1]`.
///
/// Zero when there is nothing to do (`total <= 0`), so an empty Mission never
/// shows progress.
double ringFraction(int done, int total) {
  if (total <= 0 || done <= 0) return 0;
  return math.min(done, total) / total;
}

/// Sweep angle in radians of the progress arc.
double ringSweep(int done, int total) =>
    ringFraction(done, total) * 2 * math.pi;

/// Paints the track and, only when there is progress, the brass arc.
class ProgressRingPainter extends CustomPainter {
  const ProgressRingPainter({
    required this.done,
    required this.total,
    required this.trackColor,
    required this.progressColor,
    this.radius = Metrics.ringRadius,
    this.strokeWidth = Metrics.ringStroke,
  });

  final int done;
  final int total;
  final Color trackColor;
  final Color progressColor;
  final double radius;
  final double strokeWidth;

  /// Sweep of the progress arc in radians.
  double get sweep => ringSweep(done, total);

  /// False at zero: a round cap would otherwise leave a dot on the track.
  bool get shouldDrawArc => sweep > 0;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centre = size.center(Offset.zero);
    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(centre, radius, track);

    if (!shouldDrawArc) return;
    final Paint arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = progressColor;
    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(ProgressRingPainter old) =>
      old.done != done ||
      old.total != total ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor;
}

/// The 56px Mission ring: the arc shows how much is done, the figure in the
/// middle (or [center]) how many quests are still open, so a low number is
/// the Mission that is nearly finished.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.done,
    required this.total,
    this.size = Metrics.ring,
    this.center,
  });

  final int done;
  final int total;
  final double size;

  /// Replaces the number of open quests, for example with a tick on a finished Mission.
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final TextStyle figure = context.displayText.titleMedium!.copyWith(
      fontSize: 15,
      color: p.text,
    );

    return Semantics(
      label: l.a11y_missionProgress(done, total),
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          key: const ValueKey<String>('progress-ring-paint'),
          painter: ProgressRingPainter(
            done: done,
            total: total,
            trackColor: p.boardLine,
            progressColor: p.brass,
          ),
          child: Center(
            child:
                center ??
                Text('${math.max(total - done, 0)}', style: figure),
          ),
        ),
      ),
    );
  }
}
