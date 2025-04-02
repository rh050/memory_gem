import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  Locale? selectedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedLocale = context.locale;
  }

  Future<void> _setLanguage(Locale locale) async {
    await context.setLocale(locale);
    setState(() {
      selectedLocale = locale;
    });
    final languageString = locale.languageCode == 'he' ? 'Hebrew' : 'English';
    context.go('/home', extra: languageString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr("select_language"))),
      body: ListView(
        children: [
          ListTile(
            title: const Text('English'),
            trailing: selectedLocale?.languageCode == 'en' ? const Icon(Icons.check) : null,
            onTap: () => _setLanguage(const Locale('en')),
          ),
          ListTile(
            title: const Text('עברית'),
            trailing: selectedLocale?.languageCode == 'he' ? const Icon(Icons.check) : null,
            onTap: () => _setLanguage(const Locale('he')),
          ),
        ],
      ),
    );
  }
}
