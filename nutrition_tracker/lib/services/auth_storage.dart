import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  AuthStorage._();

  static final AuthStorage instance = AuthStorage._();

  static const _keyAuthToken = 'auth_token';
  static const _keyLogin = 'login';
  static const _keyPassword = 'password';
  static const _keyTokenSavedAt = 'auth_token_saved_at';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ----------------- token -----------------

  /// Сохраняем токен + время, когда он был получен.
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
    await _storage.write(
      key: _keyTokenSavedAt,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Просто достать токен из стораджа
  Future<String?> getAuthToken() async {
    return _storage.read(key: _keyAuthToken);
  }

  /// Время, когда токен был сохранён
  Future<DateTime?> getTokenSavedAt() async {
    final raw = await _storage.read(key: _keyTokenSavedAt);
    if (raw == null) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isTokenExpired(Duration ttl) async {
    final savedAt = await getTokenSavedAt();
    if (savedAt == null) {
      return true;
    }
    final now = DateTime.now();
    return now.difference(savedAt) > ttl;
  }

  Future<void> clearAuthToken() async {
    await _storage.delete(key: _keyAuthToken);
    await _storage.delete(key: _keyTokenSavedAt);
  }

  // ----------------- login / password -----------------

  Future<void> saveLoginPassword(String login, String password) async {
    await _storage.write(key: _keyLogin, value: login);
    await _storage.write(key: _keyPassword, value: password);
  }

  Future<String?> getLogin() async {
    return _storage.read(key: _keyLogin);
  }

  Future<String?> getPassword() async {
    return _storage.read(key: _keyPassword);
  }

  Future<(String login, String password)?> getLoginPassword() async {
    final login = await getLogin();
    final password = await getPassword();
    if (login == null || password == null) return null;
    return (login, password);
  }

  // ----------------- очистка всего -----------------

  Future<void> clearAll() async {
    await _storage.delete(key: _keyAuthToken);
    await _storage.delete(key: _keyTokenSavedAt);
    await _storage.delete(key: _keyLogin);
    await _storage.delete(key: _keyPassword);
  }
}
