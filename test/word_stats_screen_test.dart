import 'package:chinese_study/data/stats_repository.dart';
import 'package:chinese_study/models/word.dart';
import 'package:chinese_study/models/word_set.dart';
import 'package:chinese_study/screens/word_stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  WordSet buildSet() => WordSet(
        id: 'test.tsv',
        displayName: 'Test',
        words: const [
          Word(hanzi: '你好', definition: 'hello'),
          Word(hanzi: '谢谢', definition: 'thank you'),
        ],
      );

  testWidgets('shows per-word accuracy and resets a single word', (
    tester,
  ) async {
    final wordSet = buildSet();
    final repo = StatsRepository();
    await repo.recordMultipleChoice(
      wordSet.id,
      wordSet.words[0].statKey,
      true,
    );
    await repo.recordMultipleChoice(
      wordSet.id,
      wordSet.words[0].statKey,
      false,
    );

    await tester.pumpWidget(
      MaterialApp(home: WordStatsScreen(wordSet: wordSet)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('1 / 2'), findsOneWidget);
    // Word 1's typing line and all of word 2 report no attempts.
    expect(find.textContaining('No attempts yet'), findsNWidgets(2));

    final resetButtons = find.byIcon(Icons.refresh);
    final firstButton = tester.widget<IconButton>(
      find
          .ancestor(of: resetButtons.first, matching: find.byType(IconButton))
          .first,
    );
    expect(firstButton.onPressed, isNotNull);

    await tester.tap(
      find
          .ancestor(of: resetButtons.first, matching: find.byType(IconButton))
          .first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Reset stats for "你好"'), findsOneWidget);
    // Both words now show "No attempts yet" (one Text widget per word).
    expect(find.textContaining('No attempts yet'), findsNWidgets(2));

    // Undo restores it.
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 / 2'), findsOneWidget);
  });

  testWidgets('clear all wipes every word after confirmation', (tester) async {
    final wordSet = buildSet();
    final repo = StatsRepository();
    await repo.recordMultipleChoice(wordSet.id, wordSet.words[0].statKey, true);
    await repo.recordTyping(wordSet.id, wordSet.words[1].statKey, false);

    await tester.pumpWidget(
      MaterialApp(home: WordStatsScreen(wordSet: wordSet)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_sweep));
    await tester.pumpAndSettle();

    expect(find.text('Clear all stats?'), findsOneWidget);
    await tester.tap(find.text('Clear All'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No attempts yet'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
