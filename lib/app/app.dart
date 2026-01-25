import 'package:flutter/material.dart';
import 'theme.dart';
import 'routes.dart';
import '../core/services/settings_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/service_locator.dart';

/// Main App Widget for Iman Flow
class ImanFlowApp extends StatefulWidget {
  const ImanFlowApp({super.key});

  @override
  State<ImanFlowApp> createState() => _ImanFlowAppState();
}

class _ImanFlowAppState extends State<ImanFlowApp> {
  final SettingsService _settingsService = getIt<SettingsService>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<AuthService>().initializationDone,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: ImanFlowTheme.bgTop,
              body: Center(child: CircularProgressIndicator(color: ImanFlowTheme.gold)),
            ),
          );
        }

        return StreamBuilder<UserSettings>(
          stream: _settingsService.settingsStream,
          initialData: _settingsService.settings,
          builder: (context, snapshot) {
            final settings = snapshot.data ?? const UserSettings();
            
            return MaterialApp.router(
              title: 'Iman Flow',
              debugShowCheckedModeBanner: false,
              theme: ImanFlowTheme.lightTheme,
              darkTheme: ImanFlowTheme.darkTheme,
              themeMode: _getThemeMode(settings.themeMode),
              routerConfig: AppRouter.router,
            );
          },
        );
      },
    );
  }

  ThemeMode _getThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
