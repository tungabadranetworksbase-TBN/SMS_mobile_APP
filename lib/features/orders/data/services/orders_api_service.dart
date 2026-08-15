import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/config/api_endpoints.dart';
import '../models/order_dto.dart';

class OrdersApiService {
  final ApiClient _apiClient;

  OrdersApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<List<OrderDto>>> getOrders() async {
    return _apiClient.get<List<OrderDto>>(
      ApiEndpoints.commerceOrders,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((e) => OrderDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  Future<ApiResponse<OrderDto>> getOrderDetails(String id) async {
    final path = ApiEndpoints.withParams(ApiEndpoints.commerceOrderDetail, {
      'id': id,
    });
    return _apiClient.get<OrderDto>(
      path,
      fromJson: (json) => OrderDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
