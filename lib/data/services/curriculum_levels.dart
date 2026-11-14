import '../models/models.dart';

/// تعريف المستويات الدراسية الأربعة وأسماء السنوات والترمات.
///
/// المعرّفات الموجودة هنا (`preparatory` / `first` / `second` / `third`
/// و `third_y2` و `t1`) هي نفس المعرّفات اللي بتتعمل بيها مسارات ملفات
/// الـ JSON وروابط Google Drive — مش ممكن تتغير من غير كسر البيانات.
class CurriculumLevels {
  CurriculumLevels._();

  static const levels = <Level>[
    Level(
      id: 'preparatory',
      name: 'المستوى تمهيدي',
      subtitle: 'سنة دراسية واحدة',
      yearsCount: 1, // 0
    ),
    Level(
      id: 'first',
      name: 'المستوى الأول',
      subtitle: '٣ سنوات دراسية',
      yearsCount: 2, // 0, 1, 2
    ),
    Level(
      id: 'second',
      name: 'المستوى الثاني',
      subtitle: '٣ سنوات دراسية',
      yearsCount: 3,
    ),
    Level(
      id: 'third',
      name: 'المستوى الثالث',
      subtitle: '٣ سنوات دراسية',
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
          name: level.yearsCount == 1 ? 'المستوى تمهيدي' : yearNames[i]),
    );
  }

  static List<Term> terms() {
    return List.generate(3, (i) => Term(id: 't${i + 1}', name: termNames[i]));
  }
}
