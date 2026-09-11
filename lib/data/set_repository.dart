import 'package:flutter/services.dart' show rootBundle, AssetManifest;

import '../models/word_set.dart';
import 'tsv_parser.dart';

/// Discovers and loads flashcard sets bundled under `assets/sets/`.
///
/// To add a new set: drop a `name.tsv` file (tab-separated `word\tdefinition`
/// lines, one per row) into `assets/sets/` and rebuild the app. No code or
/// frontend changes are needed - sets are discovered automatically from the
/// asset bundle at startup.
class SetRepository {
  static const String assetDir = 'assets/sets/';

  Future<List<WordSet>> loadAllSets() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final paths = manifest
        .listAssets()
        .where(
          (p) => p.startsWith(assetDir) && p.toLowerCase().endsWith('.tsv'),
        )
        .toList()
      ..sort();

    final sets = <WordSet>[];
    for (final path in paths) {
      final content = await rootBundle.loadString(path);
      final words = parseTsv(content);
      if (words.isEmpty) continue;

      final fileName = path.substring(assetDir.length);
      sets.add(
        WordSet(
          id: fileName,
          displayName: _displayNameFor(fileName),
          words: words,
        ),
      );
    }
    return sets;
  }

  String _displayNameFor(String fileName) {
    final withoutExt = fileName.replaceAll(RegExp(r'\.tsv$'), '');
    final spaced = withoutExt.replaceAll('_', ' ').replaceAll('-', ' ');
    if (spaced.isEmpty) return fileName;
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}
