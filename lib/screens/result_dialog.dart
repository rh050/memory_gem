import 'package:flutter/material.dart';

class ResultDialog extends StatelessWidget {
  final int score;
  final int mistakes;
  final int level;
  final VoidCallback onPlayAgain;
  final VoidCallback onGoHome;

  const ResultDialog({
    super.key,
    required this.score,
    required this.mistakes,
    required this.level,
    required this.onPlayAgain,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    double accuracy = ((10 - mistakes) / 10) * 100;
    bool passed = accuracy >= 70;

    return Scaffold(
      body: Center(
        child: AlertDialog(
          title: Text(
            'Level $level ${passed ? 'Completed! 🎉' : 'Failed'}',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Score: $score', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 10),
              Text('Accuracy: ${accuracy.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 18)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: onPlayAgain,
              child: const Text('Play Again'),
            ),
            TextButton(
              onPressed: onGoHome,
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
