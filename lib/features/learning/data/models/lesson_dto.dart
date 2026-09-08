import '../../../../core/network/json_value.dart';

class LessonDto {
  final String id;
  final String title;
  final String description;
  final String type;
  final String? url;
  final int durationMinutes;
  final bool isCompleted;

  LessonDto({
    required this.id,
    required this.title,
    this.description = '',
    required this.type,
    this.url,
    this.durationMinutes = 0,
    this.isCompleted = false,
  });

  factory LessonDto.fromJson(Map<String, dynamic> json) {
    final rawType = jsonStr(json['type'], 'video').toLowerCase();
    return LessonDto(
      id: jsonStr(json['id'] ?? json['lectureId']),
      title: jsonStr(json['title'] ?? json['lectureTitle']),
      description: jsonStr(json['description'] ?? json['bodyHtml']),
      type: rawType,
      url: json['url']?.toString() ??
          json['videoUrl']?.toString() ??
          json['lectureUrl']?.toString() ??
          json['linkUrl']?.toString(),
      durationMinutes: jsonInt(
        json['durationMinutes'] ?? json['durationMin'] ?? json['lectureDuration'],
      ),
      isCompleted: json['isCompleted'] == true,
    );
  }
}

class ModuleDto {
  final String id;
  final String title;
  final List<LessonDto> lessons;
  final bool isCompleted;

  ModuleDto({
    required this.id,
    required this.title,
    required this.lessons,
    this.isCompleted = false,
  });

  factory ModuleDto.fromJson(Map<String, dynamic> json) {
    final raw = json['lessons'] ?? json['chapterContent'] ?? const [];
    return ModuleDto(
      id: jsonStr(json['id'] ?? json['chapterId']),
      title: jsonStr(json['title'] ?? json['chapterTitle']),
      lessons: jsonList(raw)
          .map((e) => LessonDto.fromJson(jsonMap(e)))
          .toList(),
      isCompleted: json['isCompleted'] == true,
    );
  }
}
