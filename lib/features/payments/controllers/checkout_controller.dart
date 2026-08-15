import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../data/services/payment_gateway_service.dart';

final paymentGatewayProvider = Provider<PaymentGatewayService>((ref) {
  final service = locator<PaymentGatewayService>();
  ref.onDispose(() => service.dispose());
  return service;
});

class CheckoutController extends StateNotifier<AsyncValue<void>> {
  final PaymentGatewayService _paymentService;
  final AppConfig _appConfig;
  late StreamSubscription _successSub;
  late StreamSubscription _errorSub;

  CheckoutController({
    required PaymentGatewayService paymentService,
    required AppConfig appConfig,
  })  : _paymentService = paymentService,
        _appConfig = appConfig,
        super(const AsyncValue.data(null)) {
    _successSub = _paymentService.onPaymentSuccess.listen(_onSuccess);
    _errorSub = _paymentService.onPaymentError.listen(_onError);
  }

  @override
  void dispose() {
    _successSub.cancel();
    _errorSub.cancel();
    super.dispose();
  }

  // Called to initialize the payment flow
  Future<void> startCheckout({
    required String courseId,
    required double price,
    required String courseName,
    required String userEmail,
  }) async {
    state = const AsyncValue.loading();
    try {
      // 1. Call Backend to generate Razorpay Order ID (Mocked for now)
      // final response = await _apiService.createOrder(courseId);
      final backendOrderId = 'order_mock_${DateTime.now().millisecondsSinceEpoch}';
      
      // 2. Open Razorpay Checkout Sheet
      _paymentService.openCheckout(
        keyId: _appConfig.razorpayKeyId, // Loaded from .env
        amount: price,
        name: 'Tungabadra Networks LMS',
        description: courseName,
        orderId: backendOrderId,
        prefillEmail: userEmail,
        prefillContact: '', 
      );
      // State remains loading until payment succeeds or fails
    } catch (e) {
      state = AsyncValue.error(ApiException(message: e.toString()), StackTrace.current);
    }
  }

  void _onSuccess(PaymentSuccessResponse response) {
    // 3. Verify signature with Backend
    // await _apiService.verifyPayment(response.paymentId, response.orderId, response.signature);
    state = const AsyncValue.data(null); // Success
  }

  void _onError(PaymentFailureResponse response) {
    state = AsyncValue.error(
      ApiException(message: response.message ?? 'Payment failed or cancelled.'),
      StackTrace.current,
    );
  }
}

final checkoutControllerProvider = StateNotifierProvider<CheckoutController, AsyncValue<void>>((ref) {
  return CheckoutController(
    paymentService: ref.watch(paymentGatewayProvider),
    appConfig: locator<AppConfig>(),
  );
});
