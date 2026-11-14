import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/state/disposable_change_notifier.dart';
import '../../../data/services/audio_playback.dart';
import '../repositories/media_repository.dart';

/// مشغّل الصوت الموحد لشاشة المادة.
///
/// بدل ما كل كارت صوتي يملك مشغّله لوحده (وكان ممكن أكتر من كارت يشغّل
/// في نفس الوقت)، فيه [AudioPlayerViewModel] واحد لكل شاشة مادة:
///
/// - بيتولّى تحميل الملف الصوتي للكاش المحلي مع نسبة تقدّم.
/// - بيضمن إن في تسجيل واحد بس شغّال في أي وقت.
/// - بيحمّل كل الاشتراكات وبيقفل المشغّل في [dispose].
class AudioPlayerViewModel extends DisposableChangeNotifier {
  AudioPlayerViewModel({
    required MediaRepository mediaRepository,
    required IAudioPlayback playback,
    this.downloadTimeout = const Duration(seconds: 60),
  })  : _mediaRepository = mediaRepository,
        _playback = playback {
    _subscriptions = [
      _playback.positionChanges.listen((value) {
        _position = value;
        notifySafely();
      }),
      _playback.durationChanges.listen((value) {
        _duration = value;
        notifySafely();
      }),
      _playback.stateChanges.listen(_onPlaybackStateChanged),
      _playback.completionEvents.listen((_) {
        _isPlaying = false;
        _position = Duration.zero;
        notifySafely();
      }),
    ];
  }

  final MediaRepository _mediaRepository;
  final IAudioPlayback _playback;

  /// مهلة تحميل الملف الصوتي قبل ما نعرض رسالة "الاتصال بطيء جدًا".
  final Duration downloadTimeout;

  late final List<StreamSubscription<dynamic>> _subscriptions;

  String? _activeLessonId;
  bool _isPlaying = false;
  bool _isLoading = false;
  double? _downloadProgress;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  String? get activeLessonId => _activeLessonId;

  bool get isPlaying => _isPlaying;

  bool get isLoading => _isLoading;

  /// نسبة تحميل الملف من 0 لـ 1، و`null` لو لسه محملناش أو الحجم مش معروف.
  double? get downloadProgress => _downloadProgress;

  Duration get position => _position;

  Duration get duration => _duration;

  /// هل الدرس ده هو المفعّل حاليًا في المشغّل الموحد؟
  bool isActive(String lessonId) => _activeLessonId == lessonId;

  /// بيشغّل / يوقف مؤقتًا / يكمل تشغيل الدرس ده.
  ///
  /// يرجّع رسالة خطأ عربية للمستخدم، أو `null` لو مفيش خطأ.
  Future<String?> toggle(String lessonId, String? audioUrl) async {
    final url = _mediaRepository.playableUrl(audioUrl);
    if (url == null || url.isEmpty) return null;

    if (isActive(lessonId)) {
      if (_isPlaying) {
        await _playback.pause();
        // تحديث فوري لحالة التشغيل (الحدث الرسمي بيوصل من المشغّل بعدين).
        _isPlaying = false;
        notifySafely();
        return null;
      }
      if (_position > Duration.zero) {
        await _playback.resume();
        _isPlaying = true;
        notifySafely();
        return null;
      }
    }

    _activeLessonId = lessonId;
    _isLoading = true;
    _downloadProgress = null;
    notifySafely();

    try {
      final file = await _mediaRepository
          .resolveLocalFile(
            url,
            onProgress: (progress) {
              _downloadProgress = progress;
              notifySafely();
            },
          )
          .timeout(
            downloadTimeout,
            onTimeout: () => throw TimeoutException('انتهت مهلة تحميل الصوت'),
          );

      await _playback.playFile(file.path);
      return null;
    } on TimeoutException {
      return 'الاتصال بطيء جدًا، جرّب تاني.';
    } on AppException catch (e) {
      debugPrint('ERROR PLAYING AUDIO: ${e.message}');
      if (e.cause != null) debugPrint('CAUSE: ${e.cause}');
      return e.message;
    } catch (e) {
      debugPrint('ERROR PLAYING AUDIO: $e');
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      _downloadProgress = null;
      notifySafely();
    }
  }

  void seek(Duration position) {
    _playback.seek(position);
  }

  void _onPlaybackStateChanged(AudioPlaybackState state) {
    _isPlaying = state == AudioPlaybackState.playing;
    if (state == AudioPlaybackState.playing) {
      _isLoading = false;
    }
    notifySafely();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    unawaited(_playback.dispose());
    super.dispose();
  }
}
