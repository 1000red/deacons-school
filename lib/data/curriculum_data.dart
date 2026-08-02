import 'package:flutter/material.dart';
import '../models/models.dart';

/// بيانات المنهج الدراسي: المستويات، السنوات، الترمات، والمواد الخمس الثابتة.
/// المحتوى داخل كل مادة (الدروس/الألحان) يُولَّد بشكل تجريبي بناءً على السياق
/// (المستوى/السنة/الترم) حتى لا نحتاج لتخزين مئات التركيبات يدويًا.
class CurriculumData {
  CurriculumData._();

  static const levels = <Level>[
    Level(
      id: 'preparatory',
      name: 'تمهيدي',
      subtitle: 'سنة دراسية واحدة',
      icon: Icons.auto_awesome,
      color: Color(0xFF0D9488), // teal
      yearsCount: 1,
    ),
    Level(
      id: 'first',
      name: 'المستوى الأول',
      subtitle: '3 سنوات دراسية',
      icon: Icons.looks_one,
      color: Color(0xFF2563EB), // blue
      yearsCount: 3,
    ),
    Level(
      id: 'second',
      name: 'المستوى الثاني',
      subtitle: '3 سنوات دراسية',
      icon: Icons.looks_two,
      color: Color(0xFF7C3AED), // purple
      yearsCount: 3,
    ),
    Level(
      id: 'third',
      name: 'المستوى الثالث',
      subtitle: '3 سنوات دراسية',
      icon: Icons.looks_3,
      color: Color(0xFFB45309), // amber/gold
      yearsCount: 3,
    ),
  ];

  static const yearNames = ['السنة الأولى', 'السنة الثانية', 'السنة الثالثة'];
  static const termNames = ['الترم الأول', 'الترم الثاني', 'الترم الثالث'];

  static List<YearLevel> yearsOf(Level level) {
    return List.generate(
      level.yearsCount,
      (i) => YearLevel(
          id: '${level.id}_y${i + 1}',
          name: level.yearsCount == 1 ? 'السنة الدراسية' : yearNames[i]),
    );
  }

  static List<Term> terms() {
    return List.generate(3, (i) => Term(id: 't${i + 1}', name: termNames[i]));
  }

  static const subjects = <Subject>[
    Subject(
      id: 'notebook',
      name: 'المذكرة',
      icon: Icons.description, // يمكنك تغيير الأيقونة حسب رغبتك
      color: Color(0xFFC2410C), // لون مميز للمذكرة
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

  /// مواد المنهج تختلف في التمهيدي: لا توجد مادة قراءة في هذا المستوى.
  static List<Subject> subjectsFor(NavPath path) {
    if (path.level.id == 'preparatory') {
      return subjects.where((subject) => subject.id != 'reading').toList();
    }
    return subjects;
  }

  /// دروس/ألحان تجريبية لمادة من نوع media (ألحان أو قبطي).
  static List<MediaLessonItem> mediaLessons(NavPath path) {
    final base = path.subject!.id == 'hymns'
        ? ['لحن أبصالوس', 'لحن آجيوس', 'لحن كيرياليصون الكبير', 'مزمور باكر']
        : [
            'حرف الألفا بيتا',
            'نطق الحروف المركبة',
            'تسبحة نيك إشئنوفري',
            'قراءة قبطي مبسطة'
          ];
    return List.generate(
      base.length,
      (i) => MediaLessonItem(
          title: '${base[i]} (${path.term.name})',
          duration: '0${2 + i}:${15 + i * 7}'),
    );
  }

  /// دروس تجريبية لمادة من نوع notebook (طقس/قراءة/محفوظات) - مذكرة + محتوى.
  static List<NotebookLessonItem> notebookLessons(NavPath path) {
    final subject = path.subject!;
    final samples = switch (subject.id) {
      'rites' => [
          'ترتيب رفع بخور عشية',
          'ترتيب القداس الإلهي',
          'أواني وملابس الخدمة',
        ],
      'reading' => [
          'قراءة من سفر المزامير',
          'قراءة من الإنجيل حسب معلم',
          'تدريب على مخارج الألفاظ',
        ],
      _ => [
          'مزمور 50 كاملاً',
          'إنجيل معلم للأحد',
          'آيات مختارة من الرسائل',
        ],
    };
    return List.generate(
      samples.length,
      (i) => NotebookLessonItem(
        title: '${samples[i]} (${path.term.name})',
        notebookPages: 2 + i,
        content:
            'هذا نص تجريبي لمحتوى مادة ${subject.name} ضمن ${path.breadcrumb}.\n\n'
            'سيتم استبداله لاحقًا بالمحتوى الفعلي (نص المذكرة كاملاً) الذي يضيفه المعلم، '
            'ويشمل الشرح والتوجيهات الخاصة بهذا الدرس.',
      ),
    );
  }
}
