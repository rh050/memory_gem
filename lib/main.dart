import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app_router.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('he')],
      path: 'assets/translations', // נתיב לקבצי התרגום
      fallbackLocale: const Locale('en'),
      child: const MemoryGemApp(),
    ),
  );
}

class MemoryGemApp extends StatelessWidget {
  const MemoryGemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: tr('app_title'),
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
    );
  }
}
