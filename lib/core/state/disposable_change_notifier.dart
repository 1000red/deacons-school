import 'package:flutter/foundation.dart';

/// `ChangeNotifier` بيحترم دورة الحياة:
///
/// - [notifySafely] بتنادي `notifyListeners()` بس لو الـ ViewModel لسه
///   موجود (بتمنع "setState/notify after dispose" بعد الـ awaits الطويلة).
/// - [dispose] بتقفل العلامة قبل ما نبلّغ أي مستمع تاني.
abstract class DisposableChangeNotifier extends ChangeNotifier {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @protected
  void notifySafely() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
