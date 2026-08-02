import 'package:flutter/material.dart';
import '../data/curriculum_data.dart';
import '../models/models.dart';

import '../widgets/custom_appbar.dart';
import '../widgets/custom_breadcrumb_bar.dart';
import '../widgets/custom_placeholder_image.dart';
import '../widgets/custom_audio_card.dart';

/// شاشة مادة من نوع "صوت + صور" (ألحان أو قبطي): كل درس/لحن فيه مشغّل صوت
/// تجريبي + صورة من المذكرة + صورة من السبورة بالهزات.
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
                      Text(lesson.title,
                          style: const TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      if (lesson.hasAudio)
                        AudioPlayerCard(
                            title: 'استمع إلى ${subject.name}',
                            duration: lesson.duration,
                            color: subject.color),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (lesson.hasNotebookImage)
                              PlaceholderImageTile(
                                  label: 'صورة من المذكرة',
                                  icon: Icons.menu_book,
                                  color: subject.color),
                            if (lesson.hasNotebookImage)
                              const SizedBox(width: 10),
                            if (lesson.hasBoardImage)
                              PlaceholderImageTile(
                                  label: 'صورة السبورة بالهزات',
                                  icon: Icons.draw,
                                  color: subject.color),
                          ],
                        ),
                      ),
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
