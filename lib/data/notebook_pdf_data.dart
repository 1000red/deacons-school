import '../models/models.dart';

class NotebookPdfData {
  NotebookPdfData._();

  static const _driveIds = <String, String>{
    'third/third_y3/t3/notebook': '1FNSlqj0xoRu7nhyJx9HW7Sjh2HD_UpK-',
  };

  static String? driveUrl(NavPath path) {
    final fileId = _driveIds[path.curriculumKey];
    if (fileId == null) return null;
    return 'https://drive.google.com/uc?export=download&id=$fileId';
  }
}
