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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CurriculumPresentation.subjectIcon(subject.id),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                // 1. عنوان الدرس: تم رفعه إلى 18px ليتفوق بصرياً على فقرة النص
                child: Text(
                  lesson.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            color: color.withValues(alpha: 0.12),
            height: 1,
          ),
          const SizedBox(height: 14),
          // 2. محتوى الدرس: تم رفعه من 14px إلى 16.5px لقراءة مريحة جداً وسلسة
          Text(
            lesson.content,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 16.5,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
