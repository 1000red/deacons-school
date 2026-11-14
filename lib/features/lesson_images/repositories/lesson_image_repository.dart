import 'dart:io';

import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/app_exception.dart';

/// مسؤولية صور الدرس: قراءة الصورة المحفوظة محليًا لدرس، حفظ صورة
/// مختارة من الجهاز بشكل دائم، وحفظ الصورة في معرض الصور بتاع الجهاز.
abstract class LessonImageRepository {
  /// الصورة المحفوظة للدرس ده، أو `null` لو مفيش واحدة.
  Future<File?> localImage(String lessonId);

  /// يفتح معرض الصورة ويحفظ اختيار الدائم للدرس،
  /// ويرجّع `null` لو المستخدم لغى الاختيار.
  Future<File?> pickAndSaveImage(String lessonId);

  /// ينسخ الصورة المختارة لمساحة التطبيق الدائمة ويرجع الملف الناتج.
  Future<File> savePickedImage(String lessonId, String pickedFilePath);

  /// يحفظ الصورة في المعرض؛ يرجّع `false` لو مفيش صورة تُحفظ.
  Future<bool> saveToGallery({File? localFile, String? assetPath});
}

class LessonImageRepositoryImpl implements LessonImageRepository {
  LessonImageRepositoryImpl({
    AssetBundle? assetBundle,
    Future<Directory> Function()? documentsDirectory,
    Future<Directory> Function()? temporaryDirectory,
  })  : _assetBundle = assetBundle ?? rootBundle,
        _documentsDirectory =
            documentsDirectory ?? getApplicationDocumentsDirectory,
        _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final AssetBundle _assetBundle;
  final Future<Directory> Function() _documentsDirectory;
  final Future<Directory> Function() _temporaryDirectory;

  Future<File> _imageFile(String lessonId) async {
    final directory = await _documentsDirectory();
    return File('${directory.path}/lesson_images/$lessonId.jpg');
  }

  @override
  Future<File?> localImage(String lessonId) async {
    final file = await _imageFile(lessonId);
    return await file.exists() ? file : null;
  }

  @override
  Future<File> savePickedImage(String lessonId, String pickedFilePath) async {
    try {
      final target = await _imageFile(lessonId);
      await target.parent.create(recursive: true);
      return await File(pickedFilePath).copy(target.path);
    } catch (e) {
      throw AppException('تعذر حفظ الصورة المختارة', cause: e);
    }
  }

  @override
  Future<File?> pickAndSaveImage(String lessonId) async {
    try {
      final picker = ImagePicker();
      final result = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (result == null) return null;
      return await savePickedImage(lessonId, result.path);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('تعذر اختيار الصورة', cause: e);
    }
  }

  @override
  Future<bool> saveToGallery({File? localFile, String? assetPath}) async {
    try {
      if (localFile != null) {
        await Gal.putImage(localFile.path);
        return true;
      }

      if (assetPath != null && assetPath.isNotEmpty) {
        // الصور من الـ assets لازم تتحول لملف مؤقت الأول قبل ما تتحفظ.
        final byteData = await _assetBundle.load(assetPath);
        final temporaryDirectory = await _temporaryDirectory();
        final tempFile = File('${temporaryDirectory.path}/temp_download.jpg');
        await tempFile.writeAsBytes(byteData.buffer.asUint8List());
        await Gal.putImage(tempFile.path);
        return true;
      }

      return false;
    } catch (e) {
      throw AppException('تعذر حفظ الصورة في المعرض', cause: e);
    }
  }
}
