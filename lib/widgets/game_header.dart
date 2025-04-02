import 'package:flutter/material.dart';

class GameHeader extends StatelessWidget {
  final int level;
  final int score;
  final int mistakes;
  final int currentQuestion;
  final int totalQuestions;
  final int timeLeft;
  final int maxMistakes;

  const GameHeader({
    super.key,
    required this.level,
    required this.score,
    required this.mistakes,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.timeLeft,
    required this.maxMistakes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Chip(label: Text('Level $level')),
            const SizedBox(width: 8),
            Chip(label: Text('Score: $score')),
            const Spacer(),
            Text(
              'Time: $timeLeft s',
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (currentQuestion - 1) / totalQuestions,
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(maxMistakes, (index) {
            return Icon(
              index < (maxMistakes - mistakes) ? Icons.favorite : Icons.favorite_border,
              color: index < (maxMistakes - mistakes) ? Colors.red : Colors.grey,
            );
          }),
        ),
      ],
    );
  }
}
