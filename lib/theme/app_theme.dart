
import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color orange = Color(0xFFEF4B00);
  static const Color background = Color(0xFFF2F4F6);
  static const Color dark = Color(0xFF222428);
  static const Color green = Color(0xFF1E9E4A);
  static const Color red = Color(0xFFE5232B);
  static const Color backgroundAuth = Color(0xFFF3F4F6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFD5D7DB);
  static const Color inputIcon = Color(0xFF5C5F66);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF5F6268);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: orange,
        primary: orange,
        surface: white,
        error: red,
      ),

      // Text
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: dark),
        bodyMedium: TextStyle(color: dark),
        bodySmall: TextStyle(color: textSecondary),
        titleLarge: TextStyle(
          color: dark,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: dark,
          fontWeight: FontWeight.w600,
        ),
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: dark,
        elevation: 0,
        centerTitle: false,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        margin: EdgeInsets.zero,
      ),

      // Filled buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: orange,
          foregroundColor: white,
          disabledBackgroundColor: orange.withValues(alpha: 0.4),
          disabledForegroundColor: white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orange,
          foregroundColor: white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: orange,
          minimumSize: const Size(0, 44),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: orange,
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: inputBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // TabBar
      tabBarTheme: const TabBarThemeData(
        labelColor: orange,
        unselectedLabelColor: textSecondary,
        indicatorColor: orange,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: inputBorder,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        hintStyle: const TextStyle(color: textSecondary),
        prefixIconColor: inputIcon,
        suffixIconColor: inputIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: orange,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: red),
        ),
      ),

      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: orange,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark,
        contentTextStyle: const TextStyle(color: white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: inputBorder,
        thickness: 1,
      ),
    );
  }
}
