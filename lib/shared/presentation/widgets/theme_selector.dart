import 'package:flutter/material.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../../services/theme/theme_service.dart';
import '../../../main.dart';

class ThemeSelector extends StatefulWidget {
  const ThemeSelector({super.key});

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
  final ThemeService _themeService = di.getIt<ThemeService>();
  AppThemeMode? _selectedThemeMode;

  @override
  void initState() {
    super.initState();
    _loadSavedThemeMode();
  }

  Future<void> _loadSavedThemeMode() async {
    final savedThemeMode = await _themeService.getSavedThemeMode();
    if (mounted) {
      setState(() {
        _selectedThemeMode = savedThemeMode;
      });
    }
  }

  Future<void> _changeThemeMode(AppThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _selectedThemeMode) return;

    await _themeService.saveThemeMode(newThemeMode);
    setState(() {
      _selectedThemeMode = newThemeMode;
    });

    // Notify the app to rebuild with new theme
    if (mounted) {
      final myAppState = MyApp.of(context);
      if (myAppState != null) {
        myAppState.setThemeMode(newThemeMode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportedThemeModes = _themeService.getSupportedThemeModes();

    return DropdownButton<AppThemeMode>(
      value: _selectedThemeMode,
      hint: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.brightness_6, size: 20),
          SizedBox(width: 4),
          Text('Theme'),
        ],
      ),
      icon: const Icon(Icons.arrow_drop_down),
      underline: Container(
        height: 2,
        color: Theme.of(context).colorScheme.primary,
      ),
      items: supportedThemeModes.map((AppThemeMode themeMode) {
        IconData icon;
        switch (themeMode) {
          case AppThemeMode.light:
            icon = Icons.light_mode;
            break;
          case AppThemeMode.dark:
            icon = Icons.dark_mode;
            break;
          case AppThemeMode.system:
            icon = Icons.brightness_auto;
            break;
        }

        return DropdownMenuItem<AppThemeMode>(
          value: themeMode,
          child: Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(_themeService.getThemeModeName(themeMode)),
            ],
          ),
        );
      }).toList(),
      onChanged: _changeThemeMode,
    );
  }
}

