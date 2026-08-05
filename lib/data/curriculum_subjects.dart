import 'package:flutter/material.dart';
import '../models/models.dart';

class CurriculumSubjects {
  CurriculumSubjects._();

  static const subjects = <Subject>[
    Subject(
      id: 'notebook',
      name: 'المذكرة',
      icon: Icons.description,
      color: Color(0xFFC2410C),
      type: SubjectType.notebook,
      description: 'المذكرة الدراسية الخاصة بالمنهج والتطبيقات.',
    ),
    Subject(
      id: 'rites',
      name: 'طقس',
      icon: Icons.church,
      color: Color(0xFF1D4ED8),
      type: SubjectType.notebook,
      description: 'ترتيب وطقوس الكنيسة والقداسات والمواسم الكنسية.',
    ),
    Subject(
      id: 'coptic',
      name: 'قبطي',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF0F766E),
      type: SubjectType.media,
      description: 'اللغة القبطية: نطق وتسبحة بالصوت مع صور المذكرة والسبورة.',
    ),
    Subject(
      id: 'reading',
      name: 'قراءة',
      icon: Icons.auto_stories,
      color: Color(0xFF15803D),
      type: SubjectType.notebook,
      description: 'قراءات الكتاب المقدس والتدريب على الإلقاء الصحيح.',
    ),
    Subject(
      id: 'memorization',
      name: 'محفوظات',
      icon: Icons.self_improvement,
      color: Color(0xFFB45309),
      type: SubjectType.notebook,
      description: 'آيات وفقرات كتابية يحفظها الشماس خلال الترم.',
    ),
    Subject(
      id: 'hymns',
      name: 'ألحان',
      icon: Icons.music_note,
      color: Color(0xFF9333EA),
      type: SubjectType.media,
      description: 'ألحان وتسابيح بالصوت مع صور المذكرة والسبورة بالهزات.',
    ),
  ];

  static List<Subject> subjectsFor(NavPath path) {
    if (path.level.id == 'preparatory') {
      return subjects.where((subject) => subject.id != 'reading').toList();
    }
    return subjects;
  }
}
