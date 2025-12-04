import 'package:flutter/material.dart';
import '../services/auth_storage.dart';

import '../api/backend_api.dart';
import '../api/api_error.dart';
import 'main_menu_screen.dart';
import 'forgot_password_step1.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  Future<void> _onLoginPressed() async {
    if (_isLoading) return;

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final login = _loginController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      await BackendApi.instance.login(login: login, password: password);
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainMenuScreen()),
            (route) => false,
      );
    } on ApiError catch (e) {
      if (!mounted) return;
      _showSnackBar(e.uiMessage);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(
        'Не удалось войти. Проверьте интернет-соединение и попробуйте ещё раз.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onForgotPasswordPressed() async {
    if (_isLoading) return;

    final login = _loginController.text.trim();
    if (login.isEmpty) {
      _showSnackBar('Введите имя пользователя, чтобы восстановить пароль.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final question = await BackendApi.instance.getSecretQuestion(login);
      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ForgotPasswordStep1Screen(
            login: login,
            secretQuestion: question,
          ),
        ),
      );
    } on ApiError catch (e) {
      if (!mounted) return;
      _showSnackBar(e.uiMessage);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(
        'Не удалось получить секретный вопрос. Проверьте интернет и попробуйте ещё раз.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color.fromRGBO(236, 255, 228, 1);
    const cardColor = Color.fromRGBO(200, 255, 191, 1);
    const pinkFieldColor = Color.fromRGBO(255, 215, 239, 1);
    const titleColor = Color.fromRGBO(0, 57, 9, 1);
    const buttonColor = Color.fromRGBO(138, 209, 132, 1);
    const darkTextColor = titleColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              const Text(
                'Вход',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 96),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
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
                      TextFormField(
                        controller: _loginController,
                        enabled: !_isLoading,
                        style: const TextStyle(
                          fontSize: 18,
                          color: darkTextColor,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите имя пользователя';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Имя пользователя',
                          labelStyle: const TextStyle(
                            color: darkTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          floatingLabelBehavior:
                          FloatingLabelBehavior.never,
                          hintText: 'Введите имя',
                          hintStyle: const TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                            fontSize: 16,
                          ),
                          filled: true,
                          fillColor: pinkFieldColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
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
                      ),

                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _passwordController,
                        enabled: !_isLoading,
                        obscureText: _obscurePassword,
                        style: const TextStyle(
                          fontSize: 18,
                          color: darkTextColor,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите пароль';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          labelStyle: const TextStyle(
                            color: darkTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          floatingLabelBehavior:
                          FloatingLabelBehavior.never,
                          hintText: 'Введите пароль',
                          hintStyle: const TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                            fontSize: 16,
                          ),
                          filled: true,
                          fillColor: pinkFieldColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20,
                              color: const Color.fromRGBO(0, 0, 0, 0.5),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
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
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed:
                          _isLoading ? null : _onForgotPasswordPressed,
                          style: TextButton.styleFrom(
                            padding:
                            const EdgeInsets.symmetric(vertical: 4.0),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Забыли пароль?',
                            style: TextStyle(
                              fontSize: 14,
                              color: darkTextColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      Center(
                        child: SizedBox(
                          width: 220,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _onLoginPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(
                                  darkTextColor,
                                ),
                              ),
                            )
                                : const Text(
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

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
