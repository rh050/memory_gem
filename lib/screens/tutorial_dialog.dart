import 'package:flutter/material.dart';
import '../utils/gematria.dart';

class TutorialDialog extends StatelessWidget {
  final String language; // 'Hebrew' or 'English'

  const TutorialDialog({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final letterMap = language == 'Hebrew' ? gematriaLetters : englishGematriaLetters;

    return AlertDialog(
      title: Text(language == 'Hebrew' ? 'איך משחקים' : 'How to Play'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language == 'Hebrew'
                ? 'מטרת המשחק: לחשב את ערך הגימטריה של מילה או אות.'
                : 'Goal: Calculate the gematria value of a letter or word.'),
            const SizedBox(height: 16),
            Text(language == 'Hebrew' ? 'טבלת גימטריה:' : 'Gematria Table:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: letterMap.entries.map((entry) {
                return Chip(
                  label: Text("${entry.key} = ${entry.value}"),
                  backgroundColor: Colors.grey.shade200,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(language == 'Hebrew'
                ? 'ענה על כמה שיותר שאלות נכון, השתמש ברמזים בעת הצורך, ואל תטעה יותר מדי!'
                : 'Answer as many questions as you can correctly, use hints if needed, and avoid too many mistakes!'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(language == 'Hebrew' ? 'הבנתי' : 'Got it'),
        )
      ],
    );
  }
}
