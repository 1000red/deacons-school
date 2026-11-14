import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/navigator.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/breadcrumb_bar.dart';
import '../../../../data/models/models.dart';
import '../../viewmodels/curriculum_view_model.dart';
import '../curriculum_presentation.dart';

class SubjectsScreen extends StatelessWidget {
  final NavPath path;
  const SubjectsScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CurriculumViewModel>();
    final subjects = viewModel.subjectsFor(path.level);

    return Scaffold(
      appBar: appBarFor(path.term.name),
      body: Column(
        children: [
          BreadcrumbBar(text: path.breadcrumb),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final subject = subjects[i];
                final subjectColor =
                    CurriculumPresentation.subjectColor(subject.id);

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => AppNavigation.openSubject(
                    context,
                    path.copyWith(subject: subject),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: subjectColor.withValues(alpha: 0.2)),
                      boxShadow: [
                        BoxShadow(
                            color: subjectColor.withValues(alpha: 0.08),
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
                              color: subjectColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle),
                          child: Icon(
                              CurriculumPresentation.subjectIcon(subject.id),
                              color: subjectColor,
                              size: 26),
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
                                        ? (subject.hasImage
                                            ? 'نص + صوت + صورة'
                                            : 'نص + صوت')
                                        : 'مذكرة + محتوى',
                                    background:
                                        subjectColor.withValues(alpha: 0.12),
                                    foreground: subjectColor,
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
