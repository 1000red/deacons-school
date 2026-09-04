import '../models/models.dart';

class MediaRecordingData {
  MediaRecordingData._();

  static const _driveIds = <String, String>{
    // ===== المستوى الثالث | السنة الثانية | الترم الثاني =====
    'third/third_y2/t2/hymns/لحن اجيوس الحزايني الكبير':
        '1T9H7Hh6xm7i3T-GFnY0ZVkxLvjCc2vKp',
    'third/third_y2/t2/hymns/مرد الإبركسيس في ايام الصوم الكبير / شاريه افنوتي':
        '1LJvnSxmBpzuOPk7zAUFoae85AmuPjqbl',
    'third/third_y2/t2/hymns/لحن خريستوس أنيستي الصغيرة':
        '1g9kYgDSoapRULhAknjZ3-Fby3bnfjnLH',
    'third/third_y2/t2/hymns/لحن طوليثوس': '1JRwI83E3KK45W0vCmJ3tfEN2j0VFy0Zw',

    // قبطي
    'third/third_y2/t2/coptic/قواعد نطق بعض الحروف القبطية': '',

    // ===== المستوى الثالث | السنة الثانية | الترم الثالث =====
    // ألحان
    'third/third_y2/t3/hymns/الكاثوليكون قبطى':
        '1jqzJlDO0JDTR4-Ce8y8kX2c3O5FSsAO_',
    'third/third_y2/t3/hymns/الأسبسمس الواطس السنوى / أيها الرب إله القوات':
        '1pga1QMES3ofvYnc3oOBZsHsBwkpD62yQ',
    'third/third_y2/t3/hymns/الهوس الثانى': '1Y2I44W-Za7CZR6LmMVfXAid51V8SUj9L',
    'third/third_y2/t3/hymns/لبش الهوس الثانى / مارين أووأونه':
        '143oiHVFbVxZdStBkETgMQ-xbs5aX_mzp',
    'third/third_y2/t3/hymns/الهوس الرابع (مزمور 148، 149، 150)':
        '1wVAdwbE4YjN2NyccCqEiwMmRXbuVPXTA',
    'third/third_y2/t3/hymns/لحن إبؤرو الفرايحي':
        '1zCblk1C9e6weEDUFFVsuJ5rdYoh8Zd3z',
    'third/third_y2/t3/hymns/لحن الصليب / فاى إيطاف إنف':
        '14-Rk8fjxCu7Ks-EINxTyuqqJZ2E5FtyX',

    // قبطي
    'third/third_y2/t3/coptic/حرف بي (پ)': '',
    'third/third_y2/t3/coptic/حرف رو (ر)': '',
    'third/third_y2/t3/coptic/حرف سيما (C)': '',
    'third/third_y2/t3/coptic/حرف تاف (T)': '',
    'third/third_y2/t3/coptic/حرف ابسيلون (Y)': '',
    'third/third_y2/t3/coptic/حرف فى (Ф)': '',
    'third/third_y2/t3/coptic/حرف كى (X)': '',
    'third/third_y2/t3/coptic/حرف پسى (Ps)': '',
    'third/third_y2/t3/coptic/حرف أوميجا (W)': '',
    'third/third_y2/t3/coptic/حرف الفى (A)': '',
    'third/third_y2/t3/coptic/حرف خاى (Kh)': '',
    'third/third_y2/t3/coptic/حرف هوريع (H)': '',
    'third/third_y2/t3/coptic/حرف جانجيا (G/J)': '',
    'third/third_y2/t3/coptic/حرف تشيما (Sh/Ch)': '',
    'third/third_y2/t3/coptic/حرف تى (Ti)': '',
    'third/third_y2/t3/coptic/آيات للحفظ': '',
  };

  static String? driveFileId(NavPath path, String lessonTitle) {
    final id = _driveIds['${path.curriculumKey}/$lessonTitle'];
    return id == null || id.isEmpty ? null : id;
  }

  static String? audioUrl(NavPath path, String lessonTitle) {
    final id = driveFileId(path, lessonTitle);
    if (id == null) return null;
    // رابط مباشر بلا إعادة توجيه؛ أنسب لـ audioplayers على الموبايل.
    return 'https://drive.usercontent.google.com/download?'
        'id=$id&export=download&authuser=0&confirm=t';
  }

  /// يحول أي رابط مشاركة من Google Drive إلى رابط مناسب لمشغّل الصوت.
  /// هذا هو المكان الوحيد المسؤول عن صيغة روابط Drive في التطبيق.
  static String? playableUrl(String? url) {
    if (url == null || url.isEmpty || !url.contains('drive.google.com')) {
      return url;
    }

    if (url.contains('export=download')) return url;

    final fileMatch = RegExp(r'/d/([a-zA-Z0-9_-]+)').firstMatch(url);
    final idMatch = RegExp(r'[?&]id=([a-zA-Z0-9_-]+)').firstMatch(url);
    final fileId = fileMatch?.group(1) ?? idMatch?.group(1);

    return fileId == null
        ? url
        : 'https://drive.usercontent.google.com/download?'
            'id=$fileId&export=download&authuser=0&confirm=t';
  }
}
