import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'core/di/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/network/network_aware_widget.dart';
import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'services/notifications/notification_service.dart';
import 'services/language/language_service.dart';
import 'services/theme/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock app to portrait orientation only (disable landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Setup dependency injection
  await di.setupDependencyInjection();

  // Initialize notifications
  final notificationService = di.getIt<NotificationService>();
  await notificationService.initializeLocalNotifications();
  // Firebase Messaging initialization is handled internally by NotificationService
  // If Firebase is configured, it will be initialized automatically
  await notificationService.initializeFirebaseMessaging();

  // Get saved locale or use default
  final languageService = di.getIt<LanguageService>();
  final savedLocale = await languageService.getSavedLocale();
  Intl.defaultLocale = savedLocale.languageCode;

  // Get saved theme mode or use default
  final themeService = di.getIt<ThemeService>();
  final savedThemeMode = await themeService.getSavedThemeMode();

  runApp(MyApp(initialLocale: savedLocale, initialThemeMode: savedThemeMode));
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;
  final AppThemeMode initialThemeMode;

  const MyApp({
    super.key,
    required this.initialLocale,
    required this.initialThemeMode,
  });

  @override
  State<MyApp> createState() => MyAppState();

  static MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<MyAppState>();
  }
}

class MyAppState extends State<MyApp> {
  late Locale _locale;
  late AppThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _themeMode = widget.initialThemeMode;
  }

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
      Intl.defaultLocale = newLocale.languageCode;
    });
  }

  void setThemeMode(AppThemeMode newThemeMode) {
    setState(() {
      _themeMode = newThemeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeService = di.getIt<ThemeService>();

    return MaterialApp.router(
      title: 'CP App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.toThemeMode(_themeMode),
      // Internationalization support
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        final responsiveChild = ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        );
        return NetworkAwareWidget(child: responsiveChild);
      },
    );
  }
}
