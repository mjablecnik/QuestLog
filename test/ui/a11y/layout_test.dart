import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';


import '_a11y_harness.dart';

/// Requirements 16.7, 16.8: every iPhone width from 320 to 430 and the device
/// text size up to 130 %, in both languages, without overflow or clipped text.
Future<void> expectNoOverflow(WidgetTester tester) async {
  // A RenderFlex overflow is reported as a framework exception.
  expect(tester.takeException(), isNull);
  // Nothing may be laid out wider than the screen.
  final Size screen = tester.view.physicalSize;
  for (final Element element in find.byType(Text).evaluate()) {
    final RenderBox box = element.renderObject! as RenderBox;
    if (!box.attached || !box.hasSize) continue;
    final Rect rect = box.localToGlobal(Offset.zero) & box.size;
    if (rect.isEmpty) continue;
    final String text = (element.widget as Text).data ?? '';
    expect(
      rect.right,
      lessThanOrEqualTo(screen.width + 0.5),
      reason: 'text "$text" runs off the right edge',
    );
    expect(
      rect.left,
      greaterThanOrEqualTo(-0.5),
      reason: 'text "$text" starts left of the screen',
    );
  }
}

void main() {
  for (final MapEntry<String, Locale> language in <String, Locale>{
    'cs': const Locale('cs'),
    'en': const Locale('en'),
  }.entries) {
    a11yTest('hero bar keeps the next level readable with 12 345 XP, '
        '${language.key}', (
      WidgetTester tester,
      void Function(A11yEnv) track,
    ) async {
      track(
        await A11yEnv.pump(
          tester,
          Subject.board,
          locale: language.value,
          startXp: 12345,
        ),
      );
      // Level 21 with 255 XP to go: the line may wrap, never be cut off.
      final Finder remaining = find.textContaining('255');
      expect(remaining, findsOneWidget);
      final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
        remaining,
      );
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  const Map<String, Locale> locales = <String, Locale>{
    'cs': Locale('cs'),
    'en': Locale('en'),
  };
  const List<double> widths = <double>[320, 430];

  for (final Subject subject in Subject.values) {
    for (final double width in widths) {
      for (final MapEntry<String, Locale> language in locales.entries) {
        a11yTest(
          '${subject.name} at ${width.toInt()}px, text 130 %, ${language.key} '
          'has no overflow',
          (WidgetTester tester, void Function(A11yEnv) track) async {
            track(
              await A11yEnv.pump(
                tester,
                subject,
                width: width,
                textScale: 1.3,
                locale: language.value,
              ),
            );
            await expectNoOverflow(tester);
          },
        );
      }
    }
  }

  // The temporary palette picker: four chips, names may wrap but never clip.
  for (final MapEntry<String, Locale> language in locales.entries) {
    a11yTest(
      'palette chips at 320px, text 200 %, ${language.key} have no overflow',
      (WidgetTester tester, void Function(A11yEnv) track) async {
        track(
          await A11yEnv.pump(
            tester,
            Subject.settings,
            width: 320,
            textScale: 2,
            locale: language.value,
          ),
        );
        await expectNoOverflow(tester);
        final Finder chips = find.byWidgetPredicate(
          (Widget w) =>
              w is Semantics &&
              w.properties.inMutuallyExclusiveGroup == true &&
              w.properties.button == true &&
              w.properties.selected != null,
        );
        expect(chips, findsAtLeastNWidgets(4));
      },
    );
  }

  // The narrowest phone with large text is the worst case for headings and card titles.
  for (final Subject subject in Subject.values) {
    a11yTest(
      '${subject.name} at 320px, text 130 %, titles have no overflow',
      (WidgetTester tester, void Function(A11yEnv) track) async {
        track(
          await A11yEnv.pump(
            tester,
            subject,
            width: 320,
            textScale: 1.3,
            locale: const Locale('cs'),
          ),
        );
        await expectNoOverflow(tester);
      },
    );
  }
}
