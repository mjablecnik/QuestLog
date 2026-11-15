import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/board_day.dart';
import '../../services/providers.dart';

/// The calendar date of the current Board_Day; changes at Day_Start and on resume.
final boardDayProvider = NotifierProvider<BoardDayNotifier, DateTime>(
  BoardDayNotifier.new,
);

class BoardDayNotifier extends Notifier<DateTime> with WidgetsBindingObserver {
  Timer? _timer;

  /// Duration from [now] to the next Day_Start (always positive, DST-safe).
  static Duration untilNextBoardDay(DateTime now) {
    final start = boardDayStart(now);
    final next = boardDayStartOf(DateTime(start.year, start.month, start.day + 1));
    return next.difference(now);
  }

  @override
  DateTime build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _cancel();
    });
    _schedule();
    return todayOf(ref.read(clockProvider).now());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _refresh();
      case AppLifecycleState.inactive ||
            AppLifecycleState.hidden ||
            AppLifecycleState.paused ||
            AppLifecycleState.detached:
        _cancel();
    }
  }

  void _refresh() {
    final today = todayOf(ref.read(clockProvider).now());
    if (today != state) state = today;
    _schedule();
  }

  void _schedule() {
    _cancel();
    _timer = Timer(untilNextBoardDay(ref.read(clockProvider).now()), _refresh);
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
