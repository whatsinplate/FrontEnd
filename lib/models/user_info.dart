// lib/models/user_info.dart

class UserInfo {
  final int age;
  final String gender; // 'M' или 'F'
  final double height; // см
  final int weight;    // кг
  final String goal;   // 'lose_weight' | 'gain_weight' | 'support_weight'

  const UserInfo({
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.goal,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    double _toDouble(dynamic v) {
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString().replaceAll(',', '.')) ?? 0;
    }

    return UserInfo(
      age: _toInt(json['age']),
      gender: (json['gender'] ?? '').toString(),
      height: _toDouble(json['height']),
      weight: _toInt(json['weight']),
      goal: (json['goal'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJsonWithToken(String authToken) {
    return {
      'auth_token': authToken,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'goal': goal,
    };
  }

  UserInfo copyWith({
    int? age,
    String? gender,
    double? height,
    int? weight,
    String? goal,
  }) {
    return UserInfo(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      goal: goal ?? this.goal,
    );
  }
}
