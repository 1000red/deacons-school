import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/navigator.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/custom_list.dart';
import '../../../../data/models/models.dart';
import '../../viewmodels/curriculum_view_model.dart';
import '../curriculum_presentation.dart';

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
    final viewModel = context.watch<CurriculumViewModel>();
    final years = viewModel.yearsOf(widget.level);
    final terms = viewModel.terms;
    final levelColor = CurriculumPresentation.levelColor(widget.level.id);

    return Scaffold(
      appBar: appBarFor(widget.level.name),
      body: Column(
        children: [
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
                        subtitle: widget.level.name,
                        icon: Icons.calendar_month,
                        color: levelColor,
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
                                      color: levelColor,
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
                                        color: levelColor,
                                        filled: false,
                                        onTap: () => AppNavigation
                                            .navigateToSubjectsScreen(
                                                context, path),
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
