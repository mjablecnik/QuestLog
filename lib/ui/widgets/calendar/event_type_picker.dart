import 'package:flutter/material.dart';

import '../../../core/calendar/event_type.dart';
import '../../../l10n/app_localizations.dart';
import '../../screens/calendar/calendar_labels.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';

/// The ten event types as a grid, each with its colour and name, exactly one
/// selected. Replaces a free colour choice.
class EventTypePicker extends StatelessWidget {
  const EventTypePicker({super.key, required this.selected, required this.onSelected});

  final EventType selected;
  final ValueChanged<EventType> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = (constraints.maxWidth - Space.s8) / 2;
        return Wrap(
          spacing: Space.s8,
          runSpacing: Space.s8,
          children: <Widget>[
            for (final EventType type in EventType.values)
              SizedBox(
                width: width,
                child: _TypeOption(
                  type: type,
                  label: eventTypeName(l, type),
                  selected: type == selected,
                  onTap: () => onSelected(type),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.type,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final EventType type;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final BorderRadius radius = BorderRadius.circular(Radii.control);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s8),
          decoration: BoxDecoration(
            color: selected ? p.brassSoft : p.field,
            borderRadius: radius,
            border: Border.all(
              color: selected ? p.brass : p.boardLine,
              width: selected ? Metrics.badgeBorder : Metrics.hairline,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: Space.s12,
                height: Space.s12,
                decoration: BoxDecoration(shape: BoxShape.circle, color: p.eventColor(type)),
              ),
              const SizedBox(width: Space.s8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyText.bodyMedium!.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
