// import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../data/curriculum_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

import '../widgets/custom_appbar.dart';
import '../widgets/custom_breadcrumb_bar.dart';

class MediaSubjectScreen extends StatelessWidget {
  final NavPath path;

  const MediaSubjectScreen({
    super.key,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    final subject = path.subject!;

    return Scaffold(
      appBar: appBarFor(subject.name),
      body: Column(
        children: [
          BreadcrumbBar(text: path.breadcrumb),
          Expanded(
            child: FutureBuilder<List<MediaLessonItem>>(
              future: CurriculumData.mediaLessons(path),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'تعذر تحميل المحتوى.',
                    ),
                  );
                }

                final lessons = snapshot.data ?? [];

                if (lessons.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا يوجد محتوى متاح لهذه المادة.',
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: lessons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final lesson = lessons[i];

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: subject.color.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // =================================================
                          // عنوان الدرس
                          // =================================================
                          Text(
                            lesson.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // =================================================
                          // مكان الصورة
                          // يظهر فقط للمواد التي تحتاج صورة مثل الألحان
                          // =================================================
                          if (subject.hasImage) ...[
                            _LessonImageSlot(
                              color: subject.color,
                              imageAsset: lesson.imageAsset,
                              lessonTitle: lesson.title,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // =================================================
                          // النص القبطي بالحروف العربية
                          // يظهر لو موجود - للألحان
                          // =================================================
                          if (lesson.contentCopticArabic != null &&
                              lesson.contentCopticArabic!.isNotEmpty) ...[
                            Text(
                              lesson.contentCopticArabic!,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.7,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // =================================================
                          // المحتوى بالعربي
                          // =================================================
                          Text(
                            lesson.content,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.7,
                              color: AppColors.textSecondary,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // =================================================
                          // مشغل الصوت
                          // موجود في كل الأنواع
                          // =================================================
                          _AudioPlayerCard(
                            color: subject.color,
                            audioUrl: lesson.audioUrl,
                            lessonTitle: lesson.title,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Lesson Image Slot
// ============================================================

class _LessonImageSlot extends StatelessWidget {
  final Color color;
  final String? imageAsset;
  final String lessonTitle;

  const _LessonImageSlot({
    required this.color,
    required this.imageAsset,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    // لا توجد صورة حقيقية حتى الآن
    // نعرض Placeholder
    if (imageAsset == null || imageAsset!.isEmpty) {
      return Container(
        width: double.infinity,
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              color: color,
              size: 30,
            ),
            const SizedBox(height: 6),
            Text(
              'الصورة غير متاحة حاليًا',
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    // عند وجود صورة فعلية:
    // يتم استخدام الويدجت التي تحتوي على Zoom + Download
    return _BoardImageWithDownload(
      assetPath: imageAsset!,
      color: color,
      lessonTitle: lessonTitle,
    );
  }
}

// ============================================================
// Audio Player
// ============================================================

class _AudioPlayerCard extends StatefulWidget {
  final Color color;
  final String? audioUrl;
  final String lessonTitle;

  const _AudioPlayerCard({
    required this.color,
    required this.audioUrl,
    required this.lessonTitle,
  });

  @override
  State<_AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<_AudioPlayerCard> {
  final AudioPlayer _player = AudioPlayer();

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _player.onPositionChanged.listen((position) {
      if (!mounted) return;

      setState(() {
        _position = position;
      });
    });

    _player.onDurationChanged.listen((duration) {
      if (!mounted) return;

      setState(() {
        _duration = duration;
      });
    });

    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;

      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;

      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // ============================================================
  // Play / Pause
  // ============================================================

  Future<void> _togglePlay() async {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) {
      _showUnavailableMessage();
      return;
    }

    try {
      if (_isPlaying) {
        await _player.pause();
        return;
      }

      // لو الصوت متوقف في منتصفه نكمل من نفس المكان
      if (_position > Duration.zero) {
        await _player.resume();
      } else {
        setState(() {
          _isLoading = true;
        });

        await _player.play(
          UrlSource(widget.audioUrl!),
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر تشغيل الصوت.',
            ),
          ),
        );
      }
    }
  }

  // ============================================================
  // تقديم 10 ثواني
  // ============================================================

  Future<void> _forward() async {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) {
      _showUnavailableMessage();
      return;
    }

    final newPosition = _position + const Duration(seconds: 10);

    if (newPosition >= _duration) {
      await _player.seek(_duration);
    } else {
      await _player.seek(newPosition);
    }
  }

  // ============================================================
  // رجوع 10 ثواني
  // ============================================================

  Future<void> _rewind() async {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) {
      _showUnavailableMessage();
      return;
    }

    final newPosition = _position - const Duration(seconds: 10);

    await _player.seek(
      newPosition <= Duration.zero ? Duration.zero : newPosition,
    );
  }

  // ============================================================
  // رسالة الصوت غير متاح
  // ============================================================

  void _showUnavailableMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'الصوت غير متاح حاليًا.',
        ),
      ),
    );
  }

  // ============================================================
  // Format Duration
  // ============================================================

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final maxSeconds = _duration.inSeconds.toDouble();

    final currentSeconds = _position.inSeconds
        .clamp(
          0,
          _duration.inSeconds,
        )
        .toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.color.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          // ==========================================================
          // Header
          // ==========================================================

          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.headphones_rounded,
                  color: widget.color,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'الصوت',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.audioUrl == null)
                const Text(
                  'غير متاح',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ==========================================================
          // Progress
          // ==========================================================

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.color,
              inactiveTrackColor: widget.color.withValues(alpha: 0.18),
              thumbColor: widget.color,
              overlayColor: widget.color.withValues(alpha: 0.10),
              trackHeight: 3,
            ),
            child: Slider(
              value: maxSeconds > 0 ? currentSeconds : 0,
              min: 0,
              max: maxSeconds > 0 ? maxSeconds : 1,
              onChanged: widget.audioUrl == null
                  ? null
                  : (value) async {
                      await _player.seek(
                        Duration(
                          seconds: value.toInt(),
                        ),
                      );
                    },
            ),
          ),

          // ==========================================================
          // Time
          // ==========================================================

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ==========================================================
          // Controls
          // ==========================================================

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // رجوع 10
              IconButton(
                onPressed:
                    widget.audioUrl == null ? _showUnavailableMessage : _rewind,
                tooltip: 'رجوع 10 ثواني',
                icon: const Icon(
                  Icons.replay_10_rounded,
                  size: 30,
                ),
              ),

              const SizedBox(width: 8),

              // Play / Pause
              Material(
                color: widget.color,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _togglePlay,
                  child: SizedBox(
                    width: 54,
                    height: 54,
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              _isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // تقديم 10
              IconButton(
                onPressed: widget.audioUrl == null
                    ? _showUnavailableMessage
                    : _forward,
                tooltip: 'تقديم 10 ثواني',
                icon: const Icon(
                  Icons.forward_10_rounded,
                  size: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// صورة السبورة + Download
// ============================================================

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
          const SnackBar(
            content: Text(
              'تم حفظ الصورة في التنزيلات.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر حفظ الصورة، حاول مرة أخرى.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
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
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: widget.color,
                    size: 32,
                  ),
                );
              },
            ),
          ),
        ),

        // Zoom icon
        const Positioned(
          bottom: 8,
          right: 8,
          child: IgnorePointer(
            child: Icon(
              Icons.zoom_in_rounded,
              color: Colors.white,
              size: 22,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),

        // Download button
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
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
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
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return FadeTransition(
            opacity: animation,
            child: _FullScreenImageViewer(
              assetPath: widget.assetPath,
              lessonTitle: widget.lessonTitle,
              onDownload: _downloadImage,
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// Full Screen Image
// ============================================================

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
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                ),
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
                    onTap: () {
                      Navigator.of(context).pop();
                    },
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

// ============================================================
// Circle Button
// ============================================================

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

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
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}
