import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../core/state/disposable_change_notifier.dart';
import '../repositories/lesson_image_repository.dart';

/// صورة الدرس الواحد (لما مادة الألحان يكون لها صورة):
///
/// - بتحمّل الصورة المحفوظة محليًا للدرس (أو بتسيبها فاضية لو مفيش).
/// - بتسمح باختيار صورة جديدة من الجهاز وحفظها بشكل دائم.
/// - بتحفظ الصورة الحالية في معرض الصور بتاع الجهاز.
class LessonImageViewModel extends DisposableChangeNotifier {
  LessonImageViewModel({
    required LessonImageRepository repository,
    required String lessonId,
  })  : _repository = repository,
        _lessonId = lessonId {
    _load();
  }

  final LessonImageRepository _repository;
  final String _lessonId;

  File? _localFile;
  bool _loading = true;

  File? get localFile => _localFile;

  bool get isLoading => _loading;

  /// هل فيه صورة تُعرض (محليًا أو من الـ assets)؟
  bool hasImage(String? assetPath) =>
      _localFile != null || (assetPath?.isNotEmpty ?? false);

  Future<void> _load() async {
    try {
      _localFile = await _repository.localImage(_lessonId);
    } catch (e) {
      debugPrint('ERROR LOADING LESSON IMAGE: $e');
    }
    _loading = false;
    notifySafely();
  }

  /// يرجّع رسالة خطأ للمستخدم، أو `null` لو نجح أو المستخدم لغى الاختيار.
  Future<String?> pickAndPersistImage() async {
    try {
      final file = await _repository.pickAndSaveImage(_lessonId);
      if (file == null) return null;
      _localFile = file;
      notifySafely();
      return null;
    } catch (e) {
      debugPrint('ERROR PICKING LESSON IMAGE: $e');
      return 'تعذر حفظ الصورة';
    }
  }

  /// يرجّع رسالة النجاح، أو `null` لو مفيش صورة تُحفظ.
  Future<String?> saveToGallery({String? assetPath}) async {
    try {
      final saved = await _repository.saveToGallery(
        localFile: _localFile,
        assetPath: assetPath,
      );
      return saved ? 'تم حفظ الصورة في معرض الصور' : null;
    } catch (e) {
      debugPrint('ERROR SAVING LESSON IMAGE TO GALLERY: $e');
      return 'تعذر حفظ الصورة';
    }
  }
}
