import '../../../core/errors/app_exception.dart';
import '../../../core/state/disposable_change_notifier.dart';
import '../../../data/models/models.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends DisposableChangeNotifier {
  AuthViewModel(this._repository);

  final AuthRepository _repository;

  AppUser? _currentUser;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  String? get errorMessage => _errorMessage;

  bool login(String email, String password) {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'من فضلك أدخل البريد الإلكتروني وكلمة المرور';
      notifySafely();
      return false;
    }

    if (!email.contains('@')) {
      _errorMessage = 'من فضلك أدخل بريدًا إلكترونيًا صحيحًا';
      notifySafely();
      return false;
    }

    try {
      _currentUser = _repository.authenticate(email, password);
      _errorMessage = null;
    } on AppException catch (e) {
      _currentUser = null;
      _errorMessage = e.message;
    }

    notifySafely();
    return isAuthenticated;
  }

  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifySafely();
  }
}
