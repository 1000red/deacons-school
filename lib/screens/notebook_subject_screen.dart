import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import '../data/curriculum_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

import '../widgets/custom_breadcrumb_bar.dart';
import '../widgets/custom_placeholder_image.dart';

/// شاشة مادة من نوع "مذكرة + محتوى" (طقس/قراءة/محفوظات): لكل درس تبويبان
/// - صور المذكرة (Placeholder) - المحتوى النصي داخل التطبيق.
///
/// ملحوظة: بدل ما الـ PDF يتحمّل من asset جوه التطبيق، بقى بييجي من
/// رابط Google Drive مباشر (CurriculumData.notebookPdfUrl).
class NotebookSubjectScreen extends StatelessWidget {
  final NavPath path;
  const NotebookSubjectScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    final subject = path.subject!;
    final lessons = CurriculumData.notebookLessons(path);
    // بدل notebookPdfAsset، دلوقتي رابط مباشر (Google Drive uc?export=download)
    final pdfUrl = CurriculumData.notebookPdfUrl(path);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(subject.name),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.picture_as_pdf), text: 'المذكرة'),
              Tab(icon: Icon(Icons.article_outlined), text: 'المحتوى'),
            ],
          ),
        ),
        body: Column(
          children: [
            BreadcrumbBar(text: path.breadcrumb),
            Expanded(
              child: TabBarView(
                children: [
                  _NotebookTab(
                    subject: subject,
                    lessons: lessons,
                    pdfUrl: pdfUrl,
                  ),
                  _ContentTab(
                    subject: subject,
                    lessons: lessons,
                    hasPdfNotebook: pdfUrl != null,
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: pdfUrl == null
            ? null
            : FloatingActionButton(
                backgroundColor: AppColors.primary,
                onPressed: () => _downloadPdf(context, pdfUrl),
                child: const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  /// تنزيل الـ PDF من رابط Google Drive وحفظه في مكان يختاره المستخدم
  /// (التنزيلات) عن طريق file_saver.
  Future<void> _downloadPdf(BuildContext context, String pdfUrl) async {
    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(
        pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = response.data;
      if (bytes == null) throw Exception('empty response');

      await FileSaver.instance.saveFile(
        name: 'مذكرة_المستوى_الثالث_السنة_الثالثة_الترم_الثالث',
        bytes: Uint8List.fromList(bytes),
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ المذكرة في التنزيلات.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تنزيل المذكرة، حاول مرة أخرى.')),
        );
      }
    }
  }
}

class _NotebookTab extends StatelessWidget {
  final Subject subject;
  final List<NotebookLessonItem> lessons;
  final String? pdfUrl;
  const _NotebookTab({
    required this.subject,
    required this.lessons,
    this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (pdfUrl != null) {
      return _NetworkPdfViewer(pdfUrl: pdfUrl!);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final lesson = lessons[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: subject.color.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lesson.title,
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${lesson.notebookPages} صفحات من المذكرة',
                  style: const TextStyle(
                      fontSize: 11.5, color: AppColors.textMuted)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    lesson.notebookPages,
                    (p) => Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: PlaceholderImageTile(
                          label: 'صفحة ${p + 1}',
                          icon: Icons.description_outlined,
                          color: subject.color),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// قارئ PDF من رابط شبكة: بينزّل الملف مرة واحدة في الـ cache المؤقت،
/// ولو موجود بالفعل مش بيعيد التنزيل تاني. [PDFView] محتاج مسار ملف
/// فعلي على القرص، فمينفعش تديله الرابط على طول.
class _NetworkPdfViewer extends StatefulWidget {
  final String pdfUrl;
  const _NetworkPdfViewer({required this.pdfUrl});

  @override
  State<_NetworkPdfViewer> createState() => _NetworkPdfViewerState();
}

class _NetworkPdfViewerState extends State<_NetworkPdfViewer> {
  String? _filePath;
  String? _error;
  double _progress = 0.0;
  bool _downloading = true;

  @override
  void initState() {
    super.initState();
    _preparePdf();
  }

  Future<void> _preparePdf() async {
    try {
      final directory = await getTemporaryDirectory();
      // اسم ملف ثابت مبني على الرابط نفسه عشان الـ cache يشتغل صح
      final filename = 'notebook_${widget.pdfUrl.hashCode}.pdf';
      final file = File('${directory.path}/$filename');

      if (await file.exists() && await file.length() > 0) {
        if (mounted) {
          setState(() {
            _filePath = file.path;
            _downloading = false;
          });
        }
        return;
      }

      final dio = Dio();
      await dio.download(
        widget.pdfUrl,
        file.path,
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() => _progress = received / total);
          }
        },
      );

      if (mounted) {
        setState(() {
          _filePath = file.path;
          _downloading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'تعذر تجهيز ملف المذكرة للعرض.';
          _downloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }
    if (_downloading || _filePath == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(value: _progress > 0 ? _progress : null),
            const SizedBox(height: 12),
            Text('${(_progress * 100).toStringAsFixed(0)}%'),
          ],
        ),
      );
    }
    return PDFView(
      filePath: _filePath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      onError: (_) {
        if (mounted) {
          setState(() => _error = 'تعذر فتح ملف المذكرة.');
        }
      },
    );
  }
}

class _ContentTab extends StatelessWidget {
  final Subject subject;
  final List<NotebookLessonItem> lessons;
  final bool hasPdfNotebook;
  const _ContentTab({
    required this.subject,
    required this.lessons,
    required this.hasPdfNotebook,
  });

  @override
  Widget build(BuildContext context) {
    if (hasPdfNotebook) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'تم رفع المنهج كاملاً في تبويب «المذكرة».',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final lesson = lessons[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: subject.color.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(subject.icon, color: subject.color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(lesson.title,
                          style: const TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 10),
              Text(lesson.content,
                  style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.textSecondary)),
            ],
          ),
        );
      },
    );
  }
}
