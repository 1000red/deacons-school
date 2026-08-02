import 'package:flutter/material.dart';
import '../data/curriculum_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'years_screen.dart';
import 'terms_screen.dart';

import '../widgets/custom_card.dart';

/// الشاشة الرئيسية بعد الدخول: اختيار المستوى الدراسي (تمهيدي/أول/تاني/تالت).
class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  void _openLevel(BuildContext context, Level level) {
    if (level.yearsCount == 1) {
      final year = CurriculumData.yearsOf(level).first;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TermsScreen(level: level, year: year)));
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => YearsScreen(level: level)));
    }
  }

  void _logout(BuildContext context) {
    AppState.instance.logout();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = AppState.instance.currentUser;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 150,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout))
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(right: 16, bottom: 14),
              title:
                  const Text('مدرسة الشمامسة', style: TextStyle(fontSize: 15)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'أهلاً بيك يا ${user?.name ?? "شماس"} 👋',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
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
                        .map((level) => NavCard(
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
