import 'package:flutter/material.dart';
import 'main_menu_screen.dart';

import 'api/backend_api.dart';
import 'api/api_error.dart';

class GoalScreen extends StatefulWidget {
  final int age;
  final double height;
  final int weight;
  final String genderCode;

  const GoalScreen({
    super.key,
    required this.age,
    required this.height,
    required this.weight,
    required this.genderCode,
  });

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final List<String> _goals = ['Похудение', 'Набор веса', 'Поддержание веса'];
  String? _selectedGoal;
  bool _isLoading = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _goalToBackendCode(String goalRu) {
    switch (goalRu) {
      case 'Похудение':
        return 'lose_weight';
      case 'Набор веса':
        return 'gain_weight';
      case 'Поддержание веса':
      default:
        return 'support_weight';
    }
  }

  Future<void> _onStartPressed() async {
    if (_selectedGoal == null) {
      _showSnackBar('Пожалуйста, выберите цель.');
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final goalCode = _goalToBackendCode(_selectedGoal!);

    try {
      await BackendApi.instance.setUserInfo(
        age: widget.age,
        gender: widget.genderCode,
        height: widget.height,
        weight: widget.weight,
        goal: goalCode,
      );
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainMenuScreen()),
            (route) => false,
      );
    } on ApiError catch (e) {
      _showSnackBar(e.uiMessage);
    } catch (_) {
      _showSnackBar(
        'Не удалось сохранить данные. Проверьте интернет-соединение и попробуйте ещё раз.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color.fromRGBO(236, 255, 228, 1);
    const cardColor = Color.fromRGBO(200, 255, 191, 1);
    const innerFieldColor = Color.fromRGBO(236, 255, 228, 1);
    const primaryTextColor = Color.fromRGBO(0, 57, 9, 1);

    const pinkAccentButton = Color.fromRGBO(255, 204, 221, 1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Почти готово!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: primaryTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Выберите цель, для которой\nвы рассчитываете КБЖУ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  children: [
                    for (final goal in _goals)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedGoal = goal),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: innerFieldColor,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _selectedGoal == goal
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: primaryTextColor,
                                  size: 22,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    goal,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Center(
                child: Text(
                  "🎉",
                  style: TextStyle(fontSize: 80),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: SizedBox(
                  width: 240,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onStartPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pinkAccentButton,
                      foregroundColor: primaryTextColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(primaryTextColor),
                      ),
                    )
                        : const Text(
                      'Начать работу',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  '*Ваши данные и цель можно будет поменять\nв профиле в любое время',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
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
