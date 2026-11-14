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
              padding: const EdgeInsets.all(AppSpacing.screen),
              itemCount: subjects.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.gap),
              itemBuilder: (context, i) {
                final subject = subjects[i];
                final subjectColor =
                    CurriculumPresentation.subjectColor(subject.id);

                return InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () => AppNavigation.openSubject(
                    context,
                    path.copyWith(subject: subject),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.card),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                          color: subjectColor.withValues(alpha: 0.2)),
                      boxShadow: AppShadow.card,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: AppSizes.listIcon,
                          height: AppSizes.listIcon,
                          decoration: BoxDecoration(
                              color: subjectColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle),
                          child: Icon(
                              CurriculumPresentation.subjectIcon(subject.id),
                              color: subjectColor,
                              size: 22),
                        ),
                        const SizedBox(width: AppSpacing.iconGap),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Wrap بدل Row: لو الاسم طويل أو الشارة ما
                              // سعتش، الشارة بتنزل لسطر جديد بدل ما الـ
                              // Row يفيض ويبقى فيه خطوط تحذير.
                              Wrap(
                                spacing: AppSpacing.tight,
                                runSpacing: AppSpacing.stack,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    subject.name,
                                    style: AppTypography.rowTitle,
                                  ),
                                  AppBadge(
                                    label: subject.type == SubjectType.media
                                        ? (subject.hasImage
                                            ? 'نص + صوت + صورة'
                                            : 'نص + صوت')
                                        : 'مذكرة + محتوى',
                                    // شارة بلون المادة صلب + نص أبيض، بنفس
                                    // أسلوب كروت المستويات. النسخة القديمة
                                    // (نص ملوّن على خلفية باهتة) كان تباينها
                                    // 4.25–4.48:1 أي أقل من معيار AA.
                                    background: subjectColor,
                                    foreground: Colors.white,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.stack),
                              Text(
                                subject.description,
                                style: AppTypography.caption,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.tight),
                        const Icon(
                          Icons.chevron_left,
                          color: AppColors.textMuted,
                        ),
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
