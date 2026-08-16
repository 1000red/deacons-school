import 'package:flutter/material.dart';
import '../data/curriculum_data.dart';
import '../models/models.dart';
import 'subjects_screen.dart';

import '../widgets/custom_appbar.dart';
import '../widgets/custom_breadcrumb_bar.dart';
import '../widgets/custom_list.dart';

class YearsScreen extends StatefulWidget {
  final Level level;
  const YearsScreen({super.key, required this.level});

  @override
  State<YearsScreen> createState() => _YearsScreenState();
}

class _YearsScreenState extends State<YearsScreen> {
  int? _expandedYearIndex;

  @override
  Widget build(BuildContext context) {
    final years = CurriculumData.yearsOf(widget.level);
    final terms = CurriculumData.terms();

    return Scaffold(
      appBar: appBarFor(widget.level.name),
      body: Column(
        children: [
          BreadcrumbBar(text: widget.level.name),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: years.length,
              itemBuilder: (context, i) {
                final year = years[i];
                final isExpanded = _expandedYearIndex == i;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomList(
                        title: year.name,
                        subtitle: 'المستوى: ${widget.level.name}',
                        icon: Icons.calendar_month,
                        color: widget.level.color,
                        isExpanded: isExpanded,
                        onTap: () {
                          setState(() {
                            _expandedYearIndex = isExpanded ? null : i;
                          });
                        },
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: isExpanded
                            ? Container(
                                margin: const EdgeInsets.only(top: 10.0),
                                padding: const EdgeInsets.only(right: 10.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: widget.level.color
                                          .withValues(alpha: 0.35),
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: List.generate(terms.length, (j) {
                                    final term = terms[j];
                                    final path = NavPath(
                                      level: widget.level,
                                      year: year,
                                      term: term,
                                    );
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: CustomList(
                                        title: term.name,
                                        subtitle: 'يحتوي على 5 مواد دراسية',
                                        icon: Icons.menu_book,
                                        color: widget.level.color,
                                        filled: false,
                                        onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                SubjectsScreen(path: path),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
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
