import 'word.dart';

/// A named collection of [Word]s, sourced from one TSV asset file.
class WordSet {
  final String id; // asset file name, e.g. "hsk1.tsv" - used as storage key
  final String displayName;
  final List<Word> words;

  const WordSet({
    required this.id,
    required this.displayName,
    required this.words,
  });
}
