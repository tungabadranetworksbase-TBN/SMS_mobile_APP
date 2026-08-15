// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationMessageDto _$NotificationMessageDtoFromJson(
  Map<String, dynamic> json,
) => NotificationMessageDto(
  id: json['id'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  type: json['type'] as String,
  isRead: json['isRead'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  link: json['link'] as String?,
);

Map<String, dynamic> _$NotificationMessageDtoToJson(
  NotificationMessageDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'message': instance.message,
  'type': instance.type,
  'isRead': instance.isRead,
  'createdAt': instance.createdAt.toIso8601String(),
  'link': instance.link,
};
