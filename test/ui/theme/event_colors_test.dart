import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/ui/theme/tokens.dart';

double _channel(double c) =>
    c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double _contrast(Color foreground, Color ground) {
  final Color fg = Color.alphaBlend(foreground, ground);
  final double a = _luminance(fg);
  final double b = _luminance(ground);
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

double _f(double t) => t > 0.008856 ? math.pow(t, 1 / 3).toDouble() : 7.787 * t + 16 / 116;

List<double> _lab(Color c) {
  final double r = _channel(c.r), g = _channel(c.g), b = _channel(c.b);
  final double x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047;
  final double y = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  final double z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883;
  return <double>[116 * _f(y) - 16, 500 * (_f(x) - _f(y)), 200 * (_f(y) - _f(z))];
}

double _distance(Color a, Color b) {
  final List<double> p = _lab(a), q = _lab(b);
  return math.sqrt(math.pow(p[0] - q[0], 2) + math.pow(p[1] - q[1], 2) + math.pow(p[2] - q[2], 2));
}

void main() {
  final QuestlogPalette dark = QuestlogPalette.guildBoard;
  final List<QuestlogPalette> all = <QuestlogPalette>[
    QuestlogPalette.guildBoard,
    QuestlogPalette.daylight,
  ];

  test('there is one distinct colour per type', () {
    final Set<Color> colours = <Color>{for (final EventType t in EventType.values) dark.eventColor(t)};
    expect(colours, hasLength(EventType.values.length));
  });

  test('no two Event_Type colours are closer than 25 (CIE76)', () {
    for (final EventType a in EventType.values) {
      for (final EventType b in EventType.values) {
        if (a.index >= b.index) continue;
        expect(
          _distance(dark.eventColor(a), dark.eventColor(b)),
          greaterThanOrEqualTo(25),
          reason: '${a.key} and ${b.key}',
        );
      }
    }
  });

  test('chip ink has at least 4.5:1 on every solid colour', () {
    for (final EventType t in EventType.values) {
      expect(_contrast(dark.eventChipInk, dark.eventColor(t)), greaterThanOrEqualTo(4.5), reason: t.key);
    }
  });

  test('the body text has at least 4.5:1 on the Soft_Chip fill in every palette', () {
    for (final QuestlogPalette p in all) {
      final Color fill = Color.alphaBlend(p.eventSoftFill(EventType.notableDay), p.board);
      expect(_contrast(p.text, fill), greaterThanOrEqualTo(4.5), reason: '${p.brightness}');
    }
  });

  test('the colours are the same in every palette', () {
    for (final QuestlogPalette p in all) {
      for (final EventType t in EventType.values) {
        expect(p.eventColor(t), dark.eventColor(t));
      }
    }
  });
}
