import '../../../../core/network/json_value.dart';

class NotificationMessageDto {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? link;

  NotificationMessageDto({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.link,
  });

  factory NotificationMessageDto.fromJson(Map<String, dynamic> json) {
    return NotificationMessageDto(
      id: jsonStr(json['id']),
      title: jsonStr(json['title']),
      message: jsonStr(json['body'] ?? json['message']),
      type: jsonStr(json['kind'] ?? json['type'], 'INFO'),
      isRead: json['isRead'] == true || json['readAt'] != null,
      createdAt: jsonDate(json['createdAt']) ?? DateTime.now(),
      link: json['url']?.toString() ?? json['link']?.toString(),
    );
  }
}
