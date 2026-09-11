import 'dart:math';

import 'package:flutter/material.dart';

import '../data/stats_repository.dart';
import '../models/word.dart';
import '../models/word_set.dart';
import '../models/word_stats.dart';
import 'mc_quiz_screen.dart';

class McQuizSetupScreen extends StatefulWidget {
  final WordSet wordSet;

  const McQuizSetupScreen({super.key, required this.wordSet});

  @override
  State<McQuizSetupScreen> createState() => _McQuizSetupScreenState();
}

class _McQuizSetupScreenState extends State<McQuizSetupScreen> {
  final _statsRepository = StatsRepository();
  Map<String, WordStats> _stats = {};
  bool _loading = true;

  bool _shuffleOrder = true;
  bool _filterEnabled = false;
  double _minAccuracyPercent = 80;

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
      if (stat == null || stat.mcTotal == 0) return true;
      return stat.mcAccuracy * 100 < _minAccuracyPercent;
    }).toList();
  }

  void _startQuiz() {
    final pool = List<Word>.of(_eligibleWords);
    if (_shuffleOrder) pool.shuffle(Random());

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => McQuizScreen(wordSet: widget.wordSet, questions: pool),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiple Choice Quiz')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final totalWords = widget.wordSet.words.length;
    final eligibleCount = _eligibleWords.length;

    if (totalWords < 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'This set needs at least 2 words to run a multiple-choice quiz.',
            textAlign: TextAlign.center,
          ),
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
              title: const Text('Practice weak words only'),
              subtitle: const Text(
                'Only include words with a correct rate below X%',
              ),
              value: _filterEnabled,
              onChanged: (v) => setState(() => _filterEnabled = v),
            ),
            if (_filterEnabled) ...[
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _minAccuracyPercent,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: '${_minAccuracyPercent.round()}%',
                      onChanged: (v) =>
                          setState(() => _minAccuracyPercent = v),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text('${_minAccuracyPercent.round()}%'),
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
