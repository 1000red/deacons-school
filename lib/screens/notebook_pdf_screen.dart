import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../data/notebook_pdf_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class NotebookPdfScreen extends StatefulWidget {
  final NavPath path;

  const NotebookPdfScreen({super.key, required this.path});

  @override
  State<NotebookPdfScreen> createState() => _NotebookPdfScreenState();
}

class _NotebookPdfScreenState extends State<NotebookPdfScreen> {
  String? _localPath;
  bool _loading = true;
  bool _downloading = false;
  double _downloadProgress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _prepareViewerFile();
  }

  Future<void> _prepareViewerFile() async {
    final url = NotebookPdfData.previewUrl(widget.path) ??
        NotebookPdfData.directDownloadUrl(widget.path);

    if (url == null) {
      setState(() {
        _error = 'لا يوجد ملف متاح لهذه المادة.';
        _loading = false;
      });
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/${widget.path.curriculumKey.replaceAll('/', '_')}.pdf');

      if (!await file.exists()) {
        await Dio().download(url, file.path);
      }

      setState(() {
        _localPath = file.path;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'تعذر تحميل الملف، تأكد من الاتصال بالإنترنت.';
        _loading = false;
      });
    }
  }

  Future<void> _downloadToDevice() async {
    final url = NotebookPdfData.directDownloadUrl(widget.path) ??
        NotebookPdfData.previewUrl(widget.path);
    if (url == null) return;

    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        // على Android 13+ ممكن تحتاج READ_MEDIA / MANAGE_EXTERNAL_STORAGE
        // حسب استهدافك، غالبا استخدام getExternalStorageDirectory كفاية
      }
    }

    setState(() {
      _downloading = true;
      _downloadProgress = 0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          '${widget.path.subject!.name}_${widget.path.curriculumKey.replaceAll('/', '_')}.pdf';
      final savePath = '${dir.path}/$fileName';

      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );

      setState(() => _downloading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم تحميل الملف بنجاح'),
          action: SnackBarAction(
            label: 'فتح',
            onPressed: () => OpenFilex.open(savePath),
          ),
        ),
      );
    } catch (e) {
      setState(() => _downloading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل تحميل الملف، حاول مرة أخرى')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path.subject!.name),
      ),
      body: _buildBody(),
      floatingActionButton: (_localPath != null)
          ? FloatingActionButton(
              onPressed: _downloading ? null : _downloadToDevice,
              backgroundColor: AppColors.primary,
              child: _downloading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                        value: _downloadProgress > 0 ? _downloadProgress : null,
                      ),
                    )
                  : const Icon(Icons.download_rounded, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _localPath == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error ?? 'حدث خطأ غير متوقع.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return SfPdfViewer.file(
      File(_localPath!),
      pageLayoutMode: PdfPageLayoutMode.continuous,
      scrollDirection: PdfScrollDirection.vertical,
    );
  }
}
