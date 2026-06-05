import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  final String currentColor;

  const SplashScreen({
    super.key,
    required this.currentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColors.colorSchemes[currentColor]!;
    
    return Scaffold(
      backgroundColor: colorScheme['background'],
      body: Center(
        child: Text(
          "Be\nHappy\nEveryday",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            height: 1.2,
            fontWeight: FontWeight.normal,
            color: colorScheme['text'],
          ),
        ),
      ),
    );
  }
}
