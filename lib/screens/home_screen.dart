import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/set_repository.dart';
import '../models/word_set.dart';
import 'flashcard_screen.dart';
import 'mc_quiz_setup_screen.dart';
import 'typing_quiz_setup_screen.dart';

const _currentSetPrefKey = 'current_set_id';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = SetRepository();
  List<WordSet> _sets = [];
  WordSet? _currentSet;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final sets = await _repository.loadAllSets();
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(_currentSetPrefKey);

      WordSet? selected;
      if (savedId != null) {
        for (final s in sets) {
          if (s.id == savedId) selected = s;
        }
      }
      selected ??= sets.isNotEmpty ? sets.first : null;

      setState(() {
        _sets = sets;
        _currentSet = selected;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _selectSet(WordSet set) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentSetPrefKey, set.id);
    setState(() => _currentSet = set);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chinese Study')),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Failed to load sets:\n$_error'));
    }
    if (_sets.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No flashcard sets found.\n\n'
            'Add a "name.tsv" file (word<TAB>definition per line) to '
            'assets/sets/ and rebuild the app.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final currentSet = _currentSet!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Current set', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<WordSet>(
            initialValue: currentSet,
            isExpanded: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _sets
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text('${s.displayName} (${s.words.length} words)'),
                  ),
                )
                .toList(),
            onChanged: (s) {
              if (s != null) _selectSet(s);
            },
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            icon: const Icon(Icons.style),
            label: const Text('Flashcards'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FlashcardScreen(wordSet: currentSet),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.quiz),
            label: const Text('Multiple Choice Quiz'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => McQuizSetupScreen(wordSet: currentSet),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.keyboard),
            label: const Text('Typing Quiz'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TypingQuizSetupScreen(wordSet: currentSet),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
