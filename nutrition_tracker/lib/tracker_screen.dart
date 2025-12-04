import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api/api_config.dart';
import 'services/auth_storage.dart';
import 'models/scan_meal_result.dart';
import 'main_menu_screen.dart';
import 'profile_screen.dart';
import 'app_theme.dart';

class _TrackerMeal {
  final String mealId;
  final ScanMealResult info;
  final Uint8List? photo;

  const _TrackerMeal({
    required this.mealId,
    required this.info,
    this.photo,
  });
}

class _TrackerApi {
  static Uri _buildUri(String path, Map<String, String> query) {
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: query,
    );
  }

  static Future<List<String>> getTrackerMealsIds({
    required String authToken,
    required DateTime date,
  }) async {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final uri = _buildUri('/tracker/get_record', {
      'auth_token': authToken,
      'date': dateStr,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = (data['meals'] as List<dynamic>?) ?? [];
      return list.map((e) => e.toString()).toList();
    }

    if (response.statusCode == 204) {
      return <String>[];
    }

    throw Exception(
        'tracker/get_record: HTTP ${response.statusCode} ${response.body}');
  }

  static Future<ScanMealResult> getMealInfo({
    required String authToken,
    required String mealId,
  }) async {
    final uri = _buildUri('/meal/info', {
      'auth_token': authToken,
      'meal_id': mealId,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ScanMealResult.fromJson(data);
    }

    throw Exception('meal/info: HTTP ${response.statusCode} ${response.body}');
  }

  static Future<Uint8List?> getMealPhoto({
    required String authToken,
    required String mealId,
  }) async {
    final uri = _buildUri('/meal/photo', {
      'auth_token': authToken,
      'meal_id': mealId,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }

    return null;
  }

  static Future<String> getRecommendation({
    required String authToken,
    required DateTime date,
  }) async {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final uri = _buildUri('/ai/recommendation', {
      'auth_token': authToken,
      'date': dateStr,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['recommendation'] as String?) ?? '';
    }

    if (response.statusCode == 204 || response.statusCode == 428) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] is String) {
          return decoded['message'] as String;
        }
      } catch (_) {}
      return 'Рекомендации пока недоступны.';
    }

    throw Exception(
        'ai/recommendation: HTTP ${response.statusCode} ${response.body}');
  }
}

enum _TrackerView {
  selectDate,
  dayOverview,
}

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  _TrackerView _view = _TrackerView.selectDate;
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;
  List<_TrackerMeal> _meals = [];

  double _totalCalories = 0;
  double _totalProteins = 0;
  double _totalFats = 0;
  double _totalCarbs = 0;

  String get _formattedDate {
    final d = _selectedDate.day.toString().padLeft(2, '0');
    final m = _selectedDate.month.toString().padLeft(2, '0');
    final y = _selectedDate.year.toString();
    return '$d.$m.$y';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF335C22),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _loadDay() async {
    final token = await AuthStorage.instance.getAuthToken();
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сессия истекла. Войдите заново.')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainMenuScreen()),
            (route) => false,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final mealIds = await _TrackerApi.getTrackerMealsIds(
        authToken: token,
        date: _selectedDate,
      );

      final List<_TrackerMeal> loaded = [];

      for (final id in mealIds) {
        final info = await _TrackerApi.getMealInfo(
          authToken: token,
          mealId: id,
        );
        final photo = await _TrackerApi.getMealPhoto(
          authToken: token,
          mealId: id,
        );
        loaded.add(_TrackerMeal(mealId: id, info: info, photo: photo));
      }

      double c = 0;
      double p = 0;
      double f = 0;
      double cb = 0;

      for (final m in loaded) {
        c += (m.info.calories ?? 0);
        p += (m.info.proteins ?? 0);
        f += (m.info.fats ?? 0);
        cb += (m.info.carbohydrates ?? 0);
      }

      if (!mounted) return;
      setState(() {
        _meals = loaded;
        _totalCalories = c;
        _totalProteins = p;
        _totalFats = f;
        _totalCarbs = cb;
        _view = _TrackerView.dayOverview;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('Не удалось загрузить данные трекера. Попробуйте ещё раз.'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openRecommendation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrackerRecommendationScreen(date: _selectedDate),
      ),
    );
  }

  void _openMealDetails(_TrackerMeal meal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrackerMealDetailsScreen(
          date: _selectedDate,
          meal: meal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final background = AppColors.background;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _view == _TrackerView.selectDate
              ? _buildSelectDateView(context)
              : _buildDayOverviewView(context),
        ),
      ),
    );
  }

  Widget _buildSelectDateView(BuildContext context) {
    return Padding(
      key: const ValueKey('select_date'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildDateChip(),
          const SizedBox(height: 24),
          const Text(
            'Выберите дату',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF335C22),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7E6),
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month,
                      size: 64, color: Color(0xFF335C22)),
                  const SizedBox(height: 12),
                  Text(
                    _formattedDate,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF335C22),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Нажми, чтобы выбрать дату',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF335C22),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Center(
            child: SizedBox(
              width: 230,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF335C22),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: _isLoading ? null : _loadDay,
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  'Продолжить',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayOverviewView(BuildContext context) {
    return Padding(
      key: const ValueKey('day_overview'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildDateChip(),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7E6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_meals.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'На этот день ещё нет сохранённых приёмов пищи.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF335C22),
                              ),
                            ),
                          ),
                        for (final meal in _meals) ...[
                          InkWell(
                            onTap: () => _openMealDetails(meal),
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: meal.photo != null
                                        ? Image.memory(
                                      meal.photo!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    )
                                        : Container(
                                      width: 40,
                                      height: 40,
                                      color: const Color(0xFFBDDFAF),
                                      child: const Icon(
                                        Icons.restaurant,
                                        size: 22,
                                        color: Color(0xFF335C22),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      meal.info.mealName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF335C22),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'За день:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF335C22),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      '${_totalCalories.round()} ккал\n'
                          '${_totalProteins.round()} г белков\n'
                          '${_totalFats.round()} г жиров\n'
                          '${_totalCarbs.round()} г углеводов',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF335C22),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      '🍏',
                      style: TextStyle(
                        fontSize: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 260,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF335C22),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: _openRecommendation,
                child: const Text(
                  'Получить рекомендации',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Трекер',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF335C22),
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF335C22),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateChip() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF335C22),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          'дата/$_formattedDate',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class TrackerRecommendationScreen extends StatefulWidget {
  final DateTime date;

  const TrackerRecommendationScreen({super.key, required this.date});

  @override
  State<TrackerRecommendationScreen> createState() =>
      _TrackerRecommendationScreenState();
}

class _TrackerRecommendationScreenState
    extends State<TrackerRecommendationScreen> {
  String? _text;
  bool _loading = true;

  String get _formattedDate {
    final d = widget.date.day.toString().padLeft(2, '0');
    final m = widget.date.month.toString().padLeft(2, '0');
    final y = widget.date.year.toString();
    return '$d.$m.$y';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = await AuthStorage.instance.getAuthToken();
    if (token == null) {
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    try {
      final rec = await _TrackerApi.getRecommendation(
        authToken: token,
        date: widget.date,
      );
      if (!mounted) return;
      setState(() {
        _text = rec;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _text = 'Не удалось получить рекомендации. Попробуйте ещё раз.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Трекер',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF335C22),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF335C22),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF335C22),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'дата/$_formattedDate',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Рекомендации для тебя на\nэтот день',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF335C22),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7E6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: _loading
                      ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF335C22)),
                    ),
                  )
                      : SingleChildScrollView(
                    child: Text(
                      _text ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFF335C22),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  '🍏',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrackerMealDetailsScreen extends StatelessWidget {
  final DateTime date;
  final _TrackerMeal meal;

  const TrackerMealDetailsScreen({
    super.key,
    required this.date,
    required this.meal,
  });

  String get _formattedDate {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d.$m.$y';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Трекер',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF335C22),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF335C22),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF335C22),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'дата/$_formattedDate',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7E6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: meal.photo != null
                                ? Image.memory(
                              meal.photo!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                                : Container(
                              width: 80,
                              height: 80,
                              color: const Color(0xFFBDDFAF),
                              child: const Icon(
                                Icons.restaurant,
                                size: 40,
                                color: Color(0xFF335C22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              meal.info.mealName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF335C22),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'КБЖУ: ${meal.info.calories?.round() ?? 0} ккал\n'
                            'Белки: ${meal.info.proteins?.round() ?? 0} г\n'
                            'Жиры: ${meal.info.fats?.round() ?? 0} г\n'
                            'Углеводы: ${meal.info.carbohydrates?.round() ?? 0} г',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF335C22),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ингредиенты:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF335C22),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            meal.info.ingredients.isEmpty
                                ? 'Нет данных об ингредиентах.'
                                : meal.info.ingredients.join(', '),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF335C22),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 260,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF335C22),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Получить рекомендации',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

