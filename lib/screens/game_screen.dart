import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:memory_gem/models/game_progress.dart';
import 'package:memory_gem/services/game_progress_manager.dart';
import 'package:memory_gem/services/achievement_manager.dart';
import 'package:memory_gem/widgets/game_question.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  static const int questionsPerLevel = 10;
  static const int maxMistakes = 3;

  late GameProgress gameProgress;
  int currentQuestion = 1;
  int mistakes = 0;
  int score = 0;
  int timeLeft = 30;
  int streak = 0;
  bool isLoading = true;
  bool showResult = false;
  Timer? _timer;
  late AnimationController _feedbackController;
  Color feedbackColor = Colors.transparent;
  String feedbackSymbol = '';

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    gameProgress = await GameProgressManager.load();
    _startTimer();
    setState(() => isLoading = false);
  }

  void _startTimer() {
    _timer?.cancel();
    timeLeft = max(10, 30 - gameProgress.currentLevel * 2);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft == 0) {
        timer.cancel();
        _handleGameOver();
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  void _handleAnswer(bool isCorrect) async {
    if (isCorrect) {
      streak++;
      score += 10 * (1 + streak ~/ 3);
      feedbackColor = Colors.green;
      feedbackSymbol = '✔';
    } else {
      mistakes++;
      streak = 0;
      feedbackColor = Colors.red;
      feedbackSymbol = '✘';
      if (mistakes >= maxMistakes) {
        _handleGameOver();
        return;
      }
    }

    _feedbackController.forward(from: 0);

    if (currentQuestion >= questionsPerLevel) {
      Future.delayed(const Duration(milliseconds: 600), _handleGameOver);
    } else {
      setState(() {
        currentQuestion++;
        _startTimer();
      });
    }
  }

  Future<void> _handleGameOver() async {
    _timer?.cancel();

    final accuracy = ((questionsPerLevel - mistakes) / questionsPerLevel) * 100;
    final passedLevel = accuracy >= 70;

    if (passedLevel) {
      gameProgress.currentLevel++;
      gameProgress.score += score;
      gameProgress.highestStreak = max(gameProgress.highestStreak, streak);
      gameProgress.correctAnswers += (questionsPerLevel - mistakes);
      gameProgress.totalAnswers += questionsPerLevel;

      await GameProgressManager.save(gameProgress);

      if (gameProgress.currentLevel == 2) {
        await AchievementManager.unlock('first_level');
      }
      if (mistakes == 0) {
        await AchievementManager.unlock('no_mistakes');
      }
      if (gameProgress.totalAnswers >= 100) {
        await AchievementManager.unlock('100_answers');
      }
    }

    setState(() => showResult = true);
  }

  void _restartLevel() {
    setState(() {
      currentQuestion = 1;
      mistakes = 0;
      score = 0;
      streak = 0;
      showResult = false;
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (showResult) {
      return Scaffold(
        appBar: AppBar(title: const Text('תוצאה')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('רמה ${gameProgress.currentLevel - 1} הושלמה!',
                  style: const TextStyle(fontSize: 24)),
              Text('ניקוד: $score'),
              Text('Streak: $streak'),
              Text('טעויות: $mistakes'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _restartLevel,
                child: const Text('נסה שוב'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('רמה ${gameProgress.currentLevel}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(child: Text('⏱ $timeLeft')),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('שאלה $currentQuestion מתוך $questionsPerLevel'),
                    Row(
                      children: List.generate(maxMistakes, (index) {
                        if (index < (maxMistakes - mistakes)) {
                          return const Icon(Icons.favorite, color: Colors.red);
                        } else {
                          return const Icon(Icons.favorite_border, color: Colors.red);
                        }
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (currentQuestion - 1) / questionsPerLevel,
                ),
                const SizedBox(height: 20),
                GameQuestion(
                  level: gameProgress.currentLevel,
                  language: gameProgress.language,
                  hintsRemaining: gameProgress.hintsRemaining,
                  onAnswer: _handleAnswer,
                  onUseHint: () {
                    setState(() {
                      if (gameProgress.hintsRemaining > 0) {
                        gameProgress.hintsRemaining--;
                      }
                    });
                    GameProgressManager.save(gameProgress);
                  },
                ),
              ],
            ),
          ),
          Center(
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _feedbackController,
                curve: Curves.easeOut,
              ),
              child: Text(
                feedbackSymbol,
                style: TextStyle(fontSize: 64, color: feedbackColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
