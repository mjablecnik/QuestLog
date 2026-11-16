import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';

/// Branded splash shown until the database is open and the first
/// Reconciliation has finished. Static on purpose: nothing animates while the
/// app waits, so it also satisfies reduced motion.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    return Semantics(
      container: true,
      label: l10n.app_splashLoading,
      child: ColoredBox(
        color: p.board,
        child: Center(
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l10n.app_name,
                  style: context.displayText.headlineLarge?.copyWith(
                    color: p.brass,
                  ),
                ),
                const SizedBox(height: Space.s12),
                Text(
                  l10n.app_splashLoading,
                  style: context.bodyText.bodyMedium?.copyWith(
                    color: p.textDim,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
