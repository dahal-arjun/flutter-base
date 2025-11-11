import 'package:flutter/material.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../../core/l10n/app_localizations.dart';
import '../../../services/language/language_service.dart';
import '../../../main.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final LanguageService _languageService = di.getIt<LanguageService>();
  Locale? _selectedLocale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final savedLocale = await _languageService.getSavedLocale();
    if (mounted) {
      setState(() {
        _selectedLocale = savedLocale;
      });
    }
  }

  Future<void> _changeLanguage(Locale? newLocale) async {
    if (newLocale == null || newLocale == _selectedLocale) return;

    await _languageService.saveLocale(newLocale);
    setState(() {
      _selectedLocale = newLocale;
    });

    // Notify the app to rebuild with new locale
    if (mounted) {
      final myAppState = MyApp.of(context);
      if (myAppState != null) {
        myAppState.setLocale(newLocale);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final supportedLocales = _languageService.getSupportedLocales();

    return DropdownButton<Locale>(
      value: _selectedLocale,
      hint: Text(localizations?.selectLanguage ?? 'Select Language'),
      icon: const Icon(Icons.language),
      underline: Container(
        height: 2,
        color: Theme.of(context).colorScheme.primary,
      ),
      items: supportedLocales.map((Locale locale) {
        return DropdownMenuItem<Locale>(
          value: locale,
          child: Row(
            children: [Text(_languageService.getLanguageName(locale))],
          ),
        );
      }).toList(),
      onChanged: _changeLanguage,
    );
  }
}
