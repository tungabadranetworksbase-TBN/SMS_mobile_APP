import 'package:json_annotation/json_annotation.dart';

part 'notification_message_dto.g.dart';

@JsonSerializable()
class NotificationMessageDto {
  final String id;
  final String title;
  final String message;
  final String type; // 'INFO', 'WARNING', 'SUCCESS', 'ALERT'
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

  factory NotificationMessageDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationMessageDtoToJson(this);
}
