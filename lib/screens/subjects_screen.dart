import 'package:flutter/material.dart';
import '../data/curriculum_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'media_subject_screen.dart';
import 'notebook_subject_screen.dart';

import '../widgets/custom_appbar.dart';
import '../widgets/custom_breadcrumb_bar.dart';

/// شاشة عرض المواد الخمس الثابتة لكل ترم: طقس، قبطي، قراءة، محفوظات، ألحان.
class SubjectsScreen extends StatelessWidget {
  final NavPath path;
  const SubjectsScreen({super.key, required this.path});

  void _openSubject(BuildContext context, Subject subject) {
    final newPath = path.copyWith(subject: subject);
    if (subject.type == SubjectType.media) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MediaSubjectScreen(path: newPath)));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => NotebookSubjectScreen(path: newPath)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarFor(path.term.name),
      body: Column(
        children: [
          BreadcrumbBar(text: path.breadcrumb),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: CurriculumData.subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final subject = CurriculumData.subjects[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openSubject(context, subject),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: subject.color.withValues(alpha: 0.2)),
                      boxShadow: [
                        BoxShadow(
                            color: subject.color.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                              color: subject.color.withValues(alpha: 0.12),
                              shape: BoxShape.circle),
                          child: Icon(subject.icon,
                              color: subject.color, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(subject.name,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary)),
                                  const SizedBox(width: 8),
                                  AppBadge(
                                    label: subject.type == SubjectType.media
                                        ? 'صوت + صور'
                                        : 'مذكرة + محتوى',
                                    background:
                                        subject.color.withValues(alpha: 0.12),
                                    foreground: subject.color,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(subject.description,
                                  style: const TextStyle(
                                      fontSize: 11.5, color: Colors.black54),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_left, color: Colors.black26),
                      ],
                    ),
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
