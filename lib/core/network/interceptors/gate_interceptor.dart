import 'dart:async';

import 'package:dio/dio.dart';

import '../../auth/capabilities_refresh.dart';
import '../../auth/capabilities_store.dart';
import '../../auth/gate_store.dart';
import '../../di/service_locator.dart';
import '../../managers/session_manager.dart';
import '../api_envelope.dart';
import '../api_exception.dart';

/// Applies spec §6.2 gate codes: 401, ACCOUNT_NOT_ACTIVE, password, reg fee.
class GateInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final ex = err.error is ApiException
        ? err.error as ApiException
        : ApiEnvelope.toException(
            err.response?.statusCode ?? 0,
            err.response?.data,
          );
    _apply(ex);
    handler.next(err);
  }

  void _apply(ApiException ex) {
    if (!locator.isRegistered<SessionManager>()) return;

    if (ex.isUnauthorized || ex.isAccountNotActive) {
      if (locator.isRegistered<CapabilitiesStore>()) {
        locator<CapabilitiesStore>().clear();
      }
      if (locator.isRegistered<GateStore>()) {
        locator<GateStore>().clear();
      }
      unawaited(locator<SessionManager>().clearSession());
      return;
    }

    if (ex.isPasswordChangeRequired &&
        locator.isRegistered<CapabilitiesStore>()) {
      final caps = locator<CapabilitiesStore>().current;
      if (caps != null && !caps.mustChangePassword) {
        locator<CapabilitiesStore>().set(
          caps.copyWith(mustChangePassword: true),
        );
      }
    }

    if (ex.isRegFeeRequired && locator.isRegistered<GateStore>()) {
      locator<GateStore>().setRegFeeRequired(true);
    }

    // Spec §4.1: re-fetch capabilities after gated 403/404.
    final status = ex.statusCode;
    if ((status == 403 || status == 404) &&
        locator<SessionManager>().isAuthenticated) {
      unawaited(refreshCapabilitiesSafely());
    }
  }
}
