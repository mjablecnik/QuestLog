import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/ui/theme/tokens.dart';

void main() {
  test('corner radii follow the design: card 14, field 12, sheet 24, reward 22', () {
    expect(Radii.card, 14);
    expect(Radii.control, 12);
    expect(Radii.sheet, 24);
    expect(Radii.reward, 22);
  });

  test('the touch-target minimum is 44', () {
    expect(Metrics.touchTarget, 44);
  });

  test('the spacing scale is strictly increasing', () {
    const List<double> scale = <double>[
      Space.s2,
      Space.s4,
      Space.s6,
      Space.s8,
      Space.s10,
      Space.s12,
      Space.s16,
      Space.s18,
      Space.s20,
      Space.s22,
      Space.s24,
      Space.s26,
      Space.s32,
      Space.s48,
      Space.s64,
    ];
    for (int i = 1; i < scale.length; i++) {
      expect(scale[i], greaterThan(scale[i - 1]));
    }
  });

  test('the three transition bands: about 200, about 300 and 300 to 400 ms', () {
    expect(Motion.hover.inMilliseconds, 200);
    expect(Motion.panel.inMilliseconds, 300);
    expect(Motion.screen.inMilliseconds, inInclusiveRange(300, 400));
  });
}
