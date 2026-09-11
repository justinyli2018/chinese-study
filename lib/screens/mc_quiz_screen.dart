import 'dart:math';

import 'package:flutter/material.dart';

import '../data/stats_repository.dart';
import '../models/word.dart';
import '../models/word_set.dart';
import 'mc_quiz_result_screen.dart';

class McQuizScreen extends StatefulWidget {
  final WordSet wordSet;
  final List<Word> questions;

  const McQuizScreen({
    super.key,
    required this.wordSet,
    required this.questions,
  });

  @override
  State<McQuizScreen> createState() => _McQuizScreenState();
}

class _McQuizScreenState extends State<McQuizScreen> {
  final _statsRepository = StatsRepository();
  final _random = Random();

  int _questionIndex = 0;
  int _correctCount = 0;
  late List<Word> _choices;
  Word? _selected;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _buildChoicesForCurrentQuestion();
  }

  Word get _currentQuestion => widget.questions[_questionIndex];

  void _buildChoicesForCurrentQuestion() {
    final correct = _currentQuestion;
    final distractPool = widget.wordSet.words
        .where((w) => w.statKey != correct.statKey)
        .toList()
      ..shuffle(_random);

    final choiceCount = min(4, widget.wordSet.words.length);
    final distractors = distractPool.take(choiceCount - 1).toList();

    _choices = [correct, ...distractors]..shuffle(_random);
    _selected = null;
    _answered = false;
  }

  Future<void> _selectChoice(Word choice) async {
    if (_answered) return;
    final correct = choice.statKey == _currentQuestion.statKey;
    setState(() {
      _selected = choice;
      _answered = true;
      if (correct) _correctCount++;
    });
    await _statsRepository.recordMultipleChoice(
      widget.wordSet.id,
      _currentQuestion.statKey,
      correct,
    );
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    const threshold = 200.0;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity <= -threshold) {
      if (_answered) _next();
    } else if (velocity >= threshold) {
      Navigator.of(context).maybePop();
    }
  }

  void _next() {
    if (_questionIndex + 1 >= widget.questions.length) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => McQuizResultScreen(
            wordSet: widget.wordSet,
            correctCount: _correctCount,
            totalCount: widget.questions.length,
          ),
        ),
      );
      return;
    }
    setState(() {
      _questionIndex++;
      _buildChoicesForCurrentQuestion();
    });
  }

  Color? _colorFor(Word choice) {
    if (!_answered) return null;
    if (choice.statKey == _currentQuestion.statKey) {
      return Colors.green.shade200;
    }
    if (choice.statKey == _selected?.statKey) return Colors.red.shade200;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _questionIndex + 1 >= widget.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${_questionIndex + 1} / ${widget.questions.length}',
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              // Guarantees the gesture-detecting column always spans at
              // least the full screen height, so swipes work in any blank
              // space below the content too - not just on top of it.
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: IntrinsicHeight(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragEnd: _handleHorizontalSwipe,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Score: $_correctCount / ${_questionIndex + (_answered ? 1 : 0)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _currentQuestion.definition,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._choices.map(
                        (choice) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _colorFor(choice),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onPressed: () => _selectChoice(choice),
                              child: Text(
                                choice.hanzi,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 12),
                      if (_answered)
                        FilledButton(
                          onPressed: _next,
                          child: Text(isLast ? 'Finish' : 'Next'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
