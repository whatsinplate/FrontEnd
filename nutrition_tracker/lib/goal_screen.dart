import 'package:flutter/material.dart';
import 'main_menu_screen.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  // Цели на русском
  final List<String> _goals = ['Похудение', 'Набор веса', 'Поддержание веса'];
  String? _selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Почти готово!',
                style: TextStyle(fontSize: 18, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Выберите цель, для которой\nвы рассчитываете КБЖУ',
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20)
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              Column(
                children: _goals.map((goal) {
                  final bool isSelected = _selectedGoal == goal;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGoal = goal;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8E6C9), // Светло-зеленый фон
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent, // Обводка при выборе
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Иконка выбора (радио-кнопка)
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 15),
                            Text(
                              goal,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const Spacer(),

              ElevatedButton(
                onPressed: _selectedGoal == null ? null : () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF48FB1), // Розовая кнопка
                  disabledBackgroundColor: const Color(0xFFF48FB1).withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Начать работу', style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w600)),
              ),
              
              const SizedBox(height: 20),
               const Text(
                '*Ваши данные и цель можно будет поменять в профиле в любое время',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}