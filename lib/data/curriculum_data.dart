import '../models/models.dart';

import 'curriculum_levels.dart';
import 'curriculum_subjects.dart';
import 'media_curriculum_data.dart';
import 'notebook_curriculum_data.dart';
import 'notebook_pdf_data.dart';

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

  static List<MediaLessonItem> mediaLessons(NavPath path) =>
      MediaCurriculumData.lessons(path);

  static List<NotebookLessonItem> notebookLessons(NavPath path) =>
      NotebookCurriculumData.lessons(path);

  static String? notebookPdfUrl(NavPath path) => NotebookPdfData.driveUrl(path);
}
