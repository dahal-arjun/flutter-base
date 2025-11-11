import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/app_logger.dart';
import '../storage/secure_storage_service.dart';

/// Service for managing app language/locale settings
class LanguageService {
  static const String _languageKey = 'selected_language';
  final SecureStorageService _secureStorage;

  LanguageService(this._secureStorage);

  /// Get the saved locale or return default (English)
  Future<Locale> getSavedLocale() async {
    try {
      final languageCode = await _secureStorage.get(_languageKey);
      if (languageCode != null) {
        return Locale(languageCode);
      }
    } catch (e) {
      AppLogger.w('Failed to load saved locale, using default', e);
    }
    return AppLocalizations.supportedLocales.first;
  }

  /// Save the selected locale
  Future<void> saveLocale(Locale locale) async {
    try {
      await _secureStorage.set(_languageKey, locale.languageCode);
      AppLogger.d('Locale saved: ${locale.languageCode}');
    } catch (e) {
      AppLogger.e('Failed to save locale', e);
      rethrow;
    }
  }

  /// Get language name for display
  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  /// Get all supported locales
  List<Locale> getSupportedLocales() {
    return AppLocalizations.supportedLocales;
  }
}
