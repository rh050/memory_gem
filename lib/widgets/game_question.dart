import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/word_loader.dart';
import '../utils/gematria.dart';

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
  late WordEntry wordEntry;
  final TextEditingController _answerController = TextEditingController();
  bool showHint = false;
  String feedback = '';
  Color feedbackColor = Colors.transparent;
  late AnimationController _animController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadAndGenerateQuestion();
  }

  @override
  void didUpdateWidget(covariant GameQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level || oldWidget.language != widget.language) {
      _loadAndGenerateQuestion();
    }
  }

  Future<void> _loadAndGenerateQuestion() async {
    setState(() => isLoading = true);

    final words = await WordLoader.loadLevel(widget.language, widget.level);
    words.shuffle();

    if (widget.level == 1) {
      final lettersMap = widget.language == 'English'
          ? englishGematriaLetters
          : gematriaLetters;
      final letters = lettersMap.keys.toList();
      final letter = letters[Random().nextInt(letters.length)];
      wordEntry = WordEntry(
        word: letter,
        value: lettersMap[letter] ?? 0,
        level: 1,
      );
    } else {
      wordEntry = words.first;
    }

    _answerController.clear();
    feedback = '';
    feedbackColor = Colors.transparent;
    showHint = false;
    isLoading = false;
    setState(() {});
  }

  void _submitAnswer() {
    final userAnswer = int.tryParse(_answerController.text.trim());
    if (userAnswer == null) return;

    final correctValue = wordEntry.value;
    final isCorrect = userAnswer == correctValue;

    setState(() {
      feedback = isCorrect ? tr('correct') : tr('wrong');
      feedbackColor = isCorrect ? Colors.green : Colors.red;
    });

    _animController.forward(from: 0.0);

    Future.delayed(const Duration(milliseconds: 600), () {
      widget.onAnswer(isCorrect);
      _loadAndGenerateQuestion();
    });
  }

  String getHint() {
    final map = widget.language == 'English' ? englishGematriaLetters : gematriaLetters;
    return wordEntry.word
        .split('')
        .map((l) => "$l=${map[l] ?? 0}")
        .join(' + ');
  }

  @override
  void dispose() {
    _answerController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                wordEntry.word,
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
                    setState(() => showHint = true);
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
      ),
    );
  }
}
