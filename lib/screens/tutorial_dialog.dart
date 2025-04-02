import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/gematria.dart';

class TutorialDialog extends StatelessWidget {
  const TutorialDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final String language = context.locale.languageCode == 'he' ? 'Hebrew' : 'English';

    final Map<String, int> lettersMap =
    language == 'English' ? englishGematriaLetters : gematriaLetters;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr('how_to_play'),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(tr('tutorial_description')),
            const SizedBox(height: 24),
            Text(tr('gematria_table'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: lettersMap.entries
                      .map((entry) => Chip(
                    label: Text("${entry.key} = ${entry.value}"),
                  ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(tr('got_it')),
            )
          ],
        ),
      ),
    );
  }
}
