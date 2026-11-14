import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/models.dart';
import '../../viewmodels/audio_player_view_model.dart';

/// كارت التشغيل الصوتي الموحد لكل درس.
///
/// الكارت بس مسؤول عن الرسم؛ التحميل والتشغيل والكاش كلها في
/// [AudioPlayerViewModel] المشتركة بين كل كروت الشاشة (ففي تسجيل واحد
/// بس شغّال في أي وقت).
class AudioPlayerCard extends StatelessWidget {
  final MediaLessonItem lesson;
  final Color color;
  final String label;
  final String noAudioMessage;

  const AudioPlayerCard({
    super.key,
    required this.lesson,
    required this.color,
    this.label = 'التسجيل الصوتي',
    this.noAudioMessage = 'هذا المحتوى ليس له تسجيل بعد.',
  });

  bool get _hasAudio => lesson.audioUrl?.isNotEmpty ?? false;

  Future<void> _toggle(BuildContext context) async {
    final viewModel = context.read<AudioPlayerViewModel>();
    final error = await viewModel.toggle(lesson.id, lesson.audioUrl);

    if (error == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAudio) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.gap),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          noAudioMessage,
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(color: color),
        ),
      );
    }

    final viewModel = context.watch<AudioPlayerViewModel>();
    final isActive = viewModel.isActive(lesson.id);
    final isPlaying = isActive && viewModel.isPlaying;
    final isLoading = isActive && viewModel.isLoading;
    final downloadProgress = isActive ? viewModel.downloadProgress : null;
    final position = isActive ? viewModel.position : Duration.zero;
    final duration = isActive ? viewModel.duration : Duration.zero;

    final maximum = duration.inSeconds.toDouble();
    final current =
        position.inSeconds.clamp(0, duration.inSeconds).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.gap,
        vertical: AppSpacing.tight,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.headphones_rounded,
                size: 20,
                color: color,
              ),
              const SizedBox(width: AppSpacing.stack),
              Text(
                label,
                style: AppTypography.rowTitle,
              ),
              const Spacer(),
              if (isLoading && downloadProgress != null)
                Text(
                  '${(downloadProgress * 100).toStringAsFixed(0)}%',
                  style: AppTypography.rowTitle.copyWith(color: color),
                ),
            ],
          ),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.tight),
              child: LinearProgressIndicator(
                value: downloadProgress,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
                minHeight: 3,
              ),
            )
          else
            Row(
              children: [
                // زر التشغيل
                SizedBox(
                  width: AppSizes.iconButton,
                  height: AppSizes.iconButton,
                  child: FilledButton(
                    onPressed: () => _toggle(context),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: color,
                      shape: const CircleBorder(),
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.stack),

                // الـ Slider والوقت
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                        ),
                        child: Slider(
                          value: maximum == 0 ? 0 : current,
                          max: maximum == 0 ? 1 : maximum,
                          activeColor: color,
                          onChanged: maximum == 0
                              ? null
                              : (value) => viewModel.seek(
                                    Duration(seconds: value.toInt()),
                                  ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _format(position),
                            style: AppTypography.label,
                          ),
                          Text(
                            _format(duration),
                            style: AppTypography.label,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static String _format(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
