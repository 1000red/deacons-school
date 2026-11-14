import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../di/injection.dart';
import '../../viewmodels/lesson_image_view_model.dart';

/// ويدجت موحدة لعرض صورة الدرس:
/// - بيعرض صورة من assets أو صورة محفوظة محليًا على الجهاز
/// - بيسمح باختيار صورة جديدة من الجهاز وحفظها بشكل دائم
/// - الضغط عليها بيفتح عارض ملء الشاشة مع إمكانية الزوم
/// - فيها زرار لتنزيل/حفظ الصورة في معرض الصور بتاع الجهاز
class LessonImage extends StatelessWidget {
  final String? assetPath;
  final String lessonId;
  final bool editable;
  final double height;
  final Color accentColor;

  const LessonImage({
    super.key,
    required this.lessonId,
    this.assetPath,
    this.editable = false,
    this.height = 180,
    this.accentColor = AppColors.primaryLight,
  });

  @override
  Widget build(BuildContext context) {
    // كل صورة ليها ViewModel خاص بيها (بحسب معرف الدرس) عشان حالتها
    // تفضل مستقلة عن باقي الصور في نفس الشاشة.
    return ChangeNotifierProvider<LessonImageViewModel>(
      create: (context) =>
          context.read<ViewModelFactory>().lessonImage(lessonId),
      child: _LessonImageView(
        assetPath: assetPath,
        editable: editable,
        height: height,
        accentColor: accentColor,
      ),
    );
  }
}

class _LessonImageView extends StatelessWidget {
  final String? assetPath;
  final bool editable;
  final double height;
  final Color accentColor;

  const _LessonImageView({
    required this.assetPath,
    required this.editable,
    required this.height,
    required this.accentColor,
  });

  bool get _hasAsset => assetPath != null && assetPath!.isNotEmpty;

  Future<void> _pickAndPersistImage(
    BuildContext context,
    LessonImageViewModel viewModel,
  ) async {
    final error = await viewModel.pickAndPersistImage();

    if (error == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }

  Future<void> _downloadImage(
    BuildContext context,
    LessonImageViewModel viewModel,
  ) async {
    final message = await viewModel.saveToGallery(assetPath: assetPath);

    if (message == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openFullScreen(BuildContext context, LessonImageViewModel viewModel) {
    final localFile = viewModel.localFile;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(
          assetPath: localFile == null ? assetPath : null,
          file: localFile,
          onDownload: () => _downloadImage(context, viewModel),
        ),
      ),
    );
  }

  Widget _buildImage(LessonImageViewModel viewModel) {
    if (viewModel.isLoading) {
      return _placeholder(child: const CircularProgressIndicator());
    }

    final localFile = viewModel.localFile;

    if (localFile != null) {
      return Image.file(
        localFile,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
      );
    }

    if (_hasAsset) {
      return Image.asset(
        assetPath!,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _placeholder({Widget? child}) {
    return Container(
      width: double.infinity,
      height: height,
      color: accentColor.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: child ??
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_outlined,
                size: 32,
                color: accentColor.withValues(alpha: 0.55),
              ),
              const SizedBox(height: AppSpacing.tight),
              const Text(
                'هذا المحتوى ليس له صورة حاليًا',
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LessonImageViewModel>();
    final hasImage = viewModel.hasImage(assetPath);

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: hasImage ? () => _openFullScreen(context, viewModel) : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: _buildImage(viewModel),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.tight),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasImage)
                _circleButton(
                  Icons.download,
                  () => _downloadImage(context, viewModel),
                ),
              if (editable) ...[
                const SizedBox(width: AppSpacing.tight),
                _circleButton(
                  Icons.camera_alt,
                  () => _pickAndPersistImage(context, viewModel),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Padding(
          // هدف لمس 44×44 زي باقي أزرار التطبيق.
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// شاشة عرض الصورة بحجم كامل مع إمكانية التكبير/التصغير وزرار تنزيل.
class _FullScreenImageViewer extends StatelessWidget {
  final String? assetPath;
  final File? file;
  final VoidCallback onDownload;

  const _FullScreenImageViewer({
    this.assetPath,
    this.file,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: onDownload,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4.0,
          child: Hero(
            tag: file?.path ?? assetPath ?? 'lesson_image',
            child: file != null ? Image.file(file!) : Image.asset(assetPath!),
          ),
        ),
      ),
    );
  }
}
