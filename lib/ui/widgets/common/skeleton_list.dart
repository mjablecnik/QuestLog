import 'package:flutter/material.dart';

import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';

/// Placeholder rows shown while the first data load is pending.
///
/// Static under reduced motion; otherwise the rows breathe slowly.
class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.count = 4, this.padding});

  final int count;
  final EdgeInsetsGeometry? padding;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.pulse,
  );
  late final Animation<double> _opacity = Tween<double>(
    begin: 1,
    end: 0.55,
  ).animate(CurvedAnimation(parent: _controller, curve: Motion.curve));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: ExcludeSemantics(
        child: FadeTransition(
          opacity: _opacity,
          child: Padding(
            padding:
                widget.padding ??
                const EdgeInsets.symmetric(horizontal: Space.s16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int i = 0; i < widget.count; i++) ...<Widget>[
                  if (i > 0) const SizedBox(height: Space.s12),
                  const SkeletonRow(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One placeholder card.
class SkeletonRow extends StatelessWidget {
  const SkeletonRow({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      height: Metrics.skeletonRow,
      decoration: BoxDecoration(
        color: p.boardRaised,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: p.boardLine, width: Metrics.hairline),
      ),
    );
  }
}
