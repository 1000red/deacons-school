import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/state/disposable_change_notifier.dart';
import '../../../core/state/view_state.dart';
import '../../../data/models/models.dart';
import '../../media/repositories/media_repository.dart';
import '../../curriculum/repositories/curriculum_repository.dart';

/// محتوى المادة الصوتية (قبطي / ألحان) لمسار [NavPath] واحد.
///
/// بيجيب الدروس من [CurriculumRepository] ثم بيرفق رابط التسجيل لكل درس
/// من [MediaRepository] (خريطة Google Drive).
class MediaSubjectViewModel extends DisposableChangeNotifier {
  MediaSubjectViewModel({
    required CurriculumRepository curriculumRepository,
    required MediaRepository mediaRepository,
    required NavPath path,
  })  : _curriculumRepository = curriculumRepository,
        _mediaRepository = mediaRepository,
        _path = path {
    load();
  }

  final CurriculumRepository _curriculumRepository;
  final MediaRepository _mediaRepository;
  final NavPath _path;

  ViewState<List<MediaLessonItem>> _state = const ViewState.initial();

  ViewState<List<MediaLessonItem>> get state => _state;

  /// مسار المنهج الخاص بالشاشة دي (بيستخدمه العرض للعنوان والـ breadcrumb).
  NavPath get path => _path;

  Future<void> load() async {
    _state = const ViewState.loading();
    notifySafely();

    try {
      final lessons = await _curriculumRepository.mediaLessons(_path);
      final lessonsWithAudio = [
        for (final lesson in lessons)
          lesson.copyWith(audioUrl: _mediaRepository.audioUrl(_path, lesson.title)),
      ];

      _state = lessonsWithAudio.isEmpty
          ? const ViewState.empty()
          : ViewState.success(lessonsWithAudio);
    } on AppException catch (e) {
      debugPrint('ERROR LOADING MEDIA LESSONS: ${e.message}');
      if (e.cause != null) debugPrint('CAUSE: ${e.cause}');
      _state = const ViewState.error('تعذر تحميل المحتوى.');
    } catch (e, stackTrace) {
      debugPrint('ERROR LOADING MEDIA LESSONS: $e');
      debugPrint('STACK TRACE: $stackTrace');
      _state = const ViewState.error('تعذر تحميل المحتوى.');
    }

    notifySafely();
  }
}
