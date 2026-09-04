import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../services/media_recording_data.dart';
import '../../core/theme/app_theme.dart';

/// مشغل الصوت الموحد لكل المواد.
/// يقبل رابطًا عاديًا أو رابط Google Drive؛ وتحويل رابط Drive يتم مركزيًا
/// في [MediaRecordingData].
///
/// بدل ما يعمل stream مباشر من Drive (وده بيفشل كتير)، البلاير بيحمّل
/// الملف مرة واحدة لملف محلي (cache) مع إظهار نسبة التقدّم، وبعدين يشغّله
/// من الجهاز. المرات الجاية بيشغّل فورًا من غير تحميل تاني.
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

  /// نسبة التحميل من 0 لـ 1. null يعني لسه مبدأناش أو الحجم مش معروف.
  double? _downloadProgress;

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

  /// يحمّل الملف من الرابط (لو مش محمّل قبل كده) مع تحديث نسبة التقدّم،
  /// ويرجّع الملف المحلي. اسم الملف مبني على id بتاع Drive، فلو موجود
  /// بالفعل بيرجعه فورًا من غير تحميل جديد.
  Future<File> _resolveLocalFile(String url) async {
    final dir = await getTemporaryDirectory();
    final driveId = Uri.tryParse(url)?.queryParameters['id'];
    final key = driveId ?? url.hashCode.toString();
    final file = File('${dir.path}/audio_cache_$key');

    if (await file.exists()) {
      final size = await file.length();
      if (size > 0) return file;
    }

    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url));
      final streamedResponse = await client.send(request);

      final contentType =
          (streamedResponse.headers['content-type'] ?? '').toLowerCase();

      // لو Google Drive رجّع صفحة HTML (تحذير فيروسات مثلاً) بدل الصوت،
      // منفعش نشغّلها كملف صوتي.
      if (streamedResponse.statusCode != 200 ||
          contentType.contains('text/html')) {
        throw Exception(
          'تعذر تحميل الملف الصوتي. الرابط قد يكون غير صالح أو يحتاج صلاحيات.',
        );
      }

      final total = streamedResponse.contentLength ?? 0;
      var received = 0;
      final sink = file.openWrite();

      await for (final chunk in streamedResponse.stream) {
        received += chunk.length;
        sink.add(chunk);
        if (total > 0 && mounted) {
          setState(() => _downloadProgress = received / total);
        }
      }

      await sink.flush();
      await sink.close();

      return file;
    } finally {
      client.close();
    }
  }

  Future<void> _togglePlay() async {
    final url = MediaRecordingData.playableUrl(widget.audioUrl);
    if (url == null || url.isEmpty) return;

    try {
      if (_isPlaying) {
        await _player.pause();
        return;
      }
      if (_position > Duration.zero) {
        await _player.resume();
        return;
      }

      setState(() {
        _isLoading = true;
        _downloadProgress = null;
      });

      final file = await _resolveLocalFile(url).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('انتهت مهلة تحميل الصوت');
        },
      );

      await _player.play(DeviceFileSource(file.path));
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الاتصال بطيء جدًا، جرّب تاني.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _downloadProgress = null;
        });
      }
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
              if (_isLoading && _downloadProgress != null)
                Text(
                  '${(_downloadProgress! * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(
                value:
                    _downloadProgress, // null = indeterminate (حجم غير معروف)
                color: widget.color,
                backgroundColor: widget.color.withValues(alpha: 0.15),
              ),
            )
          else ...[
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
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: _isLoading ? null : _togglePlay,
                style: FilledButton.styleFrom(
                  backgroundColor: widget.color,
                  shape: const CircleBorder(),
                ),
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
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
