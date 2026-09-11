import 'package:flutter/material.dart';

import '../data/stats_repository.dart';
import '../models/word.dart';
import '../models/word_set.dart';
import '../models/word_stats.dart';

class WordStatsScreen extends StatefulWidget {
  final WordSet wordSet;

  const WordStatsScreen({super.key, required this.wordSet});

  @override
  State<WordStatsScreen> createState() => _WordStatsScreenState();
}

class _WordStatsScreenState extends State<WordStatsScreen> {
  final _statsRepository = StatsRepository();
  Map<String, WordStats> _stats = {};
  bool _loading = true;

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

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all stats?'),
        content: Text(
          'This clears the multiple-choice and typing accuracy history for '
          'all ${widget.wordSet.words.length} words in '
          '"${widget.wordSet.displayName}". This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _statsRepository.clearSet(widget.wordSet.id);
    if (!mounted) return;
    setState(() => _stats = {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All stats cleared for this set.')),
    );
  }

  Future<void> _resetWord(Word word) async {
    final previous = _stats[word.statKey];
    setState(() => _stats.remove(word.statKey));
    await _statsRepository.clearWord(widget.wordSet.id, word.statKey);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reset stats for "${word.hanzi}".'),
        action: previous == null
            ? null
            : SnackBarAction(
                label: 'Undo',
                onPressed: () async {
                  await _statsRepository.setWordStats(
                    widget.wordSet.id,
                    word.statKey,
                    previous,
                  );
                  if (mounted) {
                    setState(() => _stats[word.statKey] = previous);
                  }
                },
              ),
      ),
    );
  }

  String _ratioText(int correct, int total) {
    if (total == 0) return 'No attempts yet';
    final percent = (correct / total * 100).round();
    return '$correct / $total ($percent%)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stats: ${widget.wordSet.displayName}'),
        actions: [
          IconButton(
            tooltip: 'Clear all stats for this set',
            icon: const Icon(Icons.delete_sweep),
            onPressed: _loading ? null : _confirmClearAll,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.wordSet.words.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final word = widget.wordSet.words[index];
                final stat = _stats[word.statKey];
                final hasStats =
                    stat != null && (stat.mcTotal > 0 || stat.tqTotal > 0);

                return ListTile(
                  title: Text('${word.hanzi} — ${word.definition}'),
                  isThreeLine: true,
                  subtitle: Text(
                    'Multiple choice: '
                    '${_ratioText(stat?.mcCorrect ?? 0, stat?.mcTotal ?? 0)}\n'
                    'Typing: '
                    '${_ratioText(stat?.tqCorrect ?? 0, stat?.tqTotal ?? 0)}',
                  ),
                  trailing: IconButton(
                    tooltip: "Reset this word's stats",
                    icon: const Icon(Icons.refresh),
                    onPressed: hasStats ? () => _resetWord(word) : null,
                  ),
                );
              },
            ),
    );
  }
}
