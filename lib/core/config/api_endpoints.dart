/// Tungabadra Networks LMS — Centralized API Endpoint Constants
///
/// All Express/TypeScript backend endpoint paths in one place.
/// Pattern: No magic strings scattered across the codebase.
class ApiEndpoints {
  ApiEndpoints._();

  // ══════════════════════════════════════════════
  // SYSTEM
  // ══════════════════════════════════════════════
  static const String serverHealth = '/health';

  // ══════════════════════════════════════════════
  // AUTH (Better Auth)
  // ══════════════════════════════════════════════
  static const String signIn = '/auth/sign-in/email';
  static const String signUp = '/auth/sign-up/email';
  static const String signOut = '/auth/sign-out';
  static const String session = '/auth/get-session';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshSession = '/auth/session/refresh';

  // ══════════════════════════════════════════════
  // USER & PROFILE
  // ══════════════════════════════════════════════
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile/update';
  static const String uploadAvatar = '/users/profile/avatar';
  static const String changePassword = '/users/change-password';

  // ══════════════════════════════════════════════
  // DASHBOARD
  // ══════════════════════════════════════════════
  static const String studentDashboard = '/dashboard/student';
  static const String smrDashboard = '/dashboard/smr';
  static const String adminDashboard = '/dashboard/admin';

  // ══════════════════════════════════════════════
  // COURSES & LEARNING
  // ══════════════════════════════════════════════
  static const String courses = '/courses';
  static const String courseDetail = '/courses/{id}';
  static const String courseLessons = '/courses/{id}/lessons';
  static const String lessonDetail = '/lessons/{id}';
  static const String courseProgress = '/courses/{id}/progress';
  static const String updateProgress = '/courses/{id}/progress/update';

  // ══════════════════════════════════════════════
  // BATCHES & ENROLLMENTS
  // ══════════════════════════════════════════════
  static const String batches = '/batches';
  static const String batchDetail = '/batches/{id}';
  static const String enrollments = '/enrollments';
  static const String myEnrollments = '/enrollments/mine';

  // ══════════════════════════════════════════════
  // ASSIGNMENTS & ASSESSMENTS
  // ══════════════════════════════════════════════
  static const String assignments = '/assignments';
  static const String assignmentDetail = '/assignments/{id}';
  static const String submitAssignment = '/assignments/{id}/submit';
  static const String assessments = '/assessments';
  static const String assessmentDetail = '/assessments/{id}';
  static const String submitAssessment = '/assessments/{id}/submit';

  // ══════════════════════════════════════════════
  // ATTENDANCE
  // ══════════════════════════════════════════════
  static const String attendance = '/attendance';
  static const String myAttendance = '/attendance/mine';
  static const String markAttendance = '/attendance/mark';

  // ══════════════════════════════════════════════
  // ORDERS & PAYMENTS
  // ══════════════════════════════════════════════
  static const String orders = '/orders';
  static const String orderDetail = '/orders/{id}';
  static const String createOrder = '/orders/create';
  static const String verifyPayment = '/orders/verify-payment';
  static const String paymentHistory = '/payments/history';

  // ══════════════════════════════════════════════
  // CERTIFICATES
  // ══════════════════════════════════════════════
  static const String certificates = '/certificates';
  static const String certificateDetail = '/certificates/{id}';
  static const String downloadCertificate = '/certificates/{id}/download';

  // ══════════════════════════════════════════════
  // NOTIFICATIONS
  // ══════════════════════════════════════════════
  static const String notifications = '/notifications';
  static const String unreadNotifications = '/notifications/unread';
  static const String markNotificationRead = '/notifications/{id}/read';
  static const String markAllRead = '/notifications/mark-all-read';
  static const String notificationCount = '/notifications/count';

  // ══════════════════════════════════════════════
  // SUPPORT & TICKETS
  // ══════════════════════════════════════════════
  static const String tickets = '/support/tickets';
  static const String ticketDetail = '/support/tickets/{id}';
  static const String createTicket = '/support/tickets/create';
  static const String ticketMessages = '/support/tickets/{id}/messages';
  static const String sendMessage = '/support/tickets/{id}/messages/send';

  // ══════════════════════════════════════════════
  // STUDENT MANAGEMENT (SMR/Admin)
  // ══════════════════════════════════════════════
  static const String students = '/students';
  static const String studentDetail = '/students/{id}';
  static const String studentSearch = '/students/search';

  // ══════════════════════════════════════════════
  // CRM (Admin)
  // ══════════════════════════════════════════════
  static const String leads = '/crm/leads';
  static const String leadDetail = '/crm/leads/{id}';
  static const String followUps = '/crm/follow-ups';

  // ══════════════════════════════════════════════
  // ANALYTICS (Admin)
  // ══════════════════════════════════════════════
  static const String analyticsOverview = '/analytics/overview';
  static const String analyticsRevenue = '/analytics/revenue';
  static const String analyticsStudents = '/analytics/students';

  // ══════════════════════════════════════════════
  // FILE STORAGE (MinIO Presigned URLs)
  // ══════════════════════════════════════════════
  static const String uploadUrl = '/files/upload-url';
  static const String downloadUrl = '/files/download-url';

  /// Helper: replace path parameters like {id} with actual values.
  static String withParams(String endpoint, Map<String, String> params) {
    var result = endpoint;
    for (final entry in params.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }
}
