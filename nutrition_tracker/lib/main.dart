import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'choice_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Что в тарелке?',
      theme: buildAppTheme(),
      home: const ChoiceScreen(),
    );
  }
}
