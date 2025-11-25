import 'package:flutter/material.dart';
import 'dart:io'; // Нужен для отображения фото с телефона

class ScanResultScreen extends StatelessWidget {
  // Переменная для хранения пути к фото
  final String imagePath;

  const ScanResultScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      appBar: AppBar(
        title: const Text('Результаты сканирования', style: TextStyle(color: Color(0xFF1B5E20))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 1. Карточка с результатом
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8E6C9), // Зеленый фон карточки
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Ребрышки барбекю',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Фотография блюда
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network( // Пока используем тестовую картинку из интернета для красоты, или локальный файл
                        'https://img.freepik.com/free-photo/grilled-pork-ribs-with-barbecue-sauce_1339-75660.jpg', 
                        // Если хотите показать реальное фото с камеры, раскомментируйте строки ниже, а Image.network уберите:
                        // imagePath.isNotEmpty 
                        //  ? Image.file(File(imagePath), height: 200, width: double.infinity, fit: BoxFit.cover)
                        //  : Container(height: 200, color: Colors.grey),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Ингредиенты
                    const Text('Ингредиенты:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 5),
                    const Text(
                      'Свиные ребрышки\nСоус барбекю\nПетрушка\nСоль\nПерец\nПаприка\nЧеснок',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    
                    // КБЖУ
                    const Text('КБЖУ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 5),
                    const Text(
                      'Ккал: 1450\nБелки: 115\nЖиры: 90\nУглеводы: 35',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Розовая кнопка "Записать в трекер"
                    ElevatedButton(
                      onPressed: () {
                        // Логика сохранения
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сохранено в трекер!')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF48FB1),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text('Записать в трекер', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 2. Нижние кнопки (Переснять, На главную, Повторить)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSmallButton('Переснять', () {
                     Navigator.pop(context); // Возврат назад
                  }),
                  _buildSmallButton('На главную', () {
                    // Возврат в самое начало (на главный экран)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }),
                  _buildSmallButton('Повторить', () {
                    // Имитация повтора (можно просто обновить стейт)
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFA5D6A7), // Темно-зеленый
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
    );
  }
}