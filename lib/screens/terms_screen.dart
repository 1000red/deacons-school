import 'package:flutter/material.dart';
import '../data/curriculum_data.dart';
import '../models/models.dart';
import 'subjects_screen.dart';

import '../widgets/custom_appbar.dart';
import '../widgets/custom_breadcrumb_bar.dart';
import '../widgets/custom_card.dart';

/// شاشة اختيار الترم الدراسي (3 ترمات لكل سنة).
class TermsScreen extends StatelessWidget {
  final Level level;
  final YearLevel year;
  const TermsScreen({super.key, required this.level, required this.year});

  @override
  Widget build(BuildContext context) {
    final terms = CurriculumData.terms();
    final crumb = '${level.name} • ${year.name}';
    return Scaffold(
      appBar: appBarFor(year.name),
      body: Column(
        children: [
          BreadcrumbBar(text: crumb),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: terms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final term = terms[i];
                final path = NavPath(level: level, year: year, term: term);
                return NavCard(
                  title: term.name,
                  subtitle: 'يحتوي على 5 مواد دراسية',
                  icon: Icons.menu_book,
                  color: level.color.withValues(alpha: 0.9 - i * 0.12),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => SubjectsScreen(path: path))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
