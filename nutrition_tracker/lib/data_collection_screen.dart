import 'package:flutter/material.dart';
import 'goal_screen.dart';

class DataCollectionScreen extends StatefulWidget {
  const DataCollectionScreen({super.key});

  @override
  State<DataCollectionScreen> createState() => _DataCollectionScreenState();
}

class _DataCollectionScreenState extends State<DataCollectionScreen> {
  // Варианты на русском языке
  final List<String> genderOptions = ['Мужской', 'Женский'];
  final List<String> activityLevels = [
    'Малая активность',
    'Умеренная активность',
    'Большая активность',
  ];

  String? _selectedGender;
  String? _selectedActivityLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          children: [
            const Center(
              child: Text(
                'Введите свои данные',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFC8E6C9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  _buildTextField('Возраст', 'Введите ваш возраст', keyboardType: TextInputType.number),
                  const SizedBox(height: 15),
                  _buildTextField('Рост', 'Введите ваш рост, см', keyboardType: TextInputType.number),
                  const SizedBox(height: 15),
                  _buildTextField('Вес', 'Введите ваш вес, кг', keyboardType: TextInputType.number),
                  const SizedBox(height: 15),

                  // Выпадающий список: ПОЛ
                  _buildDropdownField(
                    label: 'Пол',
                    hint: 'Выберите свой пол',
                    value: _selectedGender,
                    items: genderOptions,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 15),

                  // Выпадающий список: АКТИВНОСТЬ
                  _buildDropdownField(
                    label: 'Уровень активности',
                    hint: 'Выберите уровень активности',
                    value: _selectedActivityLevel,
                    items: activityLevels,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedActivityLevel = newValue;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 30),
                  
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GoalScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF48FB1), // Розовая кнопка
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Продолжить', style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 15),
            const Text(
              '*Данные будут использоваться для точных расчетов и рекомендаций',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 5),
          child: Text(label, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
        ),
        TextField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
            filled: true,
            fillColor: const Color(0xFFE8F5E9), // Чуть светлее фона контейнера
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: UnderlineInputBorder(
              borderSide: const BorderSide(color: Colors.black54),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 5),
          child: Text(label, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
            border: const Border(bottom: BorderSide(color: Colors.black54)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              isExpanded: true,
              icon: const Icon(Icons.search, color: Colors.black54),
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}