import 'package:flutter/material.dart';
import 'dart:async'; // Для таймера
import 'scan_result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath; // Получаем путь к фото

  const ProcessingScreen({super.key, required this.imagePath});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  
  @override
  void initState() {
    super.initState();
    // Запускаем таймер на 3 секунды
    Timer(const Duration(seconds: 3), () {
      // Когда время вышло, переходим на экран результата
      // pushReplacement заменяет экран загрузки экраном результата (чтобы нельзя было вернуться назад на загрузку)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScanResultScreen(imagePath: widget.imagePath),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Подождите',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Идет обработка фото...',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            // Крутящийся индикатор загрузки
            const SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                color: Color(0xFF81C784),
                strokeWidth: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}