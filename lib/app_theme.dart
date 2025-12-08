import 'package:flutter/material.dart';

class AppColors {
  /// Светлый зелёный фон всего приложения
  static const background = Color.fromRGBO(236, 255, 228, 1);

  /// Зелёная карточка под формами
  static const card = Color.fromRGBO(200, 255, 191, 1);

  /// Розовые поля ввода
  static const inputPink = Color.fromRGBO(255, 215, 239, 1);

  /// Тёмно-зелёный текстовый цвет (заголовки)
  static const primaryText = Color.fromRGBO(0, 57, 9, 1);

  /// Светло-зелёная кнопка
  static const mainButton = Color.fromRGBO(138, 209, 132, 1);

  /// Розовая акцентная кнопка
  static const accentPink = Color.fromRGBO(254, 62, 241, 1);

  /// Очень светлый зелёный
  static const inputGreen = Color.fromRGBO(200, 255, 191, 1);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryText,
      brightness: Brightness.light,
      background: AppColors.background,
      primary: AppColors.primaryText,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );
}
