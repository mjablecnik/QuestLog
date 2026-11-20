import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/ui/theme/tokens.dart';

/// Property 7: text contrast. Translucent colours are blended over the ground
/// they sit on before the WCAG 2.x ratio is computed.
double _channel(double c) =>
    c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double contrastRatio(Color foreground, Color ground) {
  final Color fg = Color.alphaBlend(foreground, ground);
  final double a = _luminance(fg);
  final double b = _luminance(ground);
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

/// Measured ratios (approved palette, unchanged):
///
/// | pair                          | guildBoard | daylight |
/// |-------------------------------|-----------:|---------:|
/// | text/board                    |      14.23 |    12.81 |
/// | text/boardRaised              |      12.67 |    13.86 |
/// | textDim/board                 |       6.13 | 4.10 (!) |
/// | textDim/boardRaised           |       5.73 | 4.22 (!) |
/// | ink/parchment                 |      12.07 |    14.57 |
/// | inkDim/parchment             |   3.79 (!) | 4.06 (!) |
/// | inkOnBrass/brass              |       7.79 | 3.19 (!) |
/// | inkOnDestructive/destructive  |   3.14 (!) | 3.14 (!) |
/// | text/sheet                    |      12.67 |    13.86 |
/// | textDim/sheet                 |       5.73 | 4.22 (!) |
/// | ink/parchmentEdge             |      10.30 |    11.19 |
/// | brass/board (text, 3:1)       |       8.54 | 2.92 (!) |
/// | brass/boardRaised             |       7.60 |     3.16 |
/// | brass/sheet                   |       7.60 |     3.16 |
/// | brass/parchment               |   1.69 (!) |     3.32 |
/// | textFaint/board (decorative)  |       3.50 |     2.41 |
/// | inkFaint/parchment (decor.)   |       2.17 |     2.24 |
///
typedef _Pair = (
  String,
  Color Function(QuestlogPalette),
  Color Function(QuestlogPalette),
);

final List<_Pair> _bodyPairs = <_Pair>[
  ('text/board', (p) => p.text, (p) => p.board),
  ('text/boardRaised', (p) => p.text, (p) => p.boardRaised),
  ('textDim/board', (p) => p.textDim, (p) => p.board),
  ('textDim/boardRaised', (p) => p.textDim, (p) => p.boardRaised),
  ('ink/parchment', (p) => p.ink, (p) => p.parchment),
  ('inkDim/parchment', (p) => p.inkDim, (p) => p.parchment),
  ('inkOnBrass/brass', (p) => p.inkOnBrass, (p) => p.brass),
  (
    'inkOnDestructive/destructive',
    (p) => p.inkOnDestructive,
    (p) => p.destructive,
  ),
  ('text/sheet', (p) => p.text, (p) => p.sheet),
  ('textDim/sheet', (p) => p.textDim, (p) => p.sheet),
  ('ink/parchmentEdge', (p) => p.ink, (p) => p.parchmentEdge),
];

/// Brass used as text or an icon stroke (accents, links, large figures).
final List<_Pair> _brassPairs = <_Pair>[
  ('brass/board', (p) => p.brass, (p) => p.board),
  ('brass/boardRaised', (p) => p.brass, (p) => p.boardRaised),
  ('brass/sheet', (p) => p.brass, (p) => p.sheet),
  ('brass/parchment', (p) => p.brass, (p) => p.parchment),
];

/// Accent text roles of the higher-contrast, blue and green palettes: text and icon
/// strokes use [QuestlogPalette.brassText] / [QuestlogPalette.brassOnParchment].
final List<_Pair> _highContrastBrassPairs = <_Pair>[
  ('brassText/board', (p) => p.brassText, (p) => p.board),
  ('brassText/boardRaised', (p) => p.brassText, (p) => p.boardRaised),
  ('brassText/sheet', (p) => p.brassText, (p) => p.sheet),
  ('brassOnParchment/parchment', (p) => p.brassOnParchment, (p) => p.parchment),
];

/// Quest card roles on a dark palette (a dark raised card, not parchment).
final List<_Pair> _darkSlipTextPairs = <_Pair>[
  ('slipText/slip', (p) => p.slipText, (p) => p.slip),
  ('slipTextDim/slip', (p) => p.slipTextDim, (p) => p.slip),
  ('brass/slip (XP)', (p) => p.brassText, (p) => p.slip),
  ('textDim/slipDone-over-board', (p) => p.textDim, (p) => p.board),
];

/// Non-text parts of a dark Quest card: the check ring and the empty pips.
final List<_Pair> _darkSlipGraphicPairs = <_Pair>[
  ('slipTextFaint/slip', (p) => p.slipTextFaint, (p) => p.slip),
  ('brass/slip (pips, check)', (p) => p.brass, (p) => p.slip),
];

void _checkPairs(
  Map<String, QuestlogPalette> palettes,
  List<_Pair> pairs,
  double threshold,
) {
  for (final MapEntry<String, QuestlogPalette> e in palettes.entries) {
    for (final _Pair pair in pairs) {
      final String key = '${e.key}/${pair.$1}';
      test(key, () {
        final double ratio = contrastRatio(pair.$2(e.value), pair.$3(e.value));
        expect(
          ratio,
          greaterThanOrEqualTo(threshold),
          reason: '$key = ${ratio.toStringAsFixed(2)}',
        );
      });
    }
  }
}

void main() {
  final Map<String, QuestlogPalette> palettes = <String, QuestlogPalette>{
    'guildBoard': QuestlogPalette.guildBoard,
    'daylight': QuestlogPalette.daylight,
  };

  // The blue palette has no gaps: every pair meets its threshold.
  group('body text pairs reach 4.5:1', () {
    _checkPairs(palettes, _bodyPairs, 4.5);
  });

  group('accent text roles reach 4.5:1', () {
    _checkPairs(palettes, _highContrastBrassPairs, 4.5);
  });

  group('accent fill reaches 3:1 on the ground', () {
    _checkPairs(palettes, _brassPairs.take(3).toList(), 3.0);
  });

  final Map<String, QuestlogPalette> darkPalettes = <String, QuestlogPalette>{
    'guildBoard': QuestlogPalette.guildBoard,
  };

  group('dark Quest cards: text pairs reach 4.5:1', () {
    _checkPairs(darkPalettes, _darkSlipTextPairs, 4.5);
  });

  group('the overdue Deadline text reaches 4.5:1 on the Quest card', () {
    _checkPairs(palettes, <_Pair>[('destructiveText/slip', (p) => p.destructiveText, (p) => p.slip)], 4.5);
  });

  group('dark Quest cards: check ring, pips and tick reach 3:1', () {
    _checkPairs(darkPalettes, _darkSlipGraphicPairs, 3.0);
  });

  test('the dark palette draws Quest cards as the raised board, not parchment', () {
    final QuestlogPalette p = QuestlogPalette.guildBoard;
    expect(p.slip, p.boardRaised);
    expect(p.slipEdge, p.boardLine);
    expect(p.slipText, p.text);
    expect(p.slipTextDim, p.textDim);
    expect(p.slipTextFaint, p.textFaint);
    expect(p.slipDone.a, 0, reason: 'a done card is outlined, not filled');
  });

  test('the light palette keeps the parchment slip, role for role', () {
    final QuestlogPalette p = QuestlogPalette.daylight;
    expect(p.slip, p.parchment);
    expect(p.slipEdge, p.parchmentEdge);
    expect(p.slipText, p.ink);
    expect(p.slipTextDim, p.inkDim);
    expect(p.slipTextFaint, p.inkFaint);
    expect(p.slipDone, p.boardRaised);
  });

  test('contrast helper matches known values', () {
    expect(
      contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      closeTo(21, 0.01),
    );
    expect(
      contrastRatio(const Color(0xFF777777), const Color(0xFFFFFFFF)),
      closeTo(4.48, 0.02),
    );
  });
}
