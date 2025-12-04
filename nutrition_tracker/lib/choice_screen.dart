import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../app_theme.dart';
import '../services/auth_storage.dart';
import 'login_screen.dart';
import 'main_menu_screen.dart';
import 'registration_screen.dart';

class FractionalCropAssetImage extends StatelessWidget {
  final String assetPath;
  final Rect cropRectFraction;

  const FractionalCropAssetImage({
    super.key,
    required this.assetPath,
    required this.cropRectFraction,
  });

  Future<ui.Image> _loadImage() async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: _loadImage(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final image = snapshot.data!;
        return CustomPaint(
          painter: _CroppedImagePainter(
            image: image,
            cropRectFraction: cropRectFraction,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CroppedImagePainter extends CustomPainter {
  final ui.Image image;
  final Rect cropRectFraction;

  _CroppedImagePainter({
    required this.image,
    required this.cropRectFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTRB(
      image.width * cropRectFraction.left,
      image.height * cropRectFraction.top,
      image.width * cropRectFraction.right,
      image.height * cropRectFraction.bottom,
    );

    final dst = Offset.zero & size;

    final paint = Paint();
    canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(covariant _CroppedImagePainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.cropRectFraction != cropRectFraction;
  }
}

class ChoiceScreen extends StatefulWidget {
  const ChoiceScreen({super.key});

  @override
  State<ChoiceScreen> createState() => _ChoiceScreenState();
}

class _ChoiceScreenState extends State<ChoiceScreen> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final storage = AuthStorage.instance;

    final token = await storage.getAuthToken();
    if (token == null || token.isEmpty) {
      if (mounted) setState(() => _isCheckingAuth = false);
      return;
    }

    DateTime? savedAt;
    try {
      savedAt = await storage.getTokenSavedAt();
    } catch (_) {
      savedAt = null;
    }

    bool isExpired = true;
    if (savedAt != null) {
      isExpired = DateTime.now().difference(savedAt) > const Duration(days: 1);
    }

    if (!isExpired) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainMenuScreen()),
      );
      return;
    }

    if (mounted) setState(() => _isCheckingAuth = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryText),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final w = constraints.maxWidth;
            final topImageHeight = h * 0.38;
            final plateHeight = h * 0.11;
            final buttonsWidth = w * 0.4;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: h * 0.09),

                SizedBox(
                  height: topImageHeight,
                  width: double.infinity,
                  child: Center(
                    child: SizedBox(
                      width: w * 0.9,
                      height: topImageHeight,
                      child: const FractionalCropAssetImage(
                        assetPath: 'assets/images/choice_top.png',
                        cropRectFraction: Rect.fromLTRB(
                          0.36865234375,
                          0.05908203125,
                          0.7568359375,
                          0.45166015625,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: h * 0.02),

                SizedBox(
                  height: plateHeight,
                  child: Center(
                    child: SizedBox(
                      width: w * 0.35,
                      child: Image.asset(
                        'assets/images/choice_plate.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: h * 0.03),

                Column(
                  children: const [
                    Text(
                      'Что в тарелке?',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Контроль питания стал проще',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                SizedBox(height: h * 0.055),

                Padding(
                  padding: EdgeInsets.only(bottom: h * 0.03),
                  child: Column(
                    children: [
                      SizedBox(
                        width: buttonsWidth,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor:
                            const Color.fromRGBO(138, 209, 132, 1),
                            foregroundColor:
                            const Color.fromRGBO(0, 57, 9, 1),
                            padding:
                            const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            'Войти',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: buttonsWidth,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor:
                            const Color.fromRGBO(138, 209, 132, 1),
                            foregroundColor:
                            const Color.fromRGBO(0, 57, 9, 1),
                            padding:
                            const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                  const RegistrationScreen()),
                            );
                          },
                          child: const Text(
                            'Нет аккаунта?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
