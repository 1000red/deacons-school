import 'package:deacons_school_mobile/core/errors/app_exception.dart';
import 'package:deacons_school_mobile/core/state/view_state.dart';
import 'package:deacons_school_mobile/data/models/models.dart';
import 'package:deacons_school_mobile/features/curriculum/viewmodels/text_subject_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  const lesson = NotebookLessonItem(
    title: 'القداس الأول',
    content: 'نص الطقس',
    notebookPages: 5,
  );

  TestWidgetsFlutterBinding.ensureInitialized();

  group('TextSubjectViewModel states', () {
    test('goes loading → success', () async {
      final repository = FakeCurriculumRepository()
        ..textLessonsResult = const [lesson];
      final viewModel = TextSubjectViewModel(
        repository: repository,
        path: buildPath(subject: ritesSubject),
      );

      expect(viewModel.state.isLoading, isTrue);

      final statuses = <ViewStateStatus>[];
      viewModel.addListener(() => statuses.add(viewModel.state.status));
      await pumpEventQueue();

      expect(statuses, [ViewStateStatus.success]);
      expect(viewModel.state.data, const [lesson]);
      expect(repository.textLessonsCalls, 1);
    });

    test('goes loading → empty when the subject has no lessons', () async {
      final viewModel = TextSubjectViewModel(
        repository: FakeCurriculumRepository()..textLessonsResult = const [],
        path: buildPath(subject: ritesSubject),
      );

      await pumpEventQueue();

      expect(viewModel.state.isEmpty, isTrue);
      expect(viewModel.state.data, isNull);
    });

    test('goes loading → error with the historic Arabic message', () async {
      final viewModel = TextSubjectViewModel(
        repository: FakeCurriculumRepository()
          ..textLessonsError = const AppException('asset مفقود'),
        path: buildPath(subject: ritesSubject),
      );

      await pumpEventQueue();

      expect(viewModel.state.isError, isTrue);
      expect(viewModel.state.message, 'تعذر تحميل محتوى المادة.');
    });

    test('maps unexpected failures to the same error state', () async {
      final viewModel = TextSubjectViewModel(
        repository: FakeCurriculumRepository()
          ..textLessonsError = StateError('unexpected'),
        path: buildPath(subject: ritesSubject),
      );

      await pumpEventQueue();

      expect(viewModel.state.isError, isTrue);
      expect(viewModel.state.message, 'تعذر تحميل محتوى المادة.');
    });

    test('can be reloaded manually (retry path)', () async {
      final repository = FakeCurriculumRepository();
      final viewModel = TextSubjectViewModel(
        repository: repository,
        path: buildPath(subject: ritesSubject),
      );
      await pumpEventQueue();
      expect(viewModel.state.isEmpty, isTrue);

      repository.textLessonsResult = const [lesson];
      await viewModel.load();

      expect(viewModel.state.isSuccess, isTrue);
      expect(repository.textLessonsCalls, 2);
    });
  });

  group('TextSubjectViewModel lifecycle', () {
    test('does not notify listeners after being disposed mid-load', () async {
      final repository = FakeCurriculumRepository()
        ..delay = const Duration(milliseconds: 30)
        ..textLessonsResult = const [lesson];
      final viewModel = TextSubjectViewModel(
        repository: repository,
        path: buildPath(subject: ritesSubject),
      );

      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.dispose();
      await pumpEventQueue();

      expect(viewModel.isDisposed, isTrue);
      expect(notified, isFalse);
    });
  });

  group('NavPath exposure', () {
    test('keeps the screen path available for the view', () {
      final path = buildPath(subject: ritesSubject);
      final viewModel = TextSubjectViewModel(
        repository: FakeCurriculumRepository(),
        path: path,
      );

      expect(viewModel.path, same(path));
    });
  });
}
