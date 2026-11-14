import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../data/models/models.dart';
import '../data/services/audio_playback.dart';
import '../data/services/curriculum_local_data_source.dart';
import '../features/authentication/repositories/auth_repository.dart';
import '../features/authentication/viewmodels/auth_view_model.dart';
import '../features/curriculum/repositories/curriculum_repository.dart';
import '../features/curriculum/viewmodels/curriculum_view_model.dart';
import '../features/curriculum/viewmodels/text_subject_view_model.dart';
import '../features/lesson_images/repositories/lesson_image_repository.dart';
import '../features/lesson_images/viewmodels/lesson_image_view_model.dart';
import '../features/media/repositories/media_repository.dart';
import '../features/media/viewmodels/audio_player_view_model.dart';
import '../features/media/viewmodels/hymn_details_view_model.dart';
import '../features/media/viewmodels/media_subject_view_model.dart';
import '../features/notebook/repositories/notebook_repository.dart';
import '../features/notebook/viewmodels/notebook_view_model.dart';

/// نقطة تركيب التبعيات (composition root) للمشروع.
///
/// المسؤوليات:
///
/// - إنشاء كل الـ Repositories مرة واحدة في مستوى التطبيق.
/// - إنشاء الـ ViewModels الخاصة بكل شاشة عن طريق [ViewModelFactory].
/// - تزود الشاشات بالـ ViewModels بس (الشاشات ما بتقراش الـ Repositories).
///
/// الـ Repositories بتتعمل `lazy: false` يعني موجودة من أول تشغيل التطبيق
/// قبل ما أول شاشة تترسم.
class ViewModelFactory {
  ViewModelFactory({
    required AuthRepository authRepository,
    required CurriculumRepository curriculumRepository,
    required MediaRepository mediaRepository,
    required NotebookRepository notebookRepository,
    required LessonImageRepository lessonImageRepository,
  })  : _authRepository = authRepository,
        _curriculumRepository = curriculumRepository,
        _mediaRepository = mediaRepository,
        _notebookRepository = notebookRepository,
        _lessonImageRepository = lessonImageRepository;

  final AuthRepository _authRepository;
  final CurriculumRepository _curriculumRepository;
  final MediaRepository _mediaRepository;
  final NotebookRepository _notebookRepository;
  final LessonImageRepository _lessonImageRepository;

  // ===== Auth =====
  AuthViewModel auth() => AuthViewModel(_authRepository);

  // ===== Text subject =====
  TextSubjectViewModel textSubject(NavPath path) => TextSubjectViewModel(
        repository: _curriculumRepository,
        path: path,
      );

  // ===== Media =====
  MediaSubjectViewModel mediaSubject(NavPath path) => MediaSubjectViewModel(
        curriculumRepository: _curriculumRepository,
        mediaRepository: _mediaRepository,
        path: path,
      );

  AudioPlayerViewModel audioPlayer() => AudioPlayerViewModel(
        mediaRepository: _mediaRepository,
        playback: AudioPlayerAdapter(),
      );

  // ===== Hymn details =====
  HymnDetailsViewModel hymnDetails({
    required NavPath path,
    required MediaLessonItem lesson,
  }) =>
      HymnDetailsViewModel(
        curriculumRepository: _curriculumRepository,
        mediaRepository: _mediaRepository,
        path: path,
        lesson: lesson,
      );

  // ===== Lesson images =====
  LessonImageViewModel lessonImage(String lessonId) => LessonImageViewModel(
        repository: _lessonImageRepository,
        lessonId: lessonId,
      );

  // ===== Notebook =====
  NotebookViewModel notebook(NavPath path) => NotebookViewModel(
        repository: _notebookRepository,
        path: path,
      );
}

/// بيبني شجرة التبعيات كاملة ويجمّعها في [MultiProvider] واحد.
///
/// بتتعمل مرة واحدة في `main()` قبل `runApp`، يعني قبل رسم أول شاشة.
Widget buildAppDependencies({required Widget child}) {
  final curriculumLocalDataSource = CurriculumLocalDataSource();

  return MultiProvider(
    providers: [
      // ===== Repositories (من غير lazy عشان تبقى جاهزة من أول تشغيل) =====
      Provider<AuthRepository>(
        create: (_) => const AuthRepositoryImpl(),
        lazy: false,
      ),
      Provider<CurriculumRepository>(
        create: (_) => CurriculumRepositoryImpl(
          localDataSource: curriculumLocalDataSource,
        ),
        lazy: false,
      ),
      Provider<MediaRepository>(
        create: (_) => MediaRepositoryImpl(),
        lazy: false,
      ),
      Provider<NotebookRepository>(
        create: (_) => NotebookRepositoryImpl(),
        lazy: false,
      ),
      Provider<LessonImageRepository>(
        create: (_) => LessonImageRepositoryImpl(),
        lazy: false,
      ),

      // ===== ViewModel factory =====
      Provider<ViewModelFactory>(
        lazy: false,
        create: (context) => ViewModelFactory(
          authRepository: context.read<AuthRepository>(),
          curriculumRepository: context.read<CurriculumRepository>(),
          mediaRepository: context.read<MediaRepository>(),
          notebookRepository: context.read<NotebookRepository>(),
          lessonImageRepository: context.read<LessonImageRepository>(),
        ),
      ),

      // ===== حالة تسجيل الدخول (عامة لكل التطبيق) =====
      ChangeNotifierProvider<AuthViewModel>(
        lazy: false,
        create: (context) => context.read<ViewModelFactory>().auth(),
      ),

      // ===== بيانات المنهج (ثابتة، عامة لكل شاشات التنقل) =====
      ChangeNotifierProvider<CurriculumViewModel>(
        create: (context) => CurriculumViewModel(
          context.read<CurriculumRepository>(),
        ),
      ),
    ],
    child: child,
  );
}
