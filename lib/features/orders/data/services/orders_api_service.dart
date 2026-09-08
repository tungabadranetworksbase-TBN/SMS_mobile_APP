import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/json_value.dart';
import '../models/order_dto.dart';

class OrdersApiService {
  final ApiClient _apiClient;

  OrdersApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<List<OrderDto>>> getOrders() async {
    return _apiClient.get<List<OrderDto>>(
      ApiEndpoints.purchases,
      fromJson: (json) {
        final raw = json is List
            ? json
            : jsonList(jsonMap(json)['purchases']);
        return raw.map((e) => OrderDto.fromJson(jsonMap(e))).toList();
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
