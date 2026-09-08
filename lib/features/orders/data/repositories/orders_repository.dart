import '../../../../core/demo/demo_mode.dart';
import '../../../../core/network/api_exception.dart';
import '../models/order_dto.dart';
import '../services/orders_api_service.dart';

class OrdersRepository {
  final OrdersApiService _apiService;

  OrdersRepository({required OrdersApiService apiService})
    : _apiService = apiService;

  Future<List<OrderDto>> getOrders() async {
    if (DemoMode().isActive) {
      return [];
    }
    try {
      final response = await _apiService.getOrders();
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ApiException(message: response.message ?? 'Failed to load orders');
    } catch (e) {
      rethrow;
    }
  }

  Future<OrderDto> getOrderDetails(String id) async {
    if (DemoMode().isActive) {
      throw const ApiException(message: 'Not found in Demo Mode');
    }
    final orders = await getOrders();
    for (final order in orders) {
      if (order.id == id) return order;
    }
    throw const ApiException(message: 'Order not found.');
  }
}
