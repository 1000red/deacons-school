import 'package:deacons_school_mobile/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('NavPath', () {
    test('curriculumKey keeps the historic 4-segment contract', () {
      final path = buildPath(subject: hymnsSubject);

      expect(path.curriculumKey, 'third/third_y2/t3/hymns');
    });

    test('curriculumKey falls back when year or subject are missing', () {
      const path = NavPath(
        level: Level(
          id: 'third',
          name: 'المستوى الثالث',
          subtitle: '',
          yearsCount: 3,
        ),
        term: Term(id: 't1', name: 'الترم الأول'),
      );

      expect(path.curriculumKey, 'third/no_year/t1/no_subject');
    });

    test('copyWith replaces the subject and keeps the rest', () {
      final path = buildPath(subject: ritesSubject);
      final updated = path.copyWith(subject: hymnsSubject);

      expect(updated.subject!.id, 'hymns');
      expect(updated.level, path.level);
      expect(updated.year, path.year);
      expect(updated.term, path.term);
      expect(updated.curriculumKey, 'third/third_y2/t3/hymns');
    });

    test('breadcrumb joins level, year, term and subject', () {
      final path = buildPath(subject: hymnsSubject).copyWith(
        subject: const Subject(
          id: 'hymns',
          name: 'ألحان',
          type: SubjectType.media,
          description: '',
        ),
      );

      expect(path.breadcrumb, 'مستوى • سنة • ترم • ألحان');
    });
  });

  group('MediaLessonItem.copyWith', () {
    test('attaches the audio url while keeping every other field', () {
      const lesson = MediaLessonItem(
        id: 'hymns_0',
        title: 'مرد',
        content: 'محتوى',
        contentCopticArabic: 'قبطي',
        imageAsset: 'assets/image/a.jpg',
      );

      final withAudio = lesson.copyWith(audioUrl: 'https://example.com/a.mp3');

      expect(withAudio.audioUrl, 'https://example.com/a.mp3');
      expect(withAudio.id, 'hymns_0');
      expect(withAudio.title, 'مرد');
      expect(withAudio.content, 'محتوى');
      expect(withAudio.contentCopticArabic, 'قبطي');
      expect(withAudio.imageAsset, 'assets/image/a.jpg');
    });

    test('copyWith(null) keeps the previously attached audio url', () {
      const lesson = MediaLessonItem(
        id: 'a',
        title: 't',
        content: 'c',
        audioUrl: 'https://example.com/a.mp3',
      );

      expect(lesson.copyWith().audioUrl, 'https://example.com/a.mp3');
    });
  });
}
