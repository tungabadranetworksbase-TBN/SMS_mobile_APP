import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app.dart';
import 'core/auth/capabilities.dart';
import 'core/auth/capabilities_store.dart';
import 'core/config/app_constants.dart';
import 'core/demo/demo_mode.dart';
import 'core/di/service_locator.dart';
import 'core/managers/connectivity_manager.dart';
import 'core/managers/notification_manager.dart';
import 'core/managers/offline_sync_manager.dart';
import 'core/managers/session_manager.dart';
import 'core/managers/theme_manager.dart';
import 'core/network/api_error_code.dart';
import 'core/network/api_exception.dart';
import 'core/storage/preference_manager.dart';
import 'features/auth/data/repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make status bar transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize URL strategy for web (removes # from URLs)
  GoRouter.optionURLReflectsImperativeAPIs = true;

  // Setup Dependency Injection (Managers, Storage, Network)
  await setupLocator();

  // Initialize core managers before app starts
  await Future.wait([
    locator<ThemeManager>().init(),
    locator<SessionManager>().init(),
    locator<NotificationManager>().init(),
  ]);

  // Start monitoring connectivity and offline sync
  locator<ConnectivityManager>().init();
  await locator<OfflineSyncManager>().init(locator<ConnectivityManager>());

  await _hydrateSessionOrClear();

  runApp(const ProviderScope(child: TbnApp()));
}

/// Caps must be ready before the router leaves splash. A leftover token with
/// no caps (failed /me, offline, expired demo) used to trap the splash forever.
Future<void> _hydrateSessionOrClear() async {
  final session = locator<SessionManager>();
  if (!session.isAuthenticated) return;

  final prefs = locator<PreferenceManager>();
  final token = await session.token;
  final demoRole = prefs.getString(AppConstants.keyDemoRole);
  final isDemo =
      token == 'demo-token' || (demoRole != null && demoRole.isNotEmpty);

  if (isDemo) {
    final role = (demoRole == null || demoRole.isEmpty) ? 'student' : demoRole;
    DemoMode().activate(role: role);
    locator<CapabilitiesStore>().set(Capabilities.demo(role));
    return;
  }

  try {
    await locator<AuthRepository>().refreshCapabilities().timeout(
      const Duration(seconds: 8),
    );
  } on ApiException catch (e) {
    if (e.code == ApiErrorCode.unauthorized || e.statusCode == 401) {
      await session.clearSession();
      locator<CapabilitiesStore>().clear();
      return;
    }
    // Keep token only if caps somehow landed; otherwise leave splash trap.
    if (locator<CapabilitiesStore>().current == null) {
      await session.clearSession();
    }
  } catch (_) {
    if (locator<CapabilitiesStore>().current == null) {
      await session.clearSession();
      locator<CapabilitiesStore>().clear();
    }
  }
}
