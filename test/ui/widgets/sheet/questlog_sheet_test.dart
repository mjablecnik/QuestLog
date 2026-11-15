import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/l10n/app_localizations_en.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/sheet/questlog_sheet.dart';

import '../common/_harness.dart';

final AppLocalizationsEn l10n = AppLocalizationsEn();

/// A form-like sheet: typing makes it dirty, the primary button closes it
/// with 'saved'.
class _TestSheet extends StatefulWidget {
  const _TestSheet({this.onPrimary, this.primaryEnabled = true});

  final Future<void> Function(BuildContext context)? onPrimary;
  final bool primaryEnabled;

  @override
  State<_TestSheet> createState() => _TestSheetState();
}

class _TestSheetState extends State<_TestSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuestlogSheet(
      title: 'New quest',
      primaryLabel: 'Post quest',
      isDirty: _controller.text.isNotEmpty,
      primaryEnabled: widget.primaryEnabled,
      onPrimary: () async {
        final Future<void> Function(BuildContext)? custom = widget.onPrimary;
        if (custom != null) {
          await custom(context);
        } else {
          QuestlogSheet.close<String>(context, 'saved');
        }
      },
      child: TextField(
        controller: _controller,
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}

class _Result {
  String? value;
  bool completed = false;
}

/// Pumps a host with an "open" button and returns where the result lands.
Future<_Result> _pumpHost(
  WidgetTester tester, {
  Widget sheet = const _TestSheet(),
  bool disableAnimations = false,
}) async {
  final _Result result = _Result();
  await pumpCommon(
    tester,
    Builder(
      builder: (BuildContext context) => Center(
        child: TextButton(
          onPressed: () async {
            result.value = await showQuestlogSheet<String>(
              context,
              builder: (_) => sheet,
            );
            result.completed = true;
          },
          child: const Text('open'),
        ),
      ),
    ),
    disableAnimations: disableAnimations,
  );
  return result;
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _typeInto(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), 'Hang laundry');
  await tester.pump();
}

void main() {
  group('clean sheet', () {
    testWidgets('shows grabber, cancel, centred title and primary button', (
      WidgetTester tester,
    ) async {
      await _pumpHost(tester);
      await _openSheet(tester);

      expect(find.text(l10n.common_cancel), findsOneWidget);
      expect(find.text('New quest'), findsOneWidget);
      expect(find.text('Post quest'), findsOneWidget);

      final double screenCentre =
          tester.view.physicalSize.width / tester.view.devicePixelRatio / 2;
      expect(
        tester.getCenter(find.text('New quest')).dx,
        closeTo(screenCentre, 1),
      );
      expect(
        tester.getTopLeft(find.text(l10n.common_cancel)).dx,
        lessThan(tester.getTopLeft(find.text('New quest')).dx),
      );
    });

    testWidgets('cancel closes straight away without asking', (
      WidgetTester tester,
    ) async {
      final _Result result = await _pumpHost(tester);
      await _openSheet(tester);

      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();

      expect(find.byType(QuestlogSheet), findsNothing);
      expect(find.text(l10n.sheet_discardTitle), findsNothing);
      expect(result.completed, isTrue);
      expect(result.value, isNull);
    });

    testWidgets('tapping the scrim closes without asking', (
      WidgetTester tester,
    ) async {
      final _Result result = await _pumpHost(tester);
      await _openSheet(tester);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(QuestlogSheet), findsNothing);
      expect(find.text(l10n.sheet_discardTitle), findsNothing);
      expect(result.completed, isTrue);
    });

    testWidgets('dragging the grabber down closes without asking', (
      WidgetTester tester,
    ) async {
      final _Result result = await _pumpHost(tester);
      await _openSheet(tester);

      await tester.fling(find.text('New quest'), const Offset(0, 400), 2000);
      await tester.pumpAndSettle();

      expect(find.byType(QuestlogSheet), findsNothing);
      expect(find.text(l10n.sheet_discardTitle), findsNothing);
      expect(result.completed, isTrue);
    });

    testWidgets('a short drag snaps back and keeps the sheet open', (
      WidgetTester tester,
    ) async {
      await _pumpHost(tester);
      await _openSheet(tester);
      final double top = tester.getTopLeft(find.byType(QuestlogSheet)).dy;

      await tester.drag(find.text('New quest'), const Offset(0, 20));
      await tester.pumpAndSettle();

      expect(find.byType(QuestlogSheet), findsOneWidget);
      expect(tester.getTopLeft(find.byType(QuestlogSheet)).dy, top);
    });

    testWidgets('the system back gesture closes without asking', (
      WidgetTester tester,
    ) async {
      await _pumpHost(tester);
      await _openSheet(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(QuestlogSheet), findsNothing);
      expect(find.text(l10n.sheet_discardTitle), findsNothing);
    });
  });

  group('dirty sheet', () {
    testWidgets('cancel asks first; keep editing leaves the sheet open', (
      WidgetTester tester,
    ) async {
      final _Result result = await _pumpHost(tester);
      await _openSheet(tester);
      await _typeInto(tester);

      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();

      expect(find.text(l10n.sheet_discardTitle), findsOneWidget);
      expect(find.text(l10n.sheet_discardBody), findsOneWidget);

      await tester.tap(find.text(l10n.sheet_keepEditing));
      await tester.pumpAndSettle();

      expect(find.text(l10n.sheet_discardTitle), findsNothing);
      expect(find.byType(QuestlogSheet), findsOneWidget);
      expect(find.text('Hang laundry'), findsOneWidget);
      expect(result.completed, isFalse);
    });

    testWidgets('cancel then discard closes the sheet with no result', (
      WidgetTester tester,
    ) async {
      final _Result result = await _pumpHost(tester);
      await _openSheet(tester);
      await _typeInto(tester);

      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.common_discard));
      await tester.pumpAndSettle();

      expect(find.byType(QuestlogSheet), findsNothing);
      expect(find.text(l10n.sheet_discardTitle), findsNothing);
      expect(result.completed, isTrue);
      expect(result.value, isNull);
    });

    testWidgets('tapping the scrim asks first', (WidgetTester tester) async {
      await _pumpHost(tester);
      await _openSheet(tester);
      await _typeInto(tester);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text(l10n.sheet_discardTitle), findsOneWidget);
      expect(find.byType(QuestlogSheet), findsOneWidget);
    });

    testWidgets('the system back gesture asks first', (
      WidgetTester tester,
    ) async {
      await _pumpHost(tester);
      await _openSheet(tester);
      await _typeInto(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text(l10n.sheet_discardTitle), findsOneWidget);
      expect(find.byType(QuestlogSheet), findsOneWidget);
    });

    testWidgets('a fling down asks first; keeping returns the sheet', (
      WidgetTester tester,
    ) async {
      await _pumpHost(tester);
      await _openSheet(tester);
      await _typeInto(tester);
      final double top = tester.getTopLeft(find.byType(QuestlogSheet)).dy;

      await tester.fling(find.text('New quest'), const Offset(0, 400), 2000);
      await tester.pumpAndSettle();
      expect(find.text(l10n.sheet_discardTitle), findsOneWidget);

      await tester.tap(find.text(l10n.sheet_keepEditing));
      await tester.pumpAndSettle();

      expect(find.byType(QuestlogSheet), findsOneWidget);
      expect(tester.getTopLeft(find.byType(QuestlogSheet)).dy, top);
    });

    testWidgets('a fling down then discard closes the sheet', (
      WidgetTester tester,
    ) async {
      final _Result result = await _pumpHost(tester);
      await _openSheet(tester);
      await _typeInto(tester);

      await tester.fling(find.text('New quest'), const Offset(0, 400), 2000);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.common_discard));
      await tester.pumpAndSettle();

      expect(find.byType(QuestlogSheet), findsNothing);
      expect(result.completed, isTrue);
    });

    testWidgets('a successful primary action closes without asking', (
      WidgetTester tester,
    ) async {
      final _Result result = await _pumpHost(tester);
      await _openSheet(tester);
      await _typeInto(tester);

      await tester.tap(find.text('Post quest'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.sheet_discardTitle), findsNothing);
      expect(find.byType(QuestlogSheet), findsNothing);
      expect(result.value, 'saved');
    });
  });

  group('primary button', () {
    testWidgets('is disabled when primaryEnabled is false', (
      WidgetTester tester,
    ) async {
      final _Result result = await _pumpHost(
        tester,
        sheet: const _TestSheet(primaryEnabled: false),
      );
      await _openSheet(tester);

      await tester.tap(find.text('Post quest'));
      await tester.pumpAndSettle();

      expect(find.byType(QuestlogSheet), findsOneWidget);
      expect(result.completed, isFalse);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });

    testWidgets('stays open when the action does not close it', (
      WidgetTester tester,
    ) async {
      int calls = 0;
      await _pumpHost(
        tester,
        sheet: _TestSheet(onPrimary: (_) async => calls++),
      );
      await _openSheet(tester);

      await tester.tap(find.text('Post quest'));
      await tester.pumpAndSettle();

      expect(calls, 1);
      expect(find.byType(QuestlogSheet), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
    });

    testWidgets('cannot be submitted twice while the action runs', (
      WidgetTester tester,
    ) async {
      final Completer<void> gate = Completer<void>();
      int calls = 0;
      await _pumpHost(
        tester,
        sheet: _TestSheet(
          onPrimary: (_) {
            calls++;
            return gate.future;
          },
        ),
      );
      await _openSheet(tester);

      await tester.tap(find.text('Post quest'));
      await tester.pump();
      await tester.tap(find.text('Post quest'), warnIfMissed: false);
      await tester.pump();
      expect(calls, 1);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );

      gate.complete();
      await tester.pumpAndSettle();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
    });
  });

  group('layout', () {
    testWidgets('keeps the primary button above the keyboard', (
      WidgetTester tester,
    ) async {
      await _pumpHost(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 600);
      addTearDown(tester.view.resetViewInsets);
      await _openSheet(tester);

      final double screenHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final double keyboardTop =
          screenHeight - 600 / tester.view.devicePixelRatio;
      expect(
        tester.getBottomLeft(find.byType(FilledButton)).dy,
        lessThanOrEqualTo(keyboardTop),
      );
    });

    testWidgets('scrolls a tall body while the header and button stay', (
      WidgetTester tester,
    ) async {
      await _pumpHost(
        tester,
        sheet: QuestlogSheet(
          title: 'Tall',
          primaryLabel: 'Save',
          onPrimary: () async {},
          child: Column(
            children: <Widget>[
              for (int i = 0; i < 40; i++)
                SizedBox(height: 60, child: Text('row $i')),
            ],
          ),
        ),
      );
      await _openSheet(tester);

      final double screenHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(
        tester.getBottomLeft(find.byType(FilledButton)).dy,
        lessThanOrEqualTo(screenHeight),
      );
      expect(find.text('row 39').hitTestable(), findsNothing);

      await tester.drag(find.text('row 0'), const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(find.text('row 39').hitTestable(), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Tall'), findsOneWidget);
    });
  });

  group('motion', () {
    Future<List<double>> measure(
      WidgetTester tester, {
      required bool reduced,
    }) async {
      await _pumpHost(tester, disableAnimations: reduced);
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(Motion.reducedFade ~/ 3);
      final double early = tester.getTopLeft(find.byType(QuestlogSheet)).dy;
      await tester.pumpAndSettle();
      final double settled = tester.getTopLeft(find.byType(QuestlogSheet)).dy;
      return <double>[early, settled];
    }

    testWidgets('slides in from the bottom by default', (
      WidgetTester tester,
    ) async {
      final List<double> top = await measure(tester, reduced: false);
      expect(top[0], greaterThan(top[1]));
    });

    testWidgets('reduced motion fades in place instead of sliding', (
      WidgetTester tester,
    ) async {
      final List<double> top = await measure(tester, reduced: true);
      expect(top[0], top[1]);
      expect(
        find.ancestor(
          of: find.byType(QuestlogSheet),
          matching: find.byType(FadeTransition),
        ),
        findsWidgets,
      );
    });

    testWidgets('reduced motion finishes within the reduced-fade budget', (
      WidgetTester tester,
    ) async {
      await _pumpHost(tester, disableAnimations: true);
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(Motion.reducedFade);
      await tester.pump(const Duration(milliseconds: 16));

      final FadeTransition fade = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.byType(QuestlogSheet),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(fade.opacity.value, 1.0);
    });
  });

  group('accessibility', () {
    testWidgets('exposes localized labels and a header', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pumpHost(tester);
      await _openSheet(tester);

      expect(find.bySemanticsLabel(l10n.common_cancel), findsOneWidget);
      expect(find.bySemanticsLabel('Post quest'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('New quest')),
        isSemantics(label: 'New quest', isHeader: true, namesRoute: true),
      );
      handle.dispose();
    });

    testWidgets('cancel and primary button have 44x44 hit areas', (
      WidgetTester tester,
    ) async {
      await _pumpHost(tester);
      await _openSheet(tester);

      for (final Finder finder in <Finder>[
        find.widgetWithText(TextButton, l10n.common_cancel),
        find.byType(FilledButton),
      ]) {
        final Size size = tester.getSize(finder);
        expect(size.width, greaterThanOrEqualTo(Metrics.touchTarget));
        expect(size.height, greaterThanOrEqualTo(Metrics.touchTarget));
      }
    });
  });
}
