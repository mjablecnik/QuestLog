import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart' show kPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

/// Changed 2026-11-18 at Martin's request: a touch leaves no splash, highlight
/// or hover tint on any control. State is shown by selection or an in-place
/// fill (the effort rows, the segmented control), never by Material ink.
void main() {
  final List<QuestlogPalette> palettes = <QuestlogPalette>[
    QuestlogPalette.guildBoard,
    QuestlogPalette.daylight,
  ];

  test('the theme has no tap splash, highlight or hover for any palette', () {
    for (final QuestlogPalette p in palettes) {
      final ThemeData t = buildTheme(palette: p);
      expect(t.splashFactory, same(NoSplash.splashFactory));
      expect(t.splashColor, Colors.transparent);
      expect(t.highlightColor, Colors.transparent);
      expect(t.hoverColor, Colors.transparent);
    }
  });

  test('buttons paint an overlay only for keyboard focus', () {
    final ThemeData t = buildTheme(
      palette: QuestlogPalette.guildBoard,
    );
    final List<ButtonStyle?> styles = <ButtonStyle?>[
      t.textButtonTheme.style,
      t.filledButtonTheme.style,
      t.outlinedButtonTheme.style,
      t.iconButtonTheme.style,
    ];
    for (final ButtonStyle? s in styles) {
      final WidgetStateProperty<Color?> overlay = s!.overlayColor!;
      expect(
        overlay.resolve(<WidgetState>{WidgetState.pressed}),
        Colors.transparent,
      );
      expect(
        overlay.resolve(<WidgetState>{WidgetState.hovered}),
        Colors.transparent,
      );
      expect(overlay.resolve(<WidgetState>{WidgetState.focused}), isNotNull);
    }
  });

  testWidgets('holding a chip or a button changes no pixel', (tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final GlobalKey boundary = GlobalKey();
    final ThemeData theme = buildTheme(
      palette: QuestlogPalette.guildBoard,
    );
    final QuestlogPalette p = QuestlogPalette.guildBoard;
    final Key chip = const ValueKey('chip');
    final Key text = const ValueKey('text');
    final Key filled = const ValueKey('filled');
    final Key outlined = const ValueKey('outlined');
    final Key icon = const ValueKey('icon');
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: RepaintBoundary(
          key: boundary,
          child: Scaffold(
            body: Column(
              children: <Widget>[
                Material(
                  key: chip,
                  color: p.field,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: () {},
                    child: const SizedBox(width: 160, height: 48),
                  ),
                ),
                TextButton(key: text, onPressed: () {}, child: const Text('t')),
                FilledButton(
                  key: filled,
                  onPressed: () {},
                  child: const Text('f'),
                ),
                OutlinedButton(
                  key: outlined,
                  onPressed: () {},
                  child: const Text('o'),
                ),
                IconButton(
                  key: icon,
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Future<ByteData> capture() async {
      final RenderRepaintBoundary b =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      return tester
          .runAsync(() async {
            final ui.Image image = await b.toImage();
            final ByteData? data = await image.toByteData();
            return data!;
          })
          .then((ByteData? d) => d!);
    }

    for (final Key key in <Key>[chip, text, filled, outlined, icon]) {
      final ByteData rest = await capture();
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byKey(key)),
      );
      await tester.pump(kPressTimeout + const Duration(milliseconds: 20));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 300));
      final ByteData pressed = await capture();
      await gesture.cancel();
      await tester.pump(const Duration(milliseconds: 400));

      final Uint8List a = rest.buffer.asUint8List();
      final Uint8List b = pressed.buffer.asUint8List();
      final List<int> diff = <int>[];
      for (int i = 0; i < a.length; i += 4) {
        if (a[i] != b[i] || a[i + 1] != b[i + 1] || a[i + 2] != b[i + 2]) {
          diff.add(i ~/ 4);
        }
      }
      if (diff.isNotEmpty) {
        final List<int> xs = diff.map((int i) => i % 400).toList()..sort();
        fail(
          'pressing ${(key as ValueKey<String>).value} changed ${diff.length} px: '
          'x ${xs.first}-${xs.last}, y ${diff.first ~/ 400}-${diff.last ~/ 400}, '
          'widget ${tester.getRect(find.byKey(key))}, rgba ${a.sublist(diff.first * 4, diff.first * 4 + 4)} -> ${b.sublist(diff.first * 4, diff.first * 4 + 4)}',
        );
      }
    }
  });
}
