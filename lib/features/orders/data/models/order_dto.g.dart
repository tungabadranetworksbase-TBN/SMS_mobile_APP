// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDto _$OrderDtoFromJson(Map<String, dynamic> json) => OrderDto(
  id: json['id'] as String,
  displayId: json['displayId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  currency: json['currency'] as String,
  status: json['status'] as String,
  receiptUrl: json['receiptUrl'] as String?,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OrderDtoToJson(OrderDto instance) => <String, dynamic>{
  'id': instance.id,
  'displayId': instance.displayId,
  'createdAt': instance.createdAt.toIso8601String(),
  'totalAmount': instance.totalAmount,
  'currency': instance.currency,
  'status': instance.status,
  'receiptUrl': instance.receiptUrl,
  'items': instance.items,
};

OrderItemDto _$OrderItemDtoFromJson(Map<String, dynamic> json) => OrderItemDto(
  id: json['id'] as String,
  title: json['title'] as String,
  type: json['type'] as String,
  price: (json['price'] as num).toDouble(),
);

Map<String, dynamic> _$OrderItemDtoToJson(OrderItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': instance.type,
      'price': instance.price,
    };
