import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'app_theme_mode';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final modeString = _prefs.getString(_themeKey);
    if (modeString == 'light') {
      emit(ThemeMode.light);
    } else if (modeString == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.system);
    }
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setLightMode();
    } else {
      setDarkMode();
    }
  }

  void setLightMode() {
    _prefs.setString(_themeKey, 'light');
    emit(ThemeMode.light);
  }

  void setDarkMode() {
    _prefs.setString(_themeKey, 'dark');
    emit(ThemeMode.dark);
  }
}
