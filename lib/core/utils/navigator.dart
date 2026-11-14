import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import '../../features/curriculum/views/screens/levels_screen.dart';
import '../../features/curriculum/views/screens/subjects_screen.dart';
import '../../features/curriculum/views/screens/terms_screen.dart';
import '../../features/curriculum/views/screens/text_subject_screen.dart';
import '../../features/curriculum/views/screens/years_screen.dart';
import '../../features/media/views/screens/hymn_details_screen.dart';
import '../../features/media/views/screens/media_subject_screen.dart';
import '../../features/notebook/views/screens/notebook_pdf_screen.dart';

/// كل انتقالات التطبيق بتتعمه من هنا (تنقّل واحد مركزي).
///
/// كل انتقال بيستخدم `MaterialPageRoute` زي ما كان قبل الـ refactor،
/// يعني الـ back stack بتاع التطبيق ما اتغيرش.
class AppNavigation {
  const AppNavigation._();

  static void navigateToLevelScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LevelsScreen()),
    );
  }

  static void navigateToYearsScreen(BuildContext context, Level level) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => YearsScreen(level: level)),
    );
  }

  static void navigateToTermsScreen(
    BuildContext context,
    Level level,
    YearLevel year,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TermsScreen(level: level, year: year)),
    );
  }

  static void navigateToSubjectsScreen(BuildContext context, NavPath path) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SubjectsScreen(path: path)),
    );
  }

  /// بيفتح الشاشة المناسبة حسب نوع المادة (صوتية / مذكرة / نصية).
  static void openSubject(BuildContext context, NavPath path) {
    final subject = path.subject;
    if (subject == null) return;

    final screen = switch (subject.type) {
      SubjectType.media => MediaSubjectScreen(path: path),
      SubjectType.notebook => NotebookPdfScreen(path: path),
      SubjectType.text => TextSubjectScreen(path: path),
    };

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  /// بيفتح شاشة تفاصيل اللحن المختار (من قائمة الألحان)،
  /// مع تمرير بيانات الدرس نفسه عشان الشاشة تعرض اللحن الصحيح.
  static void navigateToHymnDetails(
    BuildContext context, {
    required NavPath path,
    required MediaLessonItem lesson,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HymnDetailsScreen(path: path, lesson: lesson),
      ),
    );
  }
}
