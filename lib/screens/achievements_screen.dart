import 'package:flutter/material.dart';
import '../services/achievement_manager.dart';
import '../models/achievement.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> achievements = [];

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final list = await AchievementManager.load();
    setState(() {
      achievements = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('הישגים')),
      body: ListView.separated(
        itemCount: achievements.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final a = achievements[index];
          return ListTile(
            leading: Icon(
              a.achieved ? Icons.emoji_events : Icons.lock,
              color: a.achieved ? Colors.amber : Colors.grey,
            ),
            title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(a.description),
          );
        },
      ),
    );
  }
}
