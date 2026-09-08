import '../di/service_locator.dart';
import '../storage/preference_manager.dart';
import 'app_config.dart';

/// Browser origin for Stripe/gateway return URLs.
///
/// Prefer an explicit web client origin (`CLIENT_ORIGIN` / preference) over
/// stripping `/api` from the API host — those hosts often differ.
String clientOrigin() {
  final prefs = locator<PreferenceManager>();
  final configured =
      prefs.getClientOrigin() ?? locator<AppConfig>().clientOrigin;
  if (configured != null && configured.isNotEmpty) {
    return configured.replaceAll(RegExp(r'/+$'), '');
  }
  final raw = prefs.getServerUrl() ?? locator<AppConfig>().apiBaseUrl;
  return raw.replaceAll(RegExp(r'/api/?$'), '');
}
