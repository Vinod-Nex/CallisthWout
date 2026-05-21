import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Push, Pull, Legs accents
  static const Color pushAccentLight = Color(0xFFD85A30);
  static const Color pushAccentDark = Color(0xFFE57342);
  
  static const Color pullAccentLight = Color(0xFF378ADD);
  static const Color pullAccentDark = Color(0xFF5BA0D9);
  
  static const Color legsAccentLight = Color(0xFF1D9E75);
  static const Color legsAccentDark = Color(0xFF2BBF8F);

  static const Color successLight = Color(0xFF34C759);
  static const Color successDark = Color(0xFF30B350);

  // Backgrounds
  static const Color bgDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color borderDark = Color(0xFF38383A);

  static const Color bgLight = Color(0xFFFDF8F8);
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color borderLight = Color(0xFFE5E5EA);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF010102),
      scaffoldBackgroundColor: bgLight,
      cardColor: surfaceLight,
      dividerColor: borderLight,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.lexend(color: const Color(0xFF1C1C1E), fontSize: 22, fontWeight: FontWeight.bold, height: 1.27),
        titleLarge: GoogleFonts.lexend(color: const Color(0xFF1C1C1E), fontSize: 17, fontWeight: FontWeight.w500, height: 1.29),
        bodyLarge: GoogleFonts.lexend(color: const Color(0xFF1C1C1E), fontSize: 17, fontWeight: FontWeight.w400, height: 1.29),
        bodyMedium: GoogleFonts.lexend(color: const Color(0xFF1C1C1E), fontSize: 15),
        bodySmall: GoogleFonts.lexend(color: const Color(0xFF6C6C70), fontSize: 13, height: 1.38),
        labelSmall: GoogleFonts.jetBrainsMono(color: const Color(0xFF6C6C70), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.6),
        displayMedium: GoogleFonts.jetBrainsMono(color: const Color(0xFF1C1C1E), fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: -0.96),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF1C1C1E)),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: Color(0xFF1C1C1E),
        unselectedItemColor: Color(0xFF6C6C70),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFFFFFFF),
      scaffoldBackgroundColor: bgDark,
      cardColor: surfaceDark,
      dividerColor: borderDark,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.lexend(color: const Color(0xFFFFFFFF), fontSize: 22, fontWeight: FontWeight.bold, height: 1.27),
        titleLarge: GoogleFonts.lexend(color: const Color(0xFFFFFFFF), fontSize: 17, fontWeight: FontWeight.w500, height: 1.29),
        bodyLarge: GoogleFonts.lexend(color: const Color(0xFFFFFFFF), fontSize: 17, fontWeight: FontWeight.w400, height: 1.29),
        bodyMedium: GoogleFonts.lexend(color: const Color(0xFFFFFFFF), fontSize: 15),
        bodySmall: GoogleFonts.lexend(color: const Color(0xFF8E8E93), fontSize: 13, height: 1.38),
        labelSmall: GoogleFonts.jetBrainsMono(color: const Color(0xFF8E8E93), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.6),
        displayMedium: GoogleFonts.jetBrainsMono(color: const Color(0xFFFFFFFF), fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: -0.96),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: Color(0xFFFFFFFF),
        unselectedItemColor: Color(0xFF8E8E93),
      ),
    );
  }

  static Color getPushColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? pushAccentLight : pushAccentDark;
  }

  static Color getPullColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? pullAccentLight : pullAccentDark;
  }

  static Color getLegsColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? legsAccentLight : legsAccentDark;
  }
}
