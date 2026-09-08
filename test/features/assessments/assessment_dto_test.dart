import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/features/assessments/data/models/assessment_dto.dart';
import 'package:tbn_lms/features/assessments/data/models/submission_dto.dart';

void main() {
  test('AssessmentDto parses POST /assessments/:id/start payload', () {
    final dto = AssessmentDto.fromJson({
      'attemptId': 'a1',
      'quiz': {
        'id': 'q1',
        'title': 'CCNA Quiz',
        'description': 'Basics',
        'timeLimitMin': 15,
        'questions': [
          {
            'id': 'qq1',
            'kind': 'MCQ',
            'prompt': 'What is OSI?',
            'options': ['Model', 'Protocol'],
            'points': 5,
          },
        ],
      },
    });
    expect(dto.id, 'q1');
    expect(dto.durationMinutes, 15);
    expect(dto.questions.single.text, 'What is OSI?');
    expect(dto.questions.single.options, ['Model', 'Protocol']);
    expect(dto.totalMarks, 5);
  });

  test('SubmissionDto parses submitAttempt response', () {
    final dto = SubmissionDto.fromJson({
      'id': 'att1',
      'score': 5,
      'maxScore': 10,
      'passed': false,
      'submittedAt': '2026-01-01T00:00:00.000Z',
    });
    expect(dto.score, 5);
    expect(dto.maxScore, 10);
    expect(dto.passed, isFalse);
    expect(dto.status, 'GRADED');
  });
}
