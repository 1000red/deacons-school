import '../models/models.dart';

class NotebookCurriculumData {
  NotebookCurriculumData._();

  // (طقس/قراءة/محفوظات)
  static const _curricula = <String, List<NotebookLessonItem>>{
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

  /// دروس مادة من نوع notebook .
  static List<NotebookLessonItem> lessons(NavPath path) {
    final curriculum = _curricula[path.curriculumKey];
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
}
