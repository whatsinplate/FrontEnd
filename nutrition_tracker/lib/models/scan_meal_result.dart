// lib/models/scan_meal_result.dart

/// - mealId        — ID блюда из /ai/scan_meal (нужен для /tracker/save_meal)
/// - mealName      — имя блюда
/// - ingredients   — список ингредиентов
/// - calories      — ккал
/// - proteins      — белки
/// - fats          — жиры
/// - carbohydrates — углеводы
class ScanMealResult {
  final String mealId;
  final String mealName;
  final List<String> ingredients;
  final double calories;
  final double proteins;
  final double fats;
  final double carbohydrates;

  const ScanMealResult({
    required this.mealId,
    required this.mealName,
    required this.ingredients,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbohydrates,
  });

  factory ScanMealResult.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString().replaceAll(',', '.')) ?? 0;
    }

    List<String> _toStringList(dynamic v) {
      if (v is List) {
        return v.map((e) => e.toString()).toList();
      }
      return const <String>[];
    }

    return ScanMealResult(
      mealId: (json['meal_id'] ?? '').toString(),
      mealName: (json['meal_name'] ?? '').toString(),
      ingredients: _toStringList(json['ingredients']),
      calories: _toDouble(json['calories']),
      proteins: _toDouble(json['proteins']),
      fats: _toDouble(json['fats']),
      carbohydrates: _toDouble(json['carbohydrates']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_id': mealId,
      'meal_name': mealName,
      'ingredients': ingredients,
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbohydrates': carbohydrates,
    };
  }
}
