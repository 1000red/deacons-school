import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// حالة تسجيل الدخول والمستخدم الحالي - محاكاة محلية بدون أي اتصال بسيرفر.
class AppState extends ChangeNotifier {
  AppState._internal();
  static final AppState instance = AppState._internal();

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// تسجيل دخول وهمي: أي بريد وكلمة مرور غير فارغين يسمحان بالدخول.
  bool login(String email, String password) {
    if (email.trim().isEmpty || password.trim().isEmpty) return false;
    final name = email.split('@').first;
    _currentUser = AppUser(name: name.isEmpty ? 'شماس' : name, email: email.trim());
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
