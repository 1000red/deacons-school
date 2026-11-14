import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/breadcrumb_bar.dart';
import '../../../../data/models/models.dart';
import '../../../../di/injection.dart';
import '../../../curriculum/views/curriculum_presentation.dart';
import '../../../lesson_images/views/widgets/lesson_image.dart';
import '../../viewmodels/audio_player_view_model.dart';
import '../../viewmodels/hymn_details_view_model.dart';
import '../widgets/audio_player_card.dart';

/// شاشة تفاصيل اللحن: صورة اللحن + كلام اللحن + التسجيل الصوتي.
///
/// الشاشة مسؤولة عن الرسم بس؛ كل الحالة في [HymnDetailsViewModel]
/// (بيانات اللحن المختار) و [AudioPlayerViewModel] (مشغّل صوت واحد
/// للشاشة بينقفل تلقائيًا عند الخروج منها).
class HymnDetailsScreen extends StatelessWidget {
  final NavPath path;
  final MediaLessonItem lesson;

  const HymnDetailsScreen({
    super.key,
    required this.path,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    // نفس نمط شاشة المادة الصوتية: ViewModel للبيانات + مشغّل صوت واحد
    // للشاشة، ففي تسجيل واحد بس بيقدر يشتغل في نفس الوقت.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HymnDetailsViewModel>(
          create: (context) => context
              .read<ViewModelFactory>()
              .hymnDetails(path: path, lesson: lesson),
        ),
        ChangeNotifierProvider<AudioPlayerViewModel>(
          create: (context) => context.read<ViewModelFactory>().audioPlayer(),
        ),
      ],
      child: const _HymnDetailsView(),
    );
  }
}

class _HymnDetailsView extends StatelessWidget {
  const _HymnDetailsView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HymnDetailsViewModel>();
    final subject = viewModel.path.subject;
    final color = CurriculumPresentation.subjectColor(subject?.id ?? 'hymns');

    return Scaffold(
      appBar: appBarFor(subject?.name ?? 'الألحان'),
      body: Column(
        children: [
          BreadcrumbBar(text: viewModel.path.breadcrumb),
          Expanded(child: _buildBody(viewModel, color)),
        ],
      ),
    );
  }

  Widget _buildBody(HymnDetailsViewModel viewModel, Color color) {
    final state = viewModel.state;

    if (state.isInitial || state.isLoading) {
      return const AppStateView.loading();
    }

    if (state.isError) {
      return AppStateView.error(state.message!);
    }

    if (state.isEmpty) {
      return const AppStateView.empty('لم يتم العثور على هذا اللحن.');
    }

    final lesson = state.data!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        // ===== صورة اللحن (أكبر ما يمكن في الأعلى) =====
        LessonImage(
          lessonId: lesson.id,
          assetPath: lesson.imageAsset,
          accentColor: color,
          height: 220,
          editable: true,
        ),
        const SizedBox(height: AppSpacing.section),

        // ===== كلام اللحن =====
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.card),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: color.withValues(alpha: 0.18)),
            boxShadow: AppShadow.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.title,
                style: AppTypography.titleLarge,
              ),
              if (lesson.contentCopticArabic?.isNotEmpty ?? false) ...[
                const SizedBox(height: AppSpacing.gap),
                Text(
                  lesson.contentCopticArabic!,
                  style: AppTypography.body.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (lesson.content.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.gap),
                Text(
                  lesson.content,
                  style: AppTypography.body,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.section),

        // ===== التسجيل الصوتي =====
        AudioPlayerCard(
          lesson: lesson,
          color: color,
        ),
        const SizedBox(height: AppSpacing.section),
      ],
    );
  }
}
