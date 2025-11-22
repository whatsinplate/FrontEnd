import 'package:flutter/material.dart';
import 'reset_password_screen.dart'; 

class ForgotPasswordStep1Screen extends StatelessWidget {
  const ForgotPasswordStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Сброс пароля',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Чтобы продолжить, введите\nваш секретный вопрос и ответ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1B5E20),
                    fontWeight: FontWeight.w500,
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
                      _buildTextField('Секретный вопрос', 'Введите секретный вопрос'),
                      const SizedBox(height: 20),
                      _buildTextField('Секретный ответ', 'Введите секретный ответ'),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          // Переход ко второму шагу (ввод нового пароля)
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
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

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 5),
          child: Text(label, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
        ),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFFFCDD2).withOpacity(0.5),
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