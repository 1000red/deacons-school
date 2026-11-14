import 'dart:io';

import 'package:deacons_school_mobile/core/errors/app_exception.dart';
import 'package:deacons_school_mobile/features/media/repositories/media_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/fakes.dart';

const _audioUrl =
    'https://drive.usercontent.google.com/download?id=1bUwMWhyGENV7yqtM1b5d3_J0XqRsKrXR&export=download&authuser=0&confirm=t';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('media_repository_test');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  MediaRepositoryImpl buildRepository(http.Client client) => MediaRepositoryImpl(
        client: client,
        temporaryDirectory: () async => tempDir,
      );

  MockClient neverCalledClient() => MockClient((request) async {
        throw StateError('ما كان المفروض مفيش أي طلب شبكة: ${request.url}');
      });

  group('audioUrl', () {
    late MediaRepositoryImpl repository;

    setUp(() {
      repository = buildRepository(neverCalledClient());
    });

    test('builds the direct Drive url for a registered recording', () {
      final path = buildPath(
        levelId: 'preparatory',
        yearId: 'preparatory_y1',
        termId: 't1',
        subject: hymnsSubject,
      );

      final url = repository.audioUrl(path, 'مرد انجيل شهر كيهك');

      expect(url, _audioUrl);
    });

    test('returns null for a lesson without a recording', () {
      final path = buildPath(
        levelId: 'preparatory',
        yearId: 'preparatory_y1',
        termId: 't1',
        subject: hymnsSubject,
      );

      expect(repository.audioUrl(path, 'غير مسجّل'), isNull);
    });

    test('treats the empty Drive ids as "no recording"', () {
      final path = buildPath(
        levelId: 'third',
        yearId: 'third_y3',
        termId: 't3',
        subject: copticSubject,
      );

      expect(
        repository.audioUrl(path, 'حرف تي (Ϯϯ) - مراجعة'),
        isNull,
      );
    });
  });

  group('playableUrl', () {
    late MediaRepositoryImpl repository;

    setUp(() {
      repository = buildRepository(neverCalledClient());
    });

    test('keeps non-Drive urls untouched', () {
      expect(repository.playableUrl(null), isNull);
      expect(repository.playableUrl(''), '');
      expect(
        repository.playableUrl('https://example.com/a.mp3'),
        'https://example.com/a.mp3',
      );
    });

    test('converts a Drive share link to a direct download link', () {
      final url = repository
          .playableUrl('https://drive.google.com/file/d/ABC-123_xyz/view');

      expect(
        url,
        'https://drive.usercontent.google.com/download?'
        'id=ABC-123_xyz&export=download&authuser=0&confirm=t',
      );
    });

    test('keeps an already direct Drive url untouched', () {
      expect(repository.playableUrl(_audioUrl), _audioUrl);
    });
  });

  group('resolveLocalFile', () {
    test('downloads once, reports progress and leaves no partial file',
        () async {
      final client = MockClient((request) async => http.Response(
            'AUDIO-BYTES',
            200,
            headers: {'content-type': 'audio/mpeg'},
          ));
      final repository = buildRepository(client);
      final progress = <double>[];

      final file = await repository.resolveLocalFile(
        _audioUrl,
        onProgress: progress.add,
      );

      expect(await file.readAsString(), 'AUDIO-BYTES');
      expect(file.parent.path, tempDir.path);
      expect(progress, isNotEmpty);
      expect(progress.last, 1.0);
      expect(
        File('${tempDir.path}/audio_cache_1bUwMWhyGENV7yqtM1b5d3_J0XqRsKrXR')
            .existsSync(),
        isTrue,
      );
      expect(
        Directory(tempDir.path)
            .listSync()
            .where((e) => e.path.endsWith('.part')),
        isEmpty,
        reason: 'ممنوع يفضل ملف ناقص في الكاش',
      );
    });

    test('serves the second call from the local cache without network',
        () async {
      final first = buildRepository(MockClient(
          (request) async => http.Response('AUDIO-BYTES', 200)));
      await first.resolveLocalFile(_audioUrl);

      final second = buildRepository(neverCalledClient());
      final file = await second.resolveLocalFile(_audioUrl);

      expect(await file.readAsString(), 'AUDIO-BYTES');
    });

    test('throws and leaves nothing behind when Drive returns HTML', () async {
      final repository = buildRepository(MockClient((request) async =>
          http.Response('<html>sign in</html>', 200,
              headers: {'content-type': 'text/html; charset=utf-8'})));

      await expectLater(
        repository.resolveLocalFile(_audioUrl),
        throwsA(isA<AppException>()),
      );
      expect(tempDir.listSync(), isEmpty);
    });

    test('throws when the server answers with an error status', () async {
      final repository = buildRepository(
          MockClient((request) async => http.Response('nope', 404)));

      await expectLater(
        repository.resolveLocalFile(_audioUrl),
        throwsA(isA<AppException>()),
      );
      expect(tempDir.listSync(), isEmpty);
    });

    test('cleans up the partial file when the stream fails mid-download',
        () async {
      final repository = buildRepository(MockClient.streaming((request, _) async {
        Stream<List<int>> failing() async* {
          yield <int>[1, 2, 3];
          throw Exception('انقطع الاتصال');
        }

        return http.StreamedResponse(
          failing(),
          200,
          headers: {'content-type': 'audio/mpeg'},
        );
      }));

      await expectLater(
        repository.resolveLocalFile(_audioUrl),
        throwsA(isA<AppException>()),
      );

      final leftovers = tempDir.listSync().map((e) => e.path).toList();
      expect(leftovers, isEmpty, reason: 'ممنوع يفضل ملف ناقص في الكاش');
    });
  });
}
