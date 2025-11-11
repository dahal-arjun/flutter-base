import 'package:flutter/material.dart';
import '../../core/utils/app_logger.dart';
import '../storage/secure_storage_service.dart';

/// App theme mode options
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Service for managing app theme settings
class ThemeService {
  static const String _themeKey = 'selected_theme';
  final SecureStorageService _secureStorage;

  ThemeService(this._secureStorage);

  /// Get the saved theme mode or return default (system)
  Future<AppThemeMode> getSavedThemeMode() async {
    try {
      final themeModeString = await _secureStorage.get(_themeKey);
      if (themeModeString != null) {
        return AppThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => AppThemeMode.system,
        );
      }
    } catch (e) {
      AppLogger.w('Failed to load saved theme mode, using default', e);
    }
    return AppThemeMode.system;
  }

  /// Save the selected theme mode
  Future<void> saveThemeMode(AppThemeMode themeMode) async {
    try {
      await _secureStorage.set(_themeKey, themeMode.toString());
      AppLogger.d('Theme mode saved: ${themeMode.toString()}');
    } catch (e) {
      AppLogger.e('Failed to save theme mode', e);
      rethrow;
    }
  }

  /// Convert AppThemeMode to Flutter's ThemeMode
  ThemeMode toThemeMode(AppThemeMode appThemeMode) {
    switch (appThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Get theme mode name for display
  String getThemeModeName(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  /// Get all supported theme modes
  List<AppThemeMode> getSupportedThemeModes() {
    return AppThemeMode.values;
  }
}

