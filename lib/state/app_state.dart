import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  AppState._internal();
  static final AppState instance = AppState._internal();

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  String login(String email, String password) {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return 'من فضلك أدخل البريد الإلكتروني وكلمة المرور';
    }

    if (!email.contains('@')) {
      return 'من فضلك أدخل بريدًا إلكترونيًا صحيحًا';
    }

    if (email.trim() != "deacon@church.com" || password.trim() != "123456") {
      return 'خطأ في البريد الإلكتروني أو كلمة المرور';
    }

    notifyListeners();
    return '';
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
