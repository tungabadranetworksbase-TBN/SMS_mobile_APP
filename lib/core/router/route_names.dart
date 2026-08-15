/// Tungabadra Networks LMS — Route Names
///
/// Centralized route names and paths for GoRouter.
class RouteNames {
  RouteNames._();

  // ── Auth ──
  static const String splash = 'splash';
  static const String login = 'login';
  static const String serverConfig = 'server-config';
  static const String forgotPassword = 'forgot-password';
  static const String resetPassword = 'reset-password';
  static const String signup = 'signup';

  // ── Student ──
  static const String studentDashboard = 'student-dashboard';
  static const String studentCourses = 'student-courses';
  static const String courseDetails = 'course-details';
  static const String videoPlayer = 'video-player';
  static const String pdfViewer = 'pdf-viewer';
  static const String quizPlayer = 'quiz-player';
  static const String submitAssignment = 'submit-assignment';
  static const String studentAttendance = 'student-attendance';
  static const String studentSupport = 'student-support';
  static const String studentProfile = 'student-profile';
  static const String studentCertificates = 'student-certificates';
  static const String editProfile = 'edit-profile';
  static const String notifications = 'notifications';
  static const String orderHistory = 'order-history';
  static const String orderDetails = 'order-details';
  static const String checkout = 'checkout';
  
  // ── SMR (Student Management Rep) ──
  static const String smrDashboard = 'smr-dashboard';
  static const String smrStudents = 'smr-students';
  static const String smrBatches = 'smr-batches';
  
  // ── Admin ──
  static const String adminDashboard = 'admin-dashboard';
  static const String adminAnalytics = 'admin-analytics';
}

class RoutePaths {
  RoutePaths._();

  // ── Auth ──
  static const String splash = '/';
  static const String login = '/login';
  static const String serverConfig = '/server-config';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String signup = '/signup';

  // ── Student ──
  static const String studentDashboard = '/student/dashboard';
  static const String studentCourses = '/student/courses';
  static const String courseDetails = '/student/courses/:id';
  static const String videoPlayer = '/student/media/video';
  static const String pdfViewer = '/student/media/pdf';
  static const String quizPlayer = '/student/assessments/quiz/:id';
  static const String submitAssignment = '/student/assessments/assignment/:id/submit';
  static const String studentAttendance = '/student/attendance';
  static const String studentSupport = '/student/support';
  static const String studentProfile = '/student/profile';
  static const String studentCertificates = '/student/certificates';
  static const String editProfile = '/student/profile/edit';
  static const String notifications = '/student/notifications';
  static const String orderHistory = '/student/orders';
  static const String orderDetails = '/student/orders/:id';
  static const String checkout = '/checkout';
  
  // ── SMR (Student Management Rep) ──
  static const String smrDashboard = '/smr/dashboard';
  static const String smrStudents = '/smr/students';
  static const String smrBatches = '/smr/batches';
  
  // ── Admin ──
  static const String adminDashboard = '/admin/dashboard';
  static const String adminAnalytics = '/admin/analytics';
}
