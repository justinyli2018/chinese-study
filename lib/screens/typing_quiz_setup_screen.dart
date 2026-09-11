import 'dart:math';

import 'package:flutter/material.dart';

import '../data/stats_repository.dart';
import '../models/word.dart';
import '../models/word_set.dart';
import '../models/word_stats.dart';
import 'typing_quiz_screen.dart';

class TypingQuizSetupScreen extends StatefulWidget {
  final WordSet wordSet;

  const TypingQuizSetupScreen({super.key, required this.wordSet});

  @override
  State<TypingQuizSetupScreen> createState() => _TypingQuizSetupScreenState();
}

class _TypingQuizSetupScreenState extends State<TypingQuizSetupScreen> {
  final _statsRepository = StatsRepository();
  Map<String, WordStats> _stats = {};
  bool _loading = true;

  bool _shuffleOrder = true;
  bool _filterEnabled = false;
  double _maxErrorRatePercent = 50;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await _statsRepository.loadForSet(widget.wordSet.id);
    setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  List<Word> get _eligibleWords {
    if (!_filterEnabled) return widget.wordSet.words;
    return widget.wordSet.words.where((w) {
      final stat = _stats[w.statKey];
      if (stat == null || stat.tqTotal == 0) return true;
      return stat.tqErrorRate * 100 < _maxErrorRatePercent;
    }).toList();
  }

  void _startQuiz() {
    final pool = List<Word>.of(_eligibleWords);
    if (_shuffleOrder) pool.shuffle(Random());

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            TypingQuizScreen(wordSet: widget.wordSet, questions: pool),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Typing Quiz')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final totalWords = widget.wordSet.words.length;
    final eligibleCount = _eligibleWords.length;

    if (totalWords < 1) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('This set has no words.', textAlign: TextAlign.center),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Shuffle question order'),
              subtitle: const Text('Off = same order as the word list'),
              value: _shuffleOrder,
              onChanged: (v) => setState(() => _shuffleOrder = v),
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Filter by error rate'),
              subtitle: const Text(
                'Only include words you get wrong less than X% of the time',
              ),
              value: _filterEnabled,
              onChanged: (v) => setState(() => _filterEnabled = v),
            ),
            if (_filterEnabled) ...[
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _maxErrorRatePercent,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: '${_maxErrorRatePercent.round()}%',
                      onChanged: (v) =>
                          setState(() => _maxErrorRatePercent = v),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text('${_maxErrorRatePercent.round()}%'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text(
              '$eligibleCount of $totalWords words match this quiz.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Quiz'),
              onPressed: eligibleCount >= 1 ? _startQuiz : null,
            ),
          ],
        ),
      ),
    );
  }
}
