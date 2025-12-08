import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'processing_screen.dart';
import 'profile_screen.dart';
import 'tracker_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  Future<void> _pickImage(
      BuildContext context, {
        required ImageSource source,
      }) async {
    final picker = ImagePicker();

    try {
      final XFile? file = await picker.pickImage(
        source: source,
      );

      if (file == null) {
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProcessingScreen(imagePath: file.path),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Не удалось выбрать фото. Попробуйте ещё раз.',
            ),
          ),
        );
    }
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFE8F5E9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Center(child: Text('Camera')),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(context, source: ImageSource.camera);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Center(child: Text('Photo Library')),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(context, source: ImageSource.gallery);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Center(child: Text('Cancel')),
                  onTap: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(236, 255, 228, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(200, 255, 191, 1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 44,
                          color: Color.fromRGBO(0, 57, 9, 1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Профиль',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(0, 57, 9, 1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Что в тарелке?\nТвой удобный счётчик КБЖУ',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.4,
                    color: Color.fromRGBO(0, 57, 9, 1),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),

              const SizedBox(height: 80),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _showImageSourceSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color.fromRGBO(188, 240, 180, 1),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Распознать еду',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TrackerScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromRGBO(
                            255, 236, 245, 1),
                        border: Border.all(
                          color: const Color.fromRGBO(
                              255, 189, 233, 1),
                          width: 4,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Image.asset(
                                  'assets/images/choice_plate.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  width: 160,
                                  height: 44,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                          const TrackerScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor:
                                      const Color.fromRGBO(255, 236, 245,
                                          1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(24),
                                        side: const BorderSide(
                                          color: Color.fromRGBO(
                                              255, 189, 233, 1),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Трекер КБЖУ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromRGBO(0, 57, 9, 1),
                                      ),
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
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
