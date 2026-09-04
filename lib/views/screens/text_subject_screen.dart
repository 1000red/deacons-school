import 'package:flutter/material.dart';

import '../../services/curriculum_data.dart';
import '../../models/models.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_breadcrumb_bar.dart';
import '../widgets/custom_card.dart';

class TextSubjectScreen extends StatelessWidget {
  final NavPath path;

  const TextSubjectScreen({
    super.key,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    final subject = path.subject!;

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
      ),
      body: Column(
        children: [
          BreadcrumbBar(
            text: path.breadcrumb,
          ),
          Expanded(
            child: FutureBuilder<List<NotebookLessonItem>>(
              future: CurriculumData.textLessons(path),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'تعذر تحميل محتوى المادة.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                final lessons = snapshot.data ?? [];

                if (lessons.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا يوجد محتوى متاح لهذه المادة.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: lessons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];

                    return LessonCard(
                      subject: subject,
                      lesson: lesson,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
