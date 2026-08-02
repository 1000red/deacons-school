import 'package:flutter/material.dart';
import '../data/curriculum_data.dart';
import '../models/models.dart';
import 'terms_screen.dart';

import '../widgets/custom_appbar.dart';
import '../widgets/custom_breadcrumb_bar.dart';
import '../widgets/custom_card.dart';

/// شاشة اختيار السنة الدراسية داخل مستوى معيّن (3 سنين).
class YearsScreen extends StatelessWidget {
  final Level level;
  const YearsScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final years = CurriculumData.yearsOf(level);
    return Scaffold(
      appBar: appBarFor(level.name),
      body: Column(
        children: [
          BreadcrumbBar(text: level.name),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: years.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final year = years[i];
                return NavCard(
                  title: year.name,
                  subtitle: 'المستوى: ${level.name}',
                  icon: Icons.calendar_month,
                  color: level.color,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => TermsScreen(level: level, year: year))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
