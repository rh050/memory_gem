import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/gematria.dart';
import '../utils/words.dart';

class GameQuestion extends StatefulWidget {
  final int level;
  final String language; // 'Hebrew' or 'English'
  final Function(bool) onAnswer;
  final int hintsRemaining;
  final VoidCallback? onUseHint;

  const GameQuestion({
    Key? key,
    required this.level,
    required this.language,
    required this.onAnswer,
    this.hintsRemaining = 0,
    this.onUseHint,
  }) : super(key: key);

  @override
  State<GameQuestion> createState() => _GameQuestionState();
}

class _GameQuestionState extends State<GameQuestion> with SingleTickerProviderStateMixin {
  late String word;
  final TextEditingController _answerController = TextEditingController();
  bool showHint = false;
  String feedback = '';
  Color feedbackColor = Colors.transparent;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _generateQuestion();
  }

  @override
  void didUpdateWidget(covariant GameQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level || oldWidget.language != widget.language) {
      _generateQuestion();
    }
  }

  void _generateQuestion() {
    final random = Random();
    final words = widget.language == 'English' ? englishWords : hebrewWords;

    if (widget.level == 1) {
      final lettersMap = widget.language == 'English'
          ? englishGematriaLetters
          : gematriaLetters;
      final letters = lettersMap.keys.toList();
      final letter = letters[random.nextInt(letters.length)];
      word = letter;
    } else {
      word = words[random.nextInt(words.length)];
    }

    _answerController.clear();
    feedback = '';
    feedbackColor = Colors.transparent;
    showHint = false;
    setState(() {});
  }

  void _submitAnswer() {
    final userAnswer = int.tryParse(_answerController.text.trim());
    if (userAnswer == null) return;

    final correctValue = calculateGematria(word, widget.language);
    final isCorrect = userAnswer == correctValue;

    if (isCorrect) {
      feedback = tr('correct');
      feedbackColor = Colors.green;
    } else {
      feedback = tr('wrong');
      feedbackColor = Colors.red;
    }

    _animController.forward(from: 0.0);

    Future.delayed(const Duration(milliseconds: 600), () {
      widget.onAnswer(isCorrect);
      _generateQuestion();
    });
  }

  String getHint() {
    final map = widget.language == 'English' ? englishGematriaLetters : gematriaLetters;
    return word.split('').map((l) => "$l=${map[l]}").join(' + ');
  }

  @override
  void dispose() {
    _answerController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              word,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _answerController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: tr('your_answer')),
                    onSubmitted: (_) => _submitAnswer(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _submitAnswer,
                  child: Text(tr('submit')),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.hintsRemaining > 0 && !showHint)
              TextButton(
                onPressed: () {
                  setState(() {
                    showHint = true;
                  });
                  if (widget.onUseHint != null) widget.onUseHint!();
                },
                child: Text(tr('use_hint', namedArgs: {'count': '${widget.hintsRemaining}'})),
              ),
            if (showHint)
              Text(
                getHint(),
                style: const TextStyle(fontFamily: 'monospace', color: Colors.orange),
              ),
            const SizedBox(height: 12),
            ScaleTransition(
              scale: Tween<double>(begin: 0.0, end: 1.0).animate(_animController),
              child: Text(
                feedback,
                style: TextStyle(fontSize: 32, color: feedbackColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
