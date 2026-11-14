import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// البيانات العرضية (أيقونة + لون) للمستويات والمواد.
///
/// موجودة في طبقة الرسم عشان نماذج البيانات (`Level` / `Subject`)
/// تفضل نظيفة من أي اعتماد على واجهة Flutter.
class CurriculumPresentation {
  const CurriculumPresentation._();

  static const _fallbackIcon = Icons.subject;
  static const _fallbackColor = AppColors.primary;

  static const _levelIcons = <String, IconData>{
    'preparatory': Icons.auto_awesome,
    'first': Icons.looks_one,
    'second': Icons.looks_two,
    'third': Icons.looks_3,
  };

  static const _levelColors = <String, Color>{
    // teal-700 بدل teal-600: النص الأبيض فوقها بيدي تباين 5.5:1 (بيتجاوز
    // معيار AA) بينما teal-600 كان بيدي 3.7:1 فقط.
    'preparatory': Color(0xFF0F766E),
    'first': Color(0xFF2563EB),
    'second': Color(0xFF7C3AED),
    'third': Color(0xFFB45309),
  };

  static const _subjectIcons = <String, IconData>{
    'notebook': Icons.description,
    'rites': Icons.church,
    'coptic': Icons.menu_book_rounded,
    'reading': Icons.auto_stories,
    'memorization': Icons.self_improvement,
    'hymns': Icons.music_note,
  };

  static const _subjectColors = <String, Color>{
    'notebook': Color(0xFFC2410C),
    'rites': Color(0xFF1D4ED8),
    'coptic': Color(0xFF0F766E),
    'reading': Color(0xFF15803D),
    'memorization': Color(0xFFB45309),
    'hymns': Color(0xFF9333EA),
  };

  static IconData levelIcon(String levelId) =>
      _levelIcons[levelId] ?? _fallbackIcon;

  static Color levelColor(String levelId) =>
      _levelColors[levelId] ?? _fallbackColor;

  static IconData subjectIcon(String subjectId) =>
      _subjectIcons[subjectId] ?? _fallbackIcon;

  static Color subjectColor(String subjectId) =>
      _subjectColors[subjectId] ?? _fallbackColor;
}
