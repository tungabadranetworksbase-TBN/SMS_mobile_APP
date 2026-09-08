import '../../../../core/network/json_value.dart';

class AssessmentDto {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final int totalMarks;
  final List<QuestionDto> questions;

  const AssessmentDto({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.totalMarks,
    required this.questions,
  });

  /// Accepts either the nested `POST /assessments/:id/start` payload or a
  /// flat demo-shaped map.
  factory AssessmentDto.fromJson(Map<String, dynamic> json) {
    final quiz = jsonMap(json['quiz']);
    final root = quiz.isNotEmpty ? quiz : json;
    final questions = jsonList(root['questions'])
        .map((row) => QuestionDto.fromJson(jsonMap(row)))
        .toList();
    final totalMarks = questions.fold<int>(0, (sum, q) => sum + q.marks);
    return AssessmentDto(
      id: jsonStr(root['id'] ?? json['id']),
      title: jsonStr(root['title']),
      description: jsonStr(root['description']),
      durationMinutes: jsonInt(
        root['timeLimitMin'] ?? root['durationMinutes'],
      ),
      totalMarks: jsonInt(root['totalMarks'], totalMarks),
      questions: questions,
    );
  }
}

class QuestionDto {
  final String id;
  final String text;
  final String type;
  final List<String> options;
  final String? correctAnswer;
  final int marks;

  const QuestionDto({
    required this.id,
    required this.text,
    required this.type,
    this.options = const [],
    this.correctAnswer,
    required this.marks,
  });

  factory QuestionDto.fromJson(Map<String, dynamic> json) {
    final optionsRaw = json['options'];
    final options = optionsRaw is List
        ? optionsRaw.map((e) => e.toString()).toList()
        : <String>[];
    return QuestionDto(
      id: jsonStr(json['id']),
      text: jsonStr(json['prompt'] ?? json['text']),
      type: jsonStr(json['kind'] ?? json['type'], 'MCQ'),
      options: options,
      correctAnswer: json['correctAnswer']?.toString(),
      marks: jsonInt(json['points'] ?? json['marks'], 1),
    );
  }
}
