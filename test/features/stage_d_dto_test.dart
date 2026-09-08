import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/features/dashboard/data/models/student_dashboard_dto.dart';
import 'package:tbn_lms/features/dashboard/data/models/crm_insights_dto.dart';
import 'package:tbn_lms/features/learning/data/models/course_dto.dart';
import 'package:tbn_lms/features/notifications/data/models/notification_message_dto.dart';
import 'package:tbn_lms/features/payments/data/services/commerce_api_service.dart';
import 'package:tbn_lms/features/profile/data/models/profile_dto.dart';

void main() {
  test('student dashboard matches GET /student/dashboard', () {
    final dto = StudentDashboardDto.fromJson({
      'stats': {
        'enrolledCourses': 2,
        'completedLectures': 11,
        'purchases': 1,
      },
      'courses': [
        {
          '_id': 'c1',
          'courseTitle': 'CCNA',
          'courseThumbnail': null,
          'educator': {'_id': 's1', 'name': 'Ada'},
          'completedLectures': 3,
          'totalLectures': 10,
        },
      ],
      'continueLearning': {
        '_id': 'c1',
        'courseTitle': 'CCNA',
        'educator': {'_id': 's1', 'name': 'Ada'},
        'completedLectures': 3,
        'totalLectures': 10,
      },
    });
    expect(dto.stats.enrolledCourses, 2);
    expect(dto.courses.single.id, 'c1');
    expect(dto.continueLearning?.courseTitle, 'CCNA');
  });

  test('enrolled course uses legacy _id / courseTitle / courseContent', () {
    final course = CourseDto.fromJson({
      '_id': 'c1',
      'courseTitle': 'CCNA',
      'courseDescription': 'Networking',
      'courseThumbnail': 'https://img',
      'educator': {'_id': 's1', 'name': 'Ada'},
      'courseContent': [
        {
          'chapterId': 'ch1',
          'chapterTitle': 'Intro',
          'chapterContent': [
            {
              'lectureId': 'l1',
              'lectureTitle': 'Welcome',
              'lectureUrl': 'https://v',
              'lectureDuration': 8,
            },
          ],
        },
      ],
    });
    expect(course.id, 'c1');
    expect(course.title, 'CCNA');
    expect(course.instructorName, 'Ada');
    expect(course.modules.single.lessons.single.id, 'l1');
    expect(course.totalLessons, 1);
  });

  test('notification list row uses body/kind/readAt', () {
    final n = NotificationMessageDto.fromJson({
      'id': 'n1',
      'kind': 'INFO',
      'title': 'Hello',
      'body': 'World',
      'url': '/x',
      'readAt': null,
      'createdAt': '2026-01-01T00:00:00.000Z',
    });
    expect(n.message, 'World');
    expect(n.isRead, isFalse);
    expect(n.link, '/x');
  });

  test('profile unwraps user + profile', () {
    final p = ProfileDto.fromJson({
      'user': {
        'id': 'u1',
        'name': 'Ada',
        'email': 'ada@example.com',
        'image': null,
      },
      'profile': {'phone': '999', 'photoUrl': null},
    });
    expect(p.id, 'u1');
    expect(p.phone, '999');
  });

  test('crm insights maps pipeline and leads', () {
    final dto = CrmInsightsDto.fromJson({
      'pipeline': {'NEW': 4, 'CONVERTED': 1},
      'leads': {'total': 5, 'converted': 1, 'conversionRatePct': 20},
      'records': {'stuck': 2},
      'followUps': {'pending': 3, 'overdue': 1},
    });
    expect(dto.totalLeads, 5);
    expect(dto.pipelineCount('NEW'), 4);
    expect(dto.overdueFollowUps, 1);
  });

  test('payment options prefer Stripe then QR and keep UPI / QR details', () {
    final dto = PaymentOptionsDto.fromJson({
      'gatewayAvailable': true,
      'manualAvailable': true,
      'upi': [
        {'id': 'org@upi', 'label': 'Main'},
      ],
      'paymentQrs': [
        {
          'id': 'q1',
          'label': 'Desk',
          'imageUrl': 'https://cdn.example/qr.png',
          'instructions': 'Scan once',
        },
      ],
    });
    expect(dto.checkoutMethods, ['STRIPE', 'QR']);
    expect(dto.upi.single.id, 'org@upi');
    expect(dto.qrs.single.imageUrl, 'https://cdn.example/qr.png');
  });
}
