import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../state/calendar_state.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/sheet/questlog_sheet.dart';

/// Opens the month picker: a year stepper (2000 to 2100) and the twelve months.
Future<void> showMonthPicker(BuildContext context) =>
    showQuestlogSheet<void>(context, builder: (BuildContext _) => const _MonthPickerSheet());

class _MonthPickerSheet extends ConsumerStatefulWidget {
  const _MonthPickerSheet();

  @override
  ConsumerState<_MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends ConsumerState<_MonthPickerSheet> {
  late int _year = ref.read(visibleMonthProvider).year;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final DateTime visible = ref.watch(visibleMonthProvider);
    return QuestlogSheet(
      title: l.calendar_monthPickerTitle,
      primaryLabel: l.calendar_filterDone,
      onPrimary: () async => QuestlogSheet.close<void>(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _YearButton(
                icon: IconAsset.chevronLeft,
                label: l.calendar_prevYear,
                onTap: _year > 2000 ? () => setState(() => _year--) : null,
              ),
              Semantics(
                header: true,
                child: Text('$_year', style: context.displayText.titleLarge),
              ),
              _YearButton(
                icon: IconAsset.chevronRight,
                label: l.calendar_nextYear,
                onTap: _year < 2100 ? () => setState(() => _year++) : null,
              ),
            ],
          ),
          const SizedBox(height: Space.s8),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) {
              final double width = (box.maxWidth - 2 * Space.s8) / 3;
              return Wrap(
                spacing: Space.s8,
                runSpacing: Space.s8,
                children: <Widget>[
                  for (int month = 1; month <= 12; month++)
                    SizedBox(
                      width: width,
                      child: _MonthButton(
                        key: ValueKey<String>('picker-month-$month'),
                        label: _name(DateTime(_year, month), l.localeName),
                        selected: visible.year == _year && visible.month == month,
                        onTap: () {
                          ref.read(visibleMonthProvider.notifier).show(DateTime(_year, month));
                          QuestlogSheet.close<void>(context);
                        },
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(height: Space.s4, child: ColoredBox(color: p.sheet)),
        ],
      ),
    );
  }

  String _name(DateTime month, String locale) {
    final String text = DateFormat('LLLL', locale).format(month);
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _YearButton extends StatelessWidget {
  const _YearButton({required this.icon, required this.label, required this.onTap});

  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: Metrics.touchTarget,
          height: Metrics.touchTarget,
          child: Center(
            child: AppIcon(icon, size: Metrics.iconSmall, color: onTap == null ? p.textFaint : p.text),
          ),
        ),
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({super.key, required this.label, required this.selected, required this.onTap});

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
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: Space.s4),
          decoration: BoxDecoration(
            color: selected ? p.brassSoft : p.field,
            borderRadius: radius,
            border: Border.all(
              color: selected ? p.brass : p.boardLine,
              width: selected ? Metrics.badgeBorder : Metrics.hairline,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.bodyText.bodyMedium!.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
