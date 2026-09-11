import '../models/word.dart';

/// Parses tab-separated flashcard lines into [Word]s.
///
/// Supports two column layouts, auto-detected per file:
///   - `word\tdefinition`
///   - `index\tword\tdefinition` (a leading numeric index column is ignored)
///
/// Fields may optionally be wrapped in matching double or single quotes
/// (e.g. `"变化"\t"change; to change"`), which are stripped. If a
/// definition itself contains extra tabs, everything after the word column
/// is rejoined with a space.
///
/// - Blank lines are skipped.
/// - A leading header row (e.g. "word\tdefinition") is detected and skipped.
List<Word> parseTsv(String content) {
  final words = <Word>[];
  final lines = content.split('\n');

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trimRight().replaceAll('\r', '');
    if (line.trim().isEmpty) continue;

    final rawParts = line.split('\t');
    if (rawParts.length < 2) continue;
    final parts = rawParts.map((p) => _stripQuotes(p.trim())).toList();

    String hanzi;
    String definition;
    if (parts.length >= 3 && _isIndexLike(parts[0])) {
      hanzi = parts[1];
      definition = parts.sublist(2).join(' ').trim();
    } else {
      hanzi = parts[0];
      definition = parts.sublist(1).join(' ').trim();
    }

    if (hanzi.isEmpty || definition.isEmpty) continue;
    if (i == 0 && _looksLikeHeader(hanzi, definition)) continue;

    words.add(Word(hanzi: hanzi, definition: definition));
  }

  return words;
}

bool _isIndexLike(String s) => RegExp(r'^\d+[.)]?$').hasMatch(s);

String _stripQuotes(String s) {
  if (s.length >= 2) {
    final first = s[0];
    final last = s[s.length - 1];
    if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
      return s.substring(1, s.length - 1).trim();
    }
  }
  return s;
}

bool _looksLikeHeader(String a, String b) {
  final left = a.toLowerCase();
  final right = b.toLowerCase();
  const leftHints = ['word', 'hanzi', 'chinese', '汉字'];
  const rightHints = ['definition', 'meaning', 'english', 'translation'];
  return leftHints.any(left.contains) && rightHints.any(right.contains);
}
