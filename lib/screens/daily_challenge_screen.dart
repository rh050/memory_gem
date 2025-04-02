import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/gematria.dart';
import '../utils/words.dart';
import '../models/game_progress.dart';
import '../services/game_progress_manager.dart';
import '../services/achievement_manager.dart';

class DailyChallengeScreen extends StatefulWidget {
  final String language; // 'Hebrew' or 'English'
  const DailyChallengeScreen({super.key, required this.language});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  bool hasPlayedToday = false;
  String word = '';
  final TextEditingController _controller = TextEditingController();
  String message = '';
  bool completed = false;
  GameProgress? progress;

  static const String _dailySuccessKey = 'daily_success_count';

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    progress = await GameProgressManager.load();
    await _checkIfPlayedToday();
  }

  Future<void> _checkIfPlayedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastPlayed = prefs.getString('daily_challenge_date');

    if (lastPlayed == today) {
      setState(() {
        hasPlayedToday = true;
      });
    } else {
      _generateWord();
    }
  }

  Future<void> _markAsPlayedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString('daily_challenge_date', today);
  }

  void _generateWord() {
    final random = Random();
    final words = widget.language == 'Hebrew' ? hebrewWords : englishWords;
    setState(() {
      word = words[random.nextInt(words.length)];
    });
  }

  void _submitAnswer() async {
    if (completed) return;
    final answer = int.tryParse(_controller.text.trim());
    final correct = calculateGematria(word, widget.language);

    if (answer == correct) {
      setState(() {
        message = "✔ תשובה נכונה! קיבלת רמז נוסף 🎁";
        completed = true;
      });
      _markAsPlayedToday();
      _incrementDailySuccess();

      if (progress != null) {
        progress!.hintsRemaining += 1;
        await GameProgressManager.save(progress!);
      }
    } else {
      setState(() {
        message = "❌ לא נכון. נסה שוב!";
      });
    }
  }

  Future<void> _incrementDailySuccess() async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt(_dailySuccessKey) ?? 0;
    count += 1;
    await prefs.setInt(_dailySuccessKey, count);

    if (count >= 3) {
      await AchievementManager.unlock('daily_3');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('אתגר יומי')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: hasPlayedToday
            ? Center(
          child: Text(
            'כבר שיחקת היום!\nחזור מחר לאתגר חדש 🙂',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.language == 'Hebrew'
                  ? 'חשב את הערך הגימטרי של המילה:'
                  : 'Calculate the gematria value of this word:',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              word,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: widget.language == 'Hebrew' ? 'התשובה שלך' : 'Your answer',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAnswer,
              child: Text(widget.language == 'Hebrew' ? 'שלח תשובה' : 'Submit'),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: message.startsWith('✔') ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}