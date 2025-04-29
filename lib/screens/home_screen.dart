import 'dart:ui' as flutter;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/game_progress_manager.dart';
import '../models/game_progress.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GameProgress progress;
  bool isLoading = true;
  String playerName = 'Player';

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    playerName = prefs.getString('player_name') ?? 'Player';

    progress = await GameProgressManager.load();
    setState(() => isLoading = false);
  }

  void _changeLanguage(Locale locale) {
    context.setLocale(locale);
    progress.language = locale.languageCode == 'en' ? 'English' : 'Hebrew';
    GameProgressManager.save(progress);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.locale.languageCode == 'he'
          ? flutter.TextDirection.rtl
          : flutter.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('app_title')),
          actions: [
            PopupMenuButton<Locale>(
              icon: const Icon(Icons.language),
              onSelected: _changeLanguage,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                const PopupMenuItem(
                  value: Locale('he'),
                  child: Text('עברית'),
                ),
              ],
            )
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                tr('welcome_back', namedArgs: {'name': playerName}),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/game'),
                child: Text(tr('start_game')),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.push('/tutorial'),
                child: Text(tr('how_to_play')),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.push('/daily'),
                child: Text(tr('daily_challenge')),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.push('/achievements'),
                child: Text(tr('achievements')),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.push('/profile'),
                child: Text(tr('profile')),
              ),
              const SizedBox(height: 12),
              // כפתור להגדרות
              ElevatedButton.icon(
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.settings),
                label: Text(tr('settings')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
