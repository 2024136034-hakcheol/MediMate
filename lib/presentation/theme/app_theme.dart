import 'package:flutter/material.dart';

/// MediMate 브랜드 컬러 — 발표 슬라이드(index.html)와 동일한 톤으로 통일했다.
class AppColors {
  static const navy = Color(0xFF0F2942);
  static const navyDeep = Color(0xFF0A1825);
  static const teal = Color(0xFF0D9488);
  static const tealDeep = Color(0xFF0F766E);
  static const tealSoft = Color(0xFFF0FDFA);
  static const tealLight = Color(0xFFCCFBF1);
  static const bgSoft = Color(0xFFF8FAFC);
  static const ink = Color(0xFF1E293B);
  static const muted = Color(0xFF64748B);
  static const line = Color(0xFFE2E8F0);
  static const danger = Color(0xFFB91C1C);
  static const dangerSoft = Color(0xFFFEF2F2);
  static const amber = Color(0xFFB45309);
  static const amberSoft = Color(0xFFFFFBEB);
}

class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bgSoft,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.tealDeep,
      secondary: AppColors.navy,
      surface: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy, letterSpacing: -0.3),
      titleLarge: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy, letterSpacing: -0.2),
      titleMedium: TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy),
      bodyMedium: TextStyle(color: AppColors.ink, height: 1.5),
      bodySmall: TextStyle(color: AppColors.muted, height: 1.4),
      labelLarge: TextStyle(fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.tealDeep,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: Colors.white, letterSpacing: -0.2),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.tealDeep,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.tealDeep,
        side: const BorderSide(color: AppColors.tealDeep, width: 1.4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.tealDeep,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.tealDeep,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      indicatorColor: AppColors.tealLight,
      labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? AppColors.tealDeep : AppColors.muted,
          )),
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? AppColors.tealDeep : AppColors.muted,
          )),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.tealDeep, width: 1.6),
      ),
      labelStyle: const TextStyle(color: AppColors.muted),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.tealDeep),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.tealSoft,
      labelStyle: const TextStyle(color: AppColors.tealDeep, fontWeight: FontWeight.w700, fontSize: 12),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
