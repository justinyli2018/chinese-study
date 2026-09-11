import 'package:chinese_study/models/word.dart';
import 'package:chinese_study/models/word_set.dart';
import 'package:chinese_study/screens/flashcard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WordSet buildSet() => WordSet(
        id: 'test.tsv',
        displayName: 'Test',
        words: const [
          Word(hanzi: '你好', definition: 'hello'),
          Word(hanzi: '谢谢', definition: 'thank you'),
          Word(hanzi: '再见', definition: 'goodbye'),
        ],
      );

  testWidgets('tap flips the card', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: FlashcardScreen(wordSet: buildSet())),
    );
    await tester.pumpAndSettle();

    expect(find.text('你好'), findsOneWidget);
    expect(find.text('hello'), findsNothing);

    await tester.tap(find.text('你好'));
    await tester.pumpAndSettle();

    expect(find.text('hello'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('vertical swipe on the card flips it', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: FlashcardScreen(wordSet: buildSet())),
    );
    await tester.pumpAndSettle();

    await tester.fling(find.text('你好'), const Offset(0, -300), 800);
    await tester.pumpAndSettle();

    expect(find.text('hello'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('horizontal swipe on the card navigates, buttons still work', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: FlashcardScreen(wordSet: buildSet())),
    );
    await tester.pumpAndSettle();

    expect(find.text('你好'), findsOneWidget);

    await tester.fling(find.text('你好'), const Offset(-300, 0), 800);
    await tester.pumpAndSettle();
    expect(find.text('谢谢'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.fling(find.text('谢谢'), const Offset(300, 0), 800);
    await tester.pumpAndSettle();
    expect(find.text('你好'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Prev/Next icon buttons must still work after adding swipe gestures.
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
    expect(find.text('谢谢'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('你好'), findsOneWidget);
  });

  testWidgets('shuffle button still works', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: FlashcardScreen(wordSet: buildSet())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.shuffle));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.shuffle_on_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
