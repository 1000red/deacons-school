class AppUser {
  final String email;
  final String name;
  const AppUser({required this.name, required this.email});
}

enum SubjectType {
  media, // text + Audio
  notebook, // PDF
  text, // text from json
}

/// بيانات المادة من غير أي اعتماد على واجهة الرسم (Color / IconData).
/// الأيقونات والألوان العرضية موجودة في
/// `features/curriculum/views/curriculum_presentation.dart`.
class Subject {
  final String id;
  final String name;
  final SubjectType type;
  final String description;
  final bool hasImage; // لو المادة محتاجة تعرض صورة (زي الألحان)

  const Subject({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    this.hasImage = false,
  });
}

/// بيانات المستوى الدراسي من غير أي اعتماد على واجهة الرسم.
class Level {
  final String id;
  final String name;
  final String subtitle;
  final int yearsCount;

  const Level({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.yearsCount,
  });
}

class YearLevel {
  final String id;
  final String name;
  const YearLevel({required this.id, required this.name});
}

class Term {
  final String id;
  final String name;
  const Term({required this.id, required this.name});
}

class NavPath {
  final Level level;
  final YearLevel? year;
  final Term term;
  final Subject? subject;

  const NavPath(
      {required this.level, this.year, required this.term, this.subject});

  NavPath copyWith({Subject? subject}) => NavPath(
      level: level, year: year, term: term, subject: subject ?? this.subject);

  String get breadcrumb {
    final parts = <String>[
      level.name,
      if (year != null) year!.name,
      term.name,
      if (subject != null) subject!.name
    ];
    return parts.join(' • ');
  }

  String get curriculumKey => [
        level.id,
        year?.id ?? 'no_year',
        term.id,
        subject?.id ?? 'no_subject',
      ].join('/');
}

class MediaLessonItem {
  final String id;
  final String title;
  final String content; // النص العربي (content_ar أو content)
  final String? contentCopticArabic; // النص القبطي بالحروف العربية (للألحان بس)

  // هنستخدمهم بعدين لما نضيف الملفات
  final String? audioUrl;
  final String? imageAsset; // صورة الدرس، وتستخدمها الألحان فقط

  const MediaLessonItem({
    required this.id,
    required this.title,
    required this.content,
    this.contentCopticArabic,
    this.audioUrl,
    this.imageAsset,
  });

  /// نسخة من نفس الدرس برابط صوتي مختلف (بيستخدمه الـ ViewModel
  /// لإرفاق التسجيل بعد تحميل محتوى المادة).
  MediaLessonItem copyWith({String? audioUrl}) => MediaLessonItem(
        id: id,
        title: title,
        content: content,
        contentCopticArabic: contentCopticArabic,
        audioUrl: audioUrl ?? this.audioUrl,
        imageAsset: imageAsset,
      );
}

class NotebookLessonItem {
  final String title;
  final String content;
  final int notebookPages;

  const NotebookLessonItem(
      {required this.title,
      required this.content,
      required this.notebookPages});
}
