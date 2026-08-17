import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class NotebookPdfViewer extends StatelessWidget {
  final String filePath;

  const NotebookPdfViewer({
    super.key,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.file(
      File(filePath),
      pageLayoutMode: PdfPageLayoutMode.continuous,
      scrollDirection: PdfScrollDirection.vertical,
    );
  }
}
