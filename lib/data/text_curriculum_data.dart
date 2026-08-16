import '../models/models.dart';
import '../data/curriculum_json_loader.dart';

class NotebookCurriculumData {
  NotebookCurriculumData._();

  static Future<List<NotebookLessonItem>> lessons(NavPath path) {
    return CurriculumJsonLoader.notebookLessons(path);
  }
}
