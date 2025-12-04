import 'package:flutter/material.dart';

import 'reset_password_screen.dart';

class ForgotPasswordStep1Screen extends StatefulWidget {
  final String login;
  final String secretQuestion;

  const ForgotPasswordStep1Screen({
    super.key,
    required this.login,
    required this.secretQuestion,
  });

  @override
  State<ForgotPasswordStep1Screen> createState() =>
      _ForgotPasswordStep1ScreenState();
}

class _ForgotPasswordStep1ScreenState extends State<ForgotPasswordStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _questionController.text = widget.secretQuestion;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _onContinue() async {
    if (_isLoading) return;

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final secretAnswer = _answerController.text.trim();

    if (secretAnswer.isEmpty) {
      _showSnack('Введите секретный ответ.');
      return;
    }

    setState(() => _isLoading = true);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(
          login: widget.login,
          secretAnswer: secretAnswer,
        ),
      ),
    );

    setState(() => _isLoading = false);
  }

  Widget _buildPinkField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(
        fontSize: 16,
        color: Color.fromRGBO(0, 57, 9, 1),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: Color.fromRGBO(0, 0, 0, 0.6),
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color.fromRGBO(0, 0, 0, 0.45),
        ),
        filled: true,
        fillColor: const Color.fromRGBO(255, 215, 239, 1),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(
            color: Color.fromRGBO(0, 0, 0, 0.35),
            width: 1,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(
            color: Color.fromRGBO(0, 0, 0, 0.35),
            width: 1,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(
            color: Color.fromRGBO(0, 0, 0, 0.7),
            width: 1,
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const Text(
                  'Сброс пароля',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(0, 57, 9, 1),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Чтобы продолжить, введите\nваш секретный вопрос и ответ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(0, 57, 9, 1),
                  ),
                ),

                const SizedBox(height: 32),

                Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDEEB8),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPinkField(
                            controller: _questionController,
                            label: 'Секретный вопрос',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Введите секретный вопрос';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildPinkField(
                            controller: _answerController,
                            label: 'Секретный ответ',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Введите секретный ответ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: 190,
                            height: 46,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _onContinue,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(
                                    138, 209, 132, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                    Color.fromRGBO(0, 57, 9, 1),
                                  ),
                                ),
                              )
                                  : const Text(
                                'Продолжить',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromRGBO(0, 57, 9, 1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
