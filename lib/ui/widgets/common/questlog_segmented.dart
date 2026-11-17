import 'package:flutter/material.dart';

import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import 'app_icon.dart';

/// One segment of a [QuestlogSegmented] control.
@immutable
class SegmentedOption<T> {
  const SegmentedOption({
    required this.value,
    required this.label,
    this.icon,
    this.caption,
  });

  final T value;

  /// Already localized.
  final String label;

  /// Optional [IconAsset] name drawn before the label.
  final String? icon;

  /// Optional small second line (for example the XP of a Difficulty).
  final String? caption;
}

/// Pill-style segmented control: a field-coloured track with the selected
/// segment lifted in brass.
class QuestlogSegmented<T> extends StatelessWidget {
  const QuestlogSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final List<SegmentedOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  /// A disabled control keeps its selection visible but ignores taps.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Container(
        padding: const EdgeInsets.all(Space.s4),
        decoration: BoxDecoration(
          color: p.field,
          borderRadius: BorderRadius.circular(Radii.control),
        ),
        child: Row(
          children: <Widget>[
            for (int i = 0; i < options.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: Space.s4),
              Expanded(
                child: _Segment<T>(
                  option: options[i],
                  selected: options[i].value == selected,
                  enabled: enabled,
                  onTap: () => onChanged(options[i].value),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Segment<T> extends StatefulWidget {
  const _Segment({
    required this.option,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final SegmentedOption<T> option;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_Segment<T>> createState() => _SegmentState<T>();
}

class _SegmentState<T> extends State<_Segment<T>> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final o = widget.option;
    final bool on = widget.selected;
    final Color foreground = on ? p.brassText : p.textDim;
    final Duration fade = MediaQuery.disableAnimationsOf(context)
        ? Motion.none
        : Motion.hover;

    final Color? background = (on || _pressed) ? p.brassSoft : null;

    return Semantics(
      button: true,
      selected: on,
      inMutuallyExclusiveGroup: true,
      enabled: widget.enabled,
      label: o.caption == null ? o.label : '${o.label}, ${o.caption}',
      excludeSemantics: true,
      onTap: widget.enabled ? widget.onTap : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
        onTapUp: widget.enabled ? (_) => _setPressed(false) : null,
        onTapCancel: () => _setPressed(false),
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: fade,
          curve: Motion.curve,
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: Space.s8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(Radii.control - Space.s4),
            border: on
                // The selected option is already filled, so its pressed state
                // is a heavier outline.
                ? Border.all(
                    color: p.brass,
                    width: _pressed ? Metrics.hairline * 2 : Metrics.hairline,
                  )
                : null,
          ),
          child: Opacity(
            opacity: widget.enabled ? 1 : 0.5,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (o.icon != null) ...<Widget>[
                        AppIcon(
                          o.icon!,
                          size: Metrics.iconSmall,
                          color: foreground,
                        ),
                        const SizedBox(width: Space.s6),
                      ],
                      Flexible(
                        child: Text(
                          o.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.bodyText.labelLarge!.copyWith(
                            color: foreground,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (o.caption != null)
                    Text(
                      o.caption!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyText.labelSmall!.copyWith(
                        color: on ? p.brass : p.textFaint,
                        letterSpacing: 0,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
