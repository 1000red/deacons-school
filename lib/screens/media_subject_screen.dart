import 'package:flutter/material.dart';

import '../data/curriculum_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_audio_card.dart';
import '../widgets/custom_breadcrumb_bar.dart';
import '../widgets/custom_lesson_image.dart';

/// شاشة المواد التي تحتوي على نص وتسجيل: قبطي وألحان.
class MediaSubjectScreen extends StatelessWidget {
  final NavPath path;

  const MediaSubjectScreen({super.key, required this.path});

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
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('تعذر تحميل المحتوى.'));
                }

                final lessons = snapshot.data ?? [];
                if (lessons.isEmpty) {
                  return const Center(
                      child: Text('لا يوجد محتوى متاح لهذه المادة.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: lessons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) => _LessonCard(
                    lesson: lessons[index],
                    subject: subject,
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

class _LessonCard extends StatelessWidget {
  final MediaLessonItem lesson;
  final Subject subject;

  const _LessonCard({required this.lesson, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: subject.color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (lesson.contentCopticArabic?.isNotEmpty ?? false) ...[
            Text(
              lesson.contentCopticArabic!,
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
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
              accentColor: subject.color,
              height: 180,
              editable: true,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            lesson.content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          AudioPlayerCard(
            color: subject.color,
            audioUrl: lesson.audioUrl,
          ),
        ],
      ),
    );
  }
}
