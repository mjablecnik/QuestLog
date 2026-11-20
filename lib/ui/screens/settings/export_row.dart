import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../state/ui_providers.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/snackbar_host.dart';

/// Row in the Data group: saves all app data into one JSON file and opens the
/// share sheet. Ignores taps while an export is running.
class ExportRow extends ConsumerStatefulWidget {
  const ExportRow({super.key});

  @override
  ConsumerState<ExportRow> createState() => _ExportRowState();
}

class _ExportRowState extends ConsumerState<ExportRow> {
  bool _busy = false;

  Future<void> _export() async {
    if (_busy) return;
    // The share sheet anchors on this row on iPad.
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final failed = AppLocalizations.of(context).settings_exportFailed;
    setState(() => _busy = true);
    try {
      await ref.read(exportServiceProvider).shareExport(origin: origin);
    } catch (_) {
      if (mounted) showQuestlogSnack(context, failed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l.settings_exportTitle,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.control),
        onTap: _export,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.s2,
              vertical: Space.s8,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l.settings_exportTitle,
                        style: context.bodyText.bodyMedium!.copyWith(
                          color: p.brassText,
                        ),
                      ),
                      const SizedBox(height: Space.s2),
                      Text(
                        l.settings_exportSubtitle,
                        style: context.bodyText.bodySmall!.copyWith(
                          color: p.textDim,
                        ),
                      ),
                    ],
                  ),
                ),
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
    );
  }
}
