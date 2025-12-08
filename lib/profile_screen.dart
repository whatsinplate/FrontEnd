import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import 'choice_screen.dart';
import 'delete_account_screen.dart';
import 'forgot_password_step1.dart';
import 'main_menu_screen.dart';
import 'profile_data_screen.dart';
import 'profile_goal_screen.dart';
import '../api/backend_api.dart';
import '../api/api_error.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openData(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileDataScreen()),
    );
  }

  void _openGoal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileGoalScreen()),
    );
  }

  void _deleteAccount(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DeleteAccountScreen()),
    );
  }

  Future<void> _changePassword(BuildContext context) async {
    final login = await AuthStorage.instance.getLogin();
    if (login == null || login.isEmpty) {
      _showSnackBar(
        context,
        'Не удалось определить логин. Выйдите из аккаунта и войдите снова.',
      );
      return;
    }

    try {
      final question =
      await BackendApi.instance.getSecretQuestion(login);

      if (!context.mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ForgotPasswordStep1Screen(
            login: login,
            secretQuestion: question,
          ),
        ),
      );
    } on ApiError catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, e.uiMessage);
    } catch (_) {
      if (!context.mounted) return;
      _showSnackBar(
        context,
        'Не удалось получить секретный вопрос. Проверьте интернет и попробуйте ещё раз.',
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await BackendApi.instance.logout();
    } catch (_) {
    }

    await AuthStorage.instance.clearAll();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ChoiceScreen()),
          (route) => false,
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  Widget _buildPillButton({
    required String text,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isDestructive ? const Color(0xFF455A64) : const Color(0xFF33691E),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required String text,
    required VoidCallback onPressed,
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
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(236, 255, 228, 1),
      body: SafeArea(

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),

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

              const SizedBox(height: 80),

              _buildPillButton(
                text: 'Данные',
                onPressed: () => _openData(context),
              ),
              const SizedBox(height: 16),
              _buildPillButton(
                text: 'Диетические предпочтения',
                onPressed: () => _openGoal(context),
              ),
              const SizedBox(height: 16),
              _buildPillButton(
                text: 'Сменить пароль',
                onPressed: () => _changePassword(context),
              ),
              const SizedBox(height: 16),
              _buildPillButton(
                text: 'Удалить учетную запись',
                onPressed: () => _deleteAccount(context),
              ),

              const Spacer(),

              Row(
                children: [
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
                  const SizedBox(width: 12),
                  _buildBottomButton(
                    text: 'Выйти из аккаунта',
                    onPressed: () => _logout(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
