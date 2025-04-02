import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:memory_gem/models/game_progress.dart';
import 'package:memory_gem/services/game_progress_manager.dart';

class PlayerStatsScreen extends StatefulWidget {
  const PlayerStatsScreen({super.key});

  @override
  State<PlayerStatsScreen> createState() => _PlayerStatsScreenState();
}

class _PlayerStatsScreenState extends State<PlayerStatsScreen> {
  GameProgress? progress;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final loaded = await GameProgressManager.load();
    setState(() {
      progress = loaded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Player Stats'.tr())),
      body: progress == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            _statTile(tr('level', args: ['${progress!.currentLevel}']), Icons.star),
            _statTile(tr('score', namedArgs: {'score': '${progress!.score}'}), Icons.grade),
            _statTile('Highest Streak: ${progress!.highestStreak}', Icons.bolt),
            _statTile('Total Answers: ${progress!.totalAnswers}', Icons.list),
            _statTile('Correct Answers: ${progress!.correctAnswers}', Icons.check),
            _statTile('Hints Remaining: ${progress!.hintsRemaining}', Icons.help_outline),
            const Divider(height: 32),
            _statTile('Accuracy: ${_calculateAccuracy().toStringAsFixed(1)}%', Icons.analytics),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }

  double _calculateAccuracy() {
    if (progress!.totalAnswers == 0) return 0.0;
    return (progress!.correctAnswers / progress!.totalAnswers) * 100;
  }
}
