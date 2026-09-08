import 'package:get_it/get_it.dart';

import '../auth/capabilities_refresh.dart';
import '../auth/capabilities_store.dart';
import '../auth/gate_store.dart';
import '../config/app_config.dart';
import '../managers/connectivity_manager.dart';
import '../managers/download_manager.dart';
import '../managers/navigation_manager.dart';
import '../managers/notification_manager.dart';
import '../managers/offline_sync_manager.dart';
import '../managers/session_manager.dart';
import '../managers/theme_manager.dart';
import '../storage/preference_manager.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../storage/secure_storage.dart';
import '../storage/cache_manager.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/data/services/auth_api_service.dart';
import '../../features/auth/data/services/registration_api_service.dart';
import '../../features/auth/data/services/users_api_service.dart';
import '../../features/batches/data/repositories/batches_repository.dart';
import '../../features/batches/data/services/batches_api_service.dart';
import '../../features/dashboard/data/repositories/dashboard_repository.dart';
import '../../features/dashboard/data/services/dashboard_api_service.dart';
import '../../features/learning/data/repositories/learning_repository.dart';
import '../../features/learning/data/services/learning_api_service.dart';
import '../../features/learning/data/repositories/certificates_repository.dart';
import '../../features/learning/data/services/certificates_api_service.dart';
import '../../features/assessments/data/repositories/assessments_repository.dart';
import '../../features/assessments/data/services/assessments_api_service.dart';
import '../../features/orders/data/repositories/orders_repository.dart';
import '../../features/orders/data/services/orders_api_service.dart';
import '../../features/payments/data/services/commerce_api_service.dart';
import '../../features/payments/data/services/payment_gateway_service.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/data/services/profile_api_service.dart';
import '../../features/notifications/data/repositories/notifications_repository.dart';
import '../../features/notifications/data/services/notifications_api_service.dart';

/// Global Service Locator instance.
final GetIt locator = GetIt.instance;

/// Initialize all singletons and dependencies.
Future<void> setupLocator() async {
  // ── Config ──
  locator.registerLazySingleton<AppConfig>(() => AppConfig());

  // ── Storage ──
  locator.registerLazySingleton<SecureStorage>(() => SecureStorage());
  locator.registerLazySingleton<PreferenceManager>(() => PreferenceManager());
  locator.registerLazySingleton<CacheManager>(() => CacheManager());

  // Initialize PreferenceManager immediately as it's needed by others
  await locator<PreferenceManager>().init();
  await locator<CacheManager>().init();

  // ── Managers (Zentriva Singleton Pattern) ──
  locator.registerLazySingleton<SessionManager>(() => SessionManager());
  locator.registerLazySingleton<CapabilitiesStore>(() => CapabilitiesStore());
  locator.registerLazySingleton<GateStore>(() => GateStore());
  locator.registerLazySingleton<ThemeManager>(() => ThemeManager());
  locator.registerLazySingleton<ConnectivityManager>(
    () => ConnectivityManager(),
  );
  locator.registerLazySingleton<NavigationManager>(() => NavigationManager());
  locator.registerLazySingleton<NotificationManager>(
    () => NotificationManager(),
  );
  locator.registerLazySingleton<DownloadManager>(() => DownloadManager());
  locator.registerLazySingleton<OfflineSyncManager>(() => OfflineSyncManager());

  // ── Network ──
  locator.registerLazySingleton<NetworkInfo>(() => NetworkInfo());
  locator.registerLazySingleton<ApiClient>(() {
    final prefs = locator<PreferenceManager>();
    final config = locator<AppConfig>();
    final savedUrl = prefs.getServerUrl();

    return ApiClient(
      initialBaseUrl: savedUrl ?? config.apiBaseUrl,
      config: config,
      secureStorage: locator<SecureStorage>(),
      networkInfo: locator<NetworkInfo>(),
    );
  });

  // Note: Repositories and ViewModels will be registered here later as feature modules are built.

  // ── Auth Module ──
  locator.registerLazySingleton<AuthApiService>(
    () => AuthApiService(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<UsersApiService>(
    () => UsersApiService(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<RegistrationApiService>(
    () => RegistrationApiService(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      apiService: locator<AuthApiService>(),
      usersApi: locator<UsersApiService>(),
      registrationApi: locator<RegistrationApiService>(),
      sessionManager: locator<SessionManager>(),
      capabilitiesStore: locator<CapabilitiesStore>(),
      gateStore: locator<GateStore>(),
    ),
  );
  capabilitiesRefresh = () => locator<AuthRepository>().refreshCapabilities();

  // ── Dashboard Module ──
  locator.registerLazySingleton<DashboardApiService>(
    () => DashboardApiService(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<DashboardRepository>(
    () => DashboardRepository(apiService: locator<DashboardApiService>()),
  );

  // ── Batches Module ──
  locator.registerLazySingleton<BatchesApiService>(
    () => BatchesApiService(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<BatchesRepository>(
    () => BatchesRepository(apiService: locator<BatchesApiService>()),
  );

  // ── Learning Module ──
  locator.registerLazySingleton<LearningApiService>(
    () => LearningApiService(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<LearningRepository>(
    () => LearningRepository(
      apiService: locator<LearningApiService>(),
      cacheManager: locator<CacheManager>(),
    ),
  );
  locator.registerLazySingleton<CertificatesApiService>(
    () => CertificatesApiService(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<CertificatesRepository>(
    () => CertificatesRepository(apiService: locator<CertificatesApiService>()),
  );

  // ── Assessments Module ──
  locator.registerLazySingleton<AssessmentsApiService>(
    () => AssessmentsApiService(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<AssessmentsRepository>(
    () => AssessmentsRepository(
      apiService: locator<AssessmentsApiService>(),
      offlineSyncManager: locator<OfflineSyncManager>(),
    ),
  );

  // ── Orders Module ──
  locator.registerLazySingleton<OrdersApiService>(
    () => OrdersApiService(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<OrdersRepository>(
    () => OrdersRepository(apiService: locator<OrdersApiService>()),
  );

  // ── Payments Module ──
  locator.registerLazySingleton<CommerceApiService>(
    () => CommerceApiService(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<PaymentGatewayService>(
    () => PaymentGatewayService(),
  );

  // ── Profile Module ──
  locator.registerLazySingleton<ProfileApiService>(
    () => ProfileApiService(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(
      apiService: locator<ProfileApiService>(),
      sessionManager: locator<SessionManager>(),
    ),
  );

  // ── Notifications Module ──
  locator.registerLazySingleton<NotificationsApiService>(
    () => NotificationsApiService(apiClient: locator<ApiClient>()),
  );
  locator.registerLazySingleton<NotificationsRepository>(
    () =>
        NotificationsRepository(apiService: locator<NotificationsApiService>()),
  );
}
