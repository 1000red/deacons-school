import 'package:flutter/material.dart';
import '../data/curriculum_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

import '../widgets/custom_breadcrumb_bar.dart';

/// شاشة مادة من نوع "محتوى" (طقس/قراءة/محفوظات): المحتوى النصي فقط،
/// مقسّم لدروس/أجزاء بنفس تقسيم المذكرة الأصلية.
class NotebookSubjectScreen extends StatelessWidget {
  final NavPath path;
  const NotebookSubjectScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    final subject = path.subject!;
    final lessons = CurriculumData.notebookLessons(path);
    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
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
                    border:
                        Border.all(color: subject.color.withValues(alpha: 0.18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(subject.icon, color: subject.color, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(lesson.title,
                                  style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(lesson.content,
                          style: const TextStyle(
                              fontSize: 13,
                              height: 1.6,
                              color: AppColors.textSecondary)),
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
