import '../../../core/errors/app_exception.dart';
import '../../../data/models/models.dart';
import '../../../data/services/curriculum_local_data_source.dart';
import '../../../data/services/curriculum_levels.dart';
import '../../../data/services/curriculum_subjects.dart';

abstract class CurriculumRepository {
  List<Level> get levels;

  List<YearLevel> yearsOf(Level level);

  List<Term> terms();

  List<Subject> subjectsFor(Level level);

  Future<List<NotebookLessonItem>> textLessons(NavPath path);

  Future<List<MediaLessonItem>> mediaLessons(NavPath path);
}

class CurriculumRepositoryImpl implements CurriculumRepository {
  CurriculumRepositoryImpl({required CurriculumLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  final CurriculumLocalDataSource _localDataSource;

  @override
  List<Level> get levels => CurriculumLevels.levels;

  @override
  List<YearLevel> yearsOf(Level level) => CurriculumLevels.yearsOf(level);

  @override
  List<Term> terms() => CurriculumLevels.terms();

  @override
  List<Subject> subjectsFor(Level level) =>
      CurriculumSubjects.subjectsFor(level);

  @override
  Future<List<NotebookLessonItem>> textLessons(NavPath path) async {
    final subjectId = _subjectIdOf(path);
    final items = await _localDataSource.loadSubjectItems(path, subjectId);

    return items
        .map(
          (item) => NotebookLessonItem(
            title: item['title'] as String,
            notebookPages: item['notebookPages'] as int,
            content: item['content'] as String,
          ),
        )
        .toList();
  }

  @override
  Future<List<MediaLessonItem>> mediaLessons(NavPath path) async {
    final subjectId = _subjectIdOf(path);
    final items = await _localDataSource.loadSubjectItems(path, subjectId);

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final title = item['title'] as String? ?? '';

      return MediaLessonItem(
        id: item['id'] as String? ?? '${subjectId}_$index',
        title: title,
        content: (item['content_ar'] ?? item['content']) as String? ?? '',
        contentCopticArabic: item['content_coptic_arabic'] as String?,
        imageAsset: path.subject?.hasImage == true
            ? item['image_asset'] as String?
            : null,
      );
    }).toList();
  }

  String _subjectIdOf(NavPath path) {
    final subject = path.subject;
    if (subject == null) {
      throw const AppException('مسار المنهج غير مكتمل: لا توجد مادة دراسية');
    }
    return subject.id;
  }
}
