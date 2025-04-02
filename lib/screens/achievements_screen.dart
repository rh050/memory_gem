import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as flutter;



class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> achievements = [
      {
        'icon': Icons.emoji_events,
        'title': tr('achievement_first_level_title'),
        'desc': tr('achievement_first_level_desc'),
        'unlocked': true
      },
      {
        'icon': Icons.favorite,
        'title': tr('achievement_no_mistakes_title'),
        'desc': tr('achievement_no_mistakes_desc'),
        'unlocked': false
      },
      {
        'icon': Icons.school,
        'title': tr('achievement_100_answers_title'),
        'desc': tr('achievement_100_answers_desc'),
        'unlocked': true
      },
    ];

    return Directionality(
      textDirection: context.locale.languageCode == 'he'
          ? flutter.TextDirection.rtl
          : flutter.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('achievements')),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: achievements.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = achievements[index];
            return ListTile(
              tileColor:
              item['unlocked'] ? Colors.green.shade50 : Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              leading: Icon(
                item['icon'],
                color: item['unlocked'] ? Colors.green : Colors.grey,
              ),
              title: Text(item['title']),
              subtitle: Text(item['desc']),
              trailing: Icon(
                item['unlocked'] ? Icons.check_circle : Icons.lock,
                color: item['unlocked'] ? Colors.green : Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }
}