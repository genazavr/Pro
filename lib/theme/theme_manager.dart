import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  
  SeasonTheme _currentTheme = SeasonTheme.summer;
  String? _userId;

  SeasonTheme get currentTheme => _currentTheme;

  Future<void> initialize(String? userId) async {
    _userId = userId;
    await _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      SeasonTheme? savedTheme;

      if (_userId != null) {
        final snapshot = await _db.child('users/$_userId/settings/theme').get();
        if (snapshot.exists) {
          final themeString = snapshot.value as String;
          savedTheme = SeasonTheme.values.firstWhere(
            (theme) => theme.name == themeString,
            orElse: () => SeasonTheme.summer,
          );
        }
      }

      if (savedTheme == null) {
        final prefs = await SharedPreferences.getInstance();
        final themeString = prefs.getString(_themeKey);
        if (themeString != null) {
          savedTheme = SeasonTheme.values.firstWhere(
            (theme) => theme.name == themeString,
            orElse: () => SeasonTheme.summer,
          );
        }
      }

      if (savedTheme != null) {
        _currentTheme = savedTheme;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  Future<void> setTheme(SeasonTheme theme) async {
    try {
      _currentTheme = theme;
      notifyListeners();

      if (_userId != null) {
        await _db.child('users/$_userId/settings/theme').set(theme.name);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, theme.name);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}