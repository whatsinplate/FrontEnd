import 'package:flutter/material.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Профиль
              const Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFC8E6C9),
                    child: Icon(Icons.person_outline, size: 40, color: Colors.black87),
                  ),
                  SizedBox(width: 15),
                  Text('Профиль', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 30),
              
              // Белая карточка
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Что в тарелке?', 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))
                    ),
                    SizedBox(height: 5),
                    Text.rich(
                      TextSpan(
                        text: 'Твой удобный счетчик ',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        children: [
                          TextSpan(
                            text: 'КБЖУ',
                            style: TextStyle(color: Color(0xFF880E4F), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Кнопка "Распознать еду"
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8E6C9),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Распознать еду', style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w600)),
              ),
              
              const Spacer(),
              
              // Иллюстрация и кнопка трекера
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCDD2).withOpacity(0.5), // Бледно-розовый круг
                      shape: BoxShape.circle,
                    ),
                  ),
                  Column(
                    children: [
                      // Иконка еды
                      const Icon(Icons.lunch_dining, size: 120, color: Color(0xFF1B5E20)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF48FB1),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Трекер КБЖУ', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}