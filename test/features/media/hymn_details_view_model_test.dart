import 'package:deacons_school_mobile/core/errors/app_exception.dart';
import 'package:deacons_school_mobile/data/models/models.dart';
import 'package:deacons_school_mobile/features/media/viewmodels/hymn_details_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const hymnA = MediaLessonItem(
    id: 'hymns_0',
    title: 'أوشية المياه: 12 بؤونه إلى 9 بابه',
    content: 'سطر أول من كلام اللحن\nسطر ثانٍ منه',
    contentCopticArabic: 'طوبه ايَچَيَن إبچيِن موشي',
  );

  const hymnB = MediaLessonItem(
    id: 'hymns_1',
    title: 'مرد الابركسيس المختصر',
    content: 'كلام المرد الثاني',
  );

  HymnDetailsViewModel buildViewModel({
    List<MediaLessonItem> lessons = const [hymnA, hymnB],
    required MediaLessonItem selected,
    FakeMediaRepository? mediaRepository,
    FakeCurriculumRepository? curriculumRepository,
  }) =>
      HymnDetailsViewModel(
        curriculumRepository: curriculumRepository ??
            (FakeCurriculumRepository()..mediaLessonsResult = lessons),
        mediaRepository: mediaRepository ?? FakeMediaRepository(),
        path: buildPath(subject: hymnsSubject),
        lesson: selected,
      );

  group('HymnDetailsViewModel states', () {
    test('loads the selected hymn by id, not another hymn from the list',
        () async {
      final viewModel = buildViewModel(selected: hymnB);

      expect(viewModel.state.isLoading, isTrue);
      await pumpEventQueue();

      expect(viewModel.state.isSuccess, isTrue);
      final loaded = viewModel.state.data!;
      expect(loaded.id, 'hymns_1');
      expect(loaded.title, hymnB.title);
      expect(loaded.content, hymnB.content);
      expect(loaded.contentCopticArabic, hymnB.contentCopticArabic);
    });

    test('attaches the recording url resolved for the selected hymn', () async {
      final mediaRepository = FakeMediaRepository()
        ..audioUrlForTitle = 'https://drive.google.com/uc?export=download&id=1';
      final viewModel = buildViewModel(
        selected: hymnA,
        mediaRepository: mediaRepository,
      );

      await pumpEventQueue();

      final loaded = viewModel.state.data!;
      expect(loaded.id, 'hymns_0');
      expect(
        loaded.audioUrl,
        'https://drive.google.com/uc?export=download&id=1',
      );
      expect(mediaRepository.audioUrlPaths.single.subject!.id, 'hymns');
    });

    test('keeps audioUrl null when no recording exists for the hymn',
        () async {
      final viewModel = buildViewModel(
        selected: hymnA,
        mediaRepository: FakeMediaRepository()..audioUrlForTitle = null,
      );

      await pumpEventQueue();

      expect(viewModel.state.data!.audioUrl, isNull);
    });

    test('exposes the nav path for the breadcrumb and the title', () async {
      final viewModel = buildViewModel(selected: hymnA);

      await pumpEventQueue();

      expect(viewModel.path.subject!.id, 'hymns');
      expect(viewModel.path.breadcrumb, isNotEmpty);
    });

    test('goes loading → empty when the selected hymn is missing', () async {
      final viewModel = buildViewModel(
        lessons: const [hymnB],
        selected: hymnA,
      );

      await pumpEventQueue();

      expect(viewModel.state.isEmpty, isTrue);
      expect(viewModel.state.data, isNull);
    });

    test('goes loading → error with the historic Arabic message', () async {
      final viewModel = buildViewModel(
        selected: hymnA,
        curriculumRepository: FakeCurriculumRepository()
          ..mediaLessonsError = const AppException('asset مفقود'),
      );

      await pumpEventQueue();

      expect(viewModel.state.isError, isTrue);
      expect(viewModel.state.message, 'تعذر تحميل المحتوى.');
    });

    test('maps unexpected failures to the same error state', () async {
      final viewModel = buildViewModel(
        selected: hymnA,
        curriculumRepository: FakeCurriculumRepository()
          ..mediaLessonsError = const FormatException('broken'),
      );

      await pumpEventQueue();

      expect(viewModel.state.isError, isTrue);
      expect(viewModel.state.message, 'تعذر تحميل المحتوى.');
    });
  });

  group('HymnDetailsViewModel lifecycle', () {
    test('does not notify listeners after being disposed mid-load', () async {
      final viewModel = HymnDetailsViewModel(
        curriculumRepository: FakeCurriculumRepository()
          ..delay = const Duration(milliseconds: 30)
          ..mediaLessonsResult = const [hymnA],
        mediaRepository: FakeMediaRepository(),
        path: buildPath(subject: hymnsSubject),
        lesson: hymnA,
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
