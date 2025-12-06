// lib/api/backend_api.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_error.dart';
import '../services/auth_storage.dart';
import '../models/user_info.dart';
import '../models/scan_meal_result.dart';

class BackendApi {
  BackendApi._();

  static final BackendApi instance = BackendApi._();

  final http.Client _client = http.Client();

  // ----------------------------------------------------------
  // Вспомогательные методы
  // ----------------------------------------------------------

  Uri _buildUri(String path, [Map<String, String>? query]) {
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);
  }

  ApiError _defaultError(String message) => ApiError(
    statusCode: 0,
    backendMessage: message,
    uiMessage: message,
  );


  // ----------------------------------------------------------
  // AUTH
  // ----------------------------------------------------------

  /// POST /auth/login
  /// body: {login, password} -> {token}
  Future<void> login({
    required String login,
    required String password,
  }) async {
    final uri = _buildUri('/auth/login');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'login': login,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['token']?.toString();

      if (token == null || token.isEmpty) {
        throw _defaultError('Сервер не вернул токен авторизации.');
      }

      await AuthStorage.instance.saveAuthToken(token);
      await AuthStorage.instance.saveLoginPassword(login, password);
      return;
    }

    if (response.statusCode == 401) {
      throw _defaultError('Неверный логин или пароль.');
    }

    throw _defaultError('Не удалось выполнить вход. Попробуйте позже.');
  }

  /// POST /auth/register
  /// body: {login, password, secret_q, secret_q_ans}
  Future<void> register({
    required String login,
    required String password,
    required String secretQuestion,
    required String secretAnswer,
  }) async {
    final uri = _buildUri('/auth/register');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'login': login,
        'password': password,
        'secret_q': secretQuestion,
        'secret_q_ans': secretAnswer,
      }),
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 409) {
      throw _defaultError('Пользователь с таким логином уже существует.');
    }

    throw _defaultError('Не удалось создать аккаунт. Попробуйте позже.');
  }

  /// GET /auth/iforgot?login=
  Future<String> getSecretQuestion(String login) async {
    final uri = _buildUri('/auth/iforgot', {'login': login});

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final secret = data['secret_q']?.toString() ?? '';
      if (secret.isEmpty) {
        throw _defaultError('Секретный вопрос не найден.');
      }
      return secret;
    }

    if (response.statusCode == 404) {
      throw _defaultError('Пользователь не найден.');
    }

    throw _defaultError('Не удалось получить секретный вопрос.');
  }

  /// POST /auth/reset_password
  /// body: {login, secret_q_ans, new_password}
  Future<void> resetPassword({
    required String login,
    required String secretAnswer,
    required String newPassword,
  }) async {
    final uri = _buildUri('/auth/reset_password');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'login': login,
        'secret_q_ans': secretAnswer,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 401) {
      throw _defaultError('Неверный ответ на секретный вопрос.');
    }

    if (response.statusCode == 404) {
      throw _defaultError('Пользователь не найден.');
    }

    throw _defaultError('Не удалось сбросить пароль.');
  }

  /// GET /auth/revoke_tokens?auth_token=
  Future<void> logout() async {
    final token = await AuthStorage.instance.getAuthToken();
    if (token == null) {
      await AuthStorage.instance.clearAll();
      return;
    }

    final uri = _buildUri('/auth/revoke_tokens', {'auth_token': token});

    try {
      await _client.get(uri);
    } catch (_) {
    } finally {
      await AuthStorage.instance.clearAll();
    }
  }

  /// POST /auth/delete_account
  /// body: {auth_token, password}
  Future<void> deleteAccount() async {
    final token = await AuthStorage.instance.getAuthToken();
    final loginPassword = await AuthStorage.instance.getLoginPassword();

    if (token == null || loginPassword == null) {
      throw _defaultError(
        'Не удалось определить данные аккаунта. Выйдите и войдите снова.',
      );
    }

    final (_, password) = loginPassword;

    final uri = _buildUri('/auth/delete_account');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'auth_token': token,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      await AuthStorage.instance.clearAll();
      return;
    }

    if (response.statusCode == 401) {
      throw _defaultError('Неверный пароль. Аккаунт не был удалён.');
    }

    throw _defaultError('Не удалось удалить аккаунт. Попробуйте позже.');
  }

  // ----------------------------------------------------------
  // USER INFO
  // ----------------------------------------------------------

  /// GET /user_info/get?auth_token=
  Future<UserInfo?> getUserInfo() async {
    final token = await AuthStorage.instance.getAuthToken();
    if (token == null) return null;

    final uri = _buildUri('/user_info/get', {'auth_token': token});
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return UserInfo.fromJson(data);
    }

    if (response.statusCode == 204) {
      return null;
    }

    if (response.statusCode == 401) {
      throw _defaultError('Сессия истекла. Войдите заново.');
    }

    throw _defaultError('Не удалось получить данные пользователя.');
  }

  /// POST /user_info/set
  /// body: {auth_token, age, gender, height, weight, goal}
  Future<void> setUserInfo({
    required int age,
    required String gender,
    required num height,
    required int weight,
    required String goal,
  }) async {
    final token = await AuthStorage.instance.getAuthToken();
    if (token == null) {
      throw _defaultError('Сессия истекла. Войдите заново.');
    }

    final uri = _buildUri('/user_info/set');

    final bodyMap = <String, dynamic>{
      'auth_token': token,
      'age': age,
      'gender': gender,
      'height': height.round(),
      'weight': weight,
      'goal': goal,
    };

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 401) {
      throw _defaultError('Сессия истекла. Войдите заново.');
    }

    throw _defaultError('Не удалось сохранить данные пользователя.');
  }

  // ----------------------------------------------------------
  // AI / MEAL / TRACKER
  // ----------------------------------------------------------

  /// POST /ai/scan
  /// body: {auth_token, img_base64} -> {meal_id}
  Future<String> scanMeal(String imgBase64) async {
    final token = await AuthStorage.instance.getAuthToken();
    if (token == null) {
      throw _defaultError('Сессия истекла. Войдите заново.');
    }

    final uri = _buildUri('/ai/scan');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'auth_token': token,
        'img_base64': imgBase64,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final mealId = data['meal_id']?.toString() ?? '';
      if (mealId.isEmpty) {
        throw _defaultError('Сервер не вернул идентификатор блюда.');
      }
      return mealId;
    }

    if (response.statusCode == 422) {
      throw _defaultError('На фото не удалось распознать еду.');
    }

    if (response.statusCode == 401) {
      throw _defaultError('Сессия истекла. Войдите заново.');
    }

    throw _defaultError('Не удалось обработать фото.');
  }

  /// GET /meal/info?auth_token=&meal_id=
  Future<ScanMealResult> getMealInfo(String mealId) async {
    final token = await AuthStorage.instance.getAuthToken();
    if (token == null) {
      throw _defaultError('Сессия истекла. Войдите заново.');
    }

    final uri = _buildUri('/meal/info', {
      'auth_token': token,
      'meal_id': mealId,
    });

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final withId = <String, dynamic>{
        'meal_id': mealId,
        ...data,
      };

      return ScanMealResult.fromJson(withId);
    }

    if (response.statusCode == 404) {
      throw _defaultError('Такое блюдо не найдено.');
    }

    if (response.statusCode == 401) {
      throw _defaultError('Сессия истекла. Войдите заново.');
    }

    throw _defaultError('Не удалось получить информацию о блюде.');
  }



  /// POST /tracker/save_meal
  /// body: {auth_token, meal_id}
  Future<void> saveMealToTracker(String mealId) async {
    final token = await AuthStorage.instance.getAuthToken();
    if (token == null) {
      throw _defaultError('Сессия истекла. Войдите заново.');
    }

    final uri = _buildUri('/tracker/save_meal');

    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'auth_token': token,
        'meal_id': mealId,
      }),
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 401) {
      throw _defaultError('Сессия истекла. Войдите заново.');
    }

    throw _defaultError('Не удалось сохранить блюдо в трекер.');
  }


  /// GET /ai/recommendation?auth_token=&date=
  Future<String> getRecommendation(String dateIso) async {
    final token = await AuthStorage.instance.getAuthToken();
    if (token == null) {
      throw _defaultError('Сессия истекла. Войдите заново.');
    }

    final uri = _buildUri('/ai/recommendation', {
      'auth_token': token,
      'date': dateIso,
    });

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final text = data['recommendation']?.toString() ?? '';
      if (text.isEmpty) {
        throw _defaultError('Сервер не вернул рекомендацию.');
      }
      return text;
    }

    if (response.statusCode == 428) {
      throw _defaultError('Сначала заполните данные профиля.');
    }

    if (response.statusCode == 204) {
      throw _defaultError('За выбранный день нет приёмов пищи.');
    }

    if (response.statusCode == 401) {
      throw _defaultError('Сессия истекла. Войдите заново.');
    }

    throw _defaultError('Не удалось получить рекомендации.');
  }
}
