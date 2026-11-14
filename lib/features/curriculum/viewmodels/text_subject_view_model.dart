import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/state/disposable_change_notifier.dart';
import '../../../core/state/view_state.dart';
import '../../../data/models/models.dart';
import '../repositories/curriculum_repository.dart';

class TextSubjectViewModel extends DisposableChangeNotifier {
  TextSubjectViewModel({
    required CurriculumRepository repository,
    required NavPath path,
  })  : _repository = repository,
        _path = path {
    load();
  }

  final CurriculumRepository _repository;
  final NavPath _path;

  ViewState<List<NotebookLessonItem>> _state = const ViewState.initial();

  ViewState<List<NotebookLessonItem>> get state => _state;

  NavPath get path => _path;

  Future<void> load() async {
    _state = const ViewState.loading();
    notifySafely();

    try {
      final lessons = await _repository.textLessons(_path);
      _state = lessons.isEmpty
          ? const ViewState.empty()
          : ViewState.success(lessons);
    } on AppException catch (e) {
      debugPrint('ERROR LOADING TEXT LESSONS: ${e.message}');
      if (e.cause != null) debugPrint('CAUSE: ${e.cause}');
      _state = const ViewState.error('تعذر تحميل محتوى المادة.');
    } catch (e, stackTrace) {
      debugPrint('ERROR LOADING TEXT LESSONS: $e');
      debugPrint('STACK TRACE: $stackTrace');
      _state = const ViewState.error('تعذر تحميل محتوى المادة.');
    }

    notifySafely();
  }
}
