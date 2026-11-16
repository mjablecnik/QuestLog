import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/cadence.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/data/preferences.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/services/mission_service.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/services/recurrence_service.dart';
import 'package:questlog/services/xp_engine.dart';
import 'package:questlog/ui/screens/board/board_screen.dart';
import 'package:questlog/ui/screens/mission_detail/mission_detail_screen.dart';
import 'package:questlog/ui/screens/missions/missions_screen.dart';
import 'package:questlog/ui/screens/settings/settings_screen.dart';
import 'package:questlog/ui/screens/shell/app_shell.dart';
import 'package:questlog/ui/state/ui_providers.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/seed.dart';
import '../../helpers/test_database.dart';

/// "Now" of every accessibility test: 12:00 on the Board_Day of 15 Nov 2026.
final DateTime a11yNow = DateTime(2026, 11, 15, 12);

/// The screens the layout and accessibility tests walk.
enum Subject { board, missions, detail, settings, shell }

/// Reconciliation that posts nothing, so the shell reaches its tabs without
/// writing to the database from inside the fake-async zone.
class _QuietRecurrence extends RecurrenceService {
  _QuietRecurrence(super.db, super.clock);

  @override
  Future<List<Mission>> reconcile() async => const <Mission>[];
}

final Set<String> _loadedFonts = <String>{};

/// Registers a bundled font family under its name. The test engine substitutes
/// a square-glyph font for every family otherwise, whose text is about twice
/// as wide as the real one and would report overflows that cannot happen on a
/// device.
Future<void> _loadFont(
  WidgetTester tester,
  String family,
  List<int> weights,
) async {
  if (!_loadedFonts.add(family)) return;
  await tester.runAsync(() async {
    final FontLoader loader = FontLoader(family);
    for (final int weight in weights) {
      final Uint8List bytes = File('assets/fonts/$family-$weight.ttf')
          .readAsBytesSync();
      loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  });
}

/// One mounted screen over an in-memory database seeded with long Czech names.
class A11yEnv {
  A11yEnv._(this.tester, this.db, this.missionId);

  final WidgetTester tester;
  final QuestlogDatabase db;
  final int missionId;

  /// Lets Drift streams deliver, then finishes animations.
  Future<void> settle() async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
  }

  /// Disposes the tree inside the test body so Drift's zero-length timers are
  /// flushed before the framework verifies that none are pending.
  Future<void> dispose() async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(db.close);
  }

  /// Mounts [subject] at [width] logical pixels, with the given text scale,
  /// language and reduced-motion flag. Everything is seeded before the first
  /// frame: several awaited writes under a mounted Drift stream deadlock.
  static Future<A11yEnv> pump(
    WidgetTester tester,
    Subject subject, {
    double width = 390,
    double height = 844,
    double textScale = 1,
    Locale locale = const Locale('en'),
    bool reduceMotion = false,
    QuestlogPalette palette = QuestlogPalette.guildBoard,
    DisplayFont font = DisplayFont.figtree,
    int startXp = 0,
  }) async {
    await _loadFont(tester, 'Figtree', <int>[400, 500, 600, 700, 800]);
    if (font == DisplayFont.unbounded) {
      await _loadFont(tester, 'Unbounded', <int>[600, 700, 800]);
    }
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final QuestlogDatabase db = createTestDatabase();
    final FixedClock clock = FixedClock(a11yNow);
    final int missionId = await _seed(tester, db, clock, startXp);

    final Widget home = switch (subject) {
      Subject.board => BoardScreen(onOpenSettings: () {}),
      Subject.missions => MissionsScreen(onOpenSettings: () {}),
      Subject.detail => MissionDetailScreen(missionId: missionId),
      Subject.settings => const SettingsScreen(),
      Subject.shell => const AppShell(),
    };
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
          recurrenceServiceProvider.overrideWithValue(
            _QuietRecurrence(db, clock),
          ),
          deviceLocaleProvider.overrideWithValue(locale),
          appVersionProvider.overrideWith((Ref ref) async => '1.0.0'),
        ],
        child: MaterialApp(
          theme: buildTheme(palette: palette, font: font),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (BuildContext context, Widget? app) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              disableAnimations: reduceMotion,
            ),
            child: app!,
          ),
          home: RepaintBoundary(key: boundaryKey, child: home),
        ),
      ),
    );
    final A11yEnv env = A11yEnv._(tester, db, missionId);
    await env.settle();
    return env;
  }

  /// Key of the [RepaintBoundary] around the screen, for pixel comparisons.
  static final GlobalKey boundaryKey = GlobalKey(debugLabel: 'a11y-screen');

  /// Raw RGBA pixels of the screen.
  Future<ByteData> pixels() async {
    final RenderRepaintBoundary boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final ByteData? data = await tester.runAsync<ByteData?>(() async {
      final ui.Image image = await boundary.toImage();
      return await image.toByteData();
    });
    return data!;
  }

  static Future<int> _seed(
    WidgetTester tester,
    QuestlogDatabase db,
    FixedClock clock,
    int startXp,
  ) async {
    final int? id = await tester.runAsync(() async {
      if (startXp > 0) await XpEngine(db).apply(startXp);
      final MissionService missions = MissionService(db, XpEngine(db), clock);
      final Mission long = await missions.create(
        const MissionDraft(
          name: 'Kompletní rekonstrukce koupelny včetně obkladů a podlahy',
          bonus: MissionBonus.large,
          quests: <QuestDraft>[
            QuestDraft(
              name: 'Objednat dlaždice a spárovací hmotu u dodavatele',
              difficulty: Difficulty.easy,
            ),
            QuestDraft(
              name: 'Domluvit instalatéra na výměnu starých rozvodů',
              difficulty: Difficulty.hard,
            ),
            QuestDraft(name: 'Vynést suť', difficulty: Difficulty.normal),
          ],
        ),
      );
      await seedQuest(
        db,
        name: 'Zavolat do servisu kvůli reklamaci pračky a domluvit termín',
        difficulty: Difficulty.normal,
        sortOrder: 90,
      );
      await seedQuest(db, name: 'Koupit mléko', sortOrder: 91);
      await seedQuest(
        db,
        name: 'Odeslat daňové přiznání',
        difficulty: Difficulty.hard,
        sortOrder: 92,
        completedAt: DateTime(2026, 11, 15, 9),
      );
      await seedMission(
        db,
        name: 'Hotová mise s dlouhým názvem na dnešek',
        status: MissionStatus.completed,
        completedAt: DateTime(2026, 11, 15, 9, 30),
        awardedBonus: 50,
      );
      await RecurrenceService(db, clock).create(
        RuleDraft(
          name: 'Měsíční vyúčtování energií a internetu',
          cadence: Cadence.monthly,
          requestedAnchor: DateTime(2026, 11, 20),
          bonus: MissionBonus.small,
          quests: const <RuleQuestDraft>[
            RuleQuestDraft(name: 'Převod', difficulty: Difficulty.easy),
          ],
        ),
      );
      return long.id;
    });
    return id!;
  }
}

/// A [testWidgets] that tears the environment down at the end of the body.
void a11yTest(
  String description,
  Future<void> Function(WidgetTester tester, void Function(A11yEnv) track) body,
) {
  testWidgets(description, (WidgetTester tester) async {
    A11yEnv? env;
    try {
      await body(tester, (A11yEnv e) => env = e);
    } finally {
      await env?.dispose();
    }
  });
}

/// Rect of [node] in global coordinates.
Rect globalRect(SemanticsNode node) {
  Rect rect = node.rect;
  SemanticsNode? current = node;
  while (current != null) {
    final Matrix4? transform = current.transform;
    if (transform != null) rect = MatrixUtils.transformRect(transform, rect);
    current = current.parent;
  }
  return rect;
}

/// Every visible semantics node that exposes a tap or long-press action.
List<SemanticsNode> tappableNodes(WidgetTester tester) {
  final List<SemanticsNode> found = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    final SemanticsData data = node.getSemanticsData();
    final bool hidden = data.flagsCollection.isHidden;
    if (!hidden && !node.isMergedIntoParent) {
      if (data.hasAction(SemanticsAction.tap) ||
          data.hasAction(SemanticsAction.longPress)) {
        found.add(node);
      }
    }
    if (!hidden) {
      node.visitChildren((SemanticsNode c) {
        visit(c);
        return true;
      });
    }
  }

  visit(
    tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return found;
}

/// Label, tooltip and hint of every visible semantics node, one string each.
List<String> spokenTexts(WidgetTester tester) {
  final List<String> found = <String>[];
  void visit(SemanticsNode node) {
    final SemanticsData data = node.getSemanticsData();
    if (data.flagsCollection.isHidden) return;
    for (final String text in <String>[data.label, data.tooltip, data.hint]) {
      if (text.trim().isNotEmpty) found.add(text);
    }
    node.visitChildren((SemanticsNode c) {
      visit(c);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return found;
}
