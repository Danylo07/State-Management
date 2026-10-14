import 'package:flutter/foundation.dart';

import '../api/fake_api.dart';

/// Стан входу. Пароль у моделі НЕ зберігається - лише передається в запит.
class AuthModel extends ChangeNotifier {
  AuthModel(this._api);

  final FakeApi _api;

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  String? _email;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get email => _email;

  Future<void> login(String email, String password) async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.login(email, password);
      _email = email.trim();
      _isLoggedIn = true;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Щось пішло не так. Спробуйте ще раз';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _isLoggedIn = false;
    _isLoading = false;
    _error = null;
    _email = null;
    notifyListeners();
  }
}
