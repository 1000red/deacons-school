import 'package:flutter/material.dart';

/// المستخدم الحالي (تسجيل دخول وهمي محليًا - بدون اتصال بسيرفر).
class AppUser {
  final String name;
  final String email;
  const AppUser({required this.name, required this.email});
}

/// نوع المادة: مواد "بالصوت والصورة" (ألحان + قبطي) مقابل مواد "مذكرة + محتوى".
enum SubjectType { media, notebook }

/// مادة دراسية ثابتة (5 مواد لكل تيرم).
class Subject {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final SubjectType type;
  final String description;

  const Subject({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.description,
  });
}

/// مستوى دراسي (تمهيدي / أول / تاني / تالت).
class Level {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int yearsCount; // 1 للتمهيدي، 3 لباقي المستويات

  const Level({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.yearsCount,
  });
}

/// سنة دراسية داخل مستوى معين.
class YearLevel {
  final String id;
  final String name;
  const YearLevel({required this.id, required this.name});
}

/// ترم دراسي (3 ترمات لكل سنة).
class Term {
  final String id;
  final String name;
  const Term({required this.id, required this.name});
}

/// مسار التنقل الحالي (مستوى > سنة > ترم > مادة) - يُستخدم لعرض الـ breadcrumb
/// ولتوليد محتوى تجريبي مناسب للسياق.
class NavPath {
  final Level level;
  final YearLevel? year;
  final Term term;
  final Subject? subject;

  const NavPath({required this.level, this.year, required this.term, this.subject});

  NavPath copyWith({Subject? subject}) => NavPath(level: level, year: year, term: term, subject: subject ?? this.subject);

  String get breadcrumb {
    final parts = <String>[level.name, if (year != null) year!.name, term.name, if (subject != null) subject!.name];
    return parts.join(' • ');
  }
}

/// عنصر لحن/تسبحة قبطي (مادة من نوع media): صوت + صورة مذكرة + صورة سبورة بالهزات.
class MediaLessonItem {
  final String title;
  final String duration; // مثال: 03:45 (بيانات تجريبية للعرض)
  final bool hasAudio;
  final bool hasNotebookImage;
  final bool hasBoardImage;

  const MediaLessonItem({
    required this.title,
    required this.duration,
    this.hasAudio = true,
    this.hasNotebookImage = true,
    this.hasBoardImage = true,
  });
}

/// وحدة محتوى لمادة من نوع "مذكرة" (طقس / قراءة / محفوظات).
class NotebookLessonItem {
  final String title;
  final String content;
  final int notebookPages;

  const NotebookLessonItem({required this.title, required this.content, required this.notebookPages});
}
