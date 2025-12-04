import 'package:flutter/material.dart';
import 'services/auth_storage.dart';
import 'api/backend_api.dart';
import 'api/api_error.dart';
import 'models/user_info.dart';

class ProfileGoalScreen extends StatefulWidget {
  const ProfileGoalScreen({super.key});

  @override
  State<ProfileGoalScreen> createState() => _ProfileGoalScreenState();
}

class _ProfileGoalScreenState extends State<ProfileGoalScreen> {
  final List<String> _goalsRu = ['Похудение', 'Набор веса', 'Поддержание веса'];

  UserInfo? _userInfo;
  String? _selectedGoalRu;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _backendGoalToRu(String goal) {
    switch (goal) {
      case 'lose_weight':
        return 'Похудение';
      case 'gain_weight':
        return 'Набор веса';
      case 'support_weight':
      default:
        return 'Поддержание веса';
    }
  }

  String _ruToBackendGoal(String goalRu) {
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

  Future<void> _loadUserInfo() async {
    try {
      final info = await BackendApi.instance.getUserInfo();
      if (!mounted) return;

      if (info == null) {
        setState(() {
          _userInfo = null;
          _selectedGoalRu = 'Поддержание веса';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _userInfo = info;
        _selectedGoalRu = _backendGoalToRu(info.goal);
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


  Future<void> _onSavePressed() async {
    if (_userInfo == null || _selectedGoalRu == null) return;
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final updated = _userInfo!.copyWith(
      goal: _ruToBackendGoal(_selectedGoalRu!),
    );

    try {
      await BackendApi.instance.setUserInfo(
        age: updated.age,
        gender: updated.gender,
        height: updated.height,
        weight: updated.weight,
        goal: updated.goal,
      );
      if (!mounted) return;
      _showSnackBar('Цель успешно обновлена.');
      Navigator.of(context).pop();
    } on ApiError catch (e) {
      if (!mounted) return;
      _showSnackBar(e.uiMessage);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(
        'Не удалось сохранить цель. Проверьте интернет и попробуйте ещё раз.',
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Цель использования',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color:  Color.fromRGBO(200, 255, 191, 1),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
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
          const SizedBox(height: 16),
                ],
              ),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8E6C9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: _goalsRu.map((goal) {
                    final isSelected = _selectedGoalRu == goal;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGoalRu = goal;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xFFFFCDD2)
                                : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Color(0xFFFFCDD2)
                                  : Colors.black26,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 20,
                                color: const Color(0xFF1B5E20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  goal,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSavePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFCDD2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                      AlwaysStoppedAnimation(Colors.black87),
                    ),
                  )
                      : const Text(
                    'Сохранить',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
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
