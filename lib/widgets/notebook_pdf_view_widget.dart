import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../theme/app_theme.dart';

class NotebookPdfViewWidget extends StatelessWidget {
  final bool loading;
  final String? error;
  final String? localPath;

  const NotebookPdfViewWidget({
    super.key,
    required this.loading,
    required this.error,
    required this.localPath,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null || localPath == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error ?? 'حدث خطأ غير متوقع.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return SfPdfViewer.file(
      File(localPath!),
      pageLayoutMode: PdfPageLayoutMode.continuous,
      scrollDirection: PdfScrollDirection.vertical,
    );
  }
}
