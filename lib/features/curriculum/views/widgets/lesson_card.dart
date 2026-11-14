import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/models.dart';
import '../curriculum_presentation.dart';

/// كارت درس في المواد النصية (طقس / قراءة / محفوظات).
class LessonCard extends StatelessWidget {
  final Subject subject;
  final NotebookLessonItem lesson;

  const LessonCard({
    super.key,
    required this.subject,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    final color = CurriculumPresentation.subjectColor(subject.id);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  CurriculumPresentation.subjectIcon(subject.id),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.tight),
              Expanded(
                child: Text(
                  lesson.title,
                  style: AppTypography.title,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gap),
          Divider(color: color.withValues(alpha: 0.15)),
          const SizedBox(height: AppSpacing.gap),
          // محتوى الدرس: أطول نص في التطبيق، فبياخد أعلى ارتفاع سطر
          // وأغمق لون عشان يفضل مريح في القراءة الطويلة.
          Text(
            lesson.content,
            textAlign: TextAlign.start,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}
