import 'dart:async';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/network/api_exception.dart';

class PaymentGatewayService {
  final Razorpay _razorpay;

  // Streams for passing events back to the UI controller
  final _paymentSuccessController =
      StreamController<PaymentSuccessResponse>.broadcast();
  final _paymentErrorController =
      StreamController<PaymentFailureResponse>.broadcast();
  final _externalWalletController =
      StreamController<ExternalWalletResponse>.broadcast();

  PaymentGatewayService() : _razorpay = Razorpay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Stream<PaymentSuccessResponse> get onPaymentSuccess =>
      _paymentSuccessController.stream;
  Stream<PaymentFailureResponse> get onPaymentError =>
      _paymentErrorController.stream;
  Stream<ExternalWalletResponse> get onExternalWallet =>
      _externalWalletController.stream;

  void openCheckout({
    required String keyId,
    required double amount,
    required String name,
    required String description,
    required String orderId,
    required String prefillEmail,
    required String prefillContact,
    String themeColor = '#E65100', // Default Rust Orange
  }) {
    final options = {
      'key': keyId,
      'amount': (amount * 100)
          .toInt(), // Razorpay expects amount in subunits (paisa)
      'name': name,
      'description': description,
      'order_id': orderId,
      'prefill': {'contact': prefillContact, 'email': prefillEmail},
      'theme': {'color': themeColor},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      throw ApiException(message: 'Failed to launch payment gateway: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _paymentSuccessController.add(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _paymentErrorController.add(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _externalWalletController.add(response);
  }

  void dispose() {
    _razorpay.clear();
    _paymentSuccessController.close();
    _paymentErrorController.close();
    _externalWalletController.close();
  }
}
