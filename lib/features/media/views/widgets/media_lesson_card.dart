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
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: titleOnly
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
            : const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: titleOnly ? _compactBody(color) : _fullBody(color),
      ),
    );
  }

  /// النسخة المضغوطة: العنوان + سهم التنقّل بس (للقائمة الألحان).
  ///
  /// بنسيب العنوان يلغي سطوره لو طويل من غير قصّ، عشان المستخدم يقرا
  /// اسم اللحن كامل ويشوف نفس النص اللي هيقراه في شاشة التفاصيل.
  Widget _compactBody(Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            lesson.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.chevron_left,
          size: 26,
          color: color.withValues(alpha: 0.6),
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
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        if (lesson.contentCopticArabic?.isNotEmpty ?? false) ...[
          Text(
            lesson.contentCopticArabic!,
            style: TextStyle(
              fontSize: 17,
              height: 1.6,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (subject.hasImage) ...[
          LessonImage(
            lessonId: lesson.id,
            assetPath: lesson.imageAsset,
            accentColor: color,
            height: 180,
            editable: true,
          ),
          const SizedBox(height: 12),
        ],
        Text(
          lesson.content,
          style: const TextStyle(
            fontSize: 17,
            height: 1.7,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        AudioPlayerCard(
          color: color,
          lesson: lesson,
        ),
      ],
    );
  }
}
