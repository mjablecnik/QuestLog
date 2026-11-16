import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '_a11y_harness.dart';

String _describe(SemanticsNode node) {
  final Rect r = globalRect(node);
  return '"${node.label}" ${r.width.toStringAsFixed(1)}x'
      '${r.height.toStringAsFixed(1)} at ${r.topLeft}';
}

/// Requirements 16.1 and 16.3: every tappable element has a hit area of at
/// least 44x44 and a spoken label, in both languages.
void main() {
  const Map<String, Locale> locales = <String, Locale>{
    'cs': Locale('cs'),
    'en': Locale('en'),
  };

  for (final Subject subject in Subject.values) {
    for (final MapEntry<String, Locale> language in locales.entries) {
      a11yTest(
        '${subject.name} (${language.key}): tappables are 44x44 and labelled',
        (WidgetTester tester, void Function(A11yEnv) track) async {
          final SemanticsHandle handle = tester.ensureSemantics();
          try {
            track(
              await A11yEnv.pump(
                tester,
                subject,
                height: 2400,
                locale: language.value,
                textScale: 1.3,
              ),
            );
            final List<SemanticsNode> nodes = tappableNodes(tester);
            expect(nodes, isNotEmpty, reason: 'no tappable element found');
            final List<String> tooSmall = <String>[];
            final List<String> unlabelled = <String>[];
            for (final SemanticsNode node in nodes) {
              final Rect r = globalRect(node);
              if (r.width < 43.5 || r.height < 43.5) {
                tooSmall.add(_describe(node));
              }
              final SemanticsData data = node.getSemanticsData();
              if (data.label.trim().isEmpty &&
                  data.tooltip.trim().isEmpty &&
                  data.value.trim().isEmpty) {
                unlabelled.add(_describe(node));
              }
            }
            expect(tooSmall, isEmpty, reason: 'hit area below 44x44');
            expect(unlabelled, isEmpty, reason: 'tappable without a label');
          } finally {
            handle.dispose();
          }
        },
      );
    }
  }
}
