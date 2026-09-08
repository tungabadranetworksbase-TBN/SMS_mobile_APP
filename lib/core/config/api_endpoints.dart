/// Tungabadra Networks LMS — Centralized API Endpoint Constants
///
/// Every path is verified against the backend route inventory
/// (`lms-full-stack/server/src/app.ts` and each module's `*.routes.ts`).
/// Paths are relative to a base URL that already ends in `/api`, so none of
/// them carry that prefix.
///
/// Pattern: no magic strings scattered across the codebase.
class ApiEndpoints {
  ApiEndpoints._();

  // ══════════════════════════════════════════════
  // SYSTEM
  // ══════════════════════════════════════════════
  static const String serverHealth = '/health';

  // ══════════════════════════════════════════════
  // AUTH (Better Auth — no {success,data} envelope)
  // ══════════════════════════════════════════════
  static const String signIn = '/auth/sign-in/email';
  static const String signUp = '/auth/sign-up/email';
  static const String signOut = '/auth/sign-out';
  static const String session = '/auth/get-session';
  static const String changePassword = '/auth/change-password';

  /// Email-OTP plugin. Verification is required before a first sign-in.
  static const String sendVerificationOtp =
      '/auth/email-otp/send-verification-otp';
  static const String verifyEmailOtp = '/auth/email-otp/verify-email';
  static const String resetPasswordOtp = '/auth/email-otp/reset-password';

  // ══════════════════════════════════════════════
  // IDENTITY & CAPABILITIES
  // ══════════════════════════════════════════════

  /// `{ user, permissions[], modules{} }` — the single source of navigation.
  static const String me = '/users/me';

  /// Module + permission-key catalogue. Behind `requireStaff`.
  static const String staffRegistry = '/staff/registry';

  // ══════════════════════════════════════════════
  // STUDENT PORTAL
  // ══════════════════════════════════════════════
  static const String studentProfile = '/student/profile';
  static const String studentDashboardV1 = '/student/dashboard';
  static const String studentOverview = '/student/overview';
  static const String enrolledCourses = '/student/enrolled-courses';
  static const String studentCourseProgress = '/student/courses/{id}/progress';
  static const String purchases = '/student/purchases';
  static const String registrationStatus = '/student/registration/status';
  static const String registrationReceipt = '/student/registration/receipt';
  static const String registrationCheckout = '/student/registration/checkout';
  static const String registrationAbandoned = '/student/registration/abandoned';

  // ══════════════════════════════════════════════
  // LEARNING
  // ══════════════════════════════════════════════
  static const String courseContent = '/learning/courses/{id}/content';
  static const String fileDownload = '/learning/files/{id}/download';
  static const String assessments = '/learning/assessments';
  static const String startAssessment = '/learning/assessments/{id}/start';
  static const String submitAssessment = '/learning/assessments/{id}/submit';
  static const String assessmentResult = '/learning/assessments/{id}/result';
  static const String quizzes = '/learning/quizzes';
  static const String quizDetail = '/learning/quizzes/{id}';
  static const String quizResults = '/learning/quizzes/{id}/results';

  // ══════════════════════════════════════════════
  // BATCHES
  // ══════════════════════════════════════════════
  static const String myBatches = '/batches/mine';
  static const String myClasses = '/batches/my-classes';
  static const String availableBatches = '/batches/available';
  static const String batches = '/batches';
  static const String batchDetail = '/batches/{id}';
  static const String batchStats = '/batches/{id}/stats';
  static const String joinBatch = '/batches/{id}/join';

  // ══════════════════════════════════════════════
  // NOTIFICATIONS
  // ══════════════════════════════════════════════
  static const String notifications = '/notifications';
  static const String unreadCount = '/notifications/unread-count';
  static const String markNotificationRead = '/notifications/{id}/read';
  static const String markAllNotificationsRead = '/notifications/read-all';

  // ══════════════════════════════════════════════
  // COMMERCE
  // ══════════════════════════════════════════════
  static const String cart = '/commerce/cart';
  static const String cartItems = '/commerce/cart/items';
  static const String quote = '/commerce/quote';
  static const String checkout = '/commerce/checkout';
  static const String checkoutStatus = '/commerce/checkout/status';
  static const String paymentOptions = '/commerce/payment-options';
  static const String commerceOrders = '/commerce/orders';
  static const String commerceOrderDetail = '/commerce/orders/{id}';
  static const String commerceOrderPayments = '/commerce/orders/{id}/payments';

  // ══════════════════════════════════════════════
  // STAFF — STUDENTS
  // ══════════════════════════════════════════════
  static const String students = '/students';
  static const String studentDetail = '/students/{id}';
  static const String studentMaster = '/students/master';
  static const String studentRoster = '/students/roster';

  // ══════════════════════════════════════════════
  // STAFF — INSIGHTS
  // ══════════════════════════════════════════════
  static const String insightsDashboard = '/insights/dashboard';
  static const String analyticsCourses = '/insights/analytics/courses';
  static const String analyticsPayments = '/insights/analytics/payments';
  static const String analyticsCrm = '/insights/analytics/crm';
  static const String analyticsStudentCohorts =
      '/insights/analytics/batch-performance';

  // ══════════════════════════════════════════════
  // STAFF — CRM (v1.1)
  // ══════════════════════════════════════════════
  static const String leads = '/crm/leads';
  static const String leadDetail = '/crm/leads/{id}';
  static const String crmAnalytics = '/crm/analytics';

  // ══════════════════════════════════════════════
  // STAFF — FINANCE (v1.1)
  // ══════════════════════════════════════════════
  static const String financeOrders = '/finance/orders';
  static const String financeOrderDetail = '/finance/orders/{id}';
  static const String revenueReport = '/finance/reports/revenue';
  static const String invoicePdf = '/finance/invoices/{id}/pdf';

  /// Every declared endpoint, for hygiene tests.
  static const List<String> all = [
    serverHealth,
    signIn,
    signUp,
    signOut,
    session,
    changePassword,
    sendVerificationOtp,
    verifyEmailOtp,
    resetPasswordOtp,
    me,
    staffRegistry,
    studentProfile,
    studentDashboardV1,
    studentOverview,
    enrolledCourses,
    studentCourseProgress,
    purchases,
    registrationStatus,
    registrationReceipt,
    registrationCheckout,
    registrationAbandoned,
    courseContent,
    fileDownload,
    assessments,
    startAssessment,
    submitAssessment,
    assessmentResult,
    quizzes,
    quizDetail,
    quizResults,
    myBatches,
    myClasses,
    availableBatches,
    batches,
    batchDetail,
    batchStats,
    joinBatch,
    notifications,
    unreadCount,
    markNotificationRead,
    markAllNotificationsRead,
    cart,
    cartItems,
    quote,
    checkout,
    checkoutStatus,
    paymentOptions,
    commerceOrders,
    commerceOrderDetail,
    commerceOrderPayments,
    students,
    studentDetail,
    studentMaster,
    studentRoster,
    insightsDashboard,
    analyticsCourses,
    analyticsPayments,
    analyticsCrm,
    analyticsStudentCohorts,
    leads,
    leadDetail,
    crmAnalytics,
    financeOrders,
    financeOrderDetail,
    revenueReport,
    invoicePdf,
  ];

  /// Replaces `{name}` placeholders. An unsupplied placeholder is left intact
  /// so the failure is loud at the HTTP layer rather than a silently
  /// malformed URL.
  static String withParams(String endpoint, Map<String, String> params) {
    var result = endpoint;
    for (final entry in params.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }
}
