import 'package:flutter/material.dart';

class AppUser {
  final String email;
  final String name;
  const AppUser({required this.name, required this.email});
}

enum SubjectType {
  media, // PDF + Audio
  notebook, // PDF
  text, //text from json
}

class Subject {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final SubjectType type;
  final String description;
  final bool hasImage; // لو المادة محتاجة تعرض صورة (زي الألحان)

  const Subject({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.description,
    this.hasImage = true,
  });
}

class Level {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int yearsCount;

  const Level({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.yearsCount,
  });
}

class YearLevel {
  final String id;
  final String name;
  const YearLevel({required this.id, required this.name});
}

class Term {
  final String id;
  final String name;
  const Term({required this.id, required this.name});
}

class NavPath {
  final Level level;
  final YearLevel? year;
  final Term term;
  final Subject? subject;

  const NavPath(
      {required this.level, this.year, required this.term, this.subject});

  NavPath copyWith({Subject? subject}) => NavPath(
      level: level, year: year, term: term, subject: subject ?? this.subject);

  String get breadcrumb {
    final parts = <String>[
      level.name,
      if (year != null) year!.name,
      term.name,
      if (subject != null) subject!.name
    ];
    return parts.join(' • ');
  }

  String get curriculumKey => [
        level.id,
        year?.id ?? 'no_year',
        term.id,
        subject?.id ?? 'no_subject',
      ].join('/');
}

class MediaLessonItem {
  final String title;
  final String content; // النص العربي (content_ar أو content)
  final String? contentCopticArabic; // النص القبطي بالحروف العربية (للألحان بس)

  // هنستخدمهم بعدين لما نضيف الملفات
  final String? audioUrl;
  final String? imageAsset;

  const MediaLessonItem({
    required this.title,
    required this.content,
    this.contentCopticArabic,
    this.audioUrl,
    this.imageAsset,
  });
}

class NotebookLessonItem {
  final String title;
  final String content;
  final int notebookPages;

  const NotebookLessonItem(
      {required this.title,
      required this.content,
      required this.notebookPages});
}
