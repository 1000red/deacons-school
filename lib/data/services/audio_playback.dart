import 'package:audioplayers/audioplayers.dart';

/// حالات التشغيل المجرّدة اللي بيستهلكها الـ ViewModel
/// (منفصلة عن حالات `PlayerState` بتاعة مكتبة audioplayers).
enum AudioPlaybackState { idle, playing, paused, completed }

/// عقد تشغيل الصوت: بيعرض سلوكيات مشغّل الصوت فقط من غير أي منطق تحميل
/// أو كاش — عشان يبقى قابل للاختبار بـ fake في اختبارات الـ ViewModel.
abstract class IAudioPlayback {
  Stream<Duration> get positionChanges;

  Stream<Duration> get durationChanges;

  Stream<AudioPlaybackState> get stateChanges;

  Stream<void> get completionEvents;

  Future<void> playFile(String path);

  Future<void> pause();

  Future<void> resume();

  Future<void> seek(Duration position);

  Future<void> dispose();
}

/// التنفيذ الحقيقي فوق مكتبة `audioplayers`.
class AudioPlayerAdapter implements IAudioPlayback {
  AudioPlayerAdapter() : _player = AudioPlayer();

  final AudioPlayer _player;

  @override
  Stream<Duration> get positionChanges => _player.onPositionChanged;

  @override
  Stream<Duration> get durationChanges => _player.onDurationChanged;

  @override
  Stream<AudioPlaybackState> get stateChanges =>
      _player.onPlayerStateChanged.map(_mapState);

  @override
  Stream<void> get completionEvents => _player.onPlayerComplete;

  @override
  Future<void> playFile(String path) => _player.play(DeviceFileSource(path));

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.resume();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> dispose() => _player.dispose();

  static AudioPlaybackState _mapState(PlayerState state) => switch (state) {
        PlayerState.playing => AudioPlaybackState.playing,
        PlayerState.paused => AudioPlaybackState.paused,
        PlayerState.completed => AudioPlaybackState.completed,
        _ => AudioPlaybackState.idle,
      };
}
