import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/models.dart';
import 'package:flutter/foundation.dart';

/// بيقرا ملفات الـ JSON من assets/curriculum/{level}/{year}/{term}.json
/// وبيحولها لـ NotebookLessonItem حسب المادة (subject) المطلوبة.
///
/// بيعمل cache للملف بعد أول قراءة عشان ميعملش قراءة من الـ disk
/// في كل مرة يفتح فيها المستخدم نفس المادة.
class CurriculumJsonLoader {
  CurriculumJsonLoader._();

  static final Map<String, Map<String, dynamic>> _cache = {};

  /// path.level.id مثلاً 'third', path.year.id مثلاً 'third_y2',
  /// path.term.id مثلاً 't3'
  static Future<Map<String, dynamic>> _loadTermJson(NavPath path) async {
    final assetPath =
        'assets/curriculum/${path.level.id}/${path.year!.id}/${path.term.id}.json';

    try {
      final raw = await rootBundle.loadString(assetPath);

      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      _cache[assetPath] = decoded;

      return decoded;
    } catch (e, stackTrace) {
      debugPrint('ERROR LOADING JSON: $assetPath');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      return {};
    }
  }

  /// بيرجع دروس مادة notebook-type (زي rites, reading, memorization)
  static Future<List<NotebookLessonItem>> notebookLessons(
    NavPath path,
  ) async {
    final termJson = await _loadTermJson(path);

    final subjects = termJson['subjects'] as Map<String, dynamic>?;

    final subjectId = path.subject!.id;
    final list = subjects?[subjectId] as List<dynamic>?;

    if (list == null) return [];

    return list
        .map(
          (item) => NotebookLessonItem(
            title: item['title'] as String,
            notebookPages: item['notebookPages'] as int,
            content: item['content'] as String,
          ),
        )
        .toList();
  }

  static Future<List<MediaLessonItem>> mediaLessons(
    NavPath path,
  ) async {
    final termJson = await _loadTermJson(path);

    final subjects = termJson['subjects'] as Map<String, dynamic>?;
    if (subjects == null) return [];

    final subjectId = path.subject!.id;
    final list = subjects[subjectId] as List<dynamic>?;
    if (list == null) return [];

    return list.map((item) {
      return MediaLessonItem(
        title: item['title'] as String? ?? '',
        // بعض المواد فيها content_ar (الألحان) وبعضها content بس (الطقس/القبطي)
        content: (item['content_ar'] ?? item['content']) as String? ?? '',
        contentCopticArabic: item['content_coptic_arabic'] as String?,

        // لسه مفيش صوت أو صورة
        audioUrl: null,
        imageAsset: null,
      );
    }).toList();
  }

  /// مسح الـ cache (مفيد لو عايز تعمل refresh بعد تحديث ملف الـ json)
  static void clearCache() => _cache.clear();
}
