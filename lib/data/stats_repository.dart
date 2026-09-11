import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/word_stats.dart';

/// Persists per-word, per-set accuracy stats (multiple-choice and typing
/// quiz) to on-device storage. Words are keyed by [Word.statKey] so stats
/// survive reordering/insertion in the source TSV file.
class StatsRepository {
  static const _prefsKey = 'word_stats_v1';

  Future<Map<String, Map<String, WordStats>>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return {};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (setId, wordsJson) => MapEntry(
        setId,
        (wordsJson as Map<String, dynamic>).map(
          (wordKey, statJson) => MapEntry(
            wordKey,
            WordStats.fromJson(statJson as Map<String, dynamic>),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAll(Map<String, Map<String, WordStats>> all) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = all.map(
      (setId, words) => MapEntry(
        setId,
        words.map((wordKey, stat) => MapEntry(wordKey, stat.toJson())),
      ),
    );
    await prefs.setString(_prefsKey, jsonEncode(encoded));
  }

  Future<Map<String, WordStats>> loadForSet(String setId) async {
    final all = await _loadAll();
    return all[setId] ?? {};
  }

  Future<void> recordMultipleChoice(
    String setId,
    String wordKey,
    bool correct,
  ) async {
    final all = await _loadAll();
    final setStats = all.putIfAbsent(setId, () => {});
    final stat = setStats.putIfAbsent(wordKey, WordStats.new);
    stat.mcTotal += 1;
    if (correct) stat.mcCorrect += 1;
    await _saveAll(all);
  }

  Future<void> recordTyping(
    String setId,
    String wordKey,
    bool correct,
  ) async {
    final all = await _loadAll();
    final setStats = all.putIfAbsent(setId, () => {});
    final stat = setStats.putIfAbsent(wordKey, WordStats.new);
    stat.tqTotal += 1;
    if (correct) stat.tqCorrect += 1;
    await _saveAll(all);
  }
}
