import 'package:flutter/material.dart';
import '../models/models.dart';

/// بيانات المنهج الدراسي: المستويات، السنوات، الترمات، والمواد الثابتة.
///
/// أسماء المواد ثابتة في الغالب، لكن محتوى كل مادة يتبع مساراً كاملاً
/// (مستوى > سنة > ترم > مادة). لا نربط الدروس باسم المادة فقط حتى لا يظهر
/// منهج ترم في ترم آخر.
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

  /// تُحفظ بيانات كل منهج تحت مفتاح [NavPath.curriculumKey].
  ///
  /// هذا مثال فعلي لمنهج «المستوى الأول / السنة الثانية / قبطي»؛ كل ترم له
  /// قائمة مستقلة، ولذلك تعديل منهج الترم الثالث لا يؤثر على الترم الثاني.
  /// عند إضافة محتوى جديد، نضيفه للمفتاح المطابق فقط.
  static const _mediaCurricula = <String, List<MediaLessonItem>>{
    'first/first_y2/t1/coptic': [
      MediaLessonItem(title: 'الحروف القبطية الأساسية', duration: '03:10'),
      MediaLessonItem(title: 'نطق الحروف المتحركة', duration: '04:25'),
    ],
    'first/first_y2/t2/coptic': [
      MediaLessonItem(title: 'الحروف المركبة', duration: '04:05'),
      MediaLessonItem(title: 'كلمات قبطية قصيرة', duration: '03:40'),
      MediaLessonItem(title: 'تدريب على القراءة', duration: '05:15'),
    ],
    'first/first_y2/t3/coptic': [
      MediaLessonItem(title: 'قراءة نص قبطي مبسط', duration: '05:20'),
      MediaLessonItem(title: 'تسبحة نيك إشئنوفري', duration: '06:10'),
      MediaLessonItem(title: 'مراجعة النطق والقراءة', duration: '04:45'),
    ],
  };

  static const _notebookCurricula = <String, List<NotebookLessonItem>>{
    'first/first_y2/t1/rites': [
      NotebookLessonItem(
        title: 'مقدمة في طقس رفع بخور عشية',
        notebookPages: 3,
        content:
            'شرح ترتيب رفع بخور عشية والتدريبات المطلوبة خلال الترم الأول.',
      ),
    ],
    'first/first_y2/t2/rites': [
      NotebookLessonItem(
        title: 'أواني وملابس الخدمة',
        notebookPages: 4,
        content: 'دراسة أواني الخدمة وملابس الشماس والتطبيق العملي عليها.',
      ),
    ],
    'first/first_y2/t3/rites': [
      NotebookLessonItem(
        title: 'ترتيب القداس الإلهي',
        notebookPages: 5,
        content: 'منهج الترم الثالث: ترتيب القداس الإلهي ومسؤوليات الشماس فيه.',
      ),
    ],
  };

  /// ملفات مذكرات كاملة مرتبطة بمنهج محدد، وليست بالمادة وحدها (asset محلي).
  static const _notebookPdfAssets = <String, String>{
    'third/third_y3/t3/notebook':
        'assets/pdfs/level_3_year_3_term_3_notebook.pdf',
  };

  /// روابط مذكرات PDF مرفوعة على Google Drive، بنفس نظام المفاتيح المستخدم
  /// في [_notebookPdfAssets] (curriculumKey الكامل: مستوى/سنة/ترم/مادة).
  /// استخدم الـ FILE_ID بس (اللي بين /d/ و /view في رابط المشاركة)، مش
  /// اللينك كامل.
  static const _notebookPdfDriveIds = <String, String>{
    'third/third_y3/t3/notebook': '1FNSlqj0xoRu7nhyJx9HW7Sjh2HD_UpK-',

    // مثال لإضافة مذكرة تانية بعدين:
    // 'first/first_y2/t1/rites': 'FILE_ID_بتاع_مذكرة_الطقس',
  };

  /// مواد المنهج تختلف في التمهيدي: لا توجد مادة قراءة في هذا المستوى.
  static List<Subject> subjectsFor(NavPath path) {
    if (path.level.id == 'preparatory') {
      return subjects.where((subject) => subject.id != 'reading').toList();
    }
    return subjects;
  }

  /// دروس/ألحان مادة من نوع media (ألحان أو قبطي).
  ///
  /// القوائم المضافة إلى [_mediaCurricula] لها أولوية كاملة لأنها منهج محدد
  /// لسنة وترم بعينهما. المحتوى الافتراضي التالي موجود مؤقتاً للشاشات التي
  /// لم يُدخل منهجها بعد في كتالوج البيانات.
  static List<MediaLessonItem> mediaLessons(NavPath path) {
    final curriculum = _mediaCurricula[path.curriculumKey];
    if (curriculum != null) return curriculum;

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

  /// دروس مادة من نوع notebook (طقس/قراءة/محفوظات).
  /// راجع [mediaLessons] لطريقة حفظ المناهج المنفصلة حسب السنة والترم.
  static List<NotebookLessonItem> notebookLessons(NavPath path) {
    final curriculum = _notebookCurricula[path.curriculumKey];
    if (curriculum != null) return curriculum;

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

  /// مسار ملف الـ PDF للمذكرة إن كان قد رُفع لهذا المنهج (asset محلي).
  static String? notebookPdfAsset(NavPath path) =>
      _notebookPdfAssets[path.curriculumKey];

  /// رابط تحميل مباشر من Google Drive لمذكرة هذا المنهج، أو null لو
  /// المفتاح مش موجود في [_notebookPdfDriveIds].
  static String? notebookPdfUrl(NavPath path) {
    final fileId = _notebookPdfDriveIds[path.curriculumKey];
    if (fileId == null) return null;
    return 'https://drive.google.com/uc?export=download&id=$fileId';
  }
}
