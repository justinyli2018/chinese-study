import 'package:chinese_study/models/word.dart';
import 'package:chinese_study/models/word_set.dart';
import 'package:chinese_study/screens/typing_quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders without layout errors and submit works', (
    tester,
  ) async {
    final wordSet = WordSet(
      id: 'test.tsv',
      displayName: 'Test',
      words: const [
        Word(hanzi: '你好', definition: 'hello'),
        Word(hanzi: '谢谢', definition: 'thank you'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TypingQuizScreen(wordSet: wordSet, questions: wordSet.words),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('hello'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '你好');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Correct!'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Swiping left over the question card (not the text field) should
    // advance to the next question, same as tapping "Next".
    await tester.fling(find.text('hello'), const Offset(-300, 0), 800);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('thank you'), findsOneWidget);
  });

  testWidgets('left swipe before answering does nothing', (tester) async {
    final wordSet = WordSet(
      id: 'test2.tsv',
      displayName: 'Test 2',
      words: const [
        Word(hanzi: '你好', definition: 'hello'),
        Word(hanzi: '谢谢', definition: 'thank you'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TypingQuizScreen(wordSet: wordSet, questions: wordSet.words),
      ),
    );
    await tester.pumpAndSettle();

    await tester.fling(find.text('hello'), const Offset(-300, 0), 800);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('hello'), findsOneWidget);
  });
}
