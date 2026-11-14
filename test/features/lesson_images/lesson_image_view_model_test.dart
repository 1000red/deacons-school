import 'dart:io';

import 'package:deacons_school_mobile/features/lesson_images/viewmodels/lesson_image_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LessonImageViewModel', () {
    test('loads the locally stored image of the lesson', () async {
      final stored = File('/tmp/stored_lesson.jpg');
      final viewModel = LessonImageViewModel(
        repository: FakeLessonImageRepository()..storedImage = stored,
        lessonId: 'lesson-1',
      );

      expect(viewModel.isLoading, isTrue);
      await pumpEventQueue();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.localFile, stored);
      expect(viewModel.hasImage(null), isTrue);
    });

    test('hasImage falls back to the asset when nothing is stored', () async {
      final viewModel = LessonImageViewModel(
        repository: FakeLessonImageRepository(),
        lessonId: 'lesson-1',
      );
      await pumpEventQueue();

      expect(viewModel.localFile, isNull);
      expect(viewModel.hasImage('assets/image/kiahk.jpg'), isTrue);
      expect(viewModel.hasImage(null), isFalse);
      expect(viewModel.hasImage(''), isFalse);
    });

    test('keeps the picked image in memory after persisting it', () async {
      final picked = File('/tmp/picked.jpg');
      final viewModel = LessonImageViewModel(
        repository: FakeLessonImageRepository()..pickedImage = picked,
        lessonId: 'lesson-1',
      );
      await pumpEventQueue();

      final error = await viewModel.pickAndPersistImage();

      expect(error, isNull);
      expect(viewModel.localFile, picked);
    });

    test('returns null when the user cancels the picker', () async {
      final viewModel = LessonImageViewModel(
        repository: FakeLessonImageRepository()..pickedImage = null,
        lessonId: 'lesson-1',
      );
      await pumpEventQueue();

      expect(await viewModel.pickAndPersistImage(), isNull);
      expect(viewModel.localFile, isNull);
    });

    test('reports the historic message when saving the image fails', () async {
      final viewModel = LessonImageViewModel(
        repository: FakeLessonImageRepository()
          ..pickedImage = null
          ..galleryError = Exception('permission denied'),
        lessonId: 'lesson-1',
      );
      await pumpEventQueue();

      expect(await viewModel.saveToGallery(), 'تعذر حفظ الصورة');
    });
  });

  group('LessonImageViewModel.saveToGallery', () {
    test('returns the historic success message', () async {
      final viewModel = LessonImageViewModel(
        repository: FakeLessonImageRepository()..gallerySaveResult = true,
        lessonId: 'lesson-1',
      );
      await pumpEventQueue();

      expect(
        await viewModel.saveToGallery(assetPath: 'assets/image/a.jpg'),
        'تم حفظ الصورة في معرض الصور',
      );
    });

    test('returns null when there is nothing to save', () async {
      final viewModel = LessonImageViewModel(
        repository: FakeLessonImageRepository()..gallerySaveResult = false,
        lessonId: 'lesson-1',
      );
      await pumpEventQueue();

      expect(await viewModel.saveToGallery(), isNull);
    });

    test('does not notify listeners after dispose', () async {
      final viewModel = LessonImageViewModel(
        repository: FakeLessonImageRepository(),
        lessonId: 'lesson-1',
      );
      await pumpEventQueue();

      var notified = false;
      viewModel.addListener(() => notified = true);
      viewModel.dispose();
      await viewModel.saveToGallery();

      expect(viewModel.isDisposed, isTrue);
      expect(notified, isFalse);
    });
  });
}
