import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/models/models.dart';
import '../../../data/services/notebook_pdf_data.dart';

/// مسؤولية المذكرة (PDF): إيجاد رابط الملف من خريطة Google Drive
/// وتحميله للعرض أو تنزيله على الجهاز.
abstract class NotebookRepository {
  /// رابط المعاينة، أو `null` لو مفيش ملف مسجّل للمسار ده.
  String? previewUrl(NavPath path);

  /// رابط التنزيل المباشر، أو `null` لو مفيش ملف مسجّل للمسار ده.
  String? directDownloadUrl(NavPath path);

  /// يحمّل الملف للعرض المؤقت (مكاش في الـ temp) ويرجع مساره المحلي.
  Future<String> downloadForViewer(NavPath path);

  /// يحمّل الملف لمساحة مستندات التطبيق ويرجع مساره المحلي.
  Future<String> downloadToDevice(
    NavPath path, {
    void Function(double progress)? onProgress,
  });
}

class NotebookRepositoryImpl implements NotebookRepository {
  NotebookRepositoryImpl({
    Dio? dio,
    Future<Directory> Function()? temporaryDirectory,
    Future<Directory> Function()? documentsDirectory,
  })  : _dio = dio ?? Dio(),
        _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory,
        _documentsDirectory =
            documentsDirectory ?? getApplicationDocumentsDirectory;

  final Dio _dio;
  final Future<Directory> Function() _temporaryDirectory;
  final Future<Directory> Function() _documentsDirectory;

  @override
  String? previewUrl(NavPath path) => NotebookPdfData.previewUrl(path);

  @override
  String? directDownloadUrl(NavPath path) =>
      NotebookPdfData.directDownloadUrl(path);

  @override
  Future<String> downloadForViewer(NavPath path) async {
    final url = previewUrl(path) ?? directDownloadUrl(path);
    if (url == null) {
      throw const AppException('لا يوجد ملف متاح لهذه المادة.');
    }

    final directory = await _temporaryDirectory();
    final file = File(
        '${directory.path}/${path.curriculumKey.replaceAll('/', '_')}.pdf');

    // الكاش: لو الملف اتحمّل قبل كده بنرجعه فورًا من غير تحميل جديد.
    if (await file.exists()) return file.path;

    try {
      await _dio.download(url, file.path);
    } catch (e) {
      await _deleteQuietly(file);
      throw AppException('تعذر تحميل ملف المذكرة', cause: e);
    }
    return file.path;
  }

  @override
  Future<String> downloadToDevice(
    NavPath path, {
    void Function(double progress)? onProgress,
  }) async {
    final url = directDownloadUrl(path) ?? previewUrl(path);
    if (url == null) {
      throw const AppException('لا يوجد ملف متاح لهذه المادة.');
    }

    final subjectName = path.subject?.name;
    if (subjectName == null) {
      throw const AppException('مسار المنهج غير مكتمل: لا توجد مادة دراسية');
    }

    final directory = await _documentsDirectory();
    final fileName =
        '${subjectName}_${path.curriculumKey.replaceAll('/', '_')}.pdf';
    final savePath = '${directory.path}/$fileName';

    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) onProgress?.call(received / total);
        },
      );
    } catch (e) {
      await _deleteQuietly(File(savePath));
      throw AppException('فشل تحميل المذكرة', cause: e);
    }
    return savePath;
  }

  Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (e) {
      // مسح الملف الناقص فشل؛ بنكتفي بتسجيل الخطأ مش إخفاؤه.
      debugPrint('ERROR DELETING PARTIAL PDF ${file.path}: $e');
    }
  }
}
