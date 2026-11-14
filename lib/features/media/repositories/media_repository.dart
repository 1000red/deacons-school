import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/models/models.dart';
import '../../../data/services/media_recording_data.dart';

/// مسؤولية المادة الصوتية: إيجاد رابط التسجيل من خريطة Google Drive
/// وتحميله مرة واحدة لملف محلي (كاش) مع نسبة تقدّم.
abstract class MediaRepository {
  /// رابط التسجيل المباشر، أو `null` لو مفيش تسجيل مسجّل للدرس ده.
  String? audioUrl(NavPath path, String lessonTitle);

  /// بيحول أي رابط مشاركة من Google Drive لرابط مناسب للمشغّل.
  String? playableUrl(String? url);

  /// يرجّع الملف الصوتي المحلي، ويحمّله الأول لو مش موجود.
  ///
  /// [onProgress] بينادى بنسبة من 0 لـ 1 أثناء التحميل.
  Future<File> resolveLocalFile(
    String url, {
    void Function(double progress)? onProgress,
  });
}

class MediaRepositoryImpl implements MediaRepository {
  MediaRepositoryImpl({
    http.Client? client,
    Future<Directory> Function()? temporaryDirectory,
  })  : _client = client ?? http.Client(),
        _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  /// عميل HTTP واحد بيتعمل مرة واحدة وبيتعاد استخدامه لكل التحميلات.
  final http.Client _client;
  final Future<Directory> Function() _temporaryDirectory;

  @override
  String? audioUrl(NavPath path, String lessonTitle) =>
      MediaRecordingData.audioUrl(path, lessonTitle);

  @override
  String? playableUrl(String? url) => MediaRecordingData.playableUrl(url);

  @override
  Future<File> resolveLocalFile(
    String url, {
    void Function(double progress)? onProgress,
  }) async {
    final directory = await _temporaryDirectory();

    // اسم الملف مبني على id بتاع Drive، فلو موجود بالفعل بيرجعه فورًا.
    final driveId = Uri.tryParse(url)?.queryParameters['id'];
    final key = driveId ?? url.hashCode.toString();
    final file = File('${directory.path}/audio_cache_$key');

    if (await file.exists() && await file.length() > 0) {
      return file;
    }

    // بنحمّل في ملف `.part` الأول، وبننقله للمكان النهائي بعد نجاح
    // التحميل بالكامل — عشان أي فشل في النص ما يسيبش ملف ناقص في الكاش.
    final partial = File('${file.path}.part');

    try {
      final request = http.Request('GET', Uri.parse(url));
      final streamedResponse = await _client.send(request);

      final contentType =
          (streamedResponse.headers['content-type'] ?? '').toLowerCase();

      // لو Google Drive رجّع صفحة HTML بدل الصوت منفعش نشغّلها كملف صوتي.
      if (streamedResponse.statusCode != 200 ||
          contentType.contains('text/html')) {
        throw const AppException(
          'تعذر تحميل الملف الصوتي. الرابط قد يكون غير صالح أو يحتاج صلاحيات.',
        );
      }

      final total = streamedResponse.contentLength ?? 0;
      var received = 0;

      final sink = partial.openWrite();
      try {
        await for (final chunk in streamedResponse.stream) {
          received += chunk.length;
          sink.add(chunk);
          if (total > 0) {
            onProgress?.call(received / total);
          }
        }
        await sink.flush();
      } finally {
        await sink.close();
      }

      return await partial.rename(file.path);
    } catch (e) {
      await _deleteQuietly(partial);
      if (e is AppException) rethrow;
      throw AppException('تعذر تحميل الملف الصوتي', cause: e);
    }
  }

  Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('ERROR DELETING PARTIAL FILE ${file.path}: $e');
    }
  }
}
