import 'package:chinese_study/data/stats_repository.dart';
import 'package:chinese_study/models/word_stats.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('clearWord removes only that word, others in the set remain', () async {
    final repo = StatsRepository();
    await repo.recordMultipleChoice('set.tsv', 'wordA', true);
    await repo.recordMultipleChoice('set.tsv', 'wordB', false);

    await repo.clearWord('set.tsv', 'wordA');

    final stats = await repo.loadForSet('set.tsv');
    expect(stats.containsKey('wordA'), isFalse);
    expect(stats['wordB']!.mcTotal, 1);
  });

  test('clearSet removes all words in that set only', () async {
    final repo = StatsRepository();
    await repo.recordMultipleChoice('setA.tsv', 'word1', true);
    await repo.recordMultipleChoice('setB.tsv', 'word2', true);

    await repo.clearSet('setA.tsv');

    expect(await repo.loadForSet('setA.tsv'), isEmpty);
    final setBStats = await repo.loadForSet('setB.tsv');
    expect(setBStats['word2']!.mcTotal, 1);
  });

  test('setWordStats restores a previous value (undo)', () async {
    final repo = StatsRepository();
    await repo.recordMultipleChoice('set.tsv', 'word1', true);
    await repo.recordTyping('set.tsv', 'word1', false);

    final before = (await repo.loadForSet('set.tsv'))['word1']!;
    await repo.clearWord('set.tsv', 'word1');
    expect(await repo.loadForSet('set.tsv'), isEmpty);

    await repo.setWordStats('set.tsv', 'word1', before);
    final restored = (await repo.loadForSet('set.tsv'))['word1']!;
    expect(restored.mcCorrect, 1);
    expect(restored.mcTotal, 1);
    expect(restored.tqCorrect, 0);
    expect(restored.tqTotal, 1);
  });

  test('WordStats copies are independent (undo snapshot safety)', () {
    final stats = WordStats(mcCorrect: 1, mcTotal: 1);
    final snapshot = WordStats.fromJson(stats.toJson());
    stats.mcTotal += 5;
    expect(snapshot.mcTotal, 1);
  });
}
