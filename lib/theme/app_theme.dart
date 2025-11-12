import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SeasonTheme {
  summer('Лето', Icons.wb_sunny, Colors.orange),
  autumn('Осень', Icons.eco, Colors.brown),
  winter('Зима', Icons.ac_unit, Colors.blue),
  spring('Весна', Icons.grain, Colors.green);

  const SeasonTheme(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

class AppTheme {
  static ThemeData getThemeData(SeasonTheme theme) {
    switch (theme) {
      case SeasonTheme.summer:
        return _summerTheme;
      case SeasonTheme.autumn:
        return _autumnTheme;
      case SeasonTheme.winter:
        return _winterTheme;
      case SeasonTheme.spring:
        return _springTheme;
    }
  }

  static Color getBackgroundColor(SeasonTheme theme) {
    switch (theme) {
      case SeasonTheme.summer:
        return const Color(0xFFFFB74D);
      case SeasonTheme.autumn:
        return const Color(0xFF8D6E63);
      case SeasonTheme.winter:
        return const Color(0xFF64B5F6);
      case SeasonTheme.spring:
        return const Color(0xFF81C784);
    }
  }

  static Color getSurfaceColor(SeasonTheme theme) {
    switch (theme) {
      case SeasonTheme.summer:
        return const Color(0xFFFFF3E0);
      case SeasonTheme.autumn:
        return const Color(0xFFEFEBE9);
      case SeasonTheme.winter:
        return const Color(0xFFE3F2FD);
      case SeasonTheme.spring:
        return const Color(0xFFE8F5E8);
    }
  }

  static Color getPrimaryColor(SeasonTheme theme) {
    switch (theme) {
      case SeasonTheme.summer:
        return const Color(0xFFFF9800);
      case SeasonTheme.autumn:
        return const Color(0xFF795548);
      case SeasonTheme.winter:
        return const Color(0xFF2196F3);
      case SeasonTheme.spring:
        return const Color(0xFF4CAF50);
    }
  }

  static ThemeData get _summerTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.orange,
    primaryColor: const Color(0xFFFF9800),
    scaffoldBackgroundColor: const Color(0xFFFFB74D),
    cardColor: const Color(0xFFFFF3E0),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFFF9800),
      foregroundColor: Colors.white,
      elevation: 4,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    textTheme: GoogleFonts.nunitoTextTheme().copyWith(
      headlineLarge: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: const Color(0xFFE65100),
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF5D4037),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  static ThemeData get _autumnTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.brown,
    primaryColor: const Color(0xFF795548),
    scaffoldBackgroundColor: const Color(0xFF8D6E63),
    cardColor: const Color(0xFFEFEBE9),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF795548),
      foregroundColor: Colors.white,
      elevation: 4,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    textTheme: GoogleFonts.nunitoTextTheme().copyWith(
      headlineLarge: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF5D4037),
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF4E342E),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF795548),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  static ThemeData get _winterTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    primaryColor: const Color(0xFF2196F3),
    scaffoldBackgroundColor: const Color(0xFF64B5F6),
    cardColor: const Color(0xFFE3F2FD),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF2196F3),
      foregroundColor: Colors.white,
      elevation: 4,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    textTheme: GoogleFonts.nunitoTextTheme().copyWith(
      headlineLarge: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1565C0),
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0D47A1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  static ThemeData get _springTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.green,
    primaryColor: const Color(0xFF4CAF50),
    scaffoldBackgroundColor: const Color(0xFF81C784),
    cardColor: const Color(0xFFE8F5E8),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      elevation: 4,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    textTheme: GoogleFonts.nunitoTextTheme().copyWith(
      headlineLarge: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF2E7D32),
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1B5E20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
}