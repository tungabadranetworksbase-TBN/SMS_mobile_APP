import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/forced_password_change_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/registration_screen.dart';
import '../../features/auth/presentation/screens/server_config_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/admin_analytics_screen.dart';
import '../../features/dashboard/presentation/screens/smr_students_screen.dart';
import '../../features/dashboard/presentation/screens/smr_batches_screen.dart';
import '../../features/dashboard/presentation/screens/staff_unavailable_screen.dart';
import '../../features/dashboard/presentation/screens/student_dashboard_screen.dart';
import '../../features/learning/presentation/screens/course_details_screen.dart';
import '../../features/learning/presentation/screens/student_courses_screen.dart';
import '../../features/assessments/presentation/screens/quiz_player_screen.dart';
import '../../features/orders/presentation/screens/order_history_screen.dart';
import '../../features/orders/presentation/screens/order_details_screen.dart';
import '../../features/payments/presentation/screens/checkout_screen.dart';
import '../../features/media/presentation/screens/pdf_viewer_screen.dart';
import '../../features/media/presentation/screens/video_player_screen.dart';
import '../../features/profile/data/models/profile_dto.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/student_profile_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/dashboard/presentation/widgets/staff_shell.dart';
import '../../features/dashboard/presentation/widgets/student_shell.dart';
import '../auth/capabilities.dart';
import '../auth/capabilities_store.dart';
import '../auth/gate_store.dart';
import '../auth/session_gates.dart';
import '../auth/destinations.dart';
import '../di/service_locator.dart';
import '../managers/navigation_manager.dart';
import '../managers/session_manager.dart';
import '../storage/preference_manager.dart';
import 'route_names.dart';

/// Provider for the GoRouter instance.
/// Listens to auth state changes to trigger redirects.
final routerProvider = Provider<GoRouter>((ref) {
  final sessionManager = locator<SessionManager>();
  final capsStore = locator<CapabilitiesStore>();
  final gateStore = locator<GateStore>();

  final authStateListenable = _StreamListenable(sessionManager.authStateStream);
  final capsListenable = _StreamListenable(capsStore.changes);
  final gateListenable = _StreamListenable(gateStore.changes);
  final refresh = Listenable.merge([
    authStateListenable,
    capsListenable,
    gateListenable,
  ]);

  final router = GoRouter(
    navigatorKey: locator<NavigationManager>().navigatorKey,
    initialLocation: RoutePaths.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = sessionManager.isAuthenticated;

      if (!isLoggedIn) {
        final atServerConfig = state.matchedLocation == RoutePaths.serverConfig;

        final hasServerUrl =
            locator<PreferenceManager>().getServerUrl() != null;
        if (!hasServerUrl) {
          return atServerConfig ? null : RoutePaths.serverConfig;
        }

        final isAuthRoute =
            state.matchedLocation == RoutePaths.login ||
            state.matchedLocation == RoutePaths.signup ||
            state.matchedLocation == RoutePaths.forgotPassword ||
            state.matchedLocation == RoutePaths.resetPassword ||
            state.matchedLocation == RoutePaths.verifyEmail ||
            atServerConfig;

        if (isAuthRoute) return null;
        return RoutePaths.login;
      }

      final caps = capsStore.current;
      if (caps == null) {
        // Authenticated but caps missing — never stay on splash forever.
        // Boot hydration should have filled or cleared the session; if not,
        // bounce to login so the user is not stuck behind the spinner.
        if (state.matchedLocation == RoutePaths.splash ||
            state.matchedLocation == RoutePaths.login) {
          return RoutePaths.login;
        }
        return RoutePaths.login;
      }

      final loc = state.matchedLocation;
      final dest = SessionGates.destination(
        caps: caps,
        regFeeRequired: gateStore.regFeeRequired,
      );

      if (loc == RoutePaths.forcedPasswordChange ||
          loc == RoutePaths.registration) {
        return loc == dest ? null : dest;
      }

      final isGoingToAuth =
          loc == RoutePaths.login ||
          loc == RoutePaths.signup ||
          loc == RoutePaths.forgotPassword ||
          loc == RoutePaths.resetPassword ||
          loc == RoutePaths.verifyEmail ||
          loc == RoutePaths.serverConfig;

      final isGoingToSplash = loc == RoutePaths.splash;

      if (isGoingToAuth || isGoingToSplash) {
        return dest;
      }

      if (dest == RoutePaths.forcedPasswordChange ||
          dest == RoutePaths.registration) {
        return dest;
      }

      if (caps.tier == UserTier.student && loc.startsWith('/staff')) {
        return RoutePaths.studentDashboard;
      }

      if (caps.tier != UserTier.student && loc.startsWith('/staff')) {
        if (loc == RoutePaths.staffUnavailable) {
          return visibleStaffDestinations(caps).isEmpty
              ? null
              : dest;
        }
        final allowed = visibleStaffDestinations(caps).any(
          (d) => loc == d.route || loc.startsWith('${d.route}/'),
        );
        if (!allowed) return dest;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.signup,
        name: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RoutePaths.serverConfig,
        name: RouteNames.serverConfig,
        builder: (context, state) => const ServerConfigScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.resetPassword,
        name: RouteNames.resetPassword,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ResetPasswordScreen(email: extra['email'] ?? '');
        },
      ),
      GoRoute(
        path: RoutePaths.verifyEmail,
        name: RouteNames.verifyEmail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpVerificationScreen(
            email: extra['email'] ?? '',
            password: extra['password'] as String?,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.forcedPasswordChange,
        name: RouteNames.forcedPasswordChange,
        builder: (context, state) => const ForcedPasswordChangeScreen(),
      ),
      GoRoute(
        path: RoutePaths.registration,
        name: RouteNames.registration,
        builder: (context, state) => const RegistrationScreen(),
      ),

      // ── Media & Learning Full Screen Routes ──
      GoRoute(
        path: RoutePaths.videoPlayer,
        name: RouteNames.videoPlayer,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return VideoPlayerScreen(
            title: extra['title'] ?? 'Video Player',
            url: extra['url'] ?? '',
          );
        },
      ),
      GoRoute(
        path: RoutePaths.pdfViewer,
        name: RouteNames.pdfViewer,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PdfViewerScreen(
            title: extra['title'] ?? 'PDF Document',
            url: extra['url'] ?? '',
          );
        },
      ),
      GoRoute(
        path: RoutePaths.quizPlayer,
        name: RouteNames.quizPlayer,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return QuizPlayerScreen(
            assessmentId: id,
            title: extra['title'] ?? 'Quiz',
          );
        },
      ),
      GoRoute(
        path: RoutePaths.submitAssignment,
        name: RouteNames.submitAssignment,
        builder: (context, state) => const FeatureUnavailableScreen(
          message: 'Assignments are not available in this app version.',
        ),
      ),
      GoRoute(
        path: RoutePaths.checkout,
        name: RouteNames.checkout,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CheckoutScreen(
            courseId: extra['courseId'] ?? '',
            courseTitle: extra['courseTitle'] ?? '',
            price: (extra['price'] ?? 0).toDouble(),
          );
        },
      ),

      // ── Student Routes (Wrapped in Shell) ──
      ShellRoute(
        builder: (context, state, child) => StudentShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.studentDashboard,
            name: RouteNames.studentDashboard,
            builder: (context, state) => const StudentDashboardScreen(),
          ),
          GoRoute(
            path: RoutePaths.studentCourses,
            name: RouteNames.studentCourses,
            builder: (context, state) => const StudentCoursesScreen(),
          ),
          GoRoute(
            path: RoutePaths.courseDetails,
            name: RouteNames.courseDetails,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return CourseDetailsScreen(courseId: id);
            },
          ),
          GoRoute(
            path: RoutePaths.studentAttendance,
            name: RouteNames.studentAttendance,
            builder: (context, state) => const FeatureUnavailableScreen(
              message:
                  'Attendance is not available in this app version.',
            ),
          ),
          GoRoute(
            path: RoutePaths.studentSupport,
            name: RouteNames.studentSupport,
            builder: (context, state) => const FeatureUnavailableScreen(
              message:
                  'Support tickets are not available in this app version.',
            ),
          ),
          GoRoute(
            path: RoutePaths.studentCertificates,
            name: RouteNames.studentCertificates,
            builder: (context, state) => const FeatureUnavailableScreen(
              message:
                  'Certificates are not available in this app version.',
            ),
          ),
          GoRoute(
            path: RoutePaths.studentProfile,
            name: RouteNames.studentProfile,
            builder: (context, state) => const StudentProfileScreen(),
          ),
          GoRoute(
            path: RoutePaths.editProfile,
            name: RouteNames.editProfile,
            builder: (context, state) {
              final extra = state.extra as ProfileDto;
              return EditProfileScreen(profile: extra);
            },
          ),
          GoRoute(
            path: RoutePaths.notifications,
            name: RouteNames.notifications,
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: RoutePaths.orderHistory,
            name: RouteNames.orderHistory,
            builder: (context, state) => const OrderHistoryScreen(),
          ),
          GoRoute(
            path: RoutePaths.orderDetails,
            name: RouteNames.orderDetails,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return OrderDetailsScreen(orderId: id);
            },
          ),
        ],
      ),

      ShellRoute(
        builder: (context, state, child) => StaffShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.staffStudents,
            name: RouteNames.staffStudents,
            builder: (context, state) => const SmrStudentsScreen(),
          ),
          GoRoute(
            path: RoutePaths.staffBatches,
            name: RouteNames.staffBatches,
            builder: (context, state) => const SmrBatchesScreen(),
          ),
          GoRoute(
            path: RoutePaths.staffInsights,
            name: RouteNames.staffInsights,
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: RoutePaths.staffAnalytics,
            name: RouteNames.staffAnalytics,
            builder: (context, state) => const AdminAnalyticsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.staffUnavailable,
        name: RouteNames.staffUnavailable,
        builder: (context, state) => const StaffUnavailableScreen(),
      ),
    ],
  );

  // Register the router with NavigationManager
  locator<NavigationManager>().setRouter(router);

  return router;
});

/// Helper to convert a Stream to a Listenable for GoRouter
class _StreamListenable extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  _StreamListenable(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
