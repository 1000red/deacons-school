import 'package:deacons_school_mobile/core/errors/app_exception.dart';
import 'package:deacons_school_mobile/data/services/curriculum_local_data_source.dart';
import 'package:deacons_school_mobile/features/curriculum/repositories/curriculum_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

const _assetKey = 'assets/curriculum/third/third_y2/t3.json';

const _termJson = '''
{
  "subjects": {
    "rites": [
      {"title": "القداس الأول", "notebookPages": 5, "content": "نص الطقس"}
    ],
    "coptic": [
      {"title": "درس النطق الأول", "content": "نص عربي", "content_coptic_arabic": "نص قبطي"}
    ],
    "hymns": [
      {"title": "مرد انجيل شهر كيهك", "content_ar": "نص الألحان", "image_asset": "assets/image/kiahk.jpg"}
    ]
  }
}
''';

void main() {
  late CurriculumRepository repository;

  setUp(() {
    repository = CurriculumRepositoryImpl(
      localDataSource: CurriculumLocalDataSource(
        bundle: FakeAssetBundle({_assetKey: _termJson}),
      ),
    );
  });

  group('static curriculum catalog', () {
    test('exposes the four levels with their historic ids', () {
      expect(
        repository.levels.map((level) => level.id),
        ['preparatory', 'first', 'second', 'third'],
      );
      expect(repository.levels.first.name, 'المستوى تمهيدي');
      expect(repository.levels.last.subtitle, '٣ سنوات دراسية');
    });

    test('yearsOf(first) keeps the existing yearsCount of 2', () {
      final first = repository.levels[1];

      final years = repository.yearsOf(first);

      expect(years.map((year) => year.id), ['first_y1', 'first_y2']);
    });

    test('yearsOf(preparatory) returns a single year named as the level', () {
      final preparatory = repository.levels.first;

      final years = repository.yearsOf(preparatory);

      expect(years.single.id, 'preparatory_y1');
      expect(years.single.name, 'المستوى تمهيدي');
    });

    test('terms() returns the three historic term ids', () {
      expect(repository.terms().map((term) => term.id), ['t1', 't2', 't3']);
    });

    test('preparatory hides the reading subject', () {
      final preparatory = repository.levels.first;

      final ids = repository.subjectsFor(preparatory).map((s) => s.id);

      expect(ids, hasLength(5));
      expect(ids, isNot(contains('reading')));
      expect(ids, contains('hymns'));
    });

    test('other levels expose all six subjects', () {
      final third = repository.levels.last;

      expect(repository.subjectsFor(third), hasLength(6));
    });
  });

  group('textLessons', () {
    test('parses notebook pages, title and content', () async {
      final lessons = await repository.textLessons(
        buildPath(subject: ritesSubject),
      );

      expect(lessons, hasLength(1));
      expect(lessons.single.title, 'القداس الأول');
      expect(lessons.single.notebookPages, 5);
      expect(lessons.single.content, 'نص الطقس');
    });

    test('returns an empty list when the subject has no entries', () async {
      final lessons = await repository.textLessons(
        buildPath(subject: notebookSubject),
      );

      expect(lessons, isEmpty);
    });

    test('throws instead of silently dropping malformed entries', () async {
      final broken = CurriculumRepositoryImpl(
        localDataSource: CurriculumLocalDataSource(
          bundle: FakeAssetBundle({
            _assetKey: '{"subjects": {"rites": [{"notebookPages": 5}]}}',
          }),
        ),
      );

      expect(
        broken.textLessons(buildPath(subject: ritesSubject)),
        throwsA(isA<TypeError>()),
      );
    });

    test('throws AppException when the path has no subject', () async {
      expect(
        repository.textLessons(buildPath()),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('mediaLessons', () {
    test('maps content, coptic text and the image asset', () async {
      final lessons = await repository.mediaLessons(
        buildPath(subject: copticSubject),
      );

      final lesson = lessons.single;
      expect(lesson.title, 'درس النطق الأول');
      expect(lesson.content, 'نص عربي');
      expect(lesson.contentCopticArabic, 'نص قبطي');
      expect(lesson.id, 'coptic_0');
      expect(lesson.imageAsset, isNull);
      expect(lesson.audioUrl, isNull, reason: 'الرابط بيترفق من MediaRepository');
    });

    test('attaches image assets only for subjects that have images', () async {
      final lessons = await repository.mediaLessons(
        buildPath(subject: hymnsSubject),
      );

      final lesson = lessons.single;
      expect(lesson.imageAsset, 'assets/image/kiahk.jpg');
      expect(lesson.content, 'نص الألحان', reason: 'content_ar هو الأصل للألحان');
    });

    test('generates unique ids even when the JSON id is missing', () async {
      final lessons = await repository.mediaLessons(
        buildPath(subject: hymnsSubject),
      );

      expect(lessons.single.id, 'hymns_0');
    });
  });
}
