import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth/auth_provider.dart';
import 'app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // יוצרים את SettingsProvider ומטעינים את ההגדרות מה־SharedPreferences
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('he')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: settingsProvider.locale, // 🆕 התחלה לפי הגדרת המשתמש
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()..checkCurrentUser()),
          ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ],
        child: const MemoryGemApp(),
      ),
    ),
  );
}

class MemoryGemApp extends StatelessWidget {
  const MemoryGemApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: settings.textScale, // שימוש בהגדרת טקסט קסטום
      ),
      child: MaterialApp.router(
        title: tr('app_title'),
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        theme: ThemeData(
          brightness: settings.isDarkMode ? Brightness.dark : Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: settings.isDarkMode ? Brightness.dark : Brightness.light,
          ),
          // שימוש בערכת טקסט שתותאם למצב (dark/light)
          textTheme: settings.isDarkMode
              ? GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme)
              : GoogleFonts.robotoTextTheme(ThemeData.light().textTheme),
          useMaterial3: true,
        ),
      ),
    );
  }
}
