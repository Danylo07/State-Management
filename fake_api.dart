import 'dart:math';

import '../models/user_profile.dart';

/// Помилка входу (невірні облікові дані).
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}

/// Імітація сервера: затримки та випадкові помилки.
class FakeApi {
  static const testEmail = 'test@example.com';
  static const testPassword = 'password123';

  final _random = Random();

  /// Вхід: 1-2 с. Успіх лише для тестового акаунта.
  Future<void> login(String email, String password) async {
    await Future<void>.delayed(
      Duration(milliseconds: 1000 + _random.nextInt(1001)),
    );
    final ok = email.trim().toLowerCase() == testEmail &&
        password == testPassword;
    if (!ok) {
      throw const AuthException('Невірний email або пароль');
    }
  }

  /// Завантаження профілю: ~кожен 5-й запит завершується помилкою.
  Future<UserProfile> fetchProfile(String email) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (_random.nextInt(5) == 0) {
      throw Exception('Сервер недоступний');
    }
    return UserProfile(
      name: 'Тестовий користувач',
      email: email,
      bio: 'Вивчаю Flutter і керування станом через provider.',
    );
  }
}
