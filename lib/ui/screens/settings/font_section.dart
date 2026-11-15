import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../sheets/font_sheet.dart';
import '../../state/ui_providers.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';

/// Temporary display-font group of the Settings_Screen: one row that shows the
/// current font and opens the Font_Sheet. Draws its own group header and the
/// gap above it.
class FontSection extends ConsumerWidget {
  const FontSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    final fontName = displayFontName(l, ref.watch(displayFontProvider));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: Space.s24),
        Semantics(
          header: true,
          child: Text(
            '${l.settings_groupTemporary} · ${l.settings_temporaryHint}'
                .toUpperCase(),
            style: context.bodyText.labelSmall!.copyWith(color: p.textFaint),
          ),
        ),
        const SizedBox(height: Space.s8),
        Semantics(
          button: true,
          label: '${l.font_rowLabel}, $fontName',
          excludeSemantics: true,
          child: Material(
            color: p.field,
            borderRadius: BorderRadius.circular(Radii.control),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => showFontSheet(context),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: Metrics.touchTarget + Space.s4,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.s16),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          l.font_rowLabel,
                          style: context.bodyText.bodyLarge!.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        fontName,
                        style: context.bodyText.titleMedium!.copyWith(
                          color: p.brass,
                        ),
                      ),
                      const SizedBox(width: Space.s8),
                      AppIcon(
                        IconAsset.chevronRight,
                        size: Metrics.iconSmall,
                        color: p.textFaint,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
