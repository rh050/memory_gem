import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/language_screen.dart';
import 'screens/store_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/daily_challenge_screen.dart';
import 'screens/player_stats_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/game', builder: (context, state) => const GameScreen()),
      GoRoute(path: '/language', builder: (context, state) => const LanguageScreen()),
      GoRoute(path: '/store', builder: (context, state) => const StoreScreen()),
      GoRoute(path: '/achievements', builder: (context, state) => const AchievementsScreen()),
      GoRoute(path: '/stats', builder: (context, state) => const PlayerStatsScreen()),
      GoRoute(
        path: '/daily_challenge',
        builder: (context, state) {
          final language = state.extra as String? ?? 'Hebrew';
          return DailyChallengeScreen(language: language);
        },
      ),
    ],
  );
}