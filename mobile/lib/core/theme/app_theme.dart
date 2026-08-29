import 'package:flutter/material.dart';

/// Clean, high-contrast healthcare look. Large tap targets and readable
/// text sizes are prioritized over decoration, per the rural-accessibility
/// requirement in the project brief.
class AppColors {
  AppColors._();

static const Color darkBackground =
    Color(0xFF101816);

static const Color darkSurface =
    Color(0xFF18221F);

static const Color darkTextPrimary =
    Color(0xFFF2F6F4);

static const Color darkTextSecondary =
    Color(0xFFB7C3BF);
  static const Color primary = Color(0xFF0B7A75); // teal - trust/health
  static const Color primaryDark = Color(0xFF06544F);
  static const Color secondary = Color(0xFF1F6FEB);
  static const Color background = Color(0xFFF6FAF9);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF16211F);
  static const Color textSecondary = Color(0xFF5B6866);

  static const Color safeGreen = Color(0xFF1E8E3E);
  static const Color cautionYellow = Color(0xFFB98600);
  static const Color dangerRed = Color(0xFFD93025);

  static const Color unverifiedGrey = Color(0xFF8A8A8A);
}

class AppTheme {
  AppTheme._();

static ThemeData get darkTheme {
  final colorScheme = ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.darkSurface,
    error: AppColors.dangerRed,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor:
        AppColors.darkBackground,
    fontFamily: 'Roboto',

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        color: AppColors.darkTextPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        color: AppColors.darkTextSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor:
          AppColors.darkSurface,
      foregroundColor:
          AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: true,
    ),

    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
    ),

    inputDecorationTheme:
        InputDecorationTheme(
      filled: true,
      fillColor:
          AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
  );
}
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.dangerRed,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 17, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 15, color: AppColors.textSecondary),
        labelLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD8E3E1)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
