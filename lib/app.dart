import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/capabilities_refresh.dart';
import 'core/config/app_constants.dart';
import 'core/demo/demo_mode.dart';
import 'core/di/service_locator.dart';
import 'core/managers/session_manager.dart';
import 'core/managers/theme_manager.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class TbnApp extends ConsumerStatefulWidget {
  const TbnApp({super.key});

  @override
  ConsumerState<TbnApp> createState() => _TbnAppState();
}

class _TbnAppState extends ConsumerState<TbnApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!locator<SessionManager>().isAuthenticated) return;
    if (DemoMode().isActive) return;
    refreshCapabilitiesSafely().ignore();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeManager = locator<ThemeManager>();

    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, _) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          themeMode: themeManager.themeMode,
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          routerConfig: router,
        );
      },
    );
  }
}
