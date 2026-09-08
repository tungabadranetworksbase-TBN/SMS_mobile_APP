import 'package:dio/dio.dart';

import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/json_value.dart';

class PaymentUpiDto {
  final String id;
  final String label;

  const PaymentUpiDto({required this.id, required this.label});

  factory PaymentUpiDto.fromJson(Map<String, dynamic> json) {
    return PaymentUpiDto(
      id: jsonStr(json['id']),
      label: jsonStr(json['label'], 'UPI'),
    );
  }
}

class PaymentQrDto {
  final String id;
  final String label;
  final String imageUrl;
  final String? instructions;

  const PaymentQrDto({
    required this.id,
    required this.label,
    required this.imageUrl,
    this.instructions,
  });

  factory PaymentQrDto.fromJson(Map<String, dynamic> json) {
    return PaymentQrDto(
      id: jsonStr(json['id']),
      label: jsonStr(json['label'], 'QR'),
      imageUrl: jsonStr(json['imageUrl']),
      instructions: json['instructions']?.toString(),
    );
  }
}

class PaymentOptionsDto {
  final bool gatewayAvailable;
  final bool manualAvailable;
  final List<PaymentUpiDto> upi;
  final List<PaymentQrDto> qrs;

  const PaymentOptionsDto({
    required this.gatewayAvailable,
    required this.manualAvailable,
    this.upi = const [],
    this.qrs = const [],
  });

  factory PaymentOptionsDto.fromJson(Map<String, dynamic> json) {
    return PaymentOptionsDto(
      gatewayAvailable: json['gatewayAvailable'] == true,
      manualAvailable: json['manualAvailable'] == true,
      upi: jsonList(json['upi'])
          .map((row) => PaymentUpiDto.fromJson(jsonMap(row)))
          .where((u) => u.id.isNotEmpty)
          .toList(),
      qrs: jsonList(json['paymentQrs'] ?? json['qrs'])
          .map((row) => PaymentQrDto.fromJson(jsonMap(row)))
          .where((q) => q.imageUrl.isNotEmpty)
          .toList(),
    );
  }

  List<String> get checkoutMethods => [
    if (gatewayAvailable) 'STRIPE',
    if (manualAvailable) 'QR',
  ];
}

class CommerceCheckoutDto {
  final String orderId;
  final String? url;
  final String? sessionId;
  final double total;

  const CommerceCheckoutDto({
    required this.orderId,
    this.url,
    this.sessionId,
    this.total = 0,
  });

  factory CommerceCheckoutDto.fromJson(Map<String, dynamic> json) {
    return CommerceCheckoutDto(
      orderId: jsonStr(json['orderId']),
      url: json['url']?.toString() ?? json['checkoutUrl']?.toString(),
      sessionId: json['sessionId']?.toString(),
      total: jsonDouble(json['total'] ?? json['effectiveTotal']),
    );
  }
}

class CommerceApiService {
  final ApiClient _apiClient;

  CommerceApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<void>> addCourseToCart(String courseId) {
    return _apiClient.post<void>(
      ApiEndpoints.cartItems,
      data: {'itemType': 'COURSE', 'id': courseId},
    );
  }

  Future<ApiResponse<PaymentOptionsDto>> fetchPaymentOptions() {
    return _apiClient.get<PaymentOptionsDto>(
      ApiEndpoints.paymentOptions,
      fromJson: (json) => PaymentOptionsDto.fromJson(jsonMap(json)),
    );
  }

  Future<ApiResponse<CommerceCheckoutDto>> checkout({
    required String method,
    required String origin,
  }) {
    return _apiClient.post<CommerceCheckoutDto>(
      ApiEndpoints.checkout,
      data: {'method': method},
      headers: {'Origin': origin},
      fromJson: (json) => CommerceCheckoutDto.fromJson(jsonMap(json)),
    );
  }

  Future<ApiResponse<void>> submitOrderPayment({
    required String orderId,
    required String receiptPath,
    required double amount,
    String? reference,
  }) {
    return _apiClient.upload<void>(
      ApiEndpoints.withParams(ApiEndpoints.commerceOrderPayments, {
        'id': orderId,
      }),
      formData: FormData.fromMap({
        'receipt': MultipartFile.fromFileSync(receiptPath),
        'amount': amount.toString(),
        if (reference != null && reference.isNotEmpty) 'reference': reference,
      }),
    );
  }
}
