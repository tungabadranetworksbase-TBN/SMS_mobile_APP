import '../../../../core/network/json_value.dart';

class RegistrationStatusDto {
  final bool paid;
  final String? message;
  final String status;
  final double feeAmount;
  final String feeCurrency;
  final bool onlinePayment;

  const RegistrationStatusDto({
    required this.paid,
    this.message,
    this.status = '',
    this.feeAmount = 0,
    this.feeCurrency = 'INR',
    this.onlinePayment = false,
  });

  factory RegistrationStatusDto.fromJson(Map<String, dynamic> json) {
    final status = jsonStr(
      json['regFeeStatus'] ?? json['status'],
    ).toUpperCase();
    final fee = jsonMap(json['fee']);
    final paid =
        json['paid'] == true ||
        json['regFeePaid'] == true ||
        status == 'PAID' ||
        status == 'VERIFIED';
    return RegistrationStatusDto(
      paid: paid,
      message: json['regFeeNote']?.toString() ?? json['message']?.toString(),
      status: status,
      feeAmount: jsonDouble(fee['amount']),
      feeCurrency: jsonStr(fee['currency'], 'INR'),
      onlinePayment: json['onlinePayment'] == true,
    );
  }
}

class RegistrationCheckoutDto {
  final String? checkoutUrl;
  final String? sessionId;

  const RegistrationCheckoutDto({this.checkoutUrl, this.sessionId});

  factory RegistrationCheckoutDto.fromJson(Map<String, dynamic> json) {
    return RegistrationCheckoutDto(
      checkoutUrl: json['checkoutUrl']?.toString() ?? json['url']?.toString(),
      sessionId: json['sessionId']?.toString(),
    );
  }
}
