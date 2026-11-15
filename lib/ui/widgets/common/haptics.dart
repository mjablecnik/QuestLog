import 'package:flutter/services.dart';

/// Haptic feedback for the moments named in the spec: completing a Quest or
/// Mission, picking up a card to reorder and confirming a destructive action.
///
/// Every call is safe on platforms without a haptic engine; failures are
/// swallowed because feedback must never break the action that triggered it.
abstract final class Haptics {
  /// Picking up a card, tapping a control.
  static Future<void> light() => _run(HapticFeedback.lightImpact);

  /// Confirming a destructive action.
  static Future<void> medium() => _run(HapticFeedback.mediumImpact);

  /// Completing a Quest or Mission.
  static Future<void> success() => _run(HapticFeedback.heavyImpact);

  static Future<void> _run(Future<void> Function() impact) async {
    try {
      await impact();
    } catch (_) {
      // No haptic engine (Linux desktop, web) or the channel is unavailable.
    }
  }
}
