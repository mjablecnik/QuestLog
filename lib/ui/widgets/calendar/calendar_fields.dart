import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MaxLengthEnforcement;

import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';

/// A rounded raised card that groups the rows of a calendar form or detail.
class CalendarCard extends StatelessWidget {
  const CalendarCard({super.key, required this.children, this.gap = Space.s12});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.boardRaised,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: p.boardLine, width: Metrics.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Space.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < children.length; i++) ...<Widget>[
              if (i > 0) SizedBox(height: gap),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Filled text field in the design's field style: tinted and outlined in the
/// accent while focused, outlined in the destructive colour while invalid.
class CalendarTextField extends StatefulWidget {
  const CalendarTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.errorText,
    this.multiline = false,
    this.autofocus = false,
    this.title = false,
    this.textInputAction,
    this.onSubmitted,
    this.maxLength,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.fieldKey,
    this.onFocusChange,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool multiline;
  final bool autofocus;

  /// A larger, bolder field for the event name.
  final bool title;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  /// Longest text the field accepts; null for no limit.
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Key? fieldKey;

  /// Told when the field gains or loses focus.
  final ValueChanged<bool>? onFocusChange;

  @override
  State<CalendarTextField> createState() => _CalendarTextFieldState();
}

class _CalendarTextFieldState extends State<CalendarTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final BorderRadius radius = BorderRadius.circular(Radii.control);
    final bool hasError = widget.errorText != null;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: Metrics.hairline),
    );
    final OutlineInputBorder none = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide.none,
    );
    final TextStyle style = (widget.title ? context.bodyText.titleMedium! : context.bodyText.bodyLarge!)
        .copyWith(color: p.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onFocusChange: (bool value) {
            setState(() => _focused = value);
            widget.onFocusChange?.call(value);
          },
          child: TextField(
            key: widget.fieldKey,
            controller: widget.controller,
            maxLength: widget.maxLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            autofocus: widget.autofocus,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            keyboardType: widget.keyboardType ?? (widget.multiline ? TextInputType.multiline : TextInputType.text),
            minLines: widget.multiline ? 2 : 1,
            maxLines: widget.multiline ? 5 : 1,
            cursorColor: p.brass,
            style: style,
            decoration: InputDecoration(
              hintText: widget.hint,
              counterText: '',
              hintStyle: style.copyWith(color: p.textFaint),
              filled: true,
              fillColor: _focused ? p.fieldActive : p.field,
              contentPadding: const EdgeInsets.symmetric(horizontal: Space.s16, vertical: Space.s12),
              border: none,
              enabledBorder: hasError ? border(p.destructive) : none,
              focusedBorder: border(hasError ? p.destructive : p.brass),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: Space.s4),
            child: Semantics(
              liveRegion: true,
              child: Text(
                widget.errorText!,
                style: context.bodyText.bodySmall!.copyWith(color: p.destructive),
              ),
            ),
          ),
      ],
    );
  }
}

/// A row with a label and a switch, at least 44 logical pixels high.
class CalendarSwitchRow extends StatelessWidget {
  const CalendarSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(Radii.control),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(label, style: context.bodyText.titleMedium),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: p.inkOnBrass,
                activeTrackColor: p.brass,
                inactiveThumbColor: p.textFaint,
                inactiveTrackColor: p.field,
                trackOutlineColor: WidgetStatePropertyAll<Color>(p.boardLine),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tappable row with a label at the left and a value at the right.
class CalendarValueRow extends StatelessWidget {
  const CalendarValueRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    return Semantics(
      button: true,
      label: '$label, $value',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.control),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(label, style: context.bodyText.titleMedium)),
              Text(value, style: context.bodyText.bodyLarge!.copyWith(color: p.textDim)),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
