import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/widgets/app_state_view.dart';

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
      return const AppStateView.loading();
    }

    if (error != null || localPath == null) {
      return AppStateView.error(error ?? 'حدث خطأ غير متوقع.');
    }

    return SfPdfViewer.file(
      File(localPath!),
      pageLayoutMode: PdfPageLayoutMode.continuous,
      scrollDirection: PdfScrollDirection.vertical,
    );
  }
}
