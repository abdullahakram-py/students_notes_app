import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Complete ThemeData definition for Light and Dark modes.
class AppTheme {
  AppTheme._();

  // --- Light Theme ---
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    final headingFont = GoogleFonts.poppins();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.lightPrimary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        primaryContainer: AppColors.lightSecondary,
        secondary: AppColors.lightPrimaryDark,
        secondaryContainer: AppColors.lightSecondaryHover,
        surface: AppColors.lightSurface,
        error: AppColors.error,
        onPrimary: AppColors.lightTextPrimary,
        onSecondary: AppColors.lightBackground,
        onSurface: AppColors.lightTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: headingFont.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.lightTextPrimary,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightCardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 3,
        hoverElevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
        hintStyle: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.lightTextTertiary,
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: headingFont.copyWith(fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary),
        displayMedium: headingFont.copyWith(fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary),
        headlineLarge: headingFont.copyWith(fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary),
        headlineMedium: headingFont.copyWith(fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary),
        titleLarge: headingFont.copyWith(fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary, fontSize: 18),
        titleMedium: headingFont.copyWith(fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary, fontSize: 16),
        titleSmall: headingFont.copyWith(fontWeight: FontWeight.w600, color: AppColors.lightTextSecondary, fontSize: 14),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.lightTextPrimary, fontSize: 16),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.lightTextSecondary, fontSize: 14),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: AppColors.lightTextTertiary, fontSize: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSecondary,
        labelStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightCardBorder),
        ),
      ),
    );
  }

  // --- Dark Theme ---
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    final headingFont = GoogleFonts.poppins();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        primaryContainer: AppColors.darkSecondary,
        secondary: AppColors.darkPrimaryDark,
        secondaryContainer: AppColors.darkSecondaryHover,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: AppColors.darkBackground,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: headingFont.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkCardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkBackground,
        elevation: 3,
        hoverElevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        hintStyle: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextTertiary,
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: headingFont.copyWith(fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary),
        displayMedium: headingFont.copyWith(fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary),
        headlineLarge: headingFont.copyWith(fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
        headlineMedium: headingFont.copyWith(fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
        titleLarge: headingFont.copyWith(fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary, fontSize: 18),
        titleMedium: headingFont.copyWith(fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary, fontSize: 16),
        titleSmall: headingFont.copyWith(fontWeight: FontWeight.w600, color: AppColors.darkTextSecondary, fontSize: 14),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.darkTextPrimary, fontSize: 16),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.darkTextSecondary, fontSize: 14),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: AppColors.darkTextTertiary, fontSize: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSecondary,
        labelStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkCardBorder),
        ),
      ),
    );
  }
}
