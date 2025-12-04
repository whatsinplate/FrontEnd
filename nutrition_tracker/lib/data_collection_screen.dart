import 'package:flutter/material.dart';
import 'goal_screen.dart';

class DataCollectionScreen extends StatefulWidget {
  const DataCollectionScreen({super.key});

  @override
  State<DataCollectionScreen> createState() => _DataCollectionScreenState();
}

class _DataCollectionScreenState extends State<DataCollectionScreen> {
  final List<String> genderOptions = ['Мужской', 'Женский'];

  String? _selectedGender = 'Мужской';

  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _onContinuePressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGender == null) {
      _showSnackBar('Пожалуйста, выберите пол.');
      return;
    }

    int age;
    double height;
    int weight;

    try {
      age = int.parse(_ageController.text.trim());
    } catch (_) {
      _showSnackBar('Введите корректный возраст.');
      return;
    }

    try {
      height = double.parse(
        _heightController.text.trim().replaceAll(',', '.'),
      );
    } catch (_) {
      _showSnackBar('Введите корректный рост в сантиметрах.');
      return;
    }

    try {
      weight = int.parse(_weightController.text.trim());
    } catch (_) {
      _showSnackBar('Введите корректный вес в килограммах.');
      return;
    }

    final genderCode = _selectedGender == 'Мужской' ? 'M' : 'F';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalScreen(
          age: age,
          height: height,
          weight: weight,
          genderCode: genderCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color.fromRGBO(236, 255, 228, 1);
    const cardColor = Color.fromRGBO(200, 255, 191, 1);
    const fieldColor = Color.fromRGBO(236, 255, 228, 1);
    const titleColor = Color.fromRGBO(0, 57, 9, 1);
    const buttonColor = Color.fromRGBO(138, 209, 132, 1);
    const darkTextColor = titleColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 24),

                      const Text(
                        'Введите свои данные',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Выберите ваш пол',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: darkTextColor,
                                ),
                              ),
                              const SizedBox(height: 16),

                              _buildGenderToggle(),

                              const SizedBox(height: 24),

                              _buildTextField(
                                label: 'Вес',
                                hint: 'Введите ваш вес, кг',
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Введите вес';
                                  }
                                  final n = int.tryParse(value.trim());
                                  if (n == null || n < 30 || n > 300) {
                                    return 'Укажите вес в диапазоне 30–300 кг';
                                  }
                                  return null;
                                },
                                fieldColor: fieldColor,
                                darkTextColor: darkTextColor,
                              ),

                              const SizedBox(height: 16),

                              _buildTextField(
                                label: 'Рост',
                                hint: 'Введите ваш рост, см',
                                controller: _heightController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Введите рост';
                                  }
                                  final n = double.tryParse(
                                    value.trim().replaceAll(',', '.'),
                                  );
                                  if (n == null || n < 100 || n > 250) {
                                    return 'Укажите рост в диапазоне 100–250 см';
                                  }
                                  return null;
                                },
                                fieldColor: fieldColor,
                                darkTextColor: darkTextColor,
                              ),

                              const SizedBox(height: 16),

                              // Возраст
                              _buildTextField(
                                label: 'Возраст',
                                hint: 'Введите ваш возраст',
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Введите возраст';
                                  }
                                  final n = int.tryParse(value.trim());
                                  if (n == null || n <= 0 || n > 120) {
                                    return 'Укажите возраст от 1 до 120';
                                  }
                                  return null;
                                },
                                fieldColor: fieldColor,
                                darkTextColor: darkTextColor,
                              ),

                              const SizedBox(height: 28),

                              Center(
                                child: SizedBox(
                                  width: 220,
                                  child: ElevatedButton(
                                    onPressed: _onContinuePressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: buttonColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(32),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Продолжить',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: darkTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
                        child: Text(
                          '*Данные будут использоваться для точных расчётов и рекомендаций',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGenderToggle() {
    const maleColor = Color(0xFFB6D4FF);
    const femaleColor = Color(0xFFFFC5ED);
    const pillBackground = Color.fromRGBO(236, 255, 228, 1);
    const darkTextColor = Color.fromRGBO(0, 57, 9, 1);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: pillBackground,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildGenderButton(
              label: 'Мужской',
              isSelected: _selectedGender == 'Мужской',
              backgroundColor: maleColor,
              darkTextColor: darkTextColor,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildGenderButton(
              label: 'Женский',
              isSelected: _selectedGender == 'Женский',
              backgroundColor: femaleColor,
              darkTextColor: darkTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton({
    required String label,
    required bool isSelected,
    required Color backgroundColor,
    required Color darkTextColor,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor, // всегда цветные
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected
                ? darkTextColor.withOpacity(0.7)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    required Color fieldColor,
    required Color darkTextColor,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: 18,
        color: darkTextColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelStyle: TextStyle(
          color: darkTextColor,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color.fromRGBO(0, 0, 0, 0.4),
          fontSize: 16,
        ),
        filled: true,
        fillColor: fieldColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
