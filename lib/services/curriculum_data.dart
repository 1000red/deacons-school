import '../models/models.dart';

import 'curriculum_levels.dart';
import 'curriculum_subjects.dart';
import 'notebook_pdf_data.dart';
import 'curriculum_json_loader.dart';

class CurriculumData {
  CurriculumData._();

  static const levels = CurriculumLevels.levels;
  static const yearNames = CurriculumLevels.yearNames;
  static const termNames = CurriculumLevels.termNames;

  static List<YearLevel> yearsOf(Level level) =>
      CurriculumLevels.yearsOf(level);
  static List<Term> terms() => CurriculumLevels.terms();

  static const subjects = CurriculumSubjects.subjects;
  static List<Subject> subjectsFor(NavPath path) =>
      CurriculumSubjects.subjectsFor(path);

  static Future<List<MediaLessonItem>> mediaLessons(
    NavPath path,
  ) =>
      CurriculumJsonLoader.mediaLessons(path);

  static Future<List<NotebookLessonItem>> textLessons(NavPath path) =>
      CurriculumJsonLoader.textLessons(path);

  static String? notebookPdfUrl(NavPath path) =>
      NotebookPdfData.previewUrl(path);
}
