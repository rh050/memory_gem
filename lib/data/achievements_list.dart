import '../models/achievement.dart';

final defaultAchievements = [
  Achievement(
    id: 'first_level',
    title: 'מתחיל גימטריה',
    description: 'סיים שלב ראשון במשחק.',
    achieved: false,
  ),
  Achievement(
    id: 'no_mistakes',
    title: 'ללא טעות',
    description: 'סיים שלב שלם בלי שגיאות.',
    achieved: false,
  ),
  Achievement(
    id: '100_answers',
    title: '100 תשובות',
    description: 'ענה על 100 שאלות בסך הכל.',
    achieved: false,
  ),
  Achievement(
    id: 'daily_3',
    title: 'אתגר יומי מנצח',
    description: 'הצלח 3 אתגרים יומיים.',
    achieved: false,
  ),
];
