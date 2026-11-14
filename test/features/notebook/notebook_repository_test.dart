import 'dart:io';
import 'dart:typed_data';

import 'package:deacons_school_mobile/core/errors/app_exception.dart';
import 'package:deacons_school_mobile/features/notebook/repositories/notebook_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

/// Adapter وهمي بيرجّع محتوى PDF من غير أي شبكة.
class _FakePdfAdapter implements HttpClientAdapter {
  int fetchCount = 0;
  bool shouldFail = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetchCount++;
    if (shouldFail) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'offline',
      );
    }
    return ResponseBody.fromString(
      'PDF-BYTES',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/pdf'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Directory tempDir;
  late _FakePdfAdapter adapter;
  late NotebookRepositoryImpl repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('notebook_repository_test');
    adapter = _FakePdfAdapter();
    repository = NotebookRepositoryImpl(
      dio: Dio()..httpClientAdapter = adapter,
      temporaryDirectory: () async => Directory('${tempDir.path}/tmp')
        ..createSync(recursive: true),
      documentsDirectory: () async => Directory('${tempDir.path}/docs')
        ..createSync(recursive: true),
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  group('Drive url mapping', () {
    test('preview and direct download urls use the registered Drive id', () {
      final path = buildPath(subject: notebookSubject);

      expect(
        repository.previewUrl(path),
        'https://drive.google.com/uc?export=download&id='
        '1jYM9LmRruZA6J1DptTtsD8TSKVwlswks',
      );
      expect(
        repository.directDownloadUrl(path),
        'https://drive.usercontent.google.com/download?'
        'id=1jYM9LmRruZA6J1DptTtsD8TSKVwlswks'
        '&export=download&authuser=0&confirm=t',
      );
    });

    test('returns null when the Drive id is empty (مستويات غير جاهزة)', () {
      final path = buildPath(
        levelId: 'second',
        yearId: 'second_y1',
        termId: 't1',
        subject: notebookSubject,
      );

      expect(repository.previewUrl(path), isNull);
      expect(repository.directDownloadUrl(path), isNull);
    });

    test('returns null for a subject that has no PDF mapping', () {
      final path = buildPath(subject: hymnsSubject);

      expect(repository.previewUrl(path), isNull);
      expect(repository.directDownloadUrl(path), isNull);
    });
  });

  group('downloadForViewer', () {
    test('downloads the file once and serves later calls from cache', () async {
      final path = buildPath(subject: notebookSubject);

      final first = await repository.downloadForViewer(path);
      final second = await repository.downloadForViewer(path);

      expect(first, second);
      expect(File(first).readAsStringSync(), 'PDF-BYTES');
      expect(adapter.fetchCount, 1, reason: 'العرض مكاش ومفيش تحميل تاني');
    });

    test('throws AppException when the network fails', () async {
      adapter.shouldFail = true;
      final path = buildPath(subject: notebookSubject);

      await expectLater(
        repository.downloadForViewer(path),
        throwsA(isA<AppException>()),
      );

      final viewerDir = Directory('${tempDir.path}/tmp');
      expect(
        viewerDir.listSync().where((e) => e.path.endsWith('.part')),
        isEmpty,
      );
    });

    test('throws AppException without touching the network when there is no file',
        () async {
      final path = buildPath(subject: hymnsSubject);

      await expectLater(
        repository.downloadForViewer(path),
        throwsA(isA<AppException>()),
      );
      expect(adapter.fetchCount, 0);
    });
  });

  group('downloadToDevice', () {
    test('saves the PDF into the app documents directory', () async {
      final path = buildPath(subject: notebookSubject);

      final savePath = await repository.downloadToDevice(path);

      expect(
        savePath.endsWith('المذكرة_third_third_y2_t3_notebook.pdf'),
        isTrue,
      );
      expect(File(savePath).readAsStringSync(), 'PDF-BYTES');
    });

    test('throws AppException when the network fails and leaves no file',
        () async {
      adapter.shouldFail = true;
      final path = buildPath(subject: notebookSubject);

      await expectLater(
        repository.downloadToDevice(path),
        throwsA(isA<AppException>()),
      );

      final documents = Directory('${tempDir.path}/docs');
      expect(documents.listSync(), isEmpty);
    });

    test('throws AppException without touching the network when there is no file',
        () async {
      final path = buildPath(subject: hymnsSubject);

      await expectLater(
        repository.downloadToDevice(path),
        throwsA(isA<AppException>()),
      );
      expect(adapter.fetchCount, 0);
    });
  });
}
