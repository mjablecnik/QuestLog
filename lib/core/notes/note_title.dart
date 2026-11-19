/// The longest name a Node may have.
const int maxNodeNameLength = 80;

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
  String text = line.trim();
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
  return text;
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
/// when [body] holds no text.
String notePreview(String body) => _plainLines(body).take(2).join(' ');
