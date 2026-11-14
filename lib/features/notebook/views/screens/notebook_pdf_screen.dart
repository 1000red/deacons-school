import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../data/models/models.dart';
import '../../../../di/injection.dart';
import '../../viewmodels/notebook_view_model.dart';
import '../widgets/notebook_pdf_view_widget.dart';

/// شاشة عرض المذكرة كـ PDF (تحميل + عرض + تنزيل على الجهاز).
class NotebookPdfScreen extends StatelessWidget {
  final NavPath path;

  const NotebookPdfScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NotebookViewModel>(
      create: (context) => context.read<ViewModelFactory>().notebook(path),
      child: const _NotebookPdfView(),
    );
  }
}

class _NotebookPdfView extends StatelessWidget {
  const _NotebookPdfView();

  Future<void> _downloadToDevice(
    BuildContext context,
    NotebookViewModel viewModel,
  ) async {
    final result = await viewModel.downloadToDevice();

    if (result == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        action: result.canOpen
            ? SnackBarAction(
                label: 'فتح',
                onPressed: () => OpenFilex.open(result.filePath!),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotebookViewModel>();
    final subject = viewModel.path.subject!;
    final fileState = viewModel.fileState;

    return Scaffold(
      appBar: appBarFor(subject.name),
      body: NotebookPdfViewWidget(
        loading: fileState.isInitial || fileState.isLoading,
        error: fileState.isError ? fileState.message : null,
        localPath: fileState.data,
      ),
      floatingActionButton: fileState.isSuccess
          ? FloatingActionButton(
              onPressed: viewModel.isDownloading
                  ? null
                  : () => _downloadToDevice(context, viewModel),
              backgroundColor: AppColors.accentBlue,
              foregroundColor: Colors.white,
              tooltip: 'تنزيل المذكرة على الجهاز',
              child: viewModel.isDownloading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                        value: viewModel.downloadProgress > 0
                            ? viewModel.downloadProgress
                            : null,
                      ),
                    )
                  : const Icon(Icons.download_rounded, color: Colors.white),
            )
          : null,
    );
  }
}
