import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/ui/widgets/common/announce.dart';

import '_harness.dart';

/// Announcements captured from the `flutter/accessibility` channel.
List<String> _captureAnnouncements(WidgetTester tester) {
  final List<String> messages = <String>[];
  tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
    SystemChannels.accessibility,
    (dynamic message) async {
      final Map<dynamic, dynamic> map = message as Map<dynamic, dynamic>;
      if (map['type'] == 'announce') {
        final Map<dynamic, dynamic> data = map['data'] as Map<dynamic, dynamic>;
        messages.add(data['message'] as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger
        .setMockDecodedMessageHandler<dynamic>(
          SystemChannels.accessibility,
          null,
        ),
  );
  return messages;
}

void main() {
  testWidgets('announce sends the message to the accessibility channel', (
    tester,
  ) async {
    final List<String> sent = _captureAnnouncements(tester);
    late BuildContext ctx;
    await pumpCommon(
      tester,
      Builder(
        builder: (BuildContext c) {
          ctx = c;
          return const SizedBox();
        },
      ),
    );
    await announce(ctx, 'Hello');
    expect(sent, <String>['Hello']);
  });

  testWidgets('quest and mission helpers use the localized a11y strings', (
    tester,
  ) async {
    final List<String> sent = _captureAnnouncements(tester);
    late BuildContext ctx;
    late AppLocalizations l10n;
    await pumpCommon(
      tester,
      Builder(
        builder: (BuildContext c) {
          ctx = c;
          l10n = AppLocalizations.of(c);
          return const SizedBox();
        },
      ),
    );
    await announceQuestCompleted(ctx, l10n, 'Water plants', 25);
    await announceQuestReopened(ctx, l10n, 'Water plants');
    await announceMissionCompleted(ctx, l10n, 'Spring clean', 50);
    await announceMissionReopened(ctx, l10n, 'Spring clean');
    await announceLevelUp(ctx, l10n, 3);
    expect(sent, <String>[
      l10n.a11y_questCompleted('Water plants', 25),
      l10n.a11y_questReopened('Water plants'),
      l10n.a11y_missionCompleted('Spring clean', 50),
      l10n.a11y_missionReopened('Spring clean'),
      l10n.a11y_levelUp(3),
    ]);
    expect(sent.first, 'Quest Water plants completed, +25 XP');
    expect(sent[1], 'Quest Water plants reopened');
  });
}
