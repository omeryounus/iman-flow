import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Iman Flow Theme - Royal Emerald & Gold
class ImanFlowTheme {
  // Royal Emerald base
  static const Color bgTop = Color(0xFF021B1A); // deep emerald-black
  static const Color bgMid = Color(0xFF052C2A); // emerald core
  static const Color bgBot = Color(0xFF063F3B); // richer teal-emerald

  // Premium gold accents
  static const Color gold = Color(0xFFF4D37B); // soft gold
  static const Color goldDeep = Color(0xFFC89B3C); // royal gold

  // Glass cards
  static const Color glass = Color(0x14FFFFFF);
  static const Color glass2 = Color(0x1AFFFFFF);
  static const Color stroke = Color(0x26FFFFFF); // slightly stronger

  // Extra emerald tint for overlays
  static const Color emeraldGlow = Color(0xFF2BE6C6);

  // Legacy/Alias support for older widgets
  static const Color primaryGreen = emeraldGlow;
  static const Color primaryGreenDark = bgBot;
  static const Color accentGold = gold;
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE57373);
  static const Color accentTurquoise = emeraldGlow;
  static const Color backgroundLight = bgMid;
  static const Color backgroundDark = bgTop;
  static const Color textPrimaryLight = Colors.white; // for verse_reader

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: goldDeep,
        surface: glass2,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  // Helper for light theme if needed, though we are focusing on the dark/emerald look
  static ThemeData get lightTheme => darkTheme; 
}

/// Arabic text style for Quran verses
class ArabicTextStyles {
  static TextStyle quranVerse({
    double fontSize = 32, 
    Color? color,
    double height = 2.0,
  }) {
    return GoogleFonts.amiri( // Switched to Amiri as per new theme preference
      fontSize: fontSize,
      height: height,
      color: color ?? Colors.white.withOpacity(0.94),
      fontWeight: FontWeight.w600,
    );
  }
}
