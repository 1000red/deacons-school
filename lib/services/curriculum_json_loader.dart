import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/models.dart';
import 'package:flutter/foundation.dart';
import 'media_recording_data.dart';

/// المصدر الوحيد لبيانات المواد التي تقرأ من الـ JSON:
/// طقس، قراءة، محفوظات، قبطي، وألحان.
///
/// بيقرا ملفات الـ JSON من assets/curriculum/{level}/{year}/{term}.json
/// ويرجع بيانات المادة الموجودة في [NavPath]. المذكرة لا تستخدم هذا الملف
/// لأنها تُفتح كـ PDF من Google Drive.
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

  /// دروس طقس وقراءة ومحفوظات.
  static Future<List<NotebookLessonItem>> textLessons(
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
    // ملفات المنهج القديمة سمت الألحان melodies؛ الشاشة تستخدم hymns.
    final list = (subjects[subjectId] ??
        (subjectId == 'hymns' ? subjects['melodies'] : null)) as List<dynamic>?;
    if (list == null) return [];

    return list.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value as Map<String, dynamic>;
      final title = item['title'] as String? ?? '';

      return MediaLessonItem(
        // نستخدم id من الـ JSON لو موجود، وإلا نبني id فريد من
        // subjectId + رقم الترتيب (عشان نضمن التفرد حتى لو تكرر العنوان)
        id: item['id'] as String? ?? '${subjectId}_$index',
        title: title,
        // بعض المواد فيها content_ar (الألحان) وبعضها content بس (الطقس/القبطي)
        content: (item['content_ar'] ?? item['content']) as String? ?? '',
        contentCopticArabic: item['content_coptic_arabic'] as String?,

        // كل التسجيلات تُقرأ من ملف Google Drive المركزي فقط.
        audioUrl: MediaRecordingData.audioUrl(path, title),

        // عند إضافة تسجيل منفصل لنطق الحرف يُربط أيضًا في
        // MediaRecordingData، وليس داخل الـ JSON.

        // الألحان فقط تعرض صورة. يمكن تخصيص صورة للدرس عبر image_asset
        // في الـ JSON؛ وإن لم توجد نستخدم الصورة الافتراضية للألحان.
        imageAsset:
            path.subject!.hasImage ? item['image_asset'] as String? : null,
      );
    }).toList();
  }

  /// مسح الـ cache (مفيد لو عايز تعمل refresh بعد تحديث ملف الـ json)
  static void clearCache() => _cache.clear();
}
