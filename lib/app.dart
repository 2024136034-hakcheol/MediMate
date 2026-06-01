import 'package:flutter/material.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/theme/app_theme.dart';

class MediMateApp extends StatelessWidget {
  final bool onboardingDone;
  const MediMateApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: onboardingDone ? const MainScreen() : const OnboardingScreen(),
    );
  }
}
