import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Iman Flow Theme - Islamic-inspired serene design
class ImanFlowTheme {
  // Primary colors - Serene greens inspired by Islamic art
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF0D3311);
  
  // Accent colors - Gold and turquoise from Islamic patterns
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentTurquoise = Color(0xFF00897B);
  static const Color accentCream = Color(0xFFFFF8E1);
  
  // Neutral colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Text colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);
  
  // Semantic colors
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFD32F2F);
  
  // Prayer time colors
  static const Color fajrColor = Color(0xFF5C6BC0);
  static const Color dhuhrColor = Color(0xFFFFB300);
  static const Color asrColor = Color(0xFFFF7043);
  static const Color maghribColor = Color(0xFFAB47BC);
  static const Color ishaColor = Color(0xFF3949AB);

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        primaryContainer: primaryGreenLight.withOpacity(0.2),
        secondary: accentTurquoise,
        secondaryContainer: accentTurquoise.withOpacity(0.2),
        tertiary: accentGold,
        surface: surfaceLight,
        background: backgroundLight,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
        onBackground: textPrimaryLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.almarai(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.almarai(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textTheme: _buildTextTheme(Brightness.light),
      iconTheme: const IconThemeData(
        color: primaryGreen,
        size: 24,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentGold,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey[300],
        thickness: 1,
      ),
    );
  }

  /// Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryGreenLight,
        primaryContainer: primaryGreen.withOpacity(0.3),
        secondary: accentTurquoise,
        secondaryContainer: accentTurquoise.withOpacity(0.3),
        tertiary: accentGold,
        surface: surfaceDark,
        background: backgroundDark,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
        onBackground: textPrimaryDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.almarai(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimaryDark,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryGreenLight,
        unselectedItemColor: textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreenLight,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.almarai(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      iconTheme: const IconThemeData(
        color: primaryGreenLight,
        size: 24,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentGold,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreenLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey[800],
        thickness: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.light 
        ? textPrimaryLight 
        : textPrimaryDark;
    
    return TextTheme(
      displayLarge: GoogleFonts.almarai(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: GoogleFonts.almarai(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: GoogleFonts.almarai(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.almarai(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.almarai(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.almarai(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleLarge: GoogleFonts.almarai(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleMedium: GoogleFonts.almarai(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: GoogleFonts.almarai(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.almarai(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.almarai(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: GoogleFonts.almarai(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textColor.withOpacity(0.7),
      ),
      labelLarge: GoogleFonts.almarai(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      labelMedium: GoogleFonts.almarai(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: GoogleFonts.almarai(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textColor.withOpacity(0.7),
      ),
    );
  }

  static Color messageBubbleReceived(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[200]!;
  }
}

/// Arabic text style for Quran verses
/// Arabic text style for Quran verses
class ArabicTextStyles {
  // Scheherazade New is naturally smaller than Amiri, so we boost default size
  static TextStyle quranVerse({
    double fontSize = 32, 
    Color? color,
    double height = 2.0,
  }) {
    return GoogleFonts.scheherazadeNew(
      fontSize: fontSize,
      height: height,
      color: color ?? ImanFlowTheme.textPrimaryLight,
    );
  }
  
  static TextStyle quranVerseDark({
    double fontSize = 32,
    Color? color,
    double height = 2.0,
  }) {
    return GoogleFonts.scheherazadeNew(
      fontSize: fontSize,
      height: height,
      color: color ?? ImanFlowTheme.textPrimaryDark,
    );
  }
}
