import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/tokens.dart';

/// Names of the bundled SVG icons in `assets/icons/`.
abstract final class IconAsset {
  static const arrowUp = 'arrow_up';
  static const auto = 'auto';
  static const check = 'check';
  static const chevronLeft = 'chevron_left';
  static const chevronRight = 'chevron_right';
  static const close = 'close';
  static const drag = 'drag';
  static const edit = 'edit';
  static const gear = 'gear';
  static const missions = 'missions';
  static const moon = 'moon';
  static const more = 'more';
  static const plus = 'plus';
  static const quests = 'quests';
  static const rays = 'rays';
  static const repeat = 'repeat';
  static const sealCheck = 'seal_check';
  static const sun = 'sun';
  static const tick = 'tick';
  static const trash = 'trash';
}

/// A bundled SVG icon drawn with `currentColor` strokes, tinted by [color] or
/// the ambient [IconTheme] colour.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.name, {
    super.key,
    this.size = Metrics.iconSize,
    this.color,
    this.semanticLabel,
  });

  /// One of the [IconAsset] names.
  final String name;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? IconTheme.of(context).color;
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      colorFilter: tint == null
          ? null
          : ColorFilter.mode(tint, BlendMode.srcIn),
    );
  }
}
