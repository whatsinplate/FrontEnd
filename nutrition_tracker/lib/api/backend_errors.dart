// lib/api/backend_errors.dart

import 'dart:convert';

import 'api_error.dart';

String mapBackendMessageToUi(String backendMessage) {
  switch (backendMessage) {
  // auth.py
    case 'Credentials were wrong.':
      return 'Неверный логин или пароль.';
    case 'User already exists.':
      return 'Пользователь с таким логином уже существует.';
    case 'User does not exist.':
      return 'Пользователь не найден.';
    case 'Secret question answer was wrong.':
      return 'Неверный ответ на секретный вопрос.';
    case 'Token is invalid.':
      return 'Сессия истекла. Войдите заново.';

  // user_info.py
    case 'User info was successfully updated.':
      return 'Данные пользователя успешно обновлены.';

  // tracker / meal / ai
    case 'No such meal.':
      return 'Такой приём пищи не найден.';
    case 'The meal was successfully saved.':
      return 'Приём пищи сохранён.';
    case 'The image does not seem to contain food.':
      return 'На фото не удалось распознать еду.';
    case 'AI response is not a valid JSON. Try again.':
      return 'Сервис распознавания вернул некорректный ответ. Попробуйте ещё раз.';

    default:
      return 'Произошла ошибка. Попробуйте ещё раз.';
  }
}

ApiError parseError(int statusCode, String body) {
  String backendMessage = 'Unknown error.';

  try {
    final data = jsonDecode(body);
    if (data is Map) {
      if (data['detail'] is Map && (data['detail'] as Map)['message'] != null) {
        backendMessage = (data['detail'] as Map)['message'].toString();
      } else if (data['message'] != null) {
        backendMessage = data['message'].toString();
      }
    }
  } catch (_) {}

  return ApiError(
    statusCode: statusCode,
    backendMessage: backendMessage,
    uiMessage: mapBackendMessageToUi(backendMessage),
  );
}
