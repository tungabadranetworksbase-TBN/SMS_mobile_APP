import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/server_config_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/admin_analytics_screen.dart';
import '../../features/dashboard/presentation/screens/smr_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/smr_students_screen.dart';
import '../../features/dashboard/presentation/screens/smr_batches_screen.dart';
import '../../features/dashboard/presentation/screens/student_dashboard_screen.dart';
import '../../features/learning/presentation/screens/course_details_screen.dart';
import '../../features/learning/presentation/screens/student_courses_screen.dart';
import '../../features/learning/presentation/screens/certificates_screen.dart';
import '../../features/assessments/presentation/screens/quiz_player_screen.dart';
import '../../features/assessments/presentation/screens/assignment_submission_screen.dart';
import '../../features/orders/presentation/screens/order_history_screen.dart';
import '../../features/orders/presentation/screens/order_details_screen.dart';
import '../../features/payments/presentation/screens/checkout_screen.dart';
import '../../features/media/presentation/screens/pdf_viewer_screen.dart';
import '../../features/media/presentation/screens/video_player_screen.dart';
import '../../features/profile/data/models/profile_dto.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/student_profile_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/attendance/presentation/screens/student_attendance_screen.dart';
import '../../features/support/presentation/screens/student_support_screen.dart';
import '../../features/dashboard/presentation/widgets/admin_shell.dart';
import '../../features/dashboard/presentation/widgets/smr_shell.dart';
import '../../features/dashboard/presentation/widgets/student_shell.dart';
import '../di/service_locator.dart';
import '../managers/navigation_manager.dart';
import '../managers/session_manager.dart';
import '../storage/preference_manager.dart';
import 'route_names.dart';

// Placeholder widgets for other features
class PlaceholderScreen extends StatelessWidget { final String title; const PlaceholderScreen({super.key, required this.title}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text(title))); }

/// Provider for the GoRouter instance.
/// Listens to auth state changes to trigger redirects.
final routerProvider = Provider<GoRouter>((ref) {
  final sessionManager = locator<SessionManager>();
  
  // Listen to auth stream to trigger router refresh
  final authStateListenable = _StreamListenable(sessionManager.authStateStream);

  final router = GoRouter(
    navigatorKey: locator<NavigationManager>().navigatorKey,
    initialLocation: RoutePaths.splash,
    refreshListenable: authStateListenable,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = sessionManager.isAuthenticated;

      // 1. User is not logged in
      if (!isLoggedIn) {
        final atServerConfig = state.matchedLocation == RoutePaths.serverConfig;

        // Does the user have a server URL configured?
        final hasServerUrl = locator<PreferenceManager>().getServerUrl() != null;
        if (!hasServerUrl) {
          // No server configured -> force them to configure it first.
          // Returning the location we are already on would be a redirect loop.
          return atServerConfig ? null : RoutePaths.serverConfig;
        }

        // Let them browse Auth routes freely
        final isAuthRoute = state.matchedLocation == RoutePaths.login ||
            state.matchedLocation == RoutePaths.signup ||
            state.matchedLocation == RoutePaths.forgotPassword ||
            state.matchedLocation == RoutePaths.resetPassword ||
            atServerConfig;

        if (isAuthRoute) return null; // allow
        // Anything else (including splash) goes to login.
        return RoutePaths.login;
      }

      // 2. User is logged in but trying to access auth pages
      final isGoingToAuth = state.matchedLocation == RoutePaths.login ||
                           state.matchedLocation == RoutePaths.signup ||
                           state.matchedLocation == RoutePaths.forgotPassword ||
                           state.matchedLocation == RoutePaths.resetPassword ||
                           state.matchedLocation == RoutePaths.serverConfig;

      final isGoingToSplash = state.matchedLocation == RoutePaths.splash;

      // 3. If authenticated, prevent access to auth pages and redirect to role dashboard
      if (sessionManager.isAuthenticated && (isGoingToAuth || isGoingToSplash)) {
        if (sessionManager.isStudent) return RoutePaths.studentDashboard;
        if (sessionManager.isSmr) return RoutePaths.smrDashboard;
        if (sessionManager.hasAdminAccess) return RoutePaths.adminDashboard;
        
        // Fallback for unknown role
        return RoutePaths.studentDashboard;
      }

      // 4. Role-based route protection
      if (sessionManager.isAuthenticated) {
        final loc = state.matchedLocation;
        
        // Block students from SMR/Admin routes
        if (sessionManager.isStudent && (loc.startsWith('/smr') || loc.startsWith('/admin'))) {
          return RoutePaths.studentDashboard;
        }
        
        // Block SMRs from Admin routes
        if (sessionManager.isSmr && loc.startsWith('/admin')) {
          return RoutePaths.smrDashboard;
        }
      }

      return null; // No redirect needed
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
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return AssignmentSubmissionScreen(
            assignmentId: id,
            title: extra['title'] ?? 'Submit Assignment',
          );
        },
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
            builder: (context, state) => const StudentAttendanceScreen(),
          ),
          GoRoute(
            path: RoutePaths.studentSupport,
            name: RouteNames.studentSupport,
            builder: (context, state) => const StudentSupportScreen(),
          ),
          GoRoute(
            path: RoutePaths.studentCertificates,
            name: RouteNames.studentCertificates,
            builder: (context, state) => const CertificatesScreen(),
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
      
      // ── SMR Routes (Wrapped in Shell) ──
      ShellRoute(
        builder: (context, state, child) => SmrShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.smrDashboard,
            name: RouteNames.smrDashboard,
            builder: (context, state) => const SmrDashboardScreen(),
          ),
          GoRoute(
            path: RoutePaths.smrStudents,
            name: RouteNames.smrStudents,
            builder: (context, state) => const SmrStudentsScreen(),
          ),
          GoRoute(
            path: RoutePaths.smrBatches,
            name: RouteNames.smrBatches,
            builder: (context, state) => const SmrBatchesScreen(),
          ),
        ],
      ),
      
      // ── Admin Routes (Wrapped in Shell) ──
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.adminDashboard,
            name: RouteNames.adminDashboard,
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: RoutePaths.adminAnalytics,
            name: RouteNames.adminAnalytics,
            builder: (context, state) => const AdminAnalyticsScreen(),
          ),
        ],
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
