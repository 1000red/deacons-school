import 'package:deacons_school_mobile/core/errors/app_exception.dart';
import 'package:deacons_school_mobile/data/models/models.dart';
import 'package:deacons_school_mobile/data/services/curriculum_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

const _termJson = '''
{
  "subjects": {
    "hymns": [
      {
        "title": "مرد انجيل شهر كيهك",
        "content_ar": "نص الألحان",
        "image_asset": "assets/image/kiahk.jpg"
      }
    ],
    "melodies": [
      {"title": "قديس قديسين", "content_ar": "نص قديم"}
    ],
    "rites": [
      {
        "title": "القداس الأول",
        "notebookPages": 3,
        "content": "نص الطقس"
      }
    ]
  }
}
''';

const _assetKey = 'assets/curriculum/third/third_y2/t3.json';

void main() {
  late FakeAssetBundle bundle;
  late CurriculumLocalDataSource dataSource;

  setUp(() {
    bundle = FakeAssetBundle({_assetKey: _termJson});
    dataSource = CurriculumLocalDataSource(bundle: bundle);
  });

  group('loadSubjectItems', () {
    test('reads the items of a subject that exists in the term file', () async {
      final items = await dataSource.loadSubjectItems(
        buildPath(),
        'rites',
      );

      expect(items, hasLength(1));
      expect(items.single['title'], 'القداس الأول');
      expect(items.single['notebookPages'], 3);
    });

    test('falls back to the legacy melodies key for hymns', () async {
      // الملف ده فيه melodies بس (نفس محتوى الملفات القديمة)
      final legacyBundle = FakeAssetBundle({
        _assetKey: '''
{
  "subjects": {
    "melodies": [{"title": "قديس قديسين", "content_ar": "محتوى"}]
  }
}
''',
      });
      final legacySource = CurriculumLocalDataSource(bundle: legacyBundle);

      final items = await legacySource.loadSubjectItems(buildPath(), 'hymns');

      expect(items.single['title'], 'قديس قديسين');
    });

    test('returns an empty list when the subject is not in the file', () async {
      final items = await dataSource.loadSubjectItems(buildPath(), 'coptic');

      expect(items, isEmpty);
    });

    test('returns an empty list when the file has no subjects map', () async {
      final emptySource = CurriculumLocalDataSource(
        bundle: FakeAssetBundle({_assetKey: '{"title": "بدون مواد"}'}),
      );

      final items = await emptySource.loadSubjectItems(buildPath(), 'rites');

      expect(items, isEmpty);
    });

    test('throws AppException when the asset is missing', () async {
      final missingSource = CurriculumLocalDataSource(
        bundle: FakeAssetBundle(const {}),
      );

      expect(
        missingSource.loadSubjectItems(buildPath(), 'rites'),
        throwsA(
          isA<AppException>()
              .having((e) => e.assetPath, 'assetPath', _assetKey)
              .having((e) => e.cause, 'cause', isNotNull),
        ),
      );
    });

    test('throws AppException when the JSON is malformed', () async {
      final brokenSource = CurriculumLocalDataSource(
        bundle: FakeAssetBundle({_assetKey: '{"subjects": {'}),
      );

      expect(
        brokenSource.loadSubjectItems(buildPath(), 'rites'),
        throwsA(isA<AppException>()),
      );
    });

    test('throws AppException when the year segment is missing', () async {
      const pathWithoutYear = NavPath(
        level: Level(
          id: 'third',
          name: 'مستوى',
          subtitle: '',
          yearsCount: 3,
        ),
        term: Term(id: 't3', name: 'ترم'),
      );

      expect(
        dataSource.loadTermJson(pathWithoutYear),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('caching', () {
    test('reads the asset once and serves later calls from cache', () async {
      await dataSource.loadSubjectItems(buildPath(), 'rites');
      await dataSource.loadSubjectItems(buildPath(), 'hymns');

      expect(bundle.loadedKeys, [_assetKey]);

      dataSource.clearCache();

      await dataSource.loadSubjectItems(buildPath(), 'rites');
      expect(bundle.loadedKeys, [_assetKey, _assetKey]);
    });
  });
}
