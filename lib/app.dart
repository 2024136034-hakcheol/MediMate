import 'package:flutter/material.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/theme/app_theme.dart';

class MediMateApp extends StatelessWidget {
  const MediMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainScreen(),
    );
  }
}
