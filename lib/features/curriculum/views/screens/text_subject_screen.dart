import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/breadcrumb_bar.dart';
import '../../../../data/models/models.dart';
import '../../../../di/injection.dart';
import '../../viewmodels/text_subject_view_model.dart';
import '../widgets/lesson_card.dart';

class TextSubjectScreen extends StatelessWidget {
  final NavPath path;

  const TextSubjectScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TextSubjectViewModel>(
      create: (context) => context.read<ViewModelFactory>().textSubject(path),
      child: const _TextSubjectView(),
    );
  }
}

class _TextSubjectView extends StatelessWidget {
  const _TextSubjectView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TextSubjectViewModel>();
    final subject = viewModel.path.subject!;

    return Scaffold(
      appBar: appBarFor(subject.name),
      body: Column(
        children: [
          BreadcrumbBar(text: viewModel.path.breadcrumb),
          Expanded(child: _buildBody(viewModel, subject)),
        ],
      ),
    );
  }

  Widget _buildBody(TextSubjectViewModel viewModel, Subject subject) {
    final state = viewModel.state;

    if (state.isInitial || state.isLoading) {
      return const AppStateView.loading();
    }

    if (state.isError) {
      return AppStateView.error(state.message!);
    }

    if (state.isEmpty) {
      return const AppStateView.empty('لا يوجد محتوى متاح لهذه المادة.');
    }

    final lessons = state.data!;

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screen),
      itemCount: lessons.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.gap),
      itemBuilder: (context, index) => LessonCard(
        subject: subject,
        lesson: lessons[index],
      ),
    );
  }
}
