import 'package:flutter/material.dart';

import 'screens/splash/splash_screen.dart';
import 'theme.dart';

void main() {
  runApp(const PetLogApp());
}

class PetLogApp extends StatelessWidget {
  const PetLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '펫토리',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SplashScreen(),
    );
  }
}
