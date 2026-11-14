import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/navigator.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/breadcrumb_bar.dart';
import '../../../../data/models/models.dart';
import '../../../../di/injection.dart';
import '../../viewmodels/audio_player_view_model.dart';
import '../../viewmodels/media_subject_view_model.dart';
import '../widgets/media_lesson_card.dart';

/// شاشة عرض دروس المادة الصوتية (قبطي / ألحان).
class MediaSubjectScreen extends StatelessWidget {
  final NavPath path;

  const MediaSubjectScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    // مشغّل الصوت واحد مشترك بين كل كروت الشاشة، ففي تسجيل واحد بس
    // بيقدر يشتغل في نفس الوقت، وبيتقفل تلقائيًا عند الخروج من الشاشة.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MediaSubjectViewModel>(
          create: (context) =>
              context.read<ViewModelFactory>().mediaSubject(path),
        ),
        ChangeNotifierProvider<AudioPlayerViewModel>(
          create: (context) => context.read<ViewModelFactory>().audioPlayer(),
        ),
      ],
      child: const _MediaSubjectView(),
    );
  }
}

class _MediaSubjectView extends StatelessWidget {
  const _MediaSubjectView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MediaSubjectViewModel>();
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

  Widget _buildBody(MediaSubjectViewModel viewModel, Subject subject) {
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
      itemBuilder: (context, index) {
        final lesson = lessons[index];

        // الألحان: كارت مضغوط (العنوان بس) بيفتح شاشة التفاصيل اللي
        // فيها الصورة والكلام والصوت؛ المواد التانية (قبطي) تفضل زي ما
        // هي بالظبط من غير أي تغيير في السلوك.
        final isHymns = subject.id == 'hymns';

        return MediaLessonCard(
          lesson: lesson,
          subject: subject,
          titleOnly: isHymns,
          onTap: isHymns
              ? () => _openHymnDetails(context, viewModel, lesson)
              : null,
        );
      },
    );
  }

  /// بيفتح شاشة تفاصيل اللحن المختار بعد ما يوقّف أي تسجيل شغّال في
  /// القائمة دي (الشاشة بتفضل موجودة في الـ stack تحت شاشة التفاصيل،
  /// فلو سبنا الصوت شغّال ممكن يبقى في صوتين في نفس الوقت).
  Future<void> _openHymnDetails(
    BuildContext context,
    MediaSubjectViewModel viewModel,
    MediaLessonItem lesson,
  ) async {
    final lessons = viewModel.state.data ?? const <MediaLessonItem>[];

    // بنقرأ المشغّل بس لو في درس ليه تسجيل أصلًا، عشان ما نعملش مشغّل
    // صوت جديد من غير داعي للمواد اللي مفيهاش تسجيلات.
    final hasAnyAudio =
        lessons.any((item) => item.audioUrl?.isNotEmpty ?? false);

    if (hasAnyAudio) {
      final player = context.read<AudioPlayerViewModel>();
      final activeId = player.activeLessonId;

      if (activeId != null && player.isPlaying) {
        final active =
            lessons.where((item) => item.id == activeId).firstOrNull;

        if (active != null) {
          await player.toggle(active.id, active.audioUrl);
        }
      }
    }

    if (!context.mounted) return;

    AppNavigation.navigateToHymnDetails(
      context,
      path: viewModel.path,
      lesson: lesson,
    );
  }
}
