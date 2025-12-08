import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  AuthStorage._();

  static final AuthStorage instance = AuthStorage._();

  static const _keyAuthToken = 'auth_token';
  static const _keyLogin = 'login';
  static const _keyPassword = 'password';
  static const _keyTokenSavedAt = 'auth_token_saved_at';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _memAuthToken;
  DateTime? _memTokenSavedAt;
  String? _memLogin;
  String? _memPassword;

  // ----------------- token -----------------

  /// Сохраняем токен + время, когда он был получен.
  Future<void> saveAuthToken(String token) async {
    _memAuthToken = token;
    _memTokenSavedAt = DateTime.now();
    try {
      await _storage.write(key: _keyAuthToken, value: token);
      await _storage.write(
        key: _keyTokenSavedAt,
        value: _memTokenSavedAt!.toIso8601String(),
      );
    } catch (_) {}
  }

  Future<String?> getAuthToken() async {
    if (_memAuthToken != null) return _memAuthToken;
    return _storage.read(key: _keyAuthToken);
  }


  /// Время, когда токен был сохранён
  Future<DateTime?> getTokenSavedAt() async {
    if (_memTokenSavedAt != null) return _memTokenSavedAt;
    final raw = await _storage.read(key: _keyTokenSavedAt);
    if (raw == null) return null;
    try {
      final dt = DateTime.parse(raw);
      _memTokenSavedAt = dt;
      return dt;
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

  // ----------------- login / password -----------------

  Future<void> saveLoginPassword(String login, String password) async {
    _memLogin = login;
    _memPassword = password;
    try {
      await _storage.write(key: _keyLogin, value: login);
      await _storage.write(key: _keyPassword, value: password);
    } catch (_) {}
  }


  Future<String?> getLogin() async {
    if (_memLogin != null) return _memLogin;
    return _storage.read(key: _keyLogin);
  }

  Future<String?> getPassword() async {
    if (_memPassword != null) return _memPassword;
    return _storage.read(key: _keyPassword);
  }

  Future<(String login, String password)?> getLoginPassword() async {
    final login = await getLogin();
    final password = await getPassword();
    if (login == null || password == null) return null;
    return (login, password);
  }

  // ----------------- очистка всего -----------------

  Future<void> clearAuthToken() async {
    _memAuthToken = null;
    _memTokenSavedAt = null;
    try {
      await _storage.delete(key: _keyAuthToken);
      await _storage.delete(key: _keyTokenSavedAt);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    _memAuthToken = null;
    _memTokenSavedAt = null;
    _memLogin = null;
    _memPassword = null;
    try {
      await _storage.delete(key: _keyAuthToken);
      await _storage.delete(key: _keyTokenSavedAt);
      await _storage.delete(key: _keyLogin);
      await _storage.delete(key: _keyPassword);
    } catch (_) {}
  }
}