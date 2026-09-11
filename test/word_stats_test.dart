import 'package:chinese_study/models/word_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accuracy is 0 with no attempts', () {
    final stats = WordStats();
    expect(stats.mcAccuracy, 0.0);
    expect(stats.tqAccuracy, 0.0);
  });

  test('mc accuracy reflects correct/total', () {
    final stats = WordStats(mcCorrect: 3, mcTotal: 4);
    expect(stats.mcAccuracy, closeTo(0.75, 1e-9));
  });

  test('round trips through json', () {
    final stats = WordStats(mcCorrect: 2, mcTotal: 5, tqCorrect: 1, tqTotal: 3);
    final restored = WordStats.fromJson(stats.toJson());
    expect(restored.mcCorrect, 2);
    expect(restored.mcTotal, 5);
    expect(restored.tqCorrect, 1);
    expect(restored.tqTotal, 3);
  });
}
