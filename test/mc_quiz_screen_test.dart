import 'package:chinese_study/models/word.dart';
import 'package:chinese_study/models/word_set.dart';
import 'package:chinese_study/screens/mc_quiz_screen.dart';
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
          Word(hanzi: '再见', definition: 'goodbye'),
          Word(hanzi: '朋友', definition: 'friend'),
        ],
      );

  testWidgets('choice buttons still work and swipe-left advances after answering', (
    tester,
  ) async {
    final wordSet = buildSet();
    await tester.pumpWidget(
      MaterialApp(
        home: McQuizScreen(wordSet: wordSet, questions: wordSet.words),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('hello'), findsOneWidget);
    await tester.tap(find.text('你好'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Next'), findsOneWidget);

    await tester.fling(find.text('hello'), const Offset(-300, 0), 800);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('hello'), findsNothing);
  });

  testWidgets('swipe-left before answering does nothing', (tester) async {
    final wordSet = buildSet();
    await tester.pumpWidget(
      MaterialApp(
        home: McQuizScreen(wordSet: wordSet, questions: wordSet.words),
      ),
    );
    await tester.pumpAndSettle();

    await tester.fling(find.text('hello'), const Offset(-300, 0), 800);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('swipe-right pops back to the previous screen', (tester) async {
    final wordSet = buildSet();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Settings Screen'),
            ),
          ),
        ),
      ),
    );

    final navigatorState = tester.state<NavigatorState>(
      find.byType(Navigator),
    );
    navigatorState.push(
      MaterialPageRoute(
        builder: (_) => McQuizScreen(wordSet: wordSet, questions: wordSet.words),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('hello'), findsOneWidget);

    await tester.fling(find.text('hello'), const Offset(300, 0), 800);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Settings Screen'), findsOneWidget);
  });
}
