import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized app theme and color palette.
class AppTheme {
  // Brand colors
  static const Color primary = Color(0xFF00C896);
  static const Color emeraldDark = Color(0xFF4DFFD2);
  static const Color emeraldLight = Color(0xFF66FFD9);
  static const Color error = Color(0xFFFF4C4C);
  static const Color warning = Colors.orange;
  static const Color success = Colors.green;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, emeraldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0F1A), Color(0xFF131A26)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Default Light Theme
  static ThemeData get lightTheme {
    const lightBackground = Color(0xFFF3F4F6);
    const lightSurface = Color(0xFFFFFFFF);
    const lightCard = Colors.white;
    const lightTextPrimary = Color(0xFF111827);
    const lightTextSecondary = Color(0xFF6B7280);
    const lightDivider = Color(0xFFE5E7EB);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: emeraldDark,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        error: error,
      ),
      fontFamily: 'SF Pro Display',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: lightTextPrimary, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: lightTextPrimary, letterSpacing: -0.3),
        displaySmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: lightTextPrimary, letterSpacing: -0.2),
        headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: lightTextPrimary),
        headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: lightTextPrimary),
        titleLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: lightTextPrimary),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: lightTextPrimary),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: lightTextPrimary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: lightTextSecondary),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: lightTextSecondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: lightTextPrimary, letterSpacing: -0.3),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: lightTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightDivider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(color: lightDivider, thickness: 1, space: 1),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightTextPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: primary,
        unselectedItemColor: lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
        elevation: 0,
      ),
    );
  }

  /// Default Dark Theme
  static ThemeData get darkTheme {
    const darkBackground = Color(0xFF0A0F1A);
    const darkSurface = Color(0xFF131A26);
    const darkCard = Color(0xFF131A26);
    const darkTextPrimary = Color(0xFFF0F4FF);
    const darkTextSecondary = Color(0xFF8B9CB6);
    const darkDivider = Color(0xFF233044);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: emeraldDark,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        error: error,
      ),
      fontFamily: 'SF Pro Display',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: darkTextPrimary, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: darkTextPrimary, letterSpacing: -0.3),
        displaySmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: darkTextPrimary, letterSpacing: -0.2),
        headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkTextPrimary),
        headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkTextPrimary),
        titleLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: darkTextPrimary),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: darkTextPrimary),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: darkTextPrimary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: darkTextSecondary),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: darkTextSecondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: darkTextPrimary, letterSpacing: -0.3),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(color: darkDivider, thickness: 1, space: 1),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCard,
        contentTextStyle: const TextStyle(color: darkTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primary,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
        elevation: 0,
      ),
    );
  }
}


