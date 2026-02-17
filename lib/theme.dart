import 'package:flutter/material.dart';
class AppColors {
  static const forest = Color(0xFF2D6A4F);
  static const leaf = Color(0xFF52B788);
  static const sun = Color(0xFFF4D35E);
  static const cream = Color(0xFFFEFAE0);
  static const card = Color(0xFFFFFDF5);
  static const bark = Color(0xFF1B4332);
  static const moss = Color(0xFF5C7A6B);
  static const danger = Color(0xFFE63946);
}

class AppTheme {
  static ThemeData build() {
    return ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.forest),
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.bark),
        bodyLarge: TextStyle(color: AppColors.bark),
        titleMedium: TextStyle(color: AppColors.bark),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cream,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.leaf, width: 1.2),
        ),
        hintStyle: const TextStyle(color: AppColors.moss),
        labelStyle: const TextStyle(color: AppColors.bark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
