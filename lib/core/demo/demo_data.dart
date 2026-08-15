// Tungabadra Networks LMS — Demo Mock Data
//
// Provides realistic mock data for all features when demo mode is active.
import '../../features/dashboard/data/models/student_dashboard_dto.dart';
import '../../features/dashboard/data/models/smr_dashboard_dto.dart';
import '../../features/dashboard/data/models/admin_dashboard_dto.dart';
import '../../features/learning/data/models/course_dto.dart';
import '../../features/learning/data/models/lesson_dto.dart';
import '../../features/profile/data/models/profile_dto.dart';
import '../../features/assessments/data/models/assessment_dto.dart';
import '../../features/assessments/data/models/assignment_dto.dart';
import '../../features/assessments/data/models/submission_dto.dart';

class DemoData {
  DemoData._();

  // ── Profile Data ──
  static ProfileDto getProfile(String role) {
    switch (role) {
      case 'smr':
        return ProfileDto(
          id: 'smr-001',
          name: 'Priya Sharma (Staff)',
          email: 'priya.sharma@tungabadranetworks.com',
          phone: '+91 98765 43210',
          address: 'TBN Bangalore Office, Karnataka',
          role: 'smr',
          joinedAt: DateTime.now().subtract(const Duration(days: 365)),
        );
      case 'admin':
      case 'super_admin':
        return ProfileDto(
          id: 'admin-001',
          name: 'Administrator',
          email: 'admin@tungabadranetworks.com',
          phone: '+91 99999 88888',
          address: 'TBN Corporate HQ, Hyderabad',
          role: 'admin',
          joinedAt: DateTime.now().subtract(const Duration(days: 730)),
        );
      case 'student':
      default:
        return ProfileDto(
          id: 'stud-001',
          name: 'John Doe',
          email: 'john.doe@gmail.com',
          phone: '+91 91234 56789',
          address: 'Indiranagar, Bangalore, Karnataka',
          role: 'student',
          joinedAt: DateTime.now().subtract(const Duration(days: 45)),
        );
    }
  }

  // ── Student Dashboard ──
  static StudentDashboardDto get studentDashboard => StudentDashboardDto(
    currentClassName: 'Full-Stack Web Development – Batch 14',
    stats: DashboardStatsDto(
      attendancePercentage: 0.87,
      pendingTasksCount: 3,
      lastClassDate: DateTime.now().subtract(const Duration(days: 1)),
      activeCoursesCount: 2,
      classesAttendedCount: 42,
      tasksSubmittedCount: 18,
    ),
    activeBatches: [
      StudentBatchDto(
        id: 'batch-001',
        name: 'Batch 14 • Mon/Wed/Fri',
        courseId: 'course-001',
        courseTitle: 'Full-Stack Web Development',
        progress: 0.65,
      ),
      StudentBatchDto(
        id: 'batch-002',
        name: 'Batch 8 • Tue/Thu',
        courseId: 'course-002',
        courseTitle: 'Data Science with Python',
        progress: 0.32,
      ),
    ],
    upcomingTasks: [
      UpcomingTaskDto(
        id: 'task-001',
        title: 'Build a REST API with Express.js',
        courseName: 'Full-Stack Web Development',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        status: TaskStatus.upcoming,
      ),
      UpcomingTaskDto(
        id: 'task-002',
        title: 'Pandas Data Cleaning Exercise',
        courseName: 'Data Science with Python',
        dueDate: DateTime.now().add(const Duration(days: 4)),
        status: TaskStatus.inProgress,
      ),
      UpcomingTaskDto(
        id: 'task-003',
        title: 'React Portfolio Project',
        courseName: 'Full-Stack Web Development',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: TaskStatus.critical,
      ),
    ],
  );

  // ── SMR Dashboard ──
  static SmrDashboardDto get smrDashboard => SmrDashboardDto(
    stats: SmrStatsDto(
      totalStudents: 156,
      activeBatches: 8,
      pendingTickets: 5,
      todayAttendance: 128,
    ),
    activeBatches: [
      ActiveBatchDto(
        id: 'batch-001',
        name: 'Full-Stack Batch 14',
        studentCount: 24,
        trainerName: 'Rajesh Kumar',
        progress: 0.65,
      ),
      ActiveBatchDto(
        id: 'batch-002',
        name: 'Data Science Batch 8',
        studentCount: 18,
        trainerName: 'Priya Sharma',
        progress: 0.32,
      ),
      ActiveBatchDto(
        id: 'batch-003',
        name: 'Mobile Dev Batch 6',
        studentCount: 20,
        trainerName: 'Arun Reddy',
        progress: 0.78,
      ),
    ],
    recentActivities: [
      RecentActivityDto(
        id: 'act-001',
        description: 'New student enrolled in Full-Stack Batch 14',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'enrollment',
      ),
      RecentActivityDto(
        id: 'act-002',
        description: 'Attendance marked for Data Science Batch 8',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        type: 'attendance',
      ),
      RecentActivityDto(
        id: 'act-003',
        description: 'Support ticket #45 resolved',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        type: 'ticket',
      ),
    ],
  );

  // ── Admin Dashboard ──
  static AdminDashboardDto get adminDashboard => AdminDashboardDto(
    stats: AdminStatsDto(
      totalUsers: 1243,
      totalRevenue: 2450000,
      activeCourses: 12,
      pendingApprovals: 7,
      serverUptime: 99.7,
    ),
    revenueData: [
      RevenueDataDto(month: 'Feb', amount: 180000),
      RevenueDataDto(month: 'Mar', amount: 220000),
      RevenueDataDto(month: 'Apr', amount: 195000),
      RevenueDataDto(month: 'May', amount: 310000),
      RevenueDataDto(month: 'Jun', amount: 285000),
      RevenueDataDto(month: 'Jul', amount: 340000),
      RevenueDataDto(month: 'Aug', amount: 420000),
    ],
    systemAlerts: [
      SystemAlertDto(
        id: 'alert-001',
        message: 'Storage usage at 78% — consider cleanup',
        severity: 'medium',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      SystemAlertDto(
        id: 'alert-002',
        message: '5 new instructor applications pending review',
        severity: 'low',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ],
  );

  // ── Courses Data ──
  static List<CourseDto> get studentCourses => [
    CourseDto(
      id: 'course-001',
      title: 'Full-Stack Web Development',
      description:
          'Master HTML, CSS, JavaScript, Node.js, Express, MongoDB, and React to become a confident Full-Stack Developer.',
      instructorName: 'Rajesh Kumar',
      totalLessons: 24,
      completedLessons: 15,
      progress: 0.625,
    ),
    CourseDto(
      id: 'course-002',
      title: 'Data Science with Python',
      description:
          'Learn NumPy, Pandas, Matplotlib, Scikit-Learn, and build Machine Learning models step-by-step.',
      instructorName: 'Priya Sharma',
      totalLessons: 30,
      completedLessons: 10,
      progress: 0.333,
    ),
  ];

  // ── Course Modules ──
  static List<ModuleDto> getCourseModules(String courseId) {
    if (courseId == 'course-002') {
      return [
        ModuleDto(
          id: 'c2-mod-1',
          title: 'Introduction to Python for Data Science',
          isCompleted: true,
          lessons: [
            LessonDto(
              id: 'c2-les-1',
              title: 'Welcome & Setup',
              description: 'Installing Anaconda and Jupyter Notebooks.',
              type: 'video',
              url:
                  'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
              durationMinutes: 10,
              isCompleted: true,
            ),
            LessonDto(
              id: 'c2-les-2',
              title: 'Python Syntax & Variables',
              description: 'Basics of python script syntax and data types.',
              type: 'pdf',
              url:
                  'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
              durationMinutes: 20,
              isCompleted: true,
            ),
          ],
        ),
        ModuleDto(
          id: 'c2-mod-2',
          title: 'NumPy Arrays & Mathematical Operations',
          isCompleted: false,
          lessons: [
            LessonDto(
              id: 'c2-les-3',
              title: 'Why NumPy?',
              description:
                  'Understanding vectorization and performance differences with loops.',
              type: 'video',
              url:
                  'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
              durationMinutes: 15,
              isCompleted: false,
            ),
            LessonDto(
              id: 'c2-les-4',
              title: 'NumPy Practice Quiz',
              description: 'Quick assessment of array creations and slicing.',
              type: 'quiz',
              durationMinutes: 10,
              isCompleted: false,
            ),
          ],
        ),
      ];
    }

    // Default: course-001 modules
    return [
      ModuleDto(
        id: 'c1-mod-1',
        title: 'Module 1: Foundations of Web Development',
        isCompleted: true,
        lessons: [
          LessonDto(
            id: 'c1-les-1',
            title: 'Welcome to the Course!',
            description:
                'Meet your instructor and learn about the course roadmap.',
            type: 'video',
            url:
                'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
            durationMinutes: 8,
            isCompleted: true,
          ),
          LessonDto(
            id: 'c1-les-2',
            title: 'HTML5 Semantic Structure',
            description:
                'Learn structure tags like header, article, footer, etc.',
            type: 'pdf',
            url:
                'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
            durationMinutes: 15,
            isCompleted: true,
          ),
          LessonDto(
            id: 'c1-les-3',
            title: 'Quiz: HTML5 Structure',
            description: 'Test your understanding of HTML elements.',
            type: 'quiz',
            durationMinutes: 5,
            isCompleted: true,
          ),
        ],
      ),
      ModuleDto(
        id: 'c1-mod-2',
        title: 'Module 2: Advanced CSS & Responsive Layouts',
        isCompleted: false,
        lessons: [
          LessonDto(
            id: 'c1-les-4',
            title: 'CSS Flexbox Layouts Explained',
            description: 'Aligning components dynamically inside a container.',
            type: 'video',
            url:
                'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
            durationMinutes: 18,
            isCompleted: false,
          ),
          LessonDto(
            id: 'c1-les-5',
            title: 'CSS Grid System',
            description: 'Working with complex grid column templates.',
            type: 'video',
            url:
                'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
            durationMinutes: 22,
            isCompleted: false,
          ),
          LessonDto(
            id: 'c1-les-6',
            title: 'Portfolio Layout Assignment',
            description: 'Submit your responsive portfolio page layout.',
            type: 'assignment',
            durationMinutes: 45,
            isCompleted: false,
          ),
        ],
      ),
    ];
  }

  // ── Assessments Mock Data ──
  static AssessmentDto getAssessment(String id) {
    return AssessmentDto(
      id: id,
      title: 'HTML5 Foundations Quiz',
      description:
          'A quick quiz testing semantic layout tags, attributes and best practices.',
      durationMinutes: 10,
      totalMarks: 20,
      questions: [
        QuestionDto(
          id: 'q1',
          text:
              'Which HTML5 element represents self-contained content that could be distributed independently?',
          type: 'MULTIPLE_CHOICE',
          options: ['<section>', '<article>', '<aside>', '<div>'],
          marks: 10,
        ),
        QuestionDto(
          id: 'q2',
          text:
              'The <main> tag should be used multiple times on a single webpage.',
          type: 'TRUE_FALSE',
          options: ['True', 'False'],
          marks: 10,
        ),
      ],
    );
  }

  static AssignmentDto getAssignment(String id) {
    return AssignmentDto(
      id: id,
      title: 'Responsive Portfolio Website Design',
      description:
          'Implement a fully responsive portfolio page using Flexbox or Grid. Make sure it looks flawless on mobile devices.',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      totalMarks: 50,
    );
  }

  static SubmissionDto getSubmission(String entityId, String type) {
    return SubmissionDto(
      id: 'sub-demo-123',
      entityId: entityId,
      type: type,
      submittedAt: DateTime.now(),
      score: 10,
      status: 'GRADED',
    );
  }
}
