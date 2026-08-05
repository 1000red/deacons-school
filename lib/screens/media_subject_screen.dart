import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../data/curriculum_data.dart';
import '../data/media_curriculum_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

import '../widgets/custom_appbar.dart';
import '../widgets/custom_breadcrumb_bar.dart';

/// شاشة مادة من نوع "صورة سبورة + مشغل صوت" (زي الألحان): كل درس ليه
/// صورة سبورة ومشغّل صوت خاصين بيه (مش نفس المحتوى مكرر لكل الدروس).
///
/// بنفس فكرة [NotebookSubjectScreen] اللي بتعرض PDF من رابط مباشر، هنا
/// بدل الـ PDF بنعرض صورة + صوت لكل درس، عن طريق [MediaCurriculumData].
class MediaSubjectScreen extends StatelessWidget {
  final NavPath path;
  const MediaSubjectScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    final subject = path.subject!;
    final lessons = CurriculumData.mediaLessons(path);
    return Scaffold(
      appBar: appBarFor(subject.name),
      body: Column(
        children: [
          BreadcrumbBar(text: path.breadcrumb),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: lessons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final lesson = lessons[i];
                // كل درس بياخد صورته وصوته الخاصين بيه حسب مكانه (i) في
                // القايمة، مش نفس المحتوى مكرر لكل الدروس.
                final boardImageAsset =
                    MediaCurriculumData.boardImageAssetFor(path, i);
                final audioUrl = MediaCurriculumData.audioUrlFor(path, i);

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: subject.color.withValues(alpha: 0.18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1) عنوان الدرس
                      Text(lesson.title,
                          style: const TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.bold)),

                      // 2) صورة السبورة (asset محلي) + زرار تنزيل — تُعرض
                      // فقط لو موجودة صورة لهذا الدرس بالذات
                      if (boardImageAsset != null) ...[
                        const SizedBox(height: 12),
                        _BoardImageWithDownload(
                          assetPath: boardImageAsset,
                          color: subject.color,
                          lessonTitle: lesson.title,
                        ),
                      ],

                      // 3) مشغل الصوت أسفل الصورة مباشرة — يُعرض فقط لو
                      // موجود رابط صوت لهذا الدرس بالذات
                      if (audioUrl != null) ...[
                        const SizedBox(height: 12),
                        _NetworkAudioPlayerCard(
                          audioUrl: audioUrl,
                          color: subject.color,
                          lessonTitle: lesson.title,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// صورة السبورة (asset محلي) مع زرار صغير لتنزيلها على الجهاز.
class _BoardImageWithDownload extends StatefulWidget {
  final String assetPath;
  final Color color;
  final String lessonTitle;
  const _BoardImageWithDownload({
    required this.assetPath,
    required this.color,
    required this.lessonTitle,
  });

  @override
  State<_BoardImageWithDownload> createState() =>
      _BoardImageWithDownloadState();
}

class _BoardImageWithDownloadState extends State<_BoardImageWithDownload> {
  bool _saving = false;

  Future<void> _downloadImage() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final byteData = await rootBundle.load(widget.assetPath);
      final bytes = byteData.buffer.asUint8List();
      await FileSaver.instance.saveFile(
        name: 'صورة_${widget.lessonTitle}',
        bytes: bytes,
        fileExtension: 'jpg',
        mimeType: MimeType.jpeg,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الصورة في التنزيلات.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر حفظ الصورة، حاول مرة أخرى.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: () => _openFullScreen(context),
            child: Image.asset(
              widget.assetPath,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.broken_image_outlined,
                    color: widget.color, size: 32),
              ),
            ),
          ),
        ),
        // أيقونة صغيرة بتدل إن الصورة ممكن تتكبر
        const Positioned(
          bottom: 8,
          right: 8,
          child: IgnorePointer(
            child: Padding(
              padding: EdgeInsets.zero,
              child: Icon(Icons.zoom_in_rounded,
                  color: Colors.white,
                  size: 22,
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 6),
                  ]),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Material(
            color: Colors.black.withValues(alpha: 0.45),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _downloadImage,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.download_rounded,
                        color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: _FullScreenImageViewer(
            assetPath: widget.assetPath,
            lessonTitle: widget.lessonTitle,
            onDownload: _downloadImage,
          ),
        ),
      ),
    );
  }
}

/// عرض الصورة بملء الشاشة مع إمكانية التكبير/التصغير بإصبعين (Pinch to
/// zoom) عن طريق [InteractiveViewer]، وزرار تحميل وإغلاق فوق الصورة.
class _FullScreenImageViewer extends StatelessWidget {
  final String assetPath;
  final String lessonTitle;
  final VoidCallback onDownload;
  const _FullScreenImageViewer({
    required this.assetPath,
    required this.lessonTitle,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Image.asset(assetPath, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _CircleIconButton(
                    icon: Icons.download_rounded,
                    onTap: onDownload,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

/// مشغّل صوت حقيقي من رابط شبكة: بينزّل الملف مرة واحدة في الـ cache
/// المؤقت (زي [_NetworkPdfViewer] في NotebookSubjectScreen بالظبط)، ولو
/// موجود بالفعل مش بيعيد التنزيل تاني، بعدين يشغّله محليًا مع إمكانية
/// التقديم/الترجيع الحر، الإيقاف الكامل، وتنزيل الملف على الجهاز.
class _NetworkAudioPlayerCard extends StatefulWidget {
  final String audioUrl;
  final Color color;
  final String lessonTitle;
  const _NetworkAudioPlayerCard({
    required this.audioUrl,
    required this.color,
    required this.lessonTitle,
  });

  @override
  State<_NetworkAudioPlayerCard> createState() =>
      _NetworkAudioPlayerCardState();
}

class _NetworkAudioPlayerCardState extends State<_NetworkAudioPlayerCard> {
  final AudioPlayer _player = AudioPlayer();

  String? _filePath;
  String? _error;
  double _downloadProgress = 0.0;
  bool _downloading = true;
  bool _saving = false;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  static const _skipStep = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _prepareAudio();

    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
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

  /// تحميل ملف الصوت من Google Drive مرة واحدة وتخزينه في الـ cache
  /// المؤقت، وبعد التحميل بنجهّز مصدر الصوت فورًا عشان تظهر المدة الكاملة
  /// قبل ما المستخدم يدوس Play أصلًا.
  Future<void> _prepareAudio() async {
    try {
      final directory = await getTemporaryDirectory();
      final filename = 'media_audio_${widget.audioUrl.hashCode}.mp3';
      final file = File('${directory.path}/$filename');

      final cachedOk = await file.exists() && await file.length() > 1024;
      if (!cachedOk) {
        await _downloadFromDrive(
          widget.audioUrl,
          file,
          onProgress: (p) {
            if (mounted) setState(() => _downloadProgress = p);
          },
        );
      }

      if (await file.length() < 1024) {
        throw Exception('downloaded file too small, likely not audio');
      }

      // نجهّز المصدر فورًا عشان نقدر نعرف مدة الصوت كاملة من غير ما
      // نستنى المستخدم يشغّل الصوت الأول.
      await _player.setSource(DeviceFileSource(file.path));
      final duration = await _player.getDuration();

      if (mounted) {
        setState(() {
          _filePath = file.path;
          _downloading = false;
          if (duration != null) _duration = duration;
        });
      }
    } catch (e, st) {
      debugPrint('MediaSubjectScreen audio prepare failed: $e\n$st');
      if (mounted) {
        setState(() {
          _error = 'تعذر تجهيز الملف الصوتي.\nتفاصيل: $e';
          _downloading = false;
        });
      }
    }
  }

  /// تحميل ملف من Google Drive مع التعامل مع صفحة تحذير "فحص الفيروسات"
  /// اللي بترجع بدل الملف الفعلي لبعض الملفات (حتى لو صغيرة). الفكرة:
  /// لو الرد كان HTML بدل الملف، نستخرج الـ confirm token من الصفحة
  /// ونعيد الطلب بيه، بنفس الأسلوب اللي بتستخدمه أدوات تحميل Drive
  /// المعروفة (زي gdown).
  Future<void> _downloadFromDrive(
    String url,
    File destination, {
    required void Function(double progress) onProgress,
  }) async {
    final dio = Dio();

    Future<Response<List<int>>> fetch(String u) => dio.get<List<int>>(
          u,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            validateStatus: (status) => status != null && status < 500,
          ),
          onReceiveProgress: (received, total) {
            if (total != -1) onProgress(received / total);
          },
        );

    var response = await fetch(
      url.contains('confirm=') ? url : '$url&confirm=t',
    );

    final contentType = response.headers.value('content-type') ?? '';
    List<int> bytes = response.data ?? const [];

    if (contentType.contains('text/html')) {
      // ده على الأغلب صفحة "Google Drive can't scan this file for
      // viruses" - بنستخرج الـ confirm token منها ونعيد المحاولة.
      final html = utf8.decode(bytes, allowMalformed: true);
      final tokenMatch = RegExp(r'confirm=([0-9A-Za-z_\-]+)').firstMatch(html);
      final formMatch = RegExp(
              r'action="(https://drive\.usercontent\.google\.com/download[^"]+)"')
          .firstMatch(html);

      if (formMatch != null) {
        final formUrl = formMatch.group(1)!.replaceAll('&amp;', '&');
        response = await fetch(formUrl);
        bytes = response.data ?? const [];
      } else if (tokenMatch != null) {
        final confirmUrl = '$url&confirm=${tokenMatch.group(1)}';
        response = await fetch(confirmUrl);
        bytes = response.data ?? const [];
      } else {
        throw Exception('drive warning page without confirm token');
      }
    }

    await destination.writeAsBytes(bytes);
  }

  Future<void> _togglePlay() async {
    if (_filePath == null) return;
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  /// إيقاف كامل (مش Pause بس): بيرجع الصوت لأوله وبيوقف التشغيل تمامًا.
  Future<void> _stop() async {
    if (_filePath == null) return;
    await _player.stop();
    // بعد stop() المصدر بيتشال، فبنجهّزه تاني عشان يفضل جاهز للتشغيل
    // ومدة الصوت تفضل ظاهرة صح.
    await _player.setSource(DeviceFileSource(_filePath!));
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    }
  }

  Future<void> _seekBy(Duration offset) async {
    if (_filePath == null) return;
    var target = _position + offset;
    if (target < Duration.zero) target = Duration.zero;
    if (_duration > Duration.zero && target > _duration) target = _duration;
    await _player.seek(target);
    if (mounted) setState(() => _position = target);
  }

  Future<void> _downloadAudio() async {
    if (_filePath == null || _saving) return;
    setState(() => _saving = true);
    try {
      final bytes = await File(_filePath!).readAsBytes();
      await FileSaver.instance.saveFile(
        name: 'صوت_${widget.lessonTitle}',
        bytes: bytes,
        fileExtension: 'mp3',
        mimeType: MimeType.mp3,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الصوت في التنزيلات.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر حفظ الصوت، حاول مرة أخرى.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_error!,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _error = null;
                  _downloading = true;
                  _downloadProgress = 0;
                });
                _prepareAudio();
              },
              icon: Icon(Icons.refresh_rounded, color: widget.color, size: 18),
              label: Text('إعادة المحاولة',
                  style: TextStyle(color: widget.color, fontSize: 12)),
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            ),
          ],
        ),
      );
    }

    if (_downloading || _filePath == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: _downloadProgress > 0 ? _downloadProgress : null,
                color: widget.color,
              ),
            ),
            const SizedBox(width: 10),
            const Text('جارِ تجهيز الصوت...',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      );
    }

    final maxMs = _duration.inMilliseconds == 0
        ? 1.0
        : _duration.inMilliseconds.toDouble();
    final currentMs = _position.inMilliseconds
        .clamp(0, _duration.inMilliseconds == 0 ? 1 : _duration.inMilliseconds)
        .toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'إيقاف',
                onPressed: _stop,
                icon: Icon(Icons.stop_rounded, color: widget.color, size: 24),
              ),
              IconButton(
                tooltip: 'ترجيع 10 ثواني',
                onPressed: () => _seekBy(-_skipStep),
                icon: Icon(Icons.replay_10_rounded,
                    color: widget.color, size: 26),
              ),
              IconButton(
                onPressed: _togglePlay,
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  color: widget.color,
                  size: 40,
                ),
              ),
              IconButton(
                tooltip: 'تقديم 10 ثواني',
                onPressed: () => _seekBy(_skipStep),
                icon: Icon(Icons.forward_10_rounded,
                    color: widget.color, size: 26),
              ),
              IconButton(
                tooltip: 'تنزيل الصوت',
                onPressed: _saving ? null : _downloadAudio,
                icon: _saving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: widget.color),
                      )
                    : Icon(Icons.download_rounded,
                        color: widget.color, size: 24),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
            ),
            child: Slider(
              value: currentMs,
              max: maxMs,
              activeColor: widget.color,
              inactiveColor: widget.color.withValues(alpha: 0.2),
              onChanged: (value) {
                setState(
                    () => _position = Duration(milliseconds: value.toInt()));
              },
              onChangeEnd: (value) {
                _player.seek(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
