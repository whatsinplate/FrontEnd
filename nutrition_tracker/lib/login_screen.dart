import 'package:flutter/material.dart';
import 'main_menu_screen.dart';
import 'forgot_password_step1.dart'; // Убедитесь, что этот файл создан (код был в прошлом ответе)

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Вход',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 60),
                
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8E6C9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      _buildTextField('Имя пользователя', 'Введите имя'),
                      const SizedBox(height: 20),
                      _buildTextField('Пароль', 'Введите пароль', obscureText: true),
                      
                      // Кнопка "Забыли пароль?"
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPasswordStep1Screen()),
                            );
                          },
                          child: const Text(
                            'Забыли пароль?',
                            style: TextStyle(
                              color: Colors.black54,
                              decoration: TextDecoration.underline,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF81C784),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Продолжить', 
                          style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w600)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 5),
          child: Text(label, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
        ),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFFFCDD2).withOpacity(0.5), // Розоватый фон
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
}