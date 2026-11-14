import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deacons_school_mobile/core/state/view_state.dart';
import 'package:deacons_school_mobile/data/models/models.dart';
import 'package:deacons_school_mobile/data/services/audio_playback.dart';
import 'package:deacons_school_mobile/features/authentication/repositories/auth_repository.dart';
import 'package:deacons_school_mobile/features/curriculum/repositories/curriculum_repository.dart';
import 'package:deacons_school_mobile/features/lesson_images/repositories/lesson_image_repository.dart';
import 'package:deacons_school_mobile/features/media/repositories/media_repository.dart';
import 'package:deacons_school_mobile/features/notebook/repositories/notebook_repository.dart';
import 'package:flutter/services.dart';

/// AssetBundle وهمي بيرجع محتوى محفوظ في الذاكرة، وبيعدّ قراءات كل ملف
/// عشان نقدر نتأكد إن الـ cache شغّال.
class FakeAssetBundle extends AssetBundle {
  FakeAssetBundle(this.assets);

  final Map<String, String> assets;
  final List<String> loadedKeys = [];

  @override
  Future<ByteData> load(String key) async {
    loadedKeys.add(key);
    final text = assets[key];
    if (text == null) {
      throw StateError('FakeAssetBundle: no asset registered for "$key"');
    }
    final bytes = Uint8List.fromList(utf8.encode(text));
    return ByteData.view(bytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    loadedKeys.add(key);
    final text = assets[key];
    if (text == null) {
      throw StateError('FakeAssetBundle: no asset registered for "$key"');
    }
    return text;
  }
}

/// بيانات مسار مساعدة لبناء [NavPath] للاختبارات.
NavPath buildPath({
  String levelId = 'third',
  String yearId = 'third_y2',
  String termId = 't3',
  Subject? subject,
}) {
  final level = Level(
    id: levelId,
    name: 'مستوى',
    subtitle: 'وصف',
    yearsCount: 3,
  );
  return NavPath(
    level: level,
    year: YearLevel(id: yearId, name: 'سنة'),
    term: Term(id: termId, name: 'ترم'),
    subject: subject,
  );
}

const notebookSubject = Subject(
  id: 'notebook',
  name: 'المذكرة',
  type: SubjectType.notebook,
  description: '',
);

const hymnsSubject = Subject(
  id: 'hymns',
  name: 'ألحان',
  type: SubjectType.media,
  description: '',
  hasImage: true,
);

const copticSubject = Subject(
  id: 'coptic',
  name: 'قبطي',
  type: SubjectType.media,
  description: '',
);

const ritesSubject = Subject(
  id: 'rites',
  name: 'طقس',
  type: SubjectType.text,
  description: '',
);

/// AuthRepository وهمي بيحكم على نفس قواعد الدخول الحقيقية.
class FakeAuthRepository implements AuthRepository {
  bool shouldFail = false;
  int callCount = 0;

  @override
  AppUser authenticate(String email, String password) {
    callCount++;
    if (shouldFail) {
      throw const AuthException('خطأ في البريد الإلكتروني أو كلمة المرور');
    }
    return AppUser(name: email.trim(), email: email.trim());
  }
}

/// CurriculumRepository وهمي بنص بنية بسيطة للاختبارات.
class FakeCurriculumRepository implements CurriculumRepository {
  List<NotebookLessonItem> textLessonsResult = const [];
  List<MediaLessonItem> mediaLessonsResult = const [];
  Object? textLessonsError;
  Object? mediaLessonsError;
  Duration delay = Duration.zero;
  int textLessonsCalls = 0;

  @override
  List<Level> get levels => const [];

  @override
  List<Term> terms() => const [];

  @override
  List<YearLevel> yearsOf(Level level) => const [];

  @override
  List<Subject> subjectsFor(Level level) => const [];

  @override
  Future<List<NotebookLessonItem>> textLessons(NavPath path) async {
    textLessonsCalls++;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    final error = textLessonsError;
    if (error != null) throw error;
    return textLessonsResult;
  }

  @override
  Future<List<MediaLessonItem>> mediaLessons(NavPath path) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    final error = mediaLessonsError;
    if (error != null) throw error;
    return mediaLessonsResult;
  }
}

/// MediaRepository وهمي بيرجع مسار ملف محفوظ مسبقًا.
class FakeMediaRepository implements MediaRepository {
  File? fileToReturn;
  Object? resolveError;
  bool neverCompletes = false;
  final List<String> requestedUrls = [];
  final List<NavPath> audioUrlPaths = [];

  String? audioUrlForTitle;

  @override
  String? audioUrl(NavPath path, String lessonTitle) {
    audioUrlPaths.add(path);
    return audioUrlForTitle;
  }

  @override
  String? playableUrl(String? url) => url;

  @override
  Future<File> resolveLocalFile(
    String url, {
    void Function(double progress)? onProgress,
  }) async {
    requestedUrls.add(url);
    if (neverCompletes) {
      return Completer<File>().future;
    }
    final error = resolveError;
    if (error != null) throw error;
    final file = fileToReturn;
    if (file == null) throw StateError('FakeMediaRepository.fileToReturn == null');
    onProgress?.call(1);
    return file;
  }
}

/// NotebookRepository وهمي بلا أي شبكة.
class FakeNotebookRepository implements NotebookRepository {
  String? preview;
  String? direct;
  String viewerPath = '/tmp/fake_viewer.pdf';
  String devicePath = '/tmp/fake_device.pdf';
  Object? viewerError;
  Object? deviceError;
  int viewerCalls = 0;
  int deviceCalls = 0;

  @override
  String? previewUrl(NavPath path) => preview;

  @override
  String? directDownloadUrl(NavPath path) => direct;

  @override
  Future<String> downloadForViewer(NavPath path) async {
    viewerCalls++;
    final error = viewerError;
    if (error != null) throw error;
    return viewerPath;
  }

  @override
  Future<String> downloadToDevice(
    NavPath path, {
    void Function(double progress)? onProgress,
  }) async {
    deviceCalls++;
    final error = deviceError;
    if (error != null) throw error;
    onProgress?.call(0.5);
    return devicePath;
  }
}

/// LessonImageRepository وهمي بلا نظام ملفات حقيقي.
class FakeLessonImageRepository implements LessonImageRepository {
  File? storedImage;
  File? pickedImage;
  bool gallerySaveResult = true;
  Object? galleryError;

  @override
  Future<File?> localImage(String lessonId) async => storedImage;

  @override
  Future<File?> pickAndSaveImage(String lessonId) async => pickedImage;

  @override
  Future<File> savePickedImage(String lessonId, String pickedFilePath) async =>
      File(pickedFilePath);

  @override
  Future<bool> saveToGallery({File? localFile, String? assetPath}) async {
    final error = galleryError;
    if (error != null) throw error;
    return gallerySaveResult;
  }
}

/// مشغّل صوت وهمي بيسجّل النداءات ويبعت أحداث بشكل يدوي.
class FakeAudioPlayback implements IAudioPlayback {
  final List<String> calls = [];
  bool disposed = false;

  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _stateController = StreamController<AudioPlaybackState>.broadcast();
  final _completionController = StreamController<void>.broadcast();

  @override
  Stream<Duration> get positionChanges => _positionController.stream;

  @override
  Stream<Duration> get durationChanges => _durationController.stream;

  @override
  Stream<AudioPlaybackState> get stateChanges => _stateController.stream;

  @override
  Stream<void> get completionEvents => _completionController.stream;

  void emitPosition(Duration value) {
    if (!_positionController.isClosed) _positionController.add(value);
  }

  void emitDuration(Duration value) {
    if (!_durationController.isClosed) _durationController.add(value);
  }

  void emitState(AudioPlaybackState value) {
    if (!_stateController.isClosed) _stateController.add(value);
  }

  void emitCompletion() {
    if (!_completionController.isClosed) _completionController.add(null);
  }

  @override
  Future<void> playFile(String path) async => calls.add('play:$path');

  @override
  Future<void> pause() async => calls.add('pause');

  @override
  Future<void> resume() async => calls.add('resume');

  @override
  Future<void> seek(Duration position) async =>
      calls.add('seek:${position.inSeconds}');

  @override
  Future<void> dispose() async {
    disposed = true;
    calls.add('dispose');
    await _positionController.close();
    await _durationController.close();
    await _stateController.close();
    await _completionController.close();
  }
}

/// مستمع بيجمّع كل الـ statuses اللي بيمر بيها الـ ViewState.
class StateRecorder<T> {
  final List<ViewStateStatus> statuses = [];

  void record(ViewState<T> state) => statuses.add(state.status);
}
