import '../models/models.dart';

/// تعريف مواد المنهج الستة وقواعد عرضها لكل مستوى.
///
/// معرّف المادة (`notebook` / `rites` / `coptic` / `reading` /
/// `memorization` / `hymns`) هو نفسه مفتاح المادة داخل ملفات الـ JSON
/// وداخل خريطة روابط Google Drive.
class CurriculumSubjects {
  CurriculumSubjects._();

  static const subjects = <Subject>[
    Subject(
      id: 'notebook',
      name: 'المذكرة',
      type: SubjectType.notebook,
      description: 'المذكرة الدراسية الخاصة بالمنهج والتطبيقات.',
    ),
    Subject(
      id: 'rites',
      name: 'طقس',
      type: SubjectType.text,
      description: 'ترتيب وطقوس الكنيسة والقداسات والمواسم الكنسية.',
    ),
    Subject(
      id: 'coptic',
      name: 'قبطي',
      type: SubjectType.media,
      description: 'اللغة القبطية: نطق وتسبحة بالصوت.',
    ),
    Subject(
      id: 'reading',
      name: 'قراءة',
      type: SubjectType.text,
      description: 'قراءات الكتاب المقدس والتدريب على الإلقاء الصحيح.',
    ),
    Subject(
      id: 'memorization',
      name: 'محفوظات',
      type: SubjectType.text,
      description: 'آيات وفقرات كتابية يحفظها الشماس خلال الترم.',
    ),
    Subject(
      id: 'hymns',
      name: 'ألحان',
      type: SubjectType.media,
      hasImage: true,
      description: 'ألحان وتسابيح بالصوت مع صور المذكرة والسبورة بالهزات.',
    ),
  ];

  /// مواد المستوى التمهيدي (بدون مادة القراءة).
  static List<Subject> subjectsFor(Level level) {
    if (level.id == 'preparatory') {
      return subjects.where((subject) => subject.id != 'reading').toList();
    }
    return subjects;
  }
}
