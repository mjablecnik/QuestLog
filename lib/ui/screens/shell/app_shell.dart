import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/calendar/calendar_providers.dart';
import '../../../services/notes/notes_providers.dart';
import '../../../services/providers.dart';
import '../../state/board_day.dart';
import '../../state/ui_providers.dart';
import '../../theme/questlog_theme.dart';
import '../../widgets/common/snackbar_host.dart';
import '../board/board_screen.dart';
import '../calendar/calendar_screen.dart';
import '../missions/missions_screen.dart';
import '../notes/notes_screen.dart';
import '../settings/settings_screen.dart';
import 'deep_link.dart';
import 'questlog_tab_bar.dart';
import 'reconcile_banner.dart';
import 'splash_screen.dart';

/// Root screen: splash until the first Reconciliation has finished, then the
/// five tabs (Questy, Mise, Kalendář, Poznámky, Nastavení). The reward overlay is hosted by `QuestlogApp`, above
/// the Navigator, so it also covers pushed routes.
///
/// Reconciliation runs at start, once per return from the background, when the
/// Board_Day changes, and on retry. Requests made in the same turn are
/// coalesced into one run, and a request made while a run is in flight triggers
/// exactly one more run afterwards.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  ShellTab _tab = ShellTab.quests;
  bool _ready = false;
  bool _failed = false;

  bool _running = false;
  bool _requested = false;
  bool _wentToBackground = false;
  StreamSubscription<Uri>? _links;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestReconcile();
    _links = ref.read(deepLinksProvider).listen(_openLink, onError: (Object _) {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _links?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.hidden || AppLifecycleState.paused:
        _wentToBackground = true;
      case AppLifecycleState.resumed:
        // `inactive -> resumed` also happens without leaving the app (control
        // centre, system dialogs); only a real return from the background counts.
        if (_wentToBackground) {
          _wentToBackground = false;
          _requestReconcile();
        }
      case AppLifecycleState.inactive || AppLifecycleState.detached:
        break;
    }
  }

  void _requestReconcile() {
    _requested = true;
    if (_running) return;
    _running = true;
    scheduleMicrotask(_drain);
  }

  Future<void> _drain() async {
    try {
      while (_requested && mounted) {
        _requested = false;
        await _reconcileOnce();
      }
    } finally {
      _running = false;
    }
  }

  Future<void> _reconcileOnce() async {
    List<Mission>? posted;
    try {
      posted = await ref.read(recurrenceServiceProvider).reconcile();
    } catch (_) {
      // Not only StorageError: whatever fails, the stored data stays usable
      // and the user gets the retry banner instead of a stuck splash.
      posted = null;
    }
    // Notes: whatever expired in the Trash goes now. A failure is ignored; the
    // next request tries again and nothing else depends on it.
    try {
      await ref.read(notesServiceProvider).purgeExpired();
    } catch (_) {}
    // Calendar: addresses not used for 30 days are forgotten; same tolerance.
    try {
      await ref.read(calendarServiceProvider).purgeExpiredAddresses();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _ready = true;
      _failed = posted == null;
    });
    if (posted != null && posted.isNotEmpty) {
      // Reconciliation can finish before the first settings emission, when the
      // widget tree still runs in the device language, so the stored language
      // is resolved explicitly instead of read from the context.
      try {
        await ref.read(settingsProvider.future);
      } catch (_) {
        // Defaults apply: the message is shown in the device language.
      }
      if (!mounted) return;
      final l10n = lookupAppLocalizations(ref.read(effectiveLocaleProvider));
      ref
          .read(snackbarProvider.notifier)
          .show(
            SnackMessage(
              l10n.app_postedMissions(posted.map((m) => m.name).join(', ')),
            ),
          );
    }
  }

  void _showPendingSnack(SnackMessage? message) {
    if (message == null || !mounted) return;
    ref.read(snackbarProvider.notifier).clear();
    final action = message.action;
    showQuestlogSnack(
      context,
      message.text,
      actionLabel: action?.label,
      onAction: action?.onPressed,
    );
  }

  /// A `questlog://calendar` style link: closes what is open above the shell and
  /// shows the tab. Anything else is ignored.
  void _openLink(Uri uri) {
    final ShellTab? tab = shellTabFromUri(uri);
    if (tab == null || !mounted) return;
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
    _selectTab(tab);
  }

  void _selectTab(ShellTab tab) {
    if (tab == _tab) return;
    // A message belongs to the screen that raised it (for example a Settings
    // rule saved), so it does not follow the user to another tab.
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SnackMessage?>(
      snackbarProvider,
      (_, next) => _showPendingSnack(next),
    );
    ref.listen<DateTime>(boardDayProvider, (_, _) => _requestReconcile());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.palette.board,
      body: _ready ? _buildTabs(context) : const SplashScreen(),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          // All tabs stay mounted, so each keeps its scroll position.
          child: IndexedStack(
            index: _tab.index,
            children: <Widget>[
              BoardScreen(),
              MissionsScreen(),
              CalendarScreen(),
              NotesScreen(),
              SettingsScreen(),
            ],
          ),
        ),
        if (_failed) ReconcileBanner(onRetry: _requestReconcile),
        QuestlogTabBar(
          current: _tab,
          onSelected: _selectTab,
        ),
      ],
    );
  }
}
