import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// App localization class
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('es', ''), // Spanish
  ];

  // Common strings
  String get appTitle =>
      _localizedValues[locale.languageCode]?['appTitle'] ?? 'CP App';
  String get welcome =>
      _localizedValues[locale.languageCode]?['welcome'] ?? 'Welcome';
  String get dashboard =>
      _localizedValues[locale.languageCode]?['dashboard'] ?? 'Dashboard';
  String get posts =>
      _localizedValues[locale.languageCode]?['posts'] ?? 'Posts';
  String get users =>
      _localizedValues[locale.languageCode]?['users'] ?? 'Users';
  String get comments =>
      _localizedValues[locale.languageCode]?['comments'] ?? 'Comments';
  String get loading =>
      _localizedValues[locale.languageCode]?['loading'] ?? 'Loading...';
  String get error =>
      _localizedValues[locale.languageCode]?['error'] ?? 'Error';
  String get retry =>
      _localizedValues[locale.languageCode]?['retry'] ?? 'Retry';
  String get refresh =>
      _localizedValues[locale.languageCode]?['refresh'] ?? 'Refresh';
  String get noDataFound =>
      _localizedValues[locale.languageCode]?['noDataFound'] ?? 'No data found';
  String get offline =>
      _localizedValues[locale.languageCode]?['offline'] ??
      'You are offline. Showing cached data.';
  String get online =>
      _localizedValues[locale.languageCode]?['online'] ?? 'You are online.';
  String get language =>
      _localizedValues[locale.languageCode]?['language'] ?? 'Language';
  String get selectLanguage =>
      _localizedValues[locale.languageCode]?['selectLanguage'] ??
      'Select Language';
  String get settings =>
      _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';
  String get goToHome =>
      _localizedValues[locale.languageCode]?['goToHome'] ?? 'Go to Home';

  // Date and time formatting
  String formatDate(DateTime date) {
    return DateFormat.yMMMd(locale.languageCode).format(date);
  }

  String formatTime(DateTime time) {
    return DateFormat.Hm(locale.languageCode).format(time);
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat.yMMMd().add_Hm().format(dateTime);
  }

  // Number formatting
  String formatNumber(int number) {
    return NumberFormat.decimalPattern(locale.languageCode).format(number);
  }

  // Currency formatting
  String formatCurrency(double amount, {String? currencyCode}) {
    return NumberFormat.currency(
      locale: locale.languageCode,
      symbol: currencyCode ?? '\$',
    ).format(amount);
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Initialize Intl for the locale
    Intl.defaultLocale = locale.languageCode;
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Localized values
const Map<String, Map<String, String>> _localizedValues = {
  'en': {
    'appTitle': 'CP App',
    'welcome': 'Welcome',
    'dashboard': 'Dashboard',
    'posts': 'Posts',
    'users': 'Users',
    'comments': 'Comments',
    'loading': 'Loading...',
    'error': 'Error',
    'retry': 'Retry',
    'refresh': 'Refresh',
    'noDataFound': 'No data found',
    'offline': 'You are offline. Showing cached data.',
    'online': 'You are online.',
    'language': 'Language',
    'selectLanguage': 'Select Language',
    'settings': 'Settings',
    'goToHome': 'Go to Home',
  },
  'es': {
    'appTitle': 'Aplicación CP',
    'welcome': 'Bienvenido',
    'dashboard': 'Panel de Control',
    'posts': 'Publicaciones',
    'users': 'Usuarios',
    'comments': 'Comentarios',
    'loading': 'Cargando...',
    'error': 'Error',
    'retry': 'Reintentar',
    'refresh': 'Actualizar',
    'noDataFound': 'No se encontraron datos',
    'offline': 'Estás sin conexión. Mostrando datos en caché.',
    'online': 'Estás en línea.',
    'language': 'Idioma',
    'selectLanguage': 'Seleccionar Idioma',
    'settings': 'Configuración',
    'goToHome': 'Ir al Inicio',
  },
};
