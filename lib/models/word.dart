/// A single Chinese word/definition flashcard.
class Word {
  final String hanzi;
  final String definition;

  const Word({required this.hanzi, required this.definition});

  /// Stable identifier used to key persisted stats. Content-based (not
  /// index-based) so stats survive reordering/insertion in the TSV file.
  String get statKey => '$hanzi$definition';
}
