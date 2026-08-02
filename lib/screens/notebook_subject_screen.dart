import 'package:flutter/material.dart';
import '../data/curriculum_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

import '../widgets/custom_breadcrumb_bar.dart';
import '../widgets/custom_placeholder_image.dart';

/// شاشة مادة من نوع "مذكرة + محتوى" (طقس/قراءة/محفوظات): لكل درس تبويبان
/// - صور المذكرة (Placeholder) - المحتوى النصي داخل التطبيق.
class NotebookSubjectScreen extends StatelessWidget {
  final NavPath path;
  const NotebookSubjectScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    final subject = path.subject!;
    final lessons = CurriculumData.notebookLessons(path);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(subject.name),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.menu_book), text: 'المذكرة'),
              Tab(icon: Icon(Icons.article_outlined), text: 'المحتوى'),
            ],
          ),
        ),
        body: Column(
          children: [
            BreadcrumbBar(text: path.breadcrumb),
            Expanded(
              child: TabBarView(
                children: [
                  _NotebookTab(subject: subject, lessons: lessons),
                  _ContentTab(subject: subject, lessons: lessons),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotebookTab extends StatelessWidget {
  final Subject subject;
  final List<NotebookLessonItem> lessons;
  const _NotebookTab({required this.subject, required this.lessons});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
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
            border: Border.all(color: subject.color.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lesson.title,
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${lesson.notebookPages} صفحات من المذكرة',
                  style: const TextStyle(
                      fontSize: 11.5, color: AppColors.textMuted)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    lesson.notebookPages,
                    (p) => Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: PlaceholderImageTile(
                          label: 'صفحة ${p + 1}',
                          icon: Icons.description_outlined,
                          color: subject.color),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContentTab extends StatelessWidget {
  final Subject subject;
  final List<NotebookLessonItem> lessons;
  const _ContentTab({required this.subject, required this.lessons});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
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
            border: Border.all(color: subject.color.withValues(alpha: 0.18)),
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
                              fontSize: 14.5, fontWeight: FontWeight.bold))),
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
    );
  }
}
