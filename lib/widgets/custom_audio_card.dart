import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/media_recording_data.dart';
import '../theme/app_theme.dart';

/// مشغل الصوت الموحد لكل المواد.
/// يقبل رابطًا عاديًا أو رابط Google Drive؛ وتحويل رابط Drive يتم مركزيًا
/// في [MediaRecordingData].
class AudioPlayerCard extends StatefulWidget {
  final String? audioUrl;
  final Color color;
  final String label;
  final String noAudioMessage;

  const AudioPlayerCard({
    super.key,
    required this.audioUrl,
    required this.color,
    this.label = 'التسجيل الصوتي',
    this.noAudioMessage = 'هذا المحتوى ليس له تسجيل بعد.',
  });

  @override
  State<AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<AudioPlayerCard> {
  final AudioPlayer _player = AudioPlayer();
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isDownloading = false;

  bool get _hasAudio => widget.audioUrl?.isNotEmpty ?? false;

  @override
  void initState() {
    super.initState();
    _player.onPositionChanged.listen((value) {
      if (mounted) setState(() => _position = value);
    });
    _player.onDurationChanged.listen((value) {
      if (mounted) setState(() => _duration = value);
    });
    _player.onPlayerStateChanged.listen((value) {
      if (mounted) {
        setState(() {
          _isPlaying = value == PlayerState.playing;
          // خط أمان: أول ما الحالة تتغير فعليًا (تشغيل/إيقاف/إيقاف مؤقت)
          // لازم نطفي اللودينج، حتى لو الـ Future بتاع play() لسه معلق.
          _isLoading = false;
        });
      }
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final url = MediaRecordingData.playableUrl(widget.audioUrl);
    if (url == null || url.isEmpty) return;

    try {
      if (_isPlaying) {
        await _player.pause();
      } else if (_position > Duration.zero) {
        await _player.resume();
      } else {
        setState(() => _isLoading = true);
        // تايم أوت عشان لو الرابط بطيء أو فيه مشكلة شبكة،
        // اللودينج يتوقف بدل ما يفضل شغال للأبد.
        await _player.play(UrlSource(url)).timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            throw TimeoutException('انتهت مهلة تحميل الصوت');
          },
        );
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الاتصال بطيء جدًا، جرّب تاني.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تشغيل الصوت.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadAudio() async {
    final url = MediaRecordingData.playableUrl(widget.audioUrl);
    if (url == null || url.isEmpty) return;

    setState(() => _isDownloading = true);
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح رابط التحميل.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تحميل الملف.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  String _format(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAudio) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          widget.noAudioMessage,
          textAlign: TextAlign.center,
          style: TextStyle(color: widget.color),
        ),
      );
    }

    final maximum = _duration.inSeconds.toDouble();
    final current =
        _position.inSeconds.clamp(0, _duration.inSeconds).toDouble();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.color.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.headphones_rounded, color: widget.color),
              const SizedBox(width: 8),
              Text(widget.label,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                onPressed: _isDownloading ? null : _downloadAudio,
                icon: _isDownloading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.color,
                        ),
                      )
                    : Icon(Icons.download_rounded, color: widget.color),
                tooltip: 'تحميل التسجيل',
              ),
            ],
          ),
          Slider(
            value: maximum == 0 ? 0 : current,
            max: maximum == 0 ? 1 : maximum,
            activeColor: widget.color,
            onChanged: (value) =>
                _player.seek(Duration(seconds: value.toInt())),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_format(_position),
                  style: const TextStyle(color: AppColors.textMuted)),
              Text(_format(_duration),
                  style: const TextStyle(color: AppColors.textMuted)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: _togglePlay,
                style: FilledButton.styleFrom(
                  backgroundColor: widget.color,
                  shape: const CircleBorder(),
                ),
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
