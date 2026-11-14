import 'dart:io';

import 'package:deacons_school_mobile/core/errors/app_exception.dart';
import 'package:deacons_school_mobile/data/services/audio_playback.dart';
import 'package:deacons_school_mobile/features/media/viewmodels/audio_player_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

const _urlA = 'https://example.com/a.mp3';
const _urlB = 'https://example.com/b.mp3';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late File audioFile;
  late FakeAudioPlayback playback;
  late FakeMediaRepository media;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('audio_player_vm_test');
    audioFile = File('${tempDir.path}/audio_cache_a')..writeAsStringSync('a');
    playback = FakeAudioPlayback();
    media = FakeMediaRepository()..fileToReturn = audioFile;
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  AudioPlayerViewModel buildViewModel({
    Duration timeout = const Duration(seconds: 1),
  }) =>
      AudioPlayerViewModel(
        mediaRepository: media,
        playback: playback,
        downloadTimeout: timeout,
      );

  group('toggle', () {
    test('downloads the file and starts playback on the first tap', () async {
      final viewModel = buildViewModel();

      final error = await viewModel.toggle('lesson-1', _urlA);

      expect(error, isNull);
      expect(media.requestedUrls, [_urlA]);
      expect(playback.calls, ['play:${audioFile.path}']);
      expect(viewModel.activeLessonId, 'lesson-1');
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.downloadProgress, isNull);
    });

    test('ignores lessons without a playable url', () async {
      final viewModel = buildViewModel();

      expect(await viewModel.toggle('lesson-1', null), isNull);
      expect(await viewModel.toggle('lesson-1', ''), isNull);
      expect(media.requestedUrls, isEmpty);
      expect(playback.calls, isEmpty);
      expect(viewModel.activeLessonId, isNull);
    });

    test('pauses the active lesson on the second tap', () async {
      final viewModel = buildViewModel();
      await viewModel.toggle('lesson-1', _urlA);
      playback.emitState(AudioPlaybackState.playing);
      await pumpEventQueue();
      expect(viewModel.isPlaying, isTrue);

      final error = await viewModel.toggle('lesson-1', _urlA);

      expect(error, isNull);
      expect(playback.calls.last, 'pause');
      expect(viewModel.isPlaying, isFalse);
    });

    test('resumes the active lesson from a previous position', () async {
      final viewModel = buildViewModel();
      await viewModel.toggle('lesson-1', _urlA);
      playback.emitState(AudioPlaybackState.paused);
      playback.emitPosition(const Duration(seconds: 12));
      await pumpEventQueue();

      await viewModel.toggle('lesson-1', _urlA);

      expect(playback.calls.last, 'resume');
    });

    test('replaces the current lesson when another one is tapped', () async {
      final viewModel = buildViewModel();
      await viewModel.toggle('lesson-1', _urlA);
      playback.emitState(AudioPlaybackState.playing);
      await pumpEventQueue();

      await viewModel.toggle('lesson-2', _urlB);

      expect(viewModel.activeLessonId, 'lesson-2');
      expect(
        playback.calls.where((call) => call.startsWith('play:')),
        hasLength(2),
      );
      expect(media.requestedUrls, [_urlA, _urlB]);
    });

    test('reports the repository error message to the caller', () async {
      media.resolveError = const AppException('تعذر تحميل الملف الصوتي.');
      final viewModel = buildViewModel();

      final error = await viewModel.toggle('lesson-1', _urlA);

      expect(error, 'تعذر تحميل الملف الصوتي.');
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.downloadProgress, isNull);
      expect(playback.calls, isEmpty);
    });

    test('reports the historic slow-connection message on timeout', () async {
      media.neverCompletes = true;
      final viewModel = buildViewModel(timeout: const Duration(milliseconds: 20));

      final error = await viewModel.toggle('lesson-1', _urlA);

      expect(error, 'الاتصال بطيء جدًا، جرّب تاني.');
      expect(viewModel.isLoading, isFalse);
    });

    test('publishes the download progress while loading', () async {
      final viewModel = buildViewModel();
      final snapshots = <double?>[];
      viewModel.addListener(() {
        if (viewModel.isLoading) snapshots.add(viewModel.downloadProgress);
      });

      await viewModel.toggle('lesson-1', _urlA);

      expect(snapshots.first, isNull, reason: 'بداية التحميل من غير نسبة');
      expect(snapshots.last, 1.0, reason: 'نسبة التحميل بتتصحّح أثناء التنزيل');
    });
  });

  group('stream events', () {
    test('tracks playback state, position and completion', () async {
      final viewModel = buildViewModel();
      await viewModel.toggle('lesson-1', _urlA);

      playback.emitState(AudioPlaybackState.playing);
      playback.emitDuration(const Duration(seconds: 45));
      playback.emitPosition(const Duration(seconds: 15));
      await pumpEventQueue();

      expect(viewModel.isPlaying, isTrue);
      expect(viewModel.duration, const Duration(seconds: 45));
      expect(viewModel.position, const Duration(seconds: 15));

      playback.emitCompletion();
      await pumpEventQueue();

      expect(viewModel.isPlaying, isFalse);
      expect(viewModel.position, Duration.zero);
    });

    test('seek forwards the requested position to the player', () {
      final viewModel = buildViewModel();

      viewModel.seek(const Duration(seconds: 30));

      expect(playback.calls, ['seek:30']);
    });

    test('isActive only matches the lesson currently loaded', () async {
      final viewModel = buildViewModel();

      await viewModel.toggle('lesson-1', _urlA);

      expect(viewModel.isActive('lesson-1'), isTrue);
      expect(viewModel.isActive('lesson-2'), isFalse);
    });
  });

  group('lifecycle', () {
    test('closes the player and stops notifying after dispose', () async {
      final viewModel = buildViewModel();
      await viewModel.toggle('lesson-1', _urlA);

      var notified = false;
      viewModel.addListener(() => notified = true);
      viewModel.dispose();

      expect(viewModel.isDisposed, isTrue);
      expect(playback.disposed, isTrue);

      playback.emitState(AudioPlaybackState.playing);
      await pumpEventQueue();
      expect(notified, isFalse);
    });
  });
}
