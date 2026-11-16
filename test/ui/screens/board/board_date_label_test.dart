import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:questlog/ui/screens/board/board_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('cs');
    await initializeDateFormatting('en');
  });

  test('Czech shows the weekday and a numeric date like the artboard', () {
    expect(boardDateLabel(DateTime(2026, 11, 14), 'cs'), 'sobota 14. 11.');
    expect(boardDateLabel(DateTime(2026, 11, 15), 'cs'), 'neděle 15. 11.');
  });

  test('English spells the weekday and the month out', () {
    expect(boardDateLabel(DateTime(2026, 11, 15), 'en'), 'Sunday, November 15');
  });
}
