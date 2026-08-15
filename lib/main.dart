import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'core/managers/connectivity_manager.dart';
import 'core/managers/notification_manager.dart';
import 'core/managers/offline_sync_manager.dart';
import 'core/managers/session_manager.dart';
import 'core/managers/theme_manager.dart';

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

  runApp(
    const ProviderScope(
      child: TbnApp(),
    ),
  );
}
