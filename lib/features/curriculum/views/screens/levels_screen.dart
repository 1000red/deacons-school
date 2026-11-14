import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/navigator.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../data/models/models.dart';
import '../../viewmodels/curriculum_view_model.dart';
import '../curriculum_presentation.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  void _openLevel(
    BuildContext context,
    Level level,
    CurriculumViewModel viewModel,
  ) {
    if (level.yearsCount == 1) {
      final year = viewModel.yearsOf(level).first;
      AppNavigation.navigateToTermsScreen(context, level, year);
    } else {
      AppNavigation.navigateToYearsScreen(context, level);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CurriculumViewModel>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(right: 16, bottom: 14),
              title: const Text(
                'مدرسة الشمامسة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                // التحية في أعلى اللافتة (تحت شريط الأدوات) عشان ما تتلاقيش
                // مع اسم المدرسة اللي في أسفل اللافتة.
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(20, 64, 20, 0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      'أهلاً بيك 👋',
                      style: TextStyle(
                        color: Color(0xD9FFFFFF), // أبيض 85%
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('اختر المستوى الدراسي',
                      style: AppTypography.title),
                  const SizedBox(height: AppSpacing.stack),
                  const Text('اختَر مستواك للاطلاع على السنين والترمات والمواد',
                      style: AppTypography.caption),
                  const SizedBox(height: AppSpacing.section),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.gap,
                    crossAxisSpacing: AppSpacing.gap,
                    // ارتفاع ثابت بدل نسبة من العرض: بيخلي البطاقة مقروءة
                    // على كل عروض الشاشات، ومن غير فراغ زايد تحت النص.
                    // (العنوان سطرين كحد أقصى + الوصف سطر واحد = 154px.)
                    mainAxisExtent: 164,
                    children: viewModel.levels
                        .map((level) => CustomCard(
                              title: level.name,
                              subtitle: level.subtitle,
                              icon: CurriculumPresentation.levelIcon(level.id),
                              color:
                                  CurriculumPresentation.levelColor(level.id),
                              onTap: () =>
                                  _openLevel(context, level, viewModel),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
