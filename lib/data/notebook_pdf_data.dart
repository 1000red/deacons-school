import '../models/models.dart';

class NotebookPdfData {
  NotebookPdfData._();

  static const _levelLabels = {
    'preparatory': 'تمهيدي',
    'first': '1',
    'second': '2',
    'third': '3',
  };

  static const _yearOrdinals = {
    1: 'First Year',
    2: 'Second Year',
    3: 'Third Year',
  };

  static const _termOrdinals = {
    't1': 'First Term',
    't2': 'Second Term',
    't3': 'Third Term',
  };

  /// بيرجعلك اسم الملف المتوقع من الـ curriculumKey
  /// مثال: third/third_y2/t3/notebook -> "Level 3-Second Year-Third Term.pdf"
  /// preparatory/preparatory_y1/t1/notebook -> عدّل الصيغة لو مختلفة
  static String? expectedFileName(String curriculumKey) {
    final parts = curriculumKey.split('/');
    if (parts.length < 4) return null;

    final levelId = parts[0]; // preparatory/first/second/third
    final yearId = parts[1]; // e.g. third_y3
    final termId = parts[2]; // t1/t2/t3

    // استخراج رقم السنة من آخر yearId (بعد _y)
    final yearMatch = RegExp(r'_y(\d+)$').firstMatch(yearId);
    final yearNum =
        yearMatch != null ? int.tryParse(yearMatch.group(1)!) : null;

    final levelLabel = _levelLabels[levelId];
    final termLabel = _termOrdinals[termId];

    if (levelLabel == null || termLabel == null) return null;

    if (levelId == 'preparatory') {
      // عدّل الشكل ده لو اسم ملف التمهيدي مختلف في Drive
      return 'Level تمهيدي-$termLabel.pdf';
    }

    final yearLabel = _yearOrdinals[yearNum];
    if (yearLabel == null) return null;

    return 'Level $levelLabel-$yearLabel-$termLabel.pdf';
  }

  /// المفتاح: {level}/{level}_y{رقم}/t{رقم}/notebook
  static const _driveIds = <String, String>{
    // ===== تمهيدي (preparatory) =====
    'preparatory/preparatory_y1/t1/notebook': '',
    'preparatory/preparatory_y1/t2/notebook': '',
    'preparatory/preparatory_y1/t3/notebook': '',

    // ===== المستوى الأول (first) =====
    'first/first_y1/t1/notebook': '',
    'first/first_y1/t2/notebook': '',
    'first/first_y1/t3/notebook': '',

    'first/first_y2/t1/notebook': '',
    'first/first_y2/t2/notebook': '',
    'first/first_y2/t3/notebook': '',

    'first/first_y3/t1/notebook': '',
    'first/first_y3/t2/notebook': '',
    'first/first_y3/t3/notebook': '',

    // ===== المستوى الثاني (second) =====
    'second/second_y1/t1/notebook': '',
    'second/second_y1/t2/notebook': '',
    'second/second_y1/t3/notebook': '',

    'second/second_y2/t1/notebook': '',
    'second/second_y2/t2/notebook': '',
    'second/second_y2/t3/notebook': '',

    'second/second_y3/t1/notebook': '',
    'second/second_y3/t2/notebook': '',
    'second/second_y3/t3/notebook': '',

    // ===== المستوى الثالث (third) =====
    'third/third_y1/t1/notebook': '',
    'third/third_y1/t2/notebook': '',
    'third/third_y1/t3/notebook': '',

    'third/third_y2/t1/notebook': '1Iy5Dh-RwswhX4LEEgC99_GsEXA6JThgW',
    'third/third_y2/t2/notebook': '',
    'third/third_y2/t3/notebook': '1jYM9LmRruZA6J1DptTtsD8TSKVwlswks',

    'third/third_y3/t1/notebook': '',
    'third/third_y3/t2/notebook': '',
    'third/third_y3/t3/notebook': '',
  };

  static String? driveFileId(NavPath path) => _driveIds[path.curriculumKey];

  static String? previewUrl(NavPath path) {
    final id = driveFileId(path);
    if (id == null || id.isEmpty) return null;
    return 'https://drive.google.com/uc?export=download&id=$id';
  }

  static String? directDownloadUrl(NavPath path) {
    final id = driveFileId(path);
    if (id == null || id.isEmpty) return null;
    return 'https://drive.usercontent.google.com/download?id=$id&export=download&authuser=0&confirm=t';
  }
}
