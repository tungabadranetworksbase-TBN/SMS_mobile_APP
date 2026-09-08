import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/client_origin.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../data/services/commerce_api_service.dart';

class CheckoutOutcome {
  final String? url;
  final String orderId;
  final double total;
  final List<PaymentUpiDto> upi;
  final List<PaymentQrDto> qrs;

  const CheckoutOutcome({
    this.url,
    required this.orderId,
    this.total = 0,
    this.upi = const [],
    this.qrs = const [],
  });

  bool get isManual => (url == null || url!.isEmpty) && orderId.isNotEmpty;
}

class CheckoutController extends StateNotifier<AsyncValue<void>> {
  final CommerceApiService _commerce;

  CheckoutController({required CommerceApiService commerce})
    : _commerce = commerce,
      super(const AsyncValue.data(null));

  Future<CheckoutOutcome> startCheckout({required String courseId}) async {
    state = const AsyncValue.loading();
    try {
      await _addToCart(courseId);
      final options = await _paymentOptions();
      final methods = options.checkoutMethods;
      if (methods.isEmpty) {
        throw const ApiException(message: 'No payment method available.');
      }
      ApiException? last;
      for (final method in methods) {
        try {
          final checkoutRes = await _checkoutOnce(method);
          state = const AsyncValue.data(null);
          return CheckoutOutcome(
            url: checkoutRes.url,
            orderId: checkoutRes.orderId,
            total: checkoutRes.total,
            upi: options.upi,
            qrs: options.qrs,
          );
        } on ApiException catch (e) {
          last = e;
        }
      }
      throw last ?? const ApiException(message: 'Checkout failed.');
    } on ApiException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    } catch (e) {
      final ex = ApiException(message: e.toString());
      state = AsyncValue.error(ex, StackTrace.current);
      throw ex;
    }
  }

  Future<void> submitManualPayment({
    required String orderId,
    required String receiptPath,
    required double amount,
    String? reference,
  }) async {
    state = const AsyncValue.loading();
    try {
      var res = await _commerce.submitOrderPayment(
        orderId: orderId,
        receiptPath: receiptPath,
        amount: amount,
        reference: reference,
      );
      if (!res.success) {
        res = await _commerce.submitOrderPayment(
          orderId: orderId,
          receiptPath: receiptPath,
          amount: amount,
          reference: reference,
        );
      }
      if (!res.success) {
        throw ApiException(
          message: res.message ?? 'Could not submit payment proof.',
        );
      }
      state = const AsyncValue.data(null);
    } on ApiException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    } catch (e) {
      final ex = ApiException(message: e.toString());
      state = AsyncValue.error(ex, StackTrace.current);
      throw ex;
    }
  }

  Future<void> _addToCart(String courseId) async {
    try {
      final added = await _commerce.addCourseToCart(courseId);
      if (!added.success && added.statusCode != 409) {
        throw ApiException(message: added.message ?? 'Could not add to cart.');
      }
    } on ApiException catch (e) {
      if (e.statusCode != 409) rethrow;
    }
  }

  Future<PaymentOptionsDto> _paymentOptions() async {
    var optionsRes = await _commerce.fetchPaymentOptions();
    if (!optionsRes.success || optionsRes.data == null) {
      optionsRes = await _commerce.fetchPaymentOptions();
    }
    if (!optionsRes.success || optionsRes.data == null) {
      throw ApiException(
        message: optionsRes.message ?? 'Could not load payment options.',
      );
    }
    return optionsRes.data!;
  }

  Future<CommerceCheckoutDto> _checkoutOnce(String method) async {
    var checkoutRes = await _commerce.checkout(
      method: method,
      origin: clientOrigin(),
    );
    if (!checkoutRes.success || checkoutRes.data == null) {
      checkoutRes = await _commerce.checkout(
        method: method,
        origin: clientOrigin(),
      );
    }
    if (!checkoutRes.success || checkoutRes.data == null) {
      throw ApiException(message: checkoutRes.message ?? 'Checkout failed.');
    }
    return checkoutRes.data!;
  }
}

final checkoutControllerProvider =
    StateNotifierProvider<CheckoutController, AsyncValue<void>>((ref) {
      return CheckoutController(commerce: locator<CommerceApiService>());
    });
