import 'package:flutter/material.dart';
import '../data/curriculum_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

import '../navigator.dart';

import '../widgets/custom_card.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  void _openLevel(BuildContext context, Level level) {
    if (level.yearsCount == 1) {
      final year = CurriculumData.yearsOf(level).first;
      AppNavigation.navigateToTermsScreen(context, level, year);
    } else {
      AppNavigation.navigateToYearsScreen(context, level);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(right: 16, bottom: 14),
              title: const Text('مدرسة الشمامسة',
                  style: TextStyle(color: Colors.white70, fontSize: 15)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'أهلاً بيك 👋',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('اختر المستوى الدراسي',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('اختَر مستواك للاطلاع على السنين والترمات والمواد',
                      style: TextStyle(
                          fontSize: 12.5, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.95,
                    children: CurriculumData.levels
                        .map((level) => CustomCard(
                              title: level.name,
                              subtitle: level.subtitle,
                              icon: level.icon,
                              color: level.color,
                              onTap: () => _openLevel(context, level),
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
