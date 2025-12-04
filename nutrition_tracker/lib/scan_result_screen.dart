// lib/scan_result_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';

import 'api/backend_api.dart';
import 'api/api_error.dart';
import 'main_menu_screen.dart';
import 'models/scan_meal_result.dart';

class ScanResultScreen extends StatefulWidget {
  final String imagePath;
  final ScanMealResult result;

  const ScanResultScreen({
    super.key,
    required this.imagePath,
    required this.result,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  bool _isSaving = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onAddToTrackerPressed() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await BackendApi.instance.saveMealToTracker(widget.result.mealId);

      if (!mounted) return;
      _showSnackBar('Блюдо успешно добавлено в трекер.');
    } on ApiError catch (e) {
      if (!mounted) return;
      _showSnackBar(e.uiMessage);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(
        'Не удалось сохранить блюдо в трекер. '
            'Проверьте интернет и попробуйте ещё раз.',
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
    final result = widget.result;

    const backgroundColor = Color.fromRGBO(236, 255, 228, 1);
    const cardColor = Color(0xFFC8E6C9);
    const darkGreen = Color(0xFF335C22);
    const mediumGreen = Color.fromRGBO(138, 209, 132, 1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Результаты сканирования:',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 16),

              // Карточка с блюдом (скроллится, если контента много)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            result.mealName.isEmpty
                                ? 'Блюдо'
                                : result.mealName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: darkGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Image.file(
                            File(widget.imagePath),
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Ингредиенты:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: darkGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (result.ingredients.isEmpty)
                          const Text(
                            'Не удалось определить ингредиенты.',
                            style: TextStyle(
                              fontSize: 16,
                              color: darkGreen,
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: result.ingredients
                                .map(
                                  (ing) => Text(
                                ing,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: darkGreen,
                                ),
                              ),
                            )
                                .toList(),
                          ),
                        const SizedBox(height: 24),

                        const Text(
                          'КБЖУ:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: darkGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildMacroLine('Ккал', result.calories),
                        _buildMacroLine('Белки', result.proteins),
                        _buildMacroLine('Жиры', result.fats),
                        _buildMacroLine('Углеводы', result.carbohydrates),
                        const SizedBox(height: 32),

                        // Кнопка "Записать в трекер" – не на всю ширину
                        Center(
                          child: SizedBox(
                            width: 260,
                            height: 54,
                            child: ElevatedButton(
                              onPressed:
                              _isSaving ? null : _onAddToTrackerPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkGreen,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                                  : const Text(
                                'Записать в трекер',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildBottomButton(
                      'Переснять',
                          () {
                        Navigator.of(context).pop();
                      },
                      mediumGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildBottomButton(
                      'На главную',
                          () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const MainMenuScreen(),
                          ),
                              (route) => false,
                        );
                      },
                      mediumGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildBottomButton(
                      'Повторить',
                          () {
                        Navigator.of(context).pop();
                      },
                      mediumGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroLine(String label, double value) {
    final textValue = value.isNaN ? '0' : value.toStringAsFixed(0);

    return Text(
      '$label: $textValue',
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF335C22),
      ),
    );
  }

  Widget _buildBottomButton(
      String text,
      VoidCallback onPressed,
      Color backgroundColor,
      ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
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
          color: Color(0xFF003909),
        ),
      ),
    );
  }
}
