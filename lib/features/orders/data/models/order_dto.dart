import 'package:json_annotation/json_annotation.dart';

part 'order_dto.g.dart';

@JsonSerializable()
class OrderDto {
  final String id;
  final String displayId; // Human readable like "ORD-2023-001"
  final DateTime createdAt;
  final double totalAmount;
  final String currency;
  final String status; // 'PENDING', 'PAID', 'FAILED', 'REFUNDED'
  final String? receiptUrl;
  final List<OrderItemDto> items;

  OrderDto({
    required this.id,
    required this.displayId,
    required this.createdAt,
    required this.totalAmount,
    required this.currency,
    required this.status,
    this.receiptUrl,
    required this.items,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) =>
      _$OrderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDtoToJson(this);
}

@JsonSerializable()
class OrderItemDto {
  final String id;
  final String title;
  final String type; // 'COURSE', 'SUBSCRIPTION'
  final double price;

  OrderItemDto({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) =>
      _$OrderItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemDtoToJson(this);
}
