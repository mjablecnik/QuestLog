import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/ui/widgets/common/haptics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('each helper sends its haptic impact on the platform channel', () async {
    final List<dynamic> calls = <dynamic>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            calls.add(call.arguments);
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await Haptics.light();
    await Haptics.medium();
    await Haptics.success();
    expect(calls, <String>[
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.mediumImpact',
      'HapticFeedbackType.heavyImpact',
    ]);
  });

  test('is a safe no-op when the platform has no haptic engine', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          throw PlatformException(code: 'unavailable');
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await expectLater(Haptics.light(), completes);
    await expectLater(Haptics.success(), completes);
  });
}
