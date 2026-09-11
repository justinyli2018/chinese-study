/// Cumulative accuracy for one word, across all multiple-choice (mc) and
/// typing-quiz (tq) attempts, persisted across app restarts.
class WordStats {
  int mcCorrect;
  int mcTotal;
  int tqCorrect;
  int tqTotal;

  WordStats({
    this.mcCorrect = 0,
    this.mcTotal = 0,
    this.tqCorrect = 0,
    this.tqTotal = 0,
  });

  /// Fraction of multiple-choice attempts answered correctly, in [0, 1].
  /// Words with no attempts yet report 0, so a "practice words below X%"
  /// filter includes never-seen words by default.
  double get mcAccuracy => mcTotal == 0 ? 0.0 : mcCorrect / mcTotal;

  /// Fraction of typing-quiz attempts answered correctly, in [0, 1].
  double get tqAccuracy => tqTotal == 0 ? 0.0 : tqCorrect / tqTotal;

  Map<String, dynamic> toJson() => {
        'mc': mcCorrect,
        'mt': mcTotal,
        'tc': tqCorrect,
        'tt': tqTotal,
      };

  factory WordStats.fromJson(Map<String, dynamic> json) => WordStats(
        mcCorrect: json['mc'] as int? ?? 0,
        mcTotal: json['mt'] as int? ?? 0,
        tqCorrect: json['tc'] as int? ?? 0,
        tqTotal: json['tt'] as int? ?? 0,
      );
}
