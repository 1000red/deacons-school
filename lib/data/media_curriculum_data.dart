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

  // ============================================================
  // صورة السبورة (asset محلي) + رابط الصوت (Google Drive)
  // كل درس (بمكانه/index في القايمة) ليه صورة وصوت خاصين بيه،
  // مش نفس المحتوى بيتكرر لكل الدروس تحت نفس المسار.
  //
  // شكل المفتاح: curriculumKey -> { lessonIndex: value }
  // ============================================================

  /// مسار صورة السبورة (asset) لكل درس، حسب ترتيبه في القايمة.
  static const _boardImageAssets = <String, Map<int, String>>{
    'third/third_y3/t3/hymns': {
      0: 'assets/la7n.jpeg', // لحن أبصالوس (الترم الثالث)
      // 1: 'assets/....jpeg', // لحن آجيوس — لسه محتاج صورة/ملف خاص بيه
      // 2: 'assets/....jpeg', // لحن كيرياليصون الكبير
      // 3: 'assets/....jpeg', // مزمور باكر
    },
  };

  /// الـ File ID الخاص بملف الصوت على Google Drive لكل درس.
  static const _audioIds = <String, Map<int, String>>{
    'third/third_y3/t3/hymns': {
      0: '1l7z0BFDn_RC4Ocj6Roouxq7uQY1UXYon', // لحن أبصالوس (الترم الثالث)
      // 1: '....', // لحن آجيوس — لسه محتاج ملف صوت خاص بيه
      // 2: '....', // لحن كيرياليصون الكبير
      // 3: '....', // مزمور باكر
    },
  };

  /// إرجاع مسار صورة السبورة (asset) الخاصة بدرس معيّن، أو null لو مفيش.
  static String? boardImageAssetFor(NavPath path, int lessonIndex) {
    return _boardImageAssets[path.curriculumKey]?[lessonIndex];
  }

  /// إرجاع رابط تنزيل الصوت المباشر من Google Drive الخاص بدرس معيّن،
  /// أو null لو مفيش.
  static String? audioUrlFor(NavPath path, int lessonIndex) {
    final fileId = _audioIds[path.curriculumKey]?[lessonIndex];
    if (fileId == null) return null;
    return 'https://drive.google.com/uc?export=download&id=$fileId';
  }
}
