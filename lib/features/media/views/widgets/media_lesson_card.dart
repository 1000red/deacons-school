import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/models.dart';
import '../../../lesson_images/views/widgets/lesson_image.dart';
import '../../../curriculum/views/curriculum_presentation.dart';
import 'audio_player_card.dart';

/// كارت الدرس في المواد الصوتية (قبطي / ألحان):
/// عنوان + نص قبطي بالحروف العربية + صورة (للألحان) + محتوى + مشغل الصوت.
///
/// لو [titleOnly] اتملا، الكارت بيعرض **العنوان + سهم التنقّل بس**
/// (من غير كلام أو صورة أو مشغل صوت) — بتستخدمه مادة الألحان اللي
/// عندها شاشة تفاصيل مخصّصة.
///
/// لو [onTap] اتملا، الكارت بيبقى قابل للضغط (زي فتح تفاصيل اللحن).
class MediaLessonCard extends StatelessWidget {
  final MediaLessonItem lesson;
  final Subject subject;
  final VoidCallback? onTap;
  final bool titleOnly;

  const MediaLessonCard({
    super.key,
    required this.lesson,
    required this.subject,
    this.onTap,
    this.titleOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = CurriculumPresentation.subjectColor(subject.id);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.card),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.18)),
          boxShadow: AppShadow.card,
        ),
        child: titleOnly ? _compactBody() : _fullBody(color),
      ),
    );
  }

  /// النسخة المضغوطة: العنوان + سهم التنقّل بس (للقائمة الألحان).
  ///
  /// بنسيب العنوان يلغي سطوره لو طويل من غير قصّ، عشان المستخدم يقرا
  /// اسم اللحن كامل ويشوف نفس النص اللي هيقراه في شاشة التفاصيل.
  Widget _compactBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            lesson.title,
            style: AppTypography.rowTitle,
          ),
        ),
        const SizedBox(width: AppSpacing.tight),
        const Icon(
          Icons.chevron_left,
          size: 24,
          color: AppColors.textMuted,
        ),
      ],
    );
  }

  /// النسخة الكاملة: الكلام + الصورة + مشغل الصوت (للمواد اللي مفيهاش
  /// شاشة تفاصيل، زي قبطي).
  Widget _fullBody(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lesson.title,
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: AppSpacing.gap),
        if (lesson.contentCopticArabic?.isNotEmpty ?? false) ...[
          Text(
            lesson.contentCopticArabic!,
            style: AppTypography.body.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.tight),
        ],
        if (subject.hasImage) ...[
          LessonImage(
            lessonId: lesson.id,
            assetPath: lesson.imageAsset,
            accentColor: color,
            height: 180,
            editable: true,
          ),
          const SizedBox(height: AppSpacing.gap),
        ],
        Text(
          lesson.content,
          style: AppTypography.body,
        ),
        const SizedBox(height: AppSpacing.gap),
        AudioPlayerCard(
          color: color,
          lesson: lesson,
        ),
      ],
    );
  }
}
