import 'package:flutter/material.dart';

import 'data_collection_screen.dart';
import 'api/backend_api.dart';
import 'api/api_error.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  Future<void> _onNextPressed() async {
    if (_isLoading) return;

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final login = _loginController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RegistrationSecretScreen(
            login: login,
            password: password,
          ),
        ),
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
                'Регистрация',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
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
                      // Имя пользователя
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
                          if (value.trim().length < 3) {
                            return 'Имя пользователя должно содержать минимум 3 символа';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Имя пользователя',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelStyle: TextStyle(
                            color: darkTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          hintText: 'Введите имя',
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                            fontSize: 16,
                          ),
                          filled: true,
                          fillColor: pinkFieldColor,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32)),
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
                          if (value.length < 6) {
                            return 'Пароль должен содержать минимум 6 символов';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelStyle: const TextStyle(
                            color: darkTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
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
                          border: const OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(32)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(32)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(32)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Подтверждение пароля
                      TextFormField(
                        controller: _confirmPasswordController,
                        enabled: !_isLoading,
                        obscureText: _obscureConfirmPassword,
                        style: const TextStyle(
                          fontSize: 18,
                          color: darkTextColor,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Повторите пароль';
                          }
                          if (value != _passwordController.text) {
                            return 'Пароли не совпадают';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Подтверждение пароля',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelStyle: const TextStyle(
                            color: darkTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          hintText: 'Введите пароль ещё раз',
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
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20,
                              color: const Color.fromRGBO(0, 0, 0, 0.5),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                              setState(() {
                                _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(32)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(32)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(32)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      Center(
                        child: SizedBox(
                          width: 220,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _onNextPressed,
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

class RegistrationSecretScreen extends StatefulWidget {
  final String login;
  final String password;

  const RegistrationSecretScreen({
    super.key,
    required this.login,
    required this.password,
  });

  @override
  State<RegistrationSecretScreen> createState() =>
      _RegistrationSecretScreenState();
}

class _RegistrationSecretScreenState extends State<RegistrationSecretScreen> {
  final _secretQuestionController = TextEditingController();
  final _secretAnswerController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _secretQuestionController.dispose();
    _secretAnswerController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  Future<void> _onRegisterPressed() async {
    if (_isLoading) return;

    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final login = widget.login.trim();
    final password = widget.password;
    final secretQuestion = _secretQuestionController.text.trim();
    final secretAnswer = _secretAnswerController.text.trim();

    try {
      await BackendApi.instance.register(
        login: login,
        password: password,
        secretQuestion: secretQuestion,
        secretAnswer: secretAnswer,
      );

      await BackendApi.instance.login(
        login: login,
        password: password,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const DataCollectionScreen(),
        ),
      );
    } on ApiError catch (e) {
      _showSnackBar(e.uiMessage);
    } catch (_) {
      _showSnackBar(
        'Не удалось завершить регистрацию. Проверьте подключение к интернету и попробуйте ещё раз.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
                'Регистрация',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
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
                      // Секретный вопрос
                      TextFormField(
                        controller: _secretQuestionController,
                        enabled: !_isLoading,
                        style: const TextStyle(
                          fontSize: 18,
                          color: darkTextColor,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите секретный вопрос';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Секретный вопрос',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelStyle: TextStyle(
                            color: darkTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          hintText: 'Введите секретный вопрос',
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                            fontSize: 16,
                          ),
                          filled: true,
                          fillColor: pinkFieldColor,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Секретный ответ
                      TextFormField(
                        controller: _secretAnswerController,
                        enabled: !_isLoading,
                        style: const TextStyle(
                          fontSize: 18,
                          color: darkTextColor,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите ответ на секретный вопрос';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Секретный ответ',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelStyle: TextStyle(
                            color: darkTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          hintText: 'Введите секретный ответ',
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                            fontSize: 16,
                          ),
                          filled: true,
                          fillColor: pinkFieldColor,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      Center(
                        child: SizedBox(
                          width: 220,
                          child: ElevatedButton(
                            onPressed:
                            _isLoading ? null : _onRegisterPressed,
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
