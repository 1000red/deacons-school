import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/state/disposable_change_notifier.dart';
import '../../../core/state/view_state.dart';
import '../../../data/models/models.dart';
import '../../curriculum/repositories/curriculum_repository.dart';
import '../repositories/media_repository.dart';

/// تفاصيل لحن واحد (الألحان) لمسار [NavPath] محدد.
///
/// الشاشة بتمرّر لها الدرس المختار وقت التنقّل، والـ ViewModel بيرجع
/// يتأكد منه في [CurriculumRepository] (نفس مصدر بيانات القائمة) عشان
/// البيانات المعروضة تفضل من المصدر الرسمي وما تبقاش مربوطة بلحن تاني،
/// وبيرفق رابط التسجيل الخاص بيه من [MediaRepository] عشان الصوت يبقى
/// مربوط باللحن المختار بس.
class HymnDetailsViewModel extends DisposableChangeNotifier {
  HymnDetailsViewModel({
    required CurriculumRepository curriculumRepository,
    required MediaRepository mediaRepository,
    required NavPath path,
    required MediaLessonItem lesson,
  })  : _curriculumRepository = curriculumRepository,
        _mediaRepository = mediaRepository,
        _path = path,
        _lessonId = lesson.id {
    load();
  }

  final CurriculumRepository _curriculumRepository;
  final MediaRepository _mediaRepository;
  final NavPath _path;
  final String _lessonId;

  ViewState<MediaLessonItem> _state = const ViewState.initial();

  ViewState<MediaLessonItem> get state => _state;

  /// مسار المنهج الخاص بالشاشة (بيستخدمه العرض للعنوان والـ breadcrumb).
  NavPath get path => _path;

  Future<void> load() async {
    _state = const ViewState.loading();
    notifySafely();

    try {
      final lessons = await _curriculumRepository.mediaLessons(_path);
      final selected =
          lessons.where((lesson) => lesson.id == _lessonId).firstOrNull;

      if (selected == null) {
        // اللحن المختار مش موجود في المنهج (بيانات ناقصة) — بنعرض حالة
        // "مش لاقيه" بدل ما نعرض لحن غلط بالخطأ.
        _state = const ViewState.empty();
      } else {
        _state = ViewState.success(
          selected.copyWith(
            audioUrl: _mediaRepository.audioUrl(_path, selected.title),
          ),
        );
      }
    } on AppException catch (e) {
      debugPrint('ERROR LOADING HYMN DETAILS: ${e.message}');
      if (e.cause != null) debugPrint('CAUSE: ${e.cause}');
      _state = const ViewState.error('تعذر تحميل المحتوى.');
    } catch (e, stackTrace) {
      debugPrint('ERROR LOADING HYMN DETAILS: $e');
      debugPrint('STACK TRACE: $stackTrace');
      _state = const ViewState.error('تعذر تحميل المحتوى.');
    }

    notifySafely();
  }
}
