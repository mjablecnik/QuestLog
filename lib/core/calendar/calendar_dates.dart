/// The 42 dates of the six-week grid that shows [month], Monday first.
List<DateTime> monthGridDates(DateTime month) {
  final DateTime first = DateTime(month.year, month.month, 1);
  final int lead = first.weekday - DateTime.monday;
  return <DateTime>[
    for (int i = 0; i < 42; i++) DateTime(first.year, first.month, 1 - lead + i),
  ];
}

/// The dates an occurrence that starts on [start] and spans [spanDays] touches.
List<DateTime> coveredDates(DateTime start, int spanDays) => <DateTime>[
  for (int i = 0; i <= spanDays; i++) DateTime(start.year, start.month, start.day + i),
];

/// Whether the calendar may show [month]: January 2000 to December 2100.
bool isNavigableMonth(DateTime month) => month.year >= 2000 && month.year <= 2100;

/// The first and last month the calendar can show.
final DateTime firstNavigableMonth = DateTime(2000, 1);
final DateTime lastNavigableMonth = DateTime(2100, 12);

const Map<String, String> _plain = <String, String>{
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a', 'ą': 'a',
  'ć': 'c', 'č': 'c', 'ç': 'c',
  'ď': 'd',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'ě': 'e', 'ę': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ł': 'l', 'ĺ': 'l', 'ľ': 'l',
  'ň': 'n', 'ñ': 'n', 'ń': 'n',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
  'ř': 'r', 'ŕ': 'r',
  'š': 's', 'ś': 's',
  'ť': 't',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', 'ů': 'u',
  'ý': 'y', 'ÿ': 'y',
  'ž': 'z', 'ź': 'z', 'ż': 'z',
};

/// Lower-cased [text] with diacritics removed, so that a search ignores case
/// and diacritics ("Řehoř" matches "rehor").
String searchKey(String text) {
  final StringBuffer out = StringBuffer();
  for (final int rune in text.toLowerCase().runes) {
    final String ch = String.fromCharCode(rune);
    out.write(_plain[ch] ?? ch);
  }
  return out.toString();
}
