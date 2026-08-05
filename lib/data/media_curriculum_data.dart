import '../models/models.dart';

class MediaCurriculumData {
  MediaCurriculumData._();

  // الحان و قبطي
  static const _curricula = <String, List<MediaLessonItem>>{
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

  static List<MediaLessonItem> lessons(NavPath path) {
    final curriculum = _curricula[path.curriculumKey];
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
}
