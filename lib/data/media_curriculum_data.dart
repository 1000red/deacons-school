import '../models/models.dart';
import 'curriculum_json_loader.dart';

class MediaCurriculumData {
  MediaCurriculumData._();

  static Future<List<MediaLessonItem>> lessons(
    NavPath path,
  ) {
    return CurriculumJsonLoader.mediaLessons(path);
  }
}
