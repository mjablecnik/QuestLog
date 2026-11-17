import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/palette_choice_store.dart';
import '../../../l10n/app_localizations.dart';
import '../../state/palette_choice.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/questlog_segmented.dart';

/// Temporary palette group of the Settings_Screen: switches the whole app
/// between the original colours and the higher-contrast proposal. Draws its
/// own group header and the gap above it.
class PaletteSection extends ConsumerWidget {
  const PaletteSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final PaletteChoice choice = ref.watch(paletteChoiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: Space.s24),
        Semantics(
          header: true,
          child: Text(
            '${l.settings_paletteLabel} · ${l.settings_groupTemporary}'
                .toUpperCase(),
            style: context.bodyText.labelSmall!.copyWith(
              color: context.palette.textFaint,
            ),
          ),
        ),
        const SizedBox(height: Space.s8),
        QuestlogSegmented<PaletteChoice>(
          options: <SegmentedOption<PaletteChoice>>[
            SegmentedOption<PaletteChoice>(
              value: PaletteChoice.original,
              label: l.settings_paletteOriginal,
            ),
            SegmentedOption<PaletteChoice>(
              value: PaletteChoice.highContrast,
              label: l.settings_paletteHighContrast,
            ),
          ],
          selected: choice,
          onChanged: (PaletteChoice next) =>
              ref.read(paletteChoiceProvider.notifier).select(next),
        ),
      ],
    );
  }
}
