import 'package:flutter/material.dart';
import '../services/auth_storage.dart';
import 'api/backend_api.dart';
import 'api/api_error.dart';
import 'models/user_info.dart';
import 'main_menu_screen.dart';

class ProfileDataScreen extends StatefulWidget {
  const ProfileDataScreen({super.key});

  @override
  State<ProfileDataScreen> createState() => _ProfileDataScreenState();
}

class _ProfileDataScreenState extends State<ProfileDataScreen> {
  final _formKey = GlobalKey<FormState>();

  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  UserInfo? _userInfo;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

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

  Future<void> _loadUserInfo() async {
    try {
      final info = await BackendApi.instance.getUserInfo();
      if (!mounted) return;

      if (info == null) {
        setState(() {
          _userInfo = null;
          _ageController.text = '';
          _heightController.text = '';
          _weightController.text = '';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _userInfo = info;
        _ageController.text = info.age.toString();
        _heightController.text = info.height.toStringAsFixed(0);
        _weightController.text = info.weight.toString();
        _isLoading = false;
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      _showSnackBar(e.uiMessage);
      setState(() {
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(
        'Не удалось загрузить данные. Проверьте интернет и попробуйте ещё раз.',
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    int age;
    double height;
    int weight;

    try {
      age = int.parse(_ageController.text.trim());
      height = double.parse(
        _heightController.text.trim().replaceAll(',', '.'),
      );
      weight = int.parse(_weightController.text.trim());
    } catch (_) {
      _showSnackBar('Проверьте корректность введённых значений.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final gender = _userInfo?.gender ?? 'M';
    final goal = _userInfo?.goal ?? 'support_weight';

    try {
      await BackendApi.instance.setUserInfo(
        age: age,
        gender: gender,
        height: height,
        weight: weight,
        goal: goal,
      );

      if (!mounted) return;
      _showSnackBar('Данные успешно обновлены.');
      Navigator.of(context).pop();
    } on ApiError catch (e) {
      if (!mounted) return;
      _showSnackBar(e.uiMessage);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(
        'Не удалось сохранить данные. Проверьте интернет и попробуйте ещё раз.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(236, 255, 228, 1),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF81C784),
          ),
        )
            : Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFFCDEEB8),
                    child: Icon(
                      Icons.person_outline,
                      size: 40,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 16),


                  FutureBuilder<String?>(
                    future: AuthStorage.instance.getLogin(),
                    builder: (context, snapshot) {
                      final login = snapshot.data;
                      return Text(
                        (login != null && login.isNotEmpty)
                            ? login
                            : 'Имя Пользователя',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5E20),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(178, 237, 167, 1),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            label: 'Возраст',
                            hint: 'Введите ваш возраст',
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Введите возраст';
                              }
                              final n = int.tryParse(value.trim());
                              if (n == null || n <= 0 || n > 120) {
                                return 'Укажите возраст от 1 до 120';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            label: 'Рост',
                            hint: 'Введите ваш рост, см',
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Введите рост';
                              }
                              final n = double.tryParse(
                                value
                                    .trim()
                                    .replaceAll(',', '.'),
                              );
                              if (n == null || n < 100 || n > 250) {
                                return 'Укажите рост в диапазоне 100–250 см';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            label: 'Вес',
                            hint: 'Введите ваш вес, кг',
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Введите вес';
                              }
                              final n = int.tryParse(value.trim());
                              if (n == null || n < 30 || n > 300) {
                                return 'Укажите вес в диапазоне 30–300 кг';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  _buildBottomButton(
                    text: 'Сохранить',
                    onPressed: _isSaving ? null : _onSavePressed,
                  ),
                  const SizedBox(width: 8),
                  _buildBottomButton(
                    text: 'На главную',
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const MainMenuScreen(),
                        ),
                            (route) => false,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildBottomButton(
                    text: 'Назад',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCDEEB8),
          foregroundColor: const Color(0xFF1B5E20),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFCDEEB8),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF31612B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF31612B)),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF31612B)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF31612B), width: 1.4),
              ),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
