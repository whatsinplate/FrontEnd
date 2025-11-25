import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Пакет для работы с камерой
import 'processing_screen.dart'; // Экран загрузки

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();

    void showImageSourceActionSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFFF0F8F0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext ctx) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF1B5E20)),
                  title: const Text('Камера'),
                  onTap: () async {
                    Navigator.of(ctx).pop(); // Закрыть меню
                    // Открыть камеру
                    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
                    if (photo != null) {
                      // Если фото сделано, идем на экран обработки
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProcessingScreen(imagePath: photo.path)),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFF1B5E20)),
                  title: const Text('Галерея'),
                  onTap: () async {
                    Navigator.of(ctx).pop(); // Закрыть меню
                    // Открыть галерею
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      // Если фото выбрано, идем на экран обработки
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProcessingScreen(imagePath: image.path)),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close, color: Colors.red),
                  title: const Text('Отмена', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    }

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
                onPressed: () {
                  // Вызываем меню выбора (Камера/Галерея)
                  showImageSourceActionSheet(context);
                },
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
                      color: const Color(0xFFFFCDD2).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Column(
                    children: [
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