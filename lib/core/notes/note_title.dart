/// The longest name a Node may have.
const int maxNodeNameLength = 80;

/// Characters a backslash can escape. While a line is stripped each escaped one
/// is swapped for a private-use code point so that no marker rule can see it.
const String _escapable = r'\`*_{}[]()#+-.!<>~&|';
const int _privateBase = 0xE000;
final RegExp _escaped = RegExp(r'\\([\\`*_{}\[\]()#+\-.!<>~&|])');
final RegExp _hidden = RegExp('[\uE000-\uE020]');
final RegExp _fence = RegExp(r'^\s*(```|~~~)');
final RegExp _thematicBreak = RegExp(r'^\s*([-*_=])(\s*\1){2,}\s*$');
final RegExp _heading = RegExp(r'^#{1,6}(\s+|$)');
final RegExp _quote = RegExp(r'^>\s*');
final RegExp _bullet = RegExp(r'^[-+*](\s+(\[[ xX]\](\s+|$))?|$)');
final RegExp _ordered = RegExp(r'^\d+[.)](\s+|$)');
final RegExp _link = RegExp(r'!?\[([^\]]*)\]\([^)]*\)');
final RegExp _emphasis = RegExp(r'\*+|~~|`+');
final RegExp _underscores = RegExp(r'(?<![A-Za-z0-9])_+|_+(?![A-Za-z0-9])');

/// One line with its Markdown markers removed; empty when it holds no text
/// (a fence, a thematic break or only markers).
String _plain(String line) {
  if (_fence.hasMatch(line) || _thematicBreak.hasMatch(line)) return '';
  // A backslash-escaped character is plain text: hide the pair from the marker
  // rules below and put the character back at the end.
  String text = line.trim().replaceAllMapped(
    _escaped,
    (m) => String.fromCharCode(_privateBase + _escapable.indexOf(m[1]!)),
  );
  String before;
  do {
    before = text;
    text = text
        .replaceFirst(_heading, '')
        .replaceFirst(_quote, '')
        .replaceFirst(_bullet, '')
        .replaceFirst(_ordered, '')
        .replaceAllMapped(_link, (m) => m[1] ?? '')
        .replaceAll(_emphasis, '')
        .replaceAll(_underscores, '')
        .trim();
  } while (text != before);
  return text.replaceAllMapped(_hidden, (m) => _escapable[m[0]!.codeUnitAt(0) - _privateBase]);
}

Iterable<String> _plainLines(String body) sync* {
  bool inFence = false;
  for (final String line in body.split(RegExp(r'\r\n|\r|\n'))) {
    if (_fence.hasMatch(line)) {
      inFence = !inFence;
      continue;
    }
    // Code is text too: inside a fence the line is kept as written.
    final String text = inFence ? line.trim() : _plain(line);
    if (text.isNotEmpty) yield text;
  }
}

/// First non-empty line of [body] with Markdown markers removed, cut to
/// [maxNodeNameLength] characters; null when no line holds text.
String? deriveNoteName(String body) {
  for (final String line in _plainLines(body)) {
    final String cut = String.fromCharCodes(line.runes.take(maxNodeNameLength));
    final String name = cut.trimRight();
    if (name.isNotEmpty) return name;
  }
  return null;
}

/// First two non-empty lines with markers removed, joined by a space; empty
/// when [body] holds no text. With [skipFirstLine] the line a Note was named
/// after is left out, so the preview does not repeat the name.
String notePreview(String body, {bool skipFirstLine = false}) =>
    _plainLines(body).skip(skipFirstLine ? 1 : 0).take(2).join(' ');
