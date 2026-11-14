import 'package:deacons_school_mobile/core/state/view_state.dart';
import 'package:deacons_school_mobile/features/notebook/viewmodels/notebook_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const viewerPath = '/tmp/fake_viewer.pdf';
  const devicePath = '/tmp/fake_device.pdf';

  group('prepare() state', () {
    test('starts loading then exposes the local viewer path', () async {
      final viewModel = NotebookViewModel(
        repository: FakeNotebookRepository()
          ..preview = 'https://drive.google.com/uc?export=download&id=1'
          ..viewerPath = viewerPath,
        path: buildPath(subject: notebookSubject),
      );

      expect(viewModel.fileState.isLoading, isTrue);

      await pumpEventQueue();

      expect(viewModel.fileState.isSuccess, isTrue);
      expect(viewModel.fileState.data, viewerPath);
    });

    test('reports the historic "no file" message without downloading', () async {
      final repository = FakeNotebookRepository();
      final viewModel = NotebookViewModel(
        repository: repository,
        path: buildPath(subject: notebookSubject),
      );

      await pumpEventQueue();

      expect(viewModel.fileState.isError, isTrue);
      expect(viewModel.fileState.message, 'لا يوجد ملف متاح لهذه المادة.');
      expect(repository.viewerCalls, 0);
    });

    test('reports the historic connection message when the download fails',
        () async {
      final viewModel = NotebookViewModel(
        repository: FakeNotebookRepository()
          ..preview = 'https://example.com/notebook.pdf'
          ..viewerError = Exception('offline'),
        path: buildPath(subject: notebookSubject),
      );

      await pumpEventQueue();

      expect(viewModel.fileState.isError, isTrue);
      expect(
        viewModel.fileState.message,
        'تعذر تحميل الملف، تأكد من الاتصال بالإنترنت.',
      );
    });

    test('can be prepared again manually (retry path)', () async {
      final repository = FakeNotebookRepository()
        ..preview = 'https://example.com/notebook.pdf'
        ..viewerPath = viewerPath;
      final viewModel = NotebookViewModel(
        repository: repository,
        path: buildPath(subject: notebookSubject),
      );
      await pumpEventQueue();

      await viewModel.prepare();

      expect(viewModel.fileState.isSuccess, isTrue);
      expect(repository.viewerCalls, 2);
    });
  });

  group('downloadToDevice()', () {
    test('returns the success message together with the opened file',
        () async {
      final repository = FakeNotebookRepository()
        ..preview = 'https://example.com/notebook.pdf'
        ..devicePath = devicePath;
      final viewModel = NotebookViewModel(
        repository: repository,
        path: buildPath(subject: notebookSubject),
      );
      await pumpEventQueue();

      final result = await viewModel.downloadToDevice();

      expect(result!.message, 'تم تحميل الملف بنجاح');
      expect(result.filePath, devicePath);
      expect(result.canOpen, isTrue);
      expect(viewModel.savedFilePath, devicePath);
      expect(viewModel.isDownloading, isFalse);
      expect(viewModel.downloadProgress, 0);
    });

    test('publishes the download progress while running', () async {
      final repository = FakeNotebookRepository()
        ..preview = 'https://example.com/notebook.pdf';
      final viewModel = NotebookViewModel(
        repository: repository,
        path: buildPath(subject: notebookSubject),
      );
      await pumpEventQueue();

      final progress = <double>[];
      viewModel.addListener(() {
        if (viewModel.isDownloading) progress.add(viewModel.downloadProgress);
      });

      await viewModel.downloadToDevice();

      expect(progress.first, 0, reason: 'بداية التنزيل');
      expect(progress.last, 0.5, reason: 'التقدّم بيتبلّغ أثناء التنزيل');
      expect(viewModel.isDownloading, isFalse);
    });

    test('returns the historic failure message', () async {
      final repository = FakeNotebookRepository()
        ..preview = 'https://example.com/notebook.pdf'
        ..deviceError = Exception('offline');
      final viewModel = NotebookViewModel(
        repository: repository,
        path: buildPath(subject: notebookSubject),
      );
      await pumpEventQueue();

      final result = await viewModel.downloadToDevice();

      expect(result!.message, 'فشل تحميل الملف، حاول مرة أخرى');
      expect(result.canOpen, isFalse);
      expect(viewModel.isDownloading, isFalse);
    });

    test('returns null (without any message) when there is no file at all',
        () async {
      final repository = FakeNotebookRepository();
      final viewModel = NotebookViewModel(
        repository: repository,
        path: buildPath(subject: notebookSubject),
      );

      final result = await viewModel.downloadToDevice();

      expect(result, isNull);
      expect(repository.deviceCalls, 0);
    });
  });

  group('lifecycle', () {
    test('does not notify listeners after dispose', () async {
      final viewModel = NotebookViewModel(
        repository: FakeNotebookRepository()
          ..preview = 'https://example.com/notebook.pdf',
        path: buildPath(subject: notebookSubject),
      );
      await pumpEventQueue();

      var notified = false;
      viewModel.addListener(() => notified = true);
      viewModel.dispose();
      await viewModel.prepare();

      expect(viewModel.isDisposed, isTrue);
      expect(notified, isFalse);
    });

    test('exposes the navigation path for the view', () {
      final path = buildPath(subject: notebookSubject);
      final viewModel = NotebookViewModel(
        repository: FakeNotebookRepository(),
        path: path,
      );

      expect(viewModel.path, same(path));
      expect(viewModel.fileState.status, ViewStateStatus.error);
    });
  });
}
