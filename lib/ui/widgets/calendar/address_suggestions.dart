import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../common/app_icon.dart';

/// The remembered addresses under the Address field of the Event_Form; a tap
/// on a row hands its text to [onPick]. Shows nothing for an empty list.
class AddressSuggestions extends StatelessWidget {
  const AddressSuggestions({
    super.key,
    required this.addresses,
    required this.onPick,
  });

  final List<String> addresses;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    if (addresses.isEmpty) return const SizedBox.shrink();
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    // A tap here counts as inside the text field, so the desktop "tap outside"
    // unfocus does not remove the rows before the tap lands.
    return TextFieldTapRegion(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final String address in addresses)
            Semantics(
              button: true,
              label: l.calendar_addressSuggestion(address),
              excludeSemantics: true,
              child: InkWell(
                key: ValueKey<String>('address-suggestion-$address'),
                onTap: () => onPick(address),
                borderRadius: BorderRadius.circular(Radii.control),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: Metrics.touchTarget,
                  ),
                  child: Row(
                    children: <Widget>[
                      const SizedBox(width: Space.s4),
                      AppIcon(
                        IconAsset.location,
                        size: Metrics.iconSmall,
                        color: p.textFaint,
                      ),
                      const SizedBox(width: Space.s12),
                      Expanded(
                        child: Text(
                          address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.bodyText.bodyMedium!.copyWith(
                            color: p.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
