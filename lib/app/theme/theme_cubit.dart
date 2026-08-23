import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/enums/app_enums.dart';
import '../../core/utils/logger.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'app_theme_mode';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final stored = _prefs.getString(_themeKey);
    final mode = AppThemeMode.fromString(stored);
    AppLogger.info('ThemeCubit: loaded theme = ${mode.name}');
    emit(mode.toFlutterThemeMode());
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setTheme(AppThemeMode.light);
    } else {
      setTheme(AppThemeMode.dark);
    }
  }

  void setTheme(AppThemeMode mode) {
    AppLogger.info('ThemeCubit: setting theme = ${mode.name}');
    _prefs.setString(_themeKey, mode.toStorageString());
    emit(mode.toFlutterThemeMode());
  }

  void setLightMode() => setTheme(AppThemeMode.light);
  void setDarkMode()  => setTheme(AppThemeMode.dark);
}
