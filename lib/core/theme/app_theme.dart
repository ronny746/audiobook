import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Palette
  static const Color saffron = Color(0xFFF4C430);
  static const Color cream = Color(0xFFFFFDD0);
  static const Color lightBrown = Color(0xFFD2B48C);
  static const Color deepMaroon = Color(0xFF800000);
  
  // Neutral Palette
  static const Color background = Color(0xFFFFF9F0); // Very light cream
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
  
  // Accents
  static const Color accentSaffron = Color(0xFFFF9933);
  static const Color softGold = Color(0xFFE5B80B);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.saffron,
        primary: AppColors.deepMaroon,
        secondary: AppColors.saffron,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.philosopher(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.deepMaroon,
        ),
        headlineMedium: GoogleFonts.philosopher(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.deepMaroon,
        ),
        titleLarge: GoogleFonts.philosopher(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 4,
        shadowColor: AppColors.deepMaroon.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.saffron.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
