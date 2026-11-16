import 'dart:typed_data';

import 'package:flutter/gestures.dart' show kPressTimeout;
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '_a11y_harness.dart';

/// How many pixels inside [rect] differ between two RGBA captures of [width].
int _changedPixels(ByteData a, ByteData b, int width, Rect rect, int height) {
  final int left = rect.left.floor().clamp(0, width);
  final int right = rect.right.ceil().clamp(0, width);
  final int top = rect.top.floor().clamp(0, height);
  final int bottom = rect.bottom.ceil().clamp(0, height);
  int changed = 0;
  for (int y = top; y < bottom; y++) {
    for (int x = left; x < right; x++) {
      final int i = (y * width + x) * 4;
      if (a.getUint32(i) != b.getUint32(i)) changed++;
    }
  }
  return changed;
}

/// Requirement 16.2: every tappable element shows a pressed state. Each
/// tappable node is held down, and the pixels under it must change.
void main() {
  const double width = 390;
  const double height = 2400;

  for (final Subject subject in <Subject>[
    Subject.board,
    Subject.missions,
    Subject.detail,
    Subject.settings,
  ]) {
    a11yTest('${subject.name}: every tappable element shows a pressed state', (
      WidgetTester tester,
      void Function(A11yEnv) track,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      try {
        final A11yEnv env = await A11yEnv.pump(
          tester,
          subject,
          width: width,
          height: height,
        );
        track(env);
        final ByteData rest = await env.pixels();
        final List<SemanticsNode> nodes = tappableNodes(tester);
        expect(nodes, isNotEmpty);
        final List<String> flat = <String>[];
        final Set<String> seen = <String>{};
        for (final SemanticsNode node in nodes) {
          // A text field answers a touch with focus and a caret, not a press.
          if (node.getSemanticsData().flagsCollection.isTextField) continue;
          final Rect rect = globalRect(node);
          if (!seen.add('${rect.left},${rect.top},${rect.width}')) continue;
          final TestGesture gesture = await tester.startGesture(rect.center);
          // A touch only counts as pressed after the press timeout, and the
          // frame that applies it only starts the animations: the next one
          // moves them.
          await tester.pump(kPressTimeout + const Duration(milliseconds: 20));
          await tester.pump(const Duration(milliseconds: 16));
          await tester.pump(const Duration(milliseconds: 300));
          final ByteData pressed = await env.pixels();
          await gesture.cancel();
          await tester.pump(const Duration(milliseconds: 16));
          await tester.pump(const Duration(milliseconds: 400));
          final int changed = _changedPixels(
            rest,
            pressed,
            width.toInt(),
            rect,
            height.toInt(),
          );
          if (changed == 0) {
            flat.add(
              '"${node.label}" ${node.getSemanticsData().tooltip} $rect',
            );
          }
        }
        expect(flat, isEmpty, reason: 'no visible change while pressed');
      } finally {
        handle.dispose();
      }
    });
  }
}
