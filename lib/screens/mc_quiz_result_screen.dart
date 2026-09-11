import 'package:flutter/material.dart';

import '../models/word_set.dart';
import 'mc_quiz_setup_screen.dart';

class McQuizResultScreen extends StatelessWidget {
  final WordSet wordSet;
  final int correctCount;
  final int totalCount;

  const McQuizResultScreen({
    super.key,
    required this.wordSet,
    required this.correctCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final percent = totalCount == 0
        ? 0
        : (correctCount / totalCount * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Complete')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Score', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                '$correctCount / $totalCount',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '$percent%',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 40),
              FilledButton.icon(
                icon: const Icon(Icons.replay),
                label: const Text('New Round'),
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => McQuizSetupScreen(wordSet: wordSet),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
