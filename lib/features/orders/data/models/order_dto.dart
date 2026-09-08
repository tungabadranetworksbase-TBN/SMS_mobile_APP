import '../../../../core/network/json_value.dart';

class OrderDto {
  final String id;
  final String displayId;
  final DateTime createdAt;
  final double totalAmount;
  final String currency;
  final String status;
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

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    if (json['course'] is Map || json['orderId'] != null) {
      return OrderDto.fromPurchase(json);
    }
    return OrderDto(
      id: jsonStr(json['id']),
      displayId: jsonStr(json['displayId'] ?? json['orderNo'] ?? json['id']),
      createdAt: jsonDate(json['createdAt']) ?? DateTime.now(),
      totalAmount: jsonDouble(json['totalAmount'] ?? json['amount']),
      currency: jsonStr(json['currency'], 'INR'),
      status: jsonStr(json['status']),
      receiptUrl: json['receiptUrl']?.toString(),
      items: jsonList(json['items'])
          .map((e) => OrderItemDto.fromJson(jsonMap(e)))
          .toList(),
    );
  }

  factory OrderDto.fromPurchase(Map<String, dynamic> json) {
    final course = jsonMap(json['course']);
    final amount = jsonDouble(json['amount']);
    return OrderDto(
      id: jsonStr(json['orderId'] ?? json['id']),
      displayId: jsonStr(json['orderNo'] ?? json['orderId'] ?? json['id']),
      createdAt: jsonDate(json['createdAt']) ?? DateTime.now(),
      totalAmount: amount,
      currency: jsonStr(json['currency'], 'INR'),
      status: jsonStr(json['status']),
      items: [
        OrderItemDto(
          id: jsonStr(json['id']),
          title: jsonStr(course['courseTitle'] ?? course['title']),
          type: 'COURSE',
          price: amount,
        ),
      ],
    );
  }
}

class OrderItemDto {
  final String id;
  final String title;
  final String type;
  final double price;

  OrderItemDto({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    return OrderItemDto(
      id: jsonStr(json['id']),
      title: jsonStr(json['title'] ?? json['titleSnapshot']),
      type: jsonStr(json['type'], 'COURSE'),
      price: jsonDouble(json['price'] ?? json['lineTotal']),
    );
  }
}
