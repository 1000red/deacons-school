import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/errors/app_exception.dart';
import '../models/models.dart';

/// مصدر بيانات المنهج الوحيد: بيقرأ ملفات الـ JSON المدمجة من
/// `assets/curriculum/{level}/{year}/{term}.json` ويرجع المحتوى الخام
/// بتاع المادة المطلوبة في [NavPath].
///
/// - المذكرة مش بتستخدم الملف ده لأنها بتفتح كـ PDF من Google Drive.
/// - بيتعمل cache للملف بعد أول قراءة، فالمتكرر بيقرأ من الذاكرة.
/// - أي فشل قراءة أو تحليل بيترمي كـ [AppException] عشان الـ ViewModel
///   يعرض حالة الخطأ بدل ما يعرض "لا يوجد محتوى" بشكل مضلل.
class CurriculumLocalDataSource {
  CurriculumLocalDataSource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final Map<String, Map<String, dynamic>> _cache = {};

  /// مسار الملف: path.level.id مثل `third`، path.year.id مثل `third_y2`،
  /// path.term.id مثل `t3`.
  Future<Map<String, dynamic>> loadTermJson(NavPath path) async {
    final yearId = path.year?.id;
    if (yearId == null) {
      throw const AppException('مسار المنهج غير مكتمل: لا توجد سنة دراسية');
    }

    final assetPath = 'assets/curriculum/${path.level.id}/$yearId/${path.term.id}.json';

    final cached = _cache[assetPath];
    if (cached != null) return cached;

    try {
      final raw = await _bundle.loadString(assetPath);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _cache[assetPath] = decoded;
      return decoded;
    } catch (e, stackTrace) {
      debugPrint('ERROR LOADING JSON: $assetPath');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      throw AppException('تعذر قراءة ملف المنهج', assetPath: assetPath, cause: e);
    }
  }

  /// عناصر المادة الخام (كل عنصر فيها Map بحقول الـ JSON).
  ///
  /// لو المادة مش موجودة في ملف الترم بنرجّع قائمة فاضية (مش خطأ).
  /// ملفات المنهج القديمة سمت الألحان `melodies`؛ الشاشة تستخدم `hymns`.
  Future<List<Map<String, dynamic>>> loadSubjectItems(
    NavPath path,
    String subjectId,
  ) async {
    final termJson = await loadTermJson(path);

    final subjects = termJson['subjects'] as Map<String, dynamic>?;
    if (subjects == null) return const [];

    dynamic raw = subjects[subjectId];
    if (raw == null && subjectId == 'hymns') {
      raw = subjects['melodies'];
    }

    final list = raw as List<dynamic>?;
    if (list == null) return const [];

    return list
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  /// مسح الـ cache (مفيد بعد تحديث ملفات الـ json أثناء التطوير).
  void clearCache() => _cache.clear();
}
