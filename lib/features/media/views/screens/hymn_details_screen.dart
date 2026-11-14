import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bar.dart';
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
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isError) {
      return Center(child: Text(state.message!));
    }

    if (state.isEmpty) {
      return const Center(child: Text('لم يتم العثور على هذا اللحن.'));
    }

    final lesson = state.data!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ===== صورة اللحن (أكبر ما يمكن في الأعلى) =====
        LessonImage(
          lessonId: lesson.id,
          assetPath: lesson.imageAsset,
          accentColor: color,
          height: 220,
          editable: true,
        ),
        const SizedBox(height: 16),

        // ===== كلام اللحن =====
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
              if (lesson.contentCopticArabic?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                Text(
                  lesson.contentCopticArabic!,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.8,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                  ),
                ),
              ],
              if (lesson.content.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  lesson.content,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.8,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ===== التسجيل الصوتي =====
        AudioPlayerCard(
          lesson: lesson,
          color: color,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
