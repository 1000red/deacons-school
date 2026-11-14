import 'dart:convert';
import 'dart:io';

import 'package:deacons_school_mobile/core/errors/app_exception.dart';
import 'package:deacons_school_mobile/data/models/models.dart';
import 'package:deacons_school_mobile/data/services/audio_playback.dart';
import 'package:deacons_school_mobile/di/injection.dart';
import 'package:deacons_school_mobile/features/lesson_images/views/widgets/lesson_image.dart';
import 'package:deacons_school_mobile/features/media/viewmodels/audio_player_view_model.dart';
import 'package:deacons_school_mobile/features/media/viewmodels/hymn_details_view_model.dart';
import 'package:deacons_school_mobile/features/media/views/screens/hymn_details_screen.dart';
import 'package:deacons_school_mobile/features/media/views/screens/media_subject_screen.dart';
import 'package:deacons_school_mobile/features/media/views/widgets/audio_player_card.dart';
import 'package:deacons_school_mobile/features/media/views/widgets/media_lesson_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/fakes.dart';

const _audioUrl =
    'https://drive.usercontent.google.com/download?id=1abc&export=download&authuser=0&confirm=t';

/// PNG صالح بحجم 1×1 بكسل لاختبار عرض الصورة المحفوظة للدرس.
const _tinyPng =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

const _hymnA = MediaLessonItem(
  id: 'hymns_0',
  title: 'أوشية المياه: 12 بؤونه إلى 9 بابه',
  content: 'سطر أول من كلام اللحن\nسطر ثانٍ منه',
  contentCopticArabic: 'طوبه ايَچَيَن إبچيِن موشي',
);

const _hymnB = MediaLessonItem(
  id: 'hymns_1',
  title: 'مرد الابركسيس المختصر',
  content: 'كلام المرد الثاني\nسطر ثانٍ من المرد',
  contentCopticArabic: 'إك اسماروؤت\nسطر قبطي ثانٍ',
);

/// درس مادة "قبطي" (نفس النوع الصوتي) للتأكد إنها لسه بتعرض محتواها
/// الكامل بعد تغيير قائمة الألحان.
const _copticLesson = MediaLessonItem(
  id: 'coptic_0',
  title: 'درس النطق الأول',
  content: 'نص عربي للدرس\nسطر ثانٍ منه',
  contentCopticArabic: 'نص قبطي بالحروف العربية',
);

final _path = buildPath(subject: hymnsSubject);

/// ViewModelFactory وهمية بتبني الـ ViewModels فوق الـ fakes، وتسجّل آخر
/// مشغّل صوت وآخر ViewModel للتفاصيل عشان الاختبارات تراقب دورة حياتهم.
class _TestViewModelFactory extends ViewModelFactory {
  _TestViewModelFactory({
    required FakeAuthRepository authRepository,
    required FakeCurriculumRepository curriculumRepository,
    required FakeMediaRepository mediaRepository,
    required FakeNotebookRepository notebookRepository,
    required FakeLessonImageRepository lessonImageRepository,
  })  : curriculum = curriculumRepository,
        media = mediaRepository,
        lessonImages = lessonImageRepository,
        super(
          authRepository: authRepository,
          curriculumRepository: curriculumRepository,
          mediaRepository: mediaRepository,
          notebookRepository: notebookRepository,
          lessonImageRepository: lessonImageRepository,
        );

  final FakeCurriculumRepository curriculum;
  final FakeMediaRepository media;
  final FakeLessonImageRepository lessonImages;

  final List<FakeAudioPlayback> playbacks = [];
  final List<AudioPlayerViewModel> audioPlayers = [];
  HymnDetailsViewModel? hymnDetailsViewModel;

  @override
  AudioPlayerViewModel audioPlayer() {
    final playback = FakeAudioPlayback();
    final player = AudioPlayerViewModel(
      mediaRepository: media,
      playback: playback,
    );
    playbacks.add(playback);
    audioPlayers.add(player);
    return player;
  }

  @override
  HymnDetailsViewModel hymnDetails({
    required NavPath path,
    required MediaLessonItem lesson,
  }) {
    final viewModel = super.hymnDetails(path: path, lesson: lesson);
    hymnDetailsViewModel = viewModel;
    return viewModel;
  }
}

_TestViewModelFactory _buildFactory({
  String? audioUrlForTitle,
  List<MediaLessonItem> lessons = const [_hymnA, _hymnB],
}) =>
    _TestViewModelFactory(
      authRepository: FakeAuthRepository(),
      curriculumRepository: FakeCurriculumRepository()
        ..mediaLessonsResult = lessons,
      mediaRepository: FakeMediaRepository()
        ..audioUrlForTitle = audioUrlForTitle,
      notebookRepository: FakeNotebookRepository(),
      lessonImageRepository: FakeLessonImageRepository(),
    );

/// بيبني التطبيق زي `main.dart` (RTL + لغة عربي) فوق شاشة القائمة.
Widget _wrapApp(_TestViewModelFactory factory, {required Widget home}) {
  return Provider<ViewModelFactory>.value(
    value: factory,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: home,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hymn_details_screen_test');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  /// شاشة عالية بما يكفي عشان كروت القائمة كلها تظهر في الـ viewport.
  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpList(
    WidgetTester tester,
    _TestViewModelFactory factory,
  ) async {
    await tester.pumpWidget(_wrapApp(
      factory,
      home: MediaSubjectScreen(path: _path),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> openHymn(WidgetTester tester, String title) async {
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
  }

  Finder detailsOf(String text) => find.descendant(
        of: find.byType(HymnDetailsScreen),
        matching: find.text(text),
      );

  group('Hymn navigation', () {
    testWidgets('tapping a hymn opens the details screen with its data',
        (tester) async {
      useTallScreen(tester);
      final factory = _buildFactory(audioUrlForTitle: _audioUrl);

      await pumpList(tester, factory);

      // القائمة تعرضت بشكلها المعتاد
      expect(find.byType(MediaSubjectScreen), findsOneWidget);
      expect(find.text(_hymnA.title), findsOneWidget);
      expect(find.text(_hymnB.title), findsOneWidget);

      // نضغط على اللحن الثاني
      await openHymn(tester, _hymnB.title);

      // الشاشة انفتحت وعرضت بيانات اللحن المختار بس
      expect(find.byType(HymnDetailsScreen), findsOneWidget);
      expect(detailsOf(_hymnB.title), findsOneWidget);
      expect(detailsOf(_hymnA.title), findsNothing);
      expect(detailsOf(_hymnB.content), findsOneWidget);
      expect(detailsOf(_hymnA.content), findsNothing);

      // والـ ViewModel استلم نفس الدرس المختار
      expect(factory.hymnDetailsViewModel!.state.isSuccess, isTrue);
      expect(factory.hymnDetailsViewModel!.state.data!.id, 'hymns_1');
      expect(factory.hymnDetailsViewModel!.path.subject!.id, 'hymns');
    });

    testWidgets('displays the complete lyrics with line breaks preserved',
        (tester) async {
      useTallScreen(tester);
      final factory = _buildFactory(audioUrlForTitle: _audioUrl);

      await pumpList(tester, factory);
      await openHymn(tester, _hymnB.title);

      // العنوان + كلام اللحن العربي + النص القبطي بالحروف العربية،
      // كلها معروضة كاملة من غير قص وبما فيها أسطر السطر الجديد.
      expect(detailsOf(_hymnB.title), findsOneWidget);
      expect(
        detailsOf('كلام المرد الثاني\nسطر ثانٍ من المرد'),
        findsOneWidget,
      );
      expect(
        detailsOf('إك اسماروؤت\nسطر قبطي ثانٍ'),
        findsOneWidget,
      );
    });

    testWidgets(
        'the back button returns to the list and disposes screen resources',
        (tester) async {
      useTallScreen(tester);
      final factory = _buildFactory(audioUrlForTitle: _audioUrl);

      await pumpList(tester, factory);
      await openHymn(tester, _hymnA.title);

      expect(find.byType(HymnDetailsScreen), findsOneWidget);
      // مشغّل للقائمة ومشغّل للتفاصيل (مشغّل واحد لكل شاشة)
      expect(factory.playbacks, hasLength(2));
      expect(factory.hymnDetailsViewModel!.isDisposed, isFalse);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.pump();

      expect(find.byType(HymnDetailsScreen), findsNothing);
      expect(find.byType(MediaSubjectScreen), findsOneWidget);

      // موارد شاشة التفاصيل اتقفلت بالكامل
      expect(factory.hymnDetailsViewModel!.isDisposed, isTrue);
      expect(factory.audioPlayers.last.isDisposed, isTrue);
      expect(factory.playbacks.last.disposed, isTrue);

      // ومشغّل القائمة لسه زي ما هو (الشاشة لسه موجودة)
      expect(factory.audioPlayers.first.isDisposed, isFalse);
      expect(factory.playbacks.first.disposed, isFalse);
    });
  });

  group('Hymn image', () {
    testWidgets('shows a placeholder when the hymn has no image',
        (tester) async {
      useTallScreen(tester);
      final factory = _buildFactory(audioUrlForTitle: _audioUrl);

      await pumpList(tester, factory);
      await openHymn(tester, _hymnA.title);

      expect(
        detailsOf('هذا المحتوى ليس له صورة حاليًا'),
        findsOneWidget,
      );
    });

    testWidgets('displays the saved image when the hymn has one',
        (tester) async {
      useTallScreen(tester);
      final factory = _buildFactory(audioUrlForTitle: _audioUrl);
      factory.lessonImages.storedImage =
          File('${tempDir.path}/hymn.png')..writeAsBytesSync(base64Decode(_tinyPng));

      await pumpList(tester, factory);
      await openHymn(tester, _hymnA.title);

      expect(
        find.descendant(
          of: find.byType(HymnDetailsScreen),
          matching: find.byType(Image),
        ),
        findsOneWidget,
      );
      expect(detailsOf('هذا المحتوى ليس له صورة حاليًا'), findsNothing);
    });
  });

  group('Hymn audio', () {
    testWidgets('shows the unavailable state when there is no recording',
        (tester) async {
      useTallScreen(tester);
      final factory = _buildFactory(audioUrlForTitle: null);

      await pumpList(tester, factory);
      await openHymn(tester, _hymnA.title);

      expect(detailsOf('هذا المحتوى ليس له تسجيل بعد.'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(HymnDetailsScreen),
          matching: find.byIcon(Icons.play_arrow_rounded),
        ),
        findsNothing,
      );
      // مفيش أي مشغّل صوت بيتعمل من غير تسجيل
      expect(factory.playbacks, isEmpty);
    });

    testWidgets('shows the loading state while the recording downloads',
        (tester) async {
      useTallScreen(tester);
      final factory = _buildFactory(audioUrlForTitle: _audioUrl);
      final audioFile = File('${tempDir.path}/audio.mp3')
        ..writeAsStringSync('audio');
      factory.media.fileToReturn = audioFile;
      factory.media.neverCompletes = true;

      await pumpList(tester, factory);
      await openHymn(tester, _hymnA.title);

      final playButton = find.descendant(
        of: find.byType(HymnDetailsScreen),
        matching: find.byIcon(Icons.play_arrow_rounded),
      );
      expect(playButton, findsOneWidget);

      await tester.tap(playButton);
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(HymnDetailsScreen),
          matching: find.byType(LinearProgressIndicator),
        ),
        findsOneWidget,
      );
      // التحميل مربوط باللحن المختار بس
      expect(factory.audioPlayers.last.activeLessonId, 'hymns_0');
      expect(factory.media.requestedUrls, [_audioUrl]);

      // نقفل الشجرة الأول (بيشيل مؤشر التحميل)، وبعدين نعدّي مهلة
      // التحميل (60 ثانية) عشان الـ timer بتاعها ما يفضلش معلّق في الآخر.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 61));
    });

    testWidgets('shows an error message when the recording fails to load',
        (tester) async {
      useTallScreen(tester);
      final factory = _buildFactory(audioUrlForTitle: _audioUrl);
      factory.media.resolveError = const AppException('تعذر تحميل الملف الصوتي');

      await pumpList(tester, factory);
      await openHymn(tester, _hymnA.title);

      await tester.tap(
        find.descendant(
          of: find.byType(HymnDetailsScreen),
          matching: find.byIcon(Icons.play_arrow_rounded),
        ),
      );
      await tester.pump();

      expect(find.text('تعذر تحميل الملف الصوتي'), findsOneWidget);

      // نخفي الـ SnackBar قبل نهاية الاختبار عشان الـ timer بتاعه ما يفضلش معلّق
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });

  group('Hymn details states', () {
    testWidgets('shows a loading indicator while the details load',
        (tester) async {
      useTallScreen(tester);
      final factory = _buildFactory(audioUrlForTitle: _audioUrl);
      factory.curriculum.delay = const Duration(milliseconds: 100);

      await pumpList(tester, factory);

      // نفتح الشاشة من غير ما نستنى عشان نشوف حالة التحميل الأولى
      // (الشاشة بتتبني في إطارين بعد الضغط)
      await tester.tap(find.text(_hymnA.title));
      await tester.pump();
      await tester.pump();

      // لحظة فتح الشاشة: حالة loading من الـ ViewState
      expect(
        find.descendant(
          of: find.byType(HymnDetailsScreen),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );

      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(HymnDetailsScreen),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsNothing,
      );
      expect(detailsOf(_hymnA.title), findsOneWidget);
    });
  });

  group('Hymn list (titles only)', () {
    testWidgets(
        'shows only the titles with a chevron — no lyrics, image or player',
        (tester) async {
      useTallScreen(tester);
      final factory = _buildFactory(audioUrlForTitle: _audioUrl);

      await pumpList(tester, factory);

      final cards = find.byType(MediaLessonCard);
      expect(cards, findsNWidgets(2));

      // كل كارت بيعرض اسم اللحن + سهم التنقّل بس
      expect(
        find.descendant(of: cards, matching: find.text(_hymnA.title)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: cards, matching: find.text(_hymnB.title)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: cards, matching: find.byIcon(Icons.chevron_left)),
        findsNWidgets(2),
      );

      // ولا كلام اللحن (عربي أو قبطي) في القائمة
      expect(
        find.descendant(of: cards, matching: find.text(_hymnA.content)),
        findsNothing,
      );
      expect(
        find.descendant(of: cards, matching: find.text(_hymnB.content)),
        findsNothing,
      );
      expect(
        find.descendant(
          of: cards,
          matching: find.text(_hymnA.contentCopticArabic!),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: cards,
          matching: find.text(_hymnB.contentCopticArabic!),
        ),
        findsNothing,
      );

      // ولا صورة ولا أي عنصر من مشغل الصوت (ولا حالة "مفيش تسجيل")
      expect(
        find.descendant(of: cards, matching: find.byType(LessonImage)),
        findsNothing,
      );
      expect(
        find.descendant(of: cards, matching: find.byType(Image)),
        findsNothing,
      );
      expect(
        find.descendant(of: cards, matching: find.byType(AudioPlayerCard)),
        findsNothing,
      );
      expect(
        find.descendant(of: cards, matching: find.byType(Slider)),
        findsNothing,
      );
      expect(
        find.descendant(
          of: cards,
          matching: find.byIcon(Icons.play_arrow_rounded),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: cards,
          matching: find.byType(LinearProgressIndicator),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: cards,
          matching: find.text('هذا المحتوى ليس له تسجيل بعد.'),
        ),
        findsNothing,
      );
    });

    testWidgets(
        'tapping a hymn opens the existing details screen with its image, '
        'full lyrics and audio player', (tester) async {
      useTallScreen(tester);
      final factory = _buildFactory(audioUrlForTitle: _audioUrl);

      await pumpList(tester, factory);
      await openHymn(tester, _hymnB.title);

      final details = find.byType(HymnDetailsScreen);
      expect(details, findsOneWidget);

      // منطقة الصورة + العنوان + الكلام كاملًا (بما فيه أسطر السطر الجديد)
      expect(
        find.descendant(of: details, matching: find.byType(LessonImage)),
        findsOneWidget,
      );
      expect(detailsOf(_hymnB.title), findsOneWidget);
      expect(detailsOf(_hymnB.content), findsOneWidget);
      expect(detailsOf(_hymnB.contentCopticArabic!), findsOneWidget);

      // مشغل الصوت بتاع اللحن المختار
      expect(
        find.descendant(of: details, matching: find.byType(AudioPlayerCard)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: details,
          matching: find.byIcon(Icons.play_arrow_rounded),
        ),
        findsOneWidget,
      );
    });

    testWidgets('pauses the recording playing in the list before navigating',
        (tester) async {
      useTallScreen(tester);
      final factory = _buildFactory(audioUrlForTitle: _audioUrl);
      factory.media.fileToReturn = File('${tempDir.path}/list_audio.mp3')
        ..writeAsStringSync('audio');

      await pumpList(tester, factory);

      // مشغّل القائمة بيتعمل أول ما حد يقراه (ال_provider كسول)،
      // وبنشغّل عليه تسجيل يدويًا لأن القائمة مبقاش فيها أزرار تشغيل.
      final listContext = tester.element(find.byType(ListView));
      final listPlayer = listContext.read<AudioPlayerViewModel>();
      expect(factory.audioPlayers, hasLength(1));

      await listPlayer.toggle(_hymnA.id, _audioUrl);
      factory.playbacks.first.emitState(AudioPlaybackState.playing);

      // `pumpEventQueue` مش متاح جوه `testWidgets` (المربّع شغّال داخل
      // FakeAsync) فالـ pump بس كافي لتفريغ أحداث الـ stream.
      await tester.pump();
      expect(listPlayer.isPlaying, isTrue);

      await openHymn(tester, _hymnA.title);

      // التسجيل اتقفل قبل ما شاشة التفاصيل تتفتح (مفيش صوتين مع بعض)
      expect(factory.playbacks.first.calls, contains('pause'));
      expect(find.byType(HymnDetailsScreen), findsOneWidget);
      expect(factory.audioPlayers, hasLength(2));
    });
  });

  group('Coptic media list', () {
    testWidgets(
        'keeps the full card: lyrics, audio player and no details navigation',
        (tester) async {
      useTallScreen(tester);
      final factory = _buildFactory(
        audioUrlForTitle: _audioUrl,
        lessons: const [_copticLesson],
      );

      await tester.pumpWidget(_wrapApp(
        factory,
        home: MediaSubjectScreen(path: buildPath(subject: copticSubject)),
      ));
      await tester.pumpAndSettle();

      final card = find.byType(MediaLessonCard);
      expect(card, findsOneWidget);

      // العنوان + الكلام العربي + الكلام القبطي زي ما هو
      expect(
        find.descendant(of: card, matching: find.text(_copticLesson.title)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text(_copticLesson.content)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: card,
          matching: find.text(_copticLesson.contentCopticArabic!),
        ),
        findsOneWidget,
      );

      // مشغل الصوت موجود وشغّال، ومفيش سهم تنقّل ولا شاشة تفاصيل
      expect(
        find.descendant(of: card, matching: find.byType(AudioPlayerCard)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: card,
          matching: find.byIcon(Icons.play_arrow_rounded),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.byIcon(Icons.chevron_left)),
        findsNothing,
      );

      // الضغط على القائمة ما بيفتحش شاشة تفاصيل (القبطي مالوش شاشة تفاصيل)
      await tester.tap(find.text(_copticLesson.title));
      await tester.pumpAndSettle();

      expect(find.byType(HymnDetailsScreen), findsNothing);
      expect(find.byType(MediaSubjectScreen), findsOneWidget);
    });
  });
}
