import 'package:flutter/material.dart';

/// App color tokens adhering strictly to the PRD & TRD design system:
/// "Yellow & White" theme with High-Contrast Dark Mode.
class AppColors {
  AppColors._();

  // --- Light Theme Colors ---
  static const Color lightPrimary = Color(0xFFFFC107); // Warm Yellow
  static const Color lightPrimaryDark = Color(0xFFFFA000); // Amber 700
  static const Color lightSecondary = Color(0xFFFFF8E1); // Soft Cream Yellow
  static const Color lightSecondaryHover = Color(0xFFFFECB3);
  static const Color lightBackground = Color(0xFFFFFFFF); // Pure White
  static const Color lightSurface = Color(0xFFFAFAFA); // Cards & Sheets
  static const Color lightCardBorder = Color(0xFFEEEEEE); // Subtle Separator
  static const Color lightTextPrimary = Color(0xFF212121); // Near-black
  static const Color lightTextSecondary = Color(0xFF6E6E6E); // Neutral grey
  static const Color lightTextTertiary = Color(0xFF9E9E9E);
  static const Color lightDivider = Color(0xFFEEEEEE);

  // --- Dark Theme Colors ---
  static const Color darkPrimary = Color(0xFFFFCA28); // Luminous Yellow for contrast
  static const Color darkPrimaryDark = Color(0xFFFFB300);
  static const Color darkSecondary = Color(0xFF2C2411); // Dark Warm Tint
  static const Color darkSecondaryHover = Color(0xFF3E3316);
  static const Color darkBackground = Color(0xFF121212); // Deep Base
  static const Color darkSurface = Color(0xFF1E1E1E); // Cards & Sheets
  static const Color darkCardBorder = Color(0xFF2C2C2C); // Subtle Separator
  static const Color darkTextPrimary = Color(0xFFF5F5F5); // High Contrast White
  static const Color darkTextSecondary = Color(0xFFB0B0B0); // Subdued text
  static const Color darkTextTertiary = Color(0xFF757575);
  static const Color darkDivider = Color(0xFF2C2C2C);

  // --- Semantic & Accent Colors ---
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFB8C00);
  static const Color info = Color(0xFF29B6F6);
  static const Color starActive = Color(0xFFFFB300);

  // --- Preset Subject Palette ---
  static const List<Color> subjectColors = [
    Color(0xFFFFC107), // Yellow
    Color(0xFFFF7043), // Deep Orange
    Color(0xFF42A5F5), // Blue
    Color(0xFF66BB6A), // Green
    Color(0xFFAB47BC), // Purple
    Color(0xFFEC407A), // Pink
    Color(0xFF26A69A), // Teal
    Color(0xFF8D6E63), // Brown
    Color(0xFF5C6BC0), // Indigo
    Color(0xFFFFA726), // Orange
  ];
}
