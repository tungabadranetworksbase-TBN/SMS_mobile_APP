import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/service_locator.dart';
import '../data/models/order_dto.dart';
import '../data/repositories/orders_repository.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return locator<OrdersRepository>();
});

final ordersListProvider = FutureProvider<List<OrderDto>>((ref) {
  return ref.read(ordersRepositoryProvider).getOrders();
});

final orderDetailsProvider = FutureProvider.family<OrderDto, String>((ref, id) {
  return ref.read(ordersRepositoryProvider).getOrderDetails(id);
});
