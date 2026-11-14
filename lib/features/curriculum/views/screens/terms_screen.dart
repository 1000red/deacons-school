import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/navigator.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/breadcrumb_bar.dart';
import '../../../../core/widgets/custom_list.dart';
import '../../../../data/models/models.dart';
import '../../viewmodels/curriculum_view_model.dart';
import '../curriculum_presentation.dart';

class TermsScreen extends StatelessWidget {
  final Level level;
  final YearLevel year;

  const TermsScreen({super.key, required this.level, required this.year});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CurriculumViewModel>();
    final terms = viewModel.terms;
    final crumb = '${level.name} • ${year.name}';
    final levelColor = CurriculumPresentation.levelColor(level.id);

    return Scaffold(
      appBar: appBarFor(year.name),
      body: Column(
        children: [
          BreadcrumbBar(text: crumb),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screen),
              itemCount: terms.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.gap),
              itemBuilder: (context, i) {
                final term = terms[i];
                final path = NavPath(level: level, year: year, term: term);
                return CustomList(
                  title: term.name,
                  subtitle: 'يحتوي على 5 مواد دراسية',
                  icon: Icons.menu_book,
                  // لون واحد ثابت لكل الترمات (بدل التدرّج حسب الرقم اللي
                  // كان بيقلل تباين النص الأبيض لدرجة غير مقروءة).
                  color: levelColor,
                  onTap: () =>
                      AppNavigation.navigateToSubjectsScreen(context, path),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
