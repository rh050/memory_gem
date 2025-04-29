import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as flutter;
import '../auth/auth_provider.dart';

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
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _generateChallenge();
      _initialized = true;
    }
  }

  int _getSeedForToday(String uid) {
    final now = DateTime.now();
    final dateHash = int.parse(
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}");
    return uid.hashCode ^ dateHash;
  }

  void _generateChallenge() {
    final profile = context.read<AuthProvider>().profile!;
    final level = profile.level;
    final uid = profile.uid;
    final seed = _getSeedForToday(uid);
    final rand = Random(seed);

    final int a = rand.nextInt(10 + level * 5);
    final int b = rand.nextInt(10 + level * 5);

    question = "$a + $b";
    correctAnswer = a + b;
    feedback = '';
    _controller.clear();
    setState(() {});
  }

  void _checkAnswer() async {
    final int? userAnswer = int.tryParse(_controller.text.trim());
    final auth = context.read<AuthProvider>();

    if (userAnswer == correctAnswer) {
      setState(() => feedback = tr('correct'));
      await auth.userDataService.updateUserFields(auth.user!.uid, {
        'dailyCompleted': true,
        'points': auth.profile!.points + 10,
      });

      auth.profile = auth.profile!.copyWith(
        dailyCompleted: true,
        points: auth.profile!.points + 10,
      );

      await auth.userDataService.saveProfileToPrefs(auth.profile!);
    } else {
      setState(() => feedback = tr('wrong'));
    }

    Future.delayed(const Duration(seconds: 1), _generateChallenge);
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
