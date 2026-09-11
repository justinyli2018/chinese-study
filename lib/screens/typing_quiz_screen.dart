import 'package:flutter/material.dart';

import '../data/stats_repository.dart';
import '../models/word.dart';
import '../models/word_set.dart';
import 'typing_quiz_result_screen.dart';

class TypingQuizScreen extends StatefulWidget {
  final WordSet wordSet;
  final List<Word> questions;

  const TypingQuizScreen({
    super.key,
    required this.wordSet,
    required this.questions,
  });

  @override
  State<TypingQuizScreen> createState() => _TypingQuizScreenState();
}

class _TypingQuizScreenState extends State<TypingQuizScreen> {
  final _statsRepository = StatsRepository();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  int _questionIndex = 0;
  int _correctCount = 0;
  bool _answered = false;
  bool _wasCorrect = false;

  Word get _currentQuestion => widget.questions[_questionIndex];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_answered) return;
    final answer = _controller.text.trim();
    if (answer.isEmpty) return;

    final correct = answer == _currentQuestion.hanzi.trim();
    setState(() {
      _answered = true;
      _wasCorrect = correct;
      if (correct) _correctCount++;
    });
    await _statsRepository.recordTyping(
      widget.wordSet.id,
      _currentQuestion.statKey,
      correct,
    );
  }

  void _next() {
    if (_questionIndex + 1 >= widget.questions.length) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TypingQuizResultScreen(
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
      _answered = false;
      _wasCorrect = false;
      _controller.clear();
    });
    _focusNode.requestFocus();
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
        child: Padding(
          padding: const EdgeInsets.all(24),
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
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                enabled: !_answered,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Type the Chinese word',
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              if (_answered)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _wasCorrect
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _wasCorrect ? 'Correct!' : 'Not quite.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (!_wasCorrect) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Correct answer: ${_currentQuestion.hanzi}',
                          style: const TextStyle(fontSize: 22),
                        ),
                      ],
                    ],
                  ),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _answered ? _next : _submit,
                child: Text(
                  _answered ? (isLast ? 'Finish' : 'Next') : 'Submit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
