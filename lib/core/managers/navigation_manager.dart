import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tungabadra Networks LMS — Navigation Manager
///
/// Singleton for centralized navigation without context.
/// Useful for deep links, notifications, and background processes.
class NavigationManager {
  static final NavigationManager _instance = NavigationManager._internal();
  factory NavigationManager() => _instance;
  NavigationManager._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  GoRouter? _router;

  void setRouter(GoRouter router) {
    _router = router;
  }

  GoRouter get router {
    assert(_router != null, 'Router not initialized in NavigationManager');
    return _router!;
  }

  BuildContext? get currentContext => navigatorKey.currentContext;

  /// Navigate to a named route.
  void goNamed(String name, {Map<String, String> pathParameters = const {}, Map<String, dynamic> queryParameters = const {}, Object? extra}) {
    router.goNamed(name, pathParameters: pathParameters, queryParameters: queryParameters, extra: extra);
  }

  /// Push a named route onto the stack.
  void pushNamed(String name, {Map<String, String> pathParameters = const {}, Map<String, dynamic> queryParameters = const {}, Object? extra}) {
    router.pushNamed(name, pathParameters: pathParameters, queryParameters: queryParameters, extra: extra);
  }

  /// Go back.
  void pop([Object? result]) {
    if (router.canPop()) {
      router.pop(result);
    }
  }

  /// Force redirect to login (e.g., from an interceptor).
  void forceLogout() {
    router.go('/login');
  }
}
