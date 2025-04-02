class GameProgress {
  int currentLevel;
  int score;
  int streak;
  int highestStreak;
  int totalAnswers;
  int correctAnswers;
  int hintsRemaining;
  String language; // 🆕 שדה חדש

  GameProgress({
    required this.currentLevel,
    required this.score,
    required this.streak,
    required this.highestStreak,
    required this.totalAnswers,
    required this.correctAnswers,
    required this.hintsRemaining,
    required this.language, // 🆕 הוסף כאן
  });

  factory GameProgress.initial() {
    return GameProgress(
      currentLevel: 1,
      score: 0,
      streak: 0,
      highestStreak: 0,
      totalAnswers: 0,
      correctAnswers: 0,
      hintsRemaining: 3,
      language: 'Hebrew', // 🆕 ברירת מחדל
    );
  }

  Map<String, dynamic> toJson() => {
    'currentLevel': currentLevel,
    'score': score,
    'streak': streak,
    'highestStreak': highestStreak,
    'totalAnswers': totalAnswers,
    'correctAnswers': correctAnswers,
    'hintsRemaining': hintsRemaining,
    'language': language, // 🆕
  };

  factory GameProgress.fromJson(Map<String, dynamic> json) {
    return GameProgress(
      currentLevel: json['currentLevel'] ?? 1,
      score: json['score'] ?? 0,
      streak: json['streak'] ?? 0,
      highestStreak: json['highestStreak'] ?? 0,
      totalAnswers: json['totalAnswers'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      hintsRemaining: json['hintsRemaining'] ?? 3,
      language: json['language'] ?? 'Hebrew', // 🆕
    );
  }
}
