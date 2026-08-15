import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_constants.dart';
import 'core/di/service_locator.dart';
import 'core/managers/theme_manager.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Tungabadra Networks LMS — App Root
class TbnApp extends ConsumerWidget {
  const TbnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeManager = locator<ThemeManager>();

    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, _) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,

          // Theming
          themeMode: themeManager.themeMode,
          theme: AppTheme.darkTheme, // We only use dark theme for now
          darkTheme: AppTheme.darkTheme,

          // Routing
          routerConfig: router,
        );
      },
    );
  }
}
