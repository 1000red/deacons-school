import 'package:deacons_school_mobile/core/errors/app_exception.dart';
import 'package:deacons_school_mobile/data/models/models.dart';
import 'package:deacons_school_mobile/features/media/viewmodels/media_subject_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const lesson = MediaLessonItem(
    id: 'coptic_0',
    title: 'درس النطق الأول',
    content: 'نص عربي',
  );

  group('MediaSubjectViewModel states', () {
    test('loads the lessons and attaches the recording url', () async {
      final mediaRepository = FakeMediaRepository()
        ..audioUrlForTitle = 'https://drive.google.com/uc?export=download&id=1';
      final viewModel = MediaSubjectViewModel(
        curriculumRepository: FakeCurriculumRepository()
          ..mediaLessonsResult = const [lesson],
        mediaRepository: mediaRepository,
        path: buildPath(subject: copticSubject),
      );

      expect(viewModel.state.isLoading, isTrue);
      await pumpEventQueue();

      expect(viewModel.state.isSuccess, isTrue);
      final loaded = viewModel.state.data!.single;
      expect(loaded.audioUrl, 'https://drive.google.com/uc?export=download&id=1');
      expect(loaded.id, 'coptic_0');
      expect(mediaRepository.audioUrlPaths.single.subject!.id, 'coptic');
    });

    test('keeps audioUrl null when no recording exists for the lesson', () async {
      final viewModel = MediaSubjectViewModel(
        curriculumRepository: FakeCurriculumRepository()
          ..mediaLessonsResult = const [lesson],
        mediaRepository: FakeMediaRepository()..audioUrlForTitle = null,
        path: buildPath(subject: copticSubject),
      );

      await pumpEventQueue();

      expect(viewModel.state.data!.single.audioUrl, isNull);
    });

    test('goes loading → empty when there are no lessons', () async {
      final viewModel = MediaSubjectViewModel(
        curriculumRepository: FakeCurriculumRepository()
          ..mediaLessonsResult = const [],
        mediaRepository: FakeMediaRepository(),
        path: buildPath(subject: copticSubject),
      );

      await pumpEventQueue();

      expect(viewModel.state.isEmpty, isTrue);
    });

    test('goes loading → error with the historic Arabic message', () async {
      final viewModel = MediaSubjectViewModel(
        curriculumRepository: FakeCurriculumRepository()
          ..mediaLessonsError = const AppException('asset مفقود'),
        mediaRepository: FakeMediaRepository(),
        path: buildPath(subject: copticSubject),
      );

      await pumpEventQueue();

      expect(viewModel.state.isError, isTrue);
      expect(viewModel.state.message, 'تعذر تحميل المحتوى.');
    });

    test('maps unexpected failures to the same error state', () async {
      final viewModel = MediaSubjectViewModel(
        curriculumRepository: FakeCurriculumRepository()
          ..mediaLessonsError = const FormatException('broken'),
        mediaRepository: FakeMediaRepository(),
        path: buildPath(subject: copticSubject),
      );

      await pumpEventQueue();

      expect(viewModel.state.isError, isTrue);
      expect(viewModel.state.message, 'تعذر تحميل المحتوى.');
    });
  });

  group('MediaSubjectViewModel lifecycle', () {
    test('does not notify listeners after being disposed mid-load', () async {
      final viewModel = MediaSubjectViewModel(
        curriculumRepository: FakeCurriculumRepository()
          ..delay = const Duration(milliseconds: 30)
          ..mediaLessonsResult = const [lesson],
        mediaRepository: FakeMediaRepository(),
        path: buildPath(subject: copticSubject),
      );

      var notified = false;
      viewModel.addListener(() => notified = true);
      viewModel.dispose();
      await pumpEventQueue();

      expect(viewModel.isDisposed, isTrue);
      expect(notified, isFalse);
    });
  });
}
