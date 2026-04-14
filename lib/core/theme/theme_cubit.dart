import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

// Theme preference keys
const String _themeKey = 'app_theme_mode';

/// Theme state
abstract class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({required this.themeMode});

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isLightMode => themeMode == ThemeMode.light;
  bool get isSystemMode => themeMode == ThemeMode.system;

  @override
  List<Object?> get props => [themeMode];
}

class ThemeInitial extends ThemeState {
  const ThemeInitial() : super(themeMode: ThemeMode.system);
}

class ThemeLoaded extends ThemeState {
  const ThemeLoaded({required super.themeMode});
}

/// Theme Cubit - Manages light/dark mode switching
class ThemeCubit extends Cubit<ThemeState> {
  final Logger _logger = Logger();
  SharedPreferences? _prefs;

  ThemeCubit() : super(const ThemeInitial()) {
    _loadTheme();
  }

  /// Initialize SharedPreferences
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Load saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      await _initPrefs();
      final savedTheme = _prefs?.getString(_themeKey);

      if (savedTheme != null) {
        final themeMode = _parseThemeMode(savedTheme);
        _logger.i('[ThemeCubit] Loaded theme: $savedTheme');
        emit(ThemeLoaded(themeMode: themeMode));
      } else {
        _logger.i('[ThemeCubit] No saved theme, using system default');
        emit(const ThemeLoaded(themeMode: ThemeMode.system));
      }
    } catch (e) {
      _logger.e('[ThemeCubit] Error loading theme: $e');
      emit(const ThemeLoaded(themeMode: ThemeMode.system));
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      await _initPrefs();
      await _prefs?.setString(_themeKey, mode.name);
      _logger.i('[ThemeCubit] Theme changed to: ${mode.name}');
      emit(ThemeLoaded(themeMode: mode));
    } catch (e) {
      _logger.e('[ThemeCubit] Error saving theme: $e');
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final currentMode = state.themeMode;
    ThemeMode newMode;

    if (currentMode == ThemeMode.light) {
      newMode = ThemeMode.dark;
    } else if (currentMode == ThemeMode.dark) {
      newMode = ThemeMode.light;
    } else {
      // If system mode, check current brightness and switch to opposite
      newMode = ThemeMode.dark;
    }

    await setThemeMode(newMode);
  }

  /// Set light mode
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Set dark mode
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Set system default mode
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Parse theme mode from string
  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Get display name for current theme
  String getThemeDisplayName() {
    switch (state.themeMode) {
      case ThemeMode.light:
        return 'Mode Terang';
      case ThemeMode.dark:
        return 'Mode Gelap';
      case ThemeMode.system:
        return 'Sistem Default';
    }
  }

  /// Get icon for current theme
  IconData getThemeIcon() {
    switch (state.themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
