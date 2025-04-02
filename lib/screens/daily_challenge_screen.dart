import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as flutter;


class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  final TextEditingController _controller = TextEditingController();
  late String question;
  late int correctAnswer;
  String feedback = '';
  late String language;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      language = context.locale.languageCode == 'he' ? 'Hebrew' : 'English';
      _generateQuestion();
      _initialized = true;
    }
  }

  void _generateQuestion() {
    final Random random = Random();
    final int a = random.nextInt(10) + 1;
    final int b = random.nextInt(10) + 1;
    question = "$a + $b";
    correctAnswer = a + b;
    feedback = '';
    _controller.clear();
    setState(() {});
  }

  void _checkAnswer() {
    final int? userAnswer = int.tryParse(_controller.text.trim());
    if (userAnswer == correctAnswer) {
      setState(() {
        feedback = tr('correct');
      });
    } else {
      setState(() {
        feedback = tr('wrong');
      });
    }
    Future.delayed(const Duration(seconds: 1), _generateQuestion);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.locale.languageCode == 'he'
          ? flutter.TextDirection.rtl
          : flutter.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('daily_challenge')),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(tr('daily_challenge_desc')),
              const SizedBox(height: 24),
              Text(
                tr('question_colon', namedArgs: {'q': question}),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: tr('your_answer')),
                onSubmitted: (_) => _checkAnswer(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkAnswer,
                child: Text(tr('submit')),
              ),
              const SizedBox(height: 16),
              Text(
                feedback,
                style: TextStyle(
                  fontSize: 20,
                  color: feedback == tr('correct') ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
