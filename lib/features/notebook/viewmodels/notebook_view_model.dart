import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/state/disposable_change_notifier.dart';
import '../../../core/state/view_state.dart';
import '../../../data/models/models.dart';
import '../repositories/notebook_repository.dart';

/// نتيجة تنزيل المذكرة على الجهاز، جاهزة لعرضها في SnackBar.
class NotebookDownloadResult {
  const NotebookDownloadResult(this.message, {this.filePath});

  /// النص اللي بيتسعرض للمستخدم.
  final String message;

  /// مسار الملف على الجهاز (لو متاح) عشان زرار "فتح".
  final String? filePath;

  bool get canOpen => filePath != null;
}

/// مسؤولية شاشة المذكرة (PDF):
///
/// - تحضير الملف للعرض (تحميل + كاش مؤقت) عبر [ViewState].
/// - تنزيل الملف على الجهاز مع نسبة تقدّم.
class NotebookViewModel extends DisposableChangeNotifier {
  NotebookViewModel({
    required NotebookRepository repository,
    required NavPath path,
  })  : _repository = repository,
        _path = path {
    prepare();
  }

  final NotebookRepository _repository;
  final NavPath _path;

  ViewState<String> _fileState = const ViewState.initial();
  bool _downloading = false;
  double _downloadProgress = 0;
  String? _savedFilePath;

  /// حالة الملف المخصص للمعاينة (المسار المحلي بتاع الـ PDF).
  ViewState<String> get fileState => _fileState;

  /// مسار المنهج الخاص بالشاشة دي (بيستخدمه العرض للعنوان).
  NavPath get path => _path;

  bool get isDownloading => _downloading;

  double get downloadProgress => _downloadProgress;

  /// آخر مسار اتنزّل بنجاح (بيستخدمه زرار "فتح" في الـ SnackBar).
  String? get savedFilePath => _savedFilePath;

  bool get hasFile =>
      _repository.previewUrl(_path) != null ||
      _repository.directDownloadUrl(_path) != null;

  Future<void> prepare() async {
    if (!hasFile) {
      _fileState = const ViewState.error('لا يوجد ملف متاح لهذه المادة.');
      notifySafely();
      return;
    }

    _fileState = const ViewState.loading();
    notifySafely();

    try {
      final localPath = await _repository.downloadForViewer(_path);
      _fileState = ViewState.success(localPath);
    } on AppException catch (e) {
      debugPrint('ERROR PREPARING NOTEBOOK PDF: ${e.message}');
      if (e.cause != null) debugPrint('CAUSE: ${e.cause}');
      _fileState =
          const ViewState.error('تعذر تحميل الملف، تأكد من الاتصال بالإنترنت.');
    } catch (e, stackTrace) {
      debugPrint('ERROR PREPARING NOTEBOOK PDF: $e');
      debugPrint('STACK TRACE: $stackTrace');
      _fileState =
          const ViewState.error('تعذر تحميل الملف، تأكد من الاتصال بالإنترنت.');
    }

    notifySafely();
  }

  /// بينزّل المذكرة لمساحة مستندات التطبيق.
  ///
  /// يرجّع `null` لو مفيش ملف أصلاً (من غير أي رسالة)، ويرجع نتيجة
  /// فيها رسالة النجاح أو الفشل لعرضها في الـ SnackBar.
  Future<NotebookDownloadResult?> downloadToDevice() async {
    if (!hasFile) return null;

    _downloading = true;
    _downloadProgress = 0;
    notifySafely();

    try {
      final savePath = await _repository.downloadToDevice(
        _path,
        onProgress: (progress) {
          _downloadProgress = progress;
          notifySafely();
        },
      );
      _savedFilePath = savePath;
      _downloading = false;
      _downloadProgress = 0;
      notifySafely();
      return NotebookDownloadResult('تم تحميل الملف بنجاح', filePath: savePath);
    } catch (e) {
      debugPrint('ERROR DOWNLOADING NOTEBOOK PDF: $e');
      _downloading = false;
      _downloadProgress = 0;
      notifySafely();
      return const NotebookDownloadResult('فشل تحميل الملف، حاول مرة أخرى');
    }
  }
}
