// lib/processing_screen.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'api/backend_api.dart';
import 'api/api_error.dart';
import 'models/scan_meal_result.dart';
import 'scan_result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;

  const ProcessingScreen({super.key, required this.imagePath});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _startProcessing() async {
    try {
      final file = File(widget.imagePath);
      if (!file.existsSync()) {
        _showSnackBar('Не удалось найти файл изображения.');
        if (mounted) Navigator.of(context).pop();
        return;
      }

      final bytes = await file.readAsBytes();
      final imgBase64 = base64Encode(bytes);

      final String mealId = await BackendApi.instance.scanMeal(imgBase64);

      final ScanMealResult result =
      await BackendApi.instance.getMealInfo(mealId);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ScanResultScreen(
            imagePath: widget.imagePath,
            result: result,
          ),
        ),
      );
    } on ApiError catch (e) {
      if (!mounted) return;
      _showSnackBar(e.uiMessage);
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(
        'Не удалось обработать фото. Проверьте интернет и попробуйте ещё раз.',
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color.fromRGBO(236, 255, 228, 1);
    const darkGreen = Color(0xFF1B5E20);
    const ringDark = Color(0xFF6E8B63);
    const ringLight = Color(0xFFCDEEB8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Подождите',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Идет обработка фото...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 64),
              Center(
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: 0.75,
                        strokeWidth: 22,
                        backgroundColor: Colors.transparent,
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(ringLight),
                      ),
                      Transform.rotate(
                        angle: 1.2,
                        child: CircularProgressIndicator(
                          value: 0.55,
                          strokeWidth: 22,
                          backgroundColor: Colors.transparent,
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(ringDark),
                        ),
                      ),
                    ],
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
