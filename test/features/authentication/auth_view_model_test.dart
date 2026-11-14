import 'package:deacons_school_mobile/features/authentication/repositories/auth_repository.dart';
import 'package:deacons_school_mobile/features/authentication/viewmodels/auth_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  group('AuthRepositoryImpl', () {
    const repository = AuthRepositoryImpl();

    test('accepts the configured local credentials', () {
      final user = repository.authenticate('deacon@church.com', '123456');

      expect(user.email, 'deacon@church.com');
      expect(user.name, 'deacon@church.com');
    });

    test('trims the email before comparing', () {
      final user = repository.authenticate('  deacon@church.com  ', '123456');

      expect(user.email, 'deacon@church.com');
    });

    test('rejects unknown credentials with the historic message', () {
      expect(
        () => repository.authenticate('deacon@church.com', 'wrong'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'خطأ في البريد الإلكتروني أو كلمة المرور',
          ),
        ),
      );
    });
  });

  group('AuthViewModel.login', () {
    late FakeAuthRepository repository;
    late AuthViewModel viewModel;
    late List<String?> notifications;

    setUp(() {
      repository = FakeAuthRepository();
      viewModel = AuthViewModel(repository);
      notifications = [];
      viewModel.addListener(() => notifications.add(viewModel.errorMessage));
    });

    test('reports the empty-fields message without calling the repository', () {
      final success = viewModel.login('', '');

      expect(success, isFalse);
      expect(viewModel.errorMessage, 'من فضلك أدخل البريد الإلكتروني وكلمة المرور');
      expect(repository.callCount, 0);
      expect(viewModel.isAuthenticated, isFalse);
    });

    test('treats whitespace-only input as empty', () {
      viewModel.login('   ', '   ');

      expect(viewModel.errorMessage, 'من فضلك أدخل البريد الإلكتروني وكلمة المرور');
      expect(repository.callCount, 0);
    });

    test('reports the invalid-email message', () {
      viewModel.login('deacon-at-church', '123456');

      expect(viewModel.errorMessage, 'من فضلك أدخل بريدًا إلكترونيًا صحيحًا');
      expect(repository.callCount, 0);
    });

    test('exposes the repository message for wrong credentials', () {
      repository.shouldFail = true;

      final success = viewModel.login('deacon@church.com', '123456');

      expect(success, isFalse);
      expect(viewModel.errorMessage, 'خطأ في البريد الإلكتروني أو كلمة المرور');
      expect(viewModel.isAuthenticated, isFalse);
      expect(viewModel.currentUser, isNull);
    });

    test('authenticates and clears any previous error', () {
      viewModel.login('', '');

      final success = viewModel.login('deacon@church.com', '123456');

      expect(success, isTrue);
      expect(viewModel.isAuthenticated, isTrue);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.currentUser!.email, 'deacon@church.com');
      expect(notifications.length, 2);
    });

    test('logout clears the session', () {
      viewModel.login('deacon@church.com', '123456');
      viewModel.logout();

      expect(viewModel.isAuthenticated, isFalse);
      expect(viewModel.currentUser, isNull);
      expect(viewModel.errorMessage, isNull);
    });
  });

  group('AuthViewModel lifecycle', () {
    test('does not notify after dispose', () {
      final viewModel = AuthViewModel(FakeAuthRepository());
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.dispose();
      viewModel.login('deacon@church.com', '123456');

      expect(viewModel.isDisposed, isTrue);
      expect(notified, isFalse);
    });
  });
}
