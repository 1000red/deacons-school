import '../../../core/errors/app_exception.dart';
import '../../../data/models/models.dart';

class AuthException extends AppException {
  const AuthException(super.message);
}

abstract class AuthRepository {
  AppUser authenticate(String email, String password);
}

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl();

  static const _email = 'deacon@church.com';
  static const _password = '123456';

  @override
  AppUser authenticate(String email, String password) {
    if (email.trim() != _email || password.trim() != _password) {
      throw const AuthException('خطأ في البريد الإلكتروني أو كلمة المرور');
    }
    return AppUser(name: email.trim(), email: email.trim());
  }
}
